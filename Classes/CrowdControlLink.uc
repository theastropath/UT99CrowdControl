class UT99CrowdControlLink extends TcpLink transient;

var string crowd_control_addr;
var CrowdControl ccModule;

var int ListenPort;
var IpAddr addr;
var int ticker;
var int reconnectTimer;
var string pendingMsg;
var bool enabled;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CrowdControlPort = 43384;

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;

struct ZoneFriction
{
    var name zonename;
    var float friction;
};
var ZoneFriction zone_frictions[32];

struct ZoneGravity
{
    var name zonename;
    var vector gravity;
};
var ZoneGravity zone_gravities[32];

struct ZoneWater
{
    var name zonename;
    var bool water;
};
var ZoneWater zone_waters[32];


const IceFriction = 0.25;
const NormalFriction = 8;
var vector NormalGravity;
var vector FloatGrav;
var vector MoonGrav;

const ReconDefault = 5;

var int behindTimer;
const BehindTimerDefault = 15;

var int fatnessTimer;
const FatnessTimerDefault = 60;

var int speedTimer;
const SpeedTimerDefault = 60;
const SlowTimerDefault = 15;
const SingleSlowTimerDefault = 45;

var int iceTimer;
const IceTimerDefault = 60;

var int gravityTimer;
const GravityTimerDefault = 60;

var int meleeTimer;
const MeleeTimerDefault = 60;

var int floodTimer;
const FloodTimerDefault = 15;

var int vampireTimer;
const VampireTimerDefault = 60;

const MaxAddedBots = 10;
var Bot added_bots[10];
var int numAddedBots;


struct JsonElement
{
    var string key;
    var string value[5];
    var int valCount;
};

struct JsonMsg
{
    var JsonElement e[20];
    var int count;
};

function string StripQuotes (string msg) {
    if (Mid(msg,0,1)==Chr(34)) {
        if (Mid(msg,Len(Msg)-1,1)==Chr(34)) {
            return Mid(msg,1,Len(msg)-2);
        }
    }        
    return msg;
}

function string JsonStripSpaces(string msg) {
    local int i;
    local string c;
    local string buf;
    local bool inQuotes;
    
    inQuotes = False;
    
    for (i = 0; i < Len(msg) ; i++) {
        c = Mid(msg,i,1); //Grab a single character
        
        if (c==" " && !inQuotes) {
            continue;  //Don't add spaces to the buffer if we're outside quotes
        } else if (c==Chr(34)) {
            inQuotes = !inQuotes;
        }
        
        buf = buf $ c;
    }    
    
    return buf;
}

//Returns the appropriate character for whatever is after
//the backslash, eg \c
function string JsonGetEscapedChar(string c) {
    switch(c){
        case "b":
            return Chr(8); //Backspace
        case "f":
            return Chr(12); //Form feed
        case "n":
            return Chr(10); //New line
        case "r":
            return Chr(13); //Carriage return
        case "t":
            return Chr(9); //Tab
        case Chr(34): //Quotes
        case Chr(92): //Backslash
            return c;
        default:
            return "";
    }
}

function JsonMsg ParseJson (string msg) {
    
    local bool msgDone;
    local int i;
    local string c;
    local string buf;
    
    local int parsestate;
    local bool inquotes;
    local bool escape;
    local int inBraces;
    
    local JsonMsg j;
    
    local bool elemDone;
    
    elemDone = False;
    
    parsestate = KeyState;
    inquotes = False;
    escape = False;
    msgDone = False;
    buf = "";

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(msg);
    
    for (i = 0; i < Len(msg) && !msgDone ; i++) {
        c = Mid(msg,i,1); //Grab a single character
        
        if (!inQuotes) {
            switch (c) {
                case ":":
                case ",":
                  //Wrap up the current string that was being handled
                  //PlayerMessage(buf);
                  if (parsestate == KeyState) {
                      j.e[j.count].key = StripQuotes(buf);
                      parsestate = ValState;
                  } else if (parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                  } else if (parsestate == ArrayState) {
                      // TODO: arrays of objects
                      if (c != ":") {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                      }
                  } else if (parsestate == ArrayDoneState){
                      parseState = KeyState;
                  }
                    buf = "";
                    break; // break for colon and comma

                case "{":
                    inBraces++;
                    buf = "";
                    break;
                
                case "}":
                    //PlayerMessage(buf);
                    inBraces--;
                    if (inBraces == 0 && parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                    }
                    if (parsestate == ArrayState) {
                        // TODO: arrays of objects
                    }
                    else if(inBraces > 0) {
                        // TODO: sub objects
                    }
                    else {
                        msgDone = True;
                    }
                    break;
                
                case "]":
                    if (parsestate == ArrayState) {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                        elemDone = True;
                        parsestate = ArrayDoneState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case "[":
                    if (parsestate == ValState){
                        parsestate = ArrayState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case Chr(34): //Quotes
                    inQuotes = !inQuotes;
                    break;
                default:
                    //Build up the buffer
                    buf = buf $ c;
                    break;
                
            }
        } else {
            switch(c) {
                case Chr(34): //Quotes
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        inQuotes = !inQuotes;
                    }
                    break;
                case Chr(92): //Backslash, escape character time
                    if (escape) {
                        //If there has already been one, then we need to turn it into the right char
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        escape = True;
                    }
                    break;
                default:
                    //Build up the buffer
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        buf = buf $ c;
                    }
                    break;
            }
        }
        
        if (elemDone) {
          //PlayerMessage("Key: "$j.e[j.count].key$ "   Val: "$j.e[j.count].value[0]);
          j.count++;
          elemDone = False;
        }
    }
    
    return j;
}

function Init(CrowdControl cc, string addr)
{
    local int i;
    
    ccModule = cc;
    crowd_control_addr = addr; 
    enabled = True;
    
    NormalGravity=vect(0,0,-950);
    FloatGrav=vect(0,0,0.15);
    MoonGrav=vect(0,0,-100);  
    
    //Initialize the pending message buffer
    pendingMsg = "";
    
    //Initialize the ticker
    ticker = 0;
    
    for (i=0;i<MaxAddedBots;i++){
        added_bots[i]=None;
    }

    Resolve(crowd_control_addr);

    reconnectTimer = ReconDefault;
    SetTimer(0.1,True);

}

function Timer() {
    
    ticker++;
    if (IsConnected()) {
        if (enabled){
            ManualReceiveBinary();
        }
    }
    
    
    //Want to force people to melee more frequently than once a second
    if (meleeTimer > 0) {
        ForceAllPawnsToMelee();
    }
    
    
    if (ticker%10 != 0) {
        return;
    }

    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            if (enabled){
                Resolve(crowd_control_addr);
            }
        }
    }

    if (behindTimer > 0) {
        behindTimer--;
        if (behindTimer <= 0) {
            SetAllPlayersBehindView(False);
            ccModule.BroadCastMessage("Returning to first person view...");

        }
    }

    if (fatnessTimer > 0) {
        fatnessTimer--;
        if (fatnessTimer <= 0) {
            SetAllPlayersFatness(120);
            ccModule.BroadCastMessage("Returning to normal fatness...");
        }
    }    

    if (speedTimer > 0) {
        speedTimer--;
        if (speedTimer <= 0) {
            SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed);
            ccModule.BroadCastMessage("Returning to normal move speed...");
        }
    }  
    
    if (iceTimer > 0) {
        iceTimer--;
        if (iceTimer <= 0) {
            SetIcePhysics(False);
            ccModule.BroadCastMessage("The ground thaws...");
        }
    }  
    
    if (gravityTimer > 0) {
        gravityTimer--;
        if (gravityTimer <= 0) {
            SetMoonPhysics(False);
            ccModule.BroadCastMessage("Gravity returns to normal...");
        }
    }  

    if (meleeTimer > 0) {
        meleeTimer--;
        if (meleeTimer <= 0) {
            ccModule.BroadCastMessage("You may use ranged weapons again...");
        }
    }  
    
    if (floodTimer > 0) {
        floodTimer--;
        if (floodTimer <= 0) {
            SetFlood(False);
            UpdateAllPawnsSwimState();

            ccModule.BroadCastMessage("The flood drains away...");
        }
    }  

    if (vampireTimer > 0) {
        vampireTimer--;
        if (vampireTimer <= 0) {
            ccModule.BroadCastMessage("You no longer feed on the blood of others...");
        }
    }  
   

}

function ScoreKill(Pawn Killer,Pawn Other)
{
    local int i;
    //ccModule.BroadCastMessage(Killer.PlayerReplicationInfo.PlayerName$" just killed "$Other.PlayerReplicationInfo.PlayerName);
    
    //Check if the killed pawn is a bot that we don't want to respawn
    for (i=0;i<MaxAddedBots;i++){
        if (added_bots[i]!=None && added_bots[i]==Other) {
            added_bots[i]=None;
            //ccModule.BroadCastMessage("Should be destroying added bot "$Other.PlayerReplicationInfo.PlayerName);
            ccModule.BroadCastMessage("Crowd Control viewer "$Other.PlayerReplicationInfo.PlayerName$" has left the match");
            Other.SpawnGibbedCarcass();
            Other.Destroy(); //This may cause issues if there are more mutators caring about ScoreKill.  Probably should schedule this deletion for later instead...
            numAddedBots--;
        }
    }
    
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType)
{
    //ccModule.BroadCastMessage(InstigatedBy.PlayerReplicationInfo.PlayerName$" inflicted "$ActualDamage$" damage to "$Victim.PlayerReplicationInfo.PlayerName);
    
    //Check if vampire mode timer is running, and if it is, do the vampire thing
    //Don't allow healing off of damage to yourself
    if (vampireTimer > 0 && Victim!=InstigatedBy) {
        InstigatedBy.Health += (ActualDamage/2); //Don't heal the full amount of damage
        
        //Don't let it overheal
        if (InstigatedBy.Health > 199) {
            InstigatedBy.Health = 199;
        }
    }
}

function RemoveAllArmor(Pawn p)
{
    // If there is armor in our inventory chain, unlink it and destroy it
	local actor Link;
    local Inventory armor;

	for( Link = p; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory.bIsAnArmor )
		{
            armor = Link.Inventory;
			Link.Inventory = Link.Inventory.Inventory;
            armor.SetOwner(None);
            armor.Destroy();
		}
	}
}

function int SuddenDeath(string viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        p.Health = 1;
        RemoveAllArmor(p);
    }
    
    ccModule.BroadCastMessage(viewer$" has initiated sudden death!  All health reduced to 1, no armour!");
    
    return Success;
}

function int FullHeal(string viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        //Don't reduce health if someone is overhealed
        if (p.Health < 100) {
            p.Health = 100;
        }
    }
    
    ccModule.BroadCastMessage("Everyone has been fully healed by "$viewer$"!");
    
    return Success;

}

//Shield Belt for everybody!
function int FullArmour(string viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        GiveShieldBeltToPawn(p);
    }
   
    ccModule.BroadCastMessage(viewer$" has given everyone a shield belt!");
    
    return Success;
}

//This is a bit more complicated than anticipated, due to armor being carried in inventory
function int GiveArmour(string viewer,int amount)
{
    //TBD
    ccModule.BroadCastMessage("Everyone has been given "$amount$" armor by "$viewer$"!");
    
    return Success;
}

function int GiveHealth(string viewer,int amount)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        p.Health = Min(p.Health + amount,199); //Let's allow this to overheal, up to 199
    }
    
    ccModule.BroadCastMessage("Everyone has been given "$amount$" health by "$viewer$"!");
    
    return Success;
}

function SetAllPlayersBehindView(bool val)
{
    local PlayerPawn p;
    
    foreach AllActors(class'PlayerPawn',p) {
        p.BehindView(val);
    }
}

function int ThirdPerson(String viewer)
{
    SetAllPlayersBehindView(True);
    behindTimer = BehindTimerDefault;

    ccModule.BroadCastMessage(viewer$" wants you to have an out of body experience!");
    
    return Success;

}

function GiveUDamageToPawn(Pawn p)
{
    local UDamage dam;
    
    dam = Spawn(class'UDamage');
        
    dam.SetOwner(p);
    dam.Inventory = p.Inventory;
    p.Inventory = dam;
    dam.Activate();

}

function int GiveDamageItem(String viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        GiveUDamageToPawn(p);
    }
    
    ccModule.BroadCastMessage(viewer$" gave everyone a damage powerup!");
    
    return Success;
}

function SetAllPlayersFatness(int fatness)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        p.Fatness = fatness;
    }
}

function int FullFat(String viewer)
{
    if (fatnessTimer>0) {
        return TempFail;
    }
  
    SetAllPlayersFatness(255);
      
    fatnessTimer = FatnessTimerDefault;

    ccModule.BroadCastMessage(viewer$" fattened everybody up!");
    
    return Success;
}

function int SkinAndBones(String viewer)
{
    if (fatnessTimer>0) {
        return TempFail;
    }

    SetAllPlayersFatness(1);

    fatnessTimer = FatnessTimerDefault;

    ccModule.BroadCastMessage(viewer$" made everyone really skinny!");
    
    return Success;
}

function SetAllPlayersGroundSpeed(int speed)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        //ccModule.BroadCastMessage("Speed before: "$p.GroundSpeed$"  Speed After: "$speed);
        p.GroundSpeed = speed;
    }
}

function int GottaGoFast(String viewer)
{
    if (speedTimer>0) {
        return TempFail;
    }

    SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed * 3);

    speedTimer = SpeedTimerDefault;

    ccModule.BroadCastMessage(viewer$" made everyone fast like Sonic!");
    
    return Success;   
}

function int GottaGoSlow(String viewer)
{
    if (speedTimer>0) {
        return TempFail;
    }

    SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed / 3);

    speedTimer = SlowTimerDefault;

    ccModule.BroadCastMessage(viewer$" made everyone slow like a snail!");
    
    return Success;   
}

function int ThanosSnap(String viewer)
{
    local Pawn p;
    local String origDamageString;
    
    origDamageString = Level.Game.SpecialDamageString;
    Level.Game.SpecialDamageString = "%o got snapped by "$viewer;
    
    foreach AllActors(class'Pawn',p) {
        if (Rand(2)==0){ //50% chance of death
            P.TakeDamage
            (
                10000,
                P,
                P.Location,
                Vect(0,0,0),
                'SpecialDamage'				
            );
        }
    }
    
    Level.Game.SpecialDamageString = origDamageString;
    
    ccModule.BroadCastMessage(viewer$" snapped their fingers!");
    
    return Success;

}

function Swap(Actor a, Actor b)
{
    local vector newloc, oldloc;
    local rotator newrot;
    local bool asuccess, bsuccess;
    local Actor abase, bbase;
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers;
    local EPhysics aphysics, bphysics;

    if( a == b ) return;
    
    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    a.SetCollision(false, false, false);

    oldloc = a.Location;
    newloc = b.Location;
    
    b.SetLocation(oldloc);
    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
    
    a.SetLocation(newLoc);
    
    newrot = b.Rotation;
    b.SetRotation(a.Rotation);
    a.SetRotation(newrot);

    aphysics = a.Physics;
    bphysics = b.Physics;
    abase = a.Base;
    bbase = b.Base;

    a.SetPhysics(bphysics);
    if(abase != bbase) a.SetBase(bbase);
    b.SetPhysics(aphysics);
    if(abase != bbase) b.SetBase(abase);
}

function Pawn findRandomPawn()
{
    local int num;
    local Pawn p;
    local Pawn pawns[50];
    
    num = 0;
    
    foreach AllActors(class'Pawn',p) {
        pawns[num++] = p;
    }

    if( num == 0 ) return None;
    return pawns[ Rand(num) ];    
}

function int swapPlayer(string viewer) {
    local Pawn a,b;
    local int tries;
    a = None;
    b = None;
    
    tries = 0; //Prevent a runaway
    
    while (tries < 5 && (a == None || b == None || a==b)) {
        a = findRandomPawn();
        b = findRandomPawn();
        tries++;
    }
    
    if (tries == 5) {
        return TempFail;
    }
    
    Swap(a,b);
    
    
    //If we swapped a bot, get them to recalculate their logic so they don't just run off a cliff
    if (a.PlayerReplicationInfo.bIsABot == True && Bot(a)!=None) {
        Bot(a).WhatToDoNext('','');
    }
    if (b.PlayerReplicationInfo.bIsABot == True && Bot(b)!=None) {
        Bot(b).WhatToDoNext('','');
    }
    
    ccModule.BroadCastMessage(viewer@"thought "$a.PlayerReplicationInfo.PlayerName$" would look better if they were where"@b.PlayerReplicationInfo.PlayerName@"was");
    
    return Success;
}

function RemoveAllAmmoFromPawn(Pawn p)
{
	local Inventory Inv;
	for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if ( Ammo(Inv) != None ) {
			Ammo(Inv).AmmoAmount = 0;
        }   
    }      
}

function int NoAmmo(String viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        RemoveAllAmmoFromPawn(p);
    }
    
    ccModule.BroadCastMessage(viewer$" stole all your ammo!");
    
    return Success;
}

function class<Actor> GetAmmoClassByName(String ammoName)
{
    local class<Actor> ammoClass;
    
    switch(ammoName){
        case "FlakAmmo":
            ammoClass = class'FlakAmmo';
            break;
        case "BioAmmo":
            ammoClass = class'BioAmmo';
            break;
        case "WarHeadAmmo":
            ammoClass = class'WarHeadAmmo';
            break;
        case "PAmmo":
            ammoClass = class'PAmmo';
            break;
        case "ShockCore":
            ammoClass = class'ShockCore';
            break;
        case "BladeHopper":
            ammoClass = class'BladeHopper';
            break;
        case "RocketPack":
            ammoClass = class'RocketPack';
            break;
        case "BulletBox":
            ammoClass = class'BulletBox';
            break;
        case "MiniAmmo":
            ammoClass = class'MiniAmmo';
            break;
        default:
            break;
    }
    
    return ammoClass;
}

function AddItemToPawnInventory(Pawn p, Inventory item)
{
        item.SetOwner(p);
        item.Inventory = p.Inventory;
        p.Inventory = item;
}

function int GiveAmmo(String viewer, String ammoName, int amount)
{
    local class<Actor> ammoClass;
    local Pawn p;
    local Inventory inv;
    local Ammo amm;
    local Actor a;
    
    ammoClass = GetAmmoClassByName(ammoName);
    
    foreach AllActors(class'Pawn',p) {
        inv = p.FindInventoryType(ammoClass);
        
        if (inv == None) {
            a = Spawn(ammoClass);
            amm = Ammo(a);
            AddItemToPawnInventory(p,amm);
            
            if (amount > 1) {
                amm.AddAmmo((amount-1)*amm.Default.AmmoAmount);    
            }
            
        } else {
            amm = Ammo(inv);
            amm.AddAmmo(amount*amm.Default.AmmoAmount);  //Add the equivalent of picking up that many boxes
        }
    }
    
    ccModule.BroadCastMessage(viewer$" gave everybody some ammo! ("$ammoName$")");
}

function int doNudge(string viewer) {
    local Rotator r;
    local vector newAccel;
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        newAccel.X = Rand(501)-100;
        newAccel.Y = Rand(501)-100;
        //newAccel.Z = Rand(31);
        
        //Not super happy with how this looks,
        //Since you sort of just teleport to the new position
        p.MoveSmooth(newAccel);
    }
        
    ccModule.BroadCastMessage(viewer@"nudged you a little bit");
    return Success;
}

function bool IsWeaponRemovable(Weapon w)
{
    switch(w.Class){
        case class'Translocator':
        case class'ImpactHammer':
        case class'Enforcer':
        case class'DoubleEnforcer':
        case class'ChainSaw':
            return False;
        default:
            return True;
    }
}

function int DropSelectedWeapon(string viewer) {
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        if (IsWeaponRemovable(p.Weapon)){
            p.DeleteInventory(p.Weapon);
        }
    }
    
    ccModule.BroadCastMessage(viewer$" stole your current weapon!");
    
    return Success;

}

function class<Weapon> GetWeaponClassByName(String weaponName)
{
    local class<Weapon> weaponClass;
    
    switch(weaponName){
        case "Translocator":
            weaponClass = class'Translocator';
            break;
        case "Ripper":
            weaponClass = class'Ripper';
            break;
        case "WarHeadLauncher":
            weaponClass = class'WarHeadLauncher';
            break;
        case "BioRifle":
            weaponClass = class'UT_BioRifle';
            break;
        case "FlakCannon":
            weaponClass = class'UT_FlakCannon';
            break;
        case "SniperRifle":
            weaponClass = class'SniperRifle';
            break;
        case "ShockRifle":
            weaponClass = class'ShockRifle';
            break;
        case "PulseGun":
            weaponClass = class'PulseGun';
            break;
        case "MiniGun":
            weaponClass = class'Minigun2';
            break;
        case "RocketLauncher":
            weaponClass = class'UT_EightBall';
            break;
        case "SuperShockRifle":
            weaponClass = class'SuperShockRifle';
            break;
        default:
            break;
    }
    
    return weaponClass;
}
function Weapon GiveWeaponToPawn(Pawn PlayerPawn, class<Weapon> WeaponClass, optional bool bBringUp)
{
	local Weapon NewWeapon;
    local Inventory inv;
  
    inv = PlayerPawn.FindInventoryType(WeaponClass);
	if (inv != None ) {
        newWeapon = Weapon(inv);
		newWeapon.GiveAmmo(PlayerPawn);
        return newWeapon;
    }
        
	newWeapon = Spawn(WeaponClass);
	if ( newWeapon != None ) {
		newWeapon.RespawnTime = 0.0;
		newWeapon.GiveTo(PlayerPawn);
		newWeapon.bHeldItem = true;
		newWeapon.GiveAmmo(PlayerPawn);
		newWeapon.SetSwitchPriority(PlayerPawn);
		newWeapon.WeaponSet(PlayerPawn);
		newWeapon.AmbientGlow = 0;
		if ( PlayerPawn.IsA('PlayerPawn') )
			newWeapon.SetHand(PlayerPawn(PlayerPawn).Handedness);
		else
			newWeapon.GotoState('Idle');
		if ( bBringUp ) {
			PlayerPawn.Weapon.GotoState('DownWeapon');
			PlayerPawn.PendingWeapon = None;
			PlayerPawn.Weapon = newWeapon;
			PlayerPawn.Weapon.BringUp();
		}
	}
	return newWeapon;
}


function int GiveWeapon(String viewer, String weaponName)
{
    local class<Weapon> weaponClass;
    local Pawn p;
    local PlayerPawn pp;
    local Inventory inv;
    local Weapon weap;
    local Actor a;
    
    weaponClass = GetWeaponClassByName(weaponName);
    
    foreach AllActors(class'Pawn',p) {  //Probably could just iterate over PlayerPawns, but...
        pp = PlayerPawn(p);
        if (pp!=None && pp.bReadyToPlay==True) { //Don't give weapons to spectators
            GiveWeaponToPawn(p,weaponClass);
        }
    }
    
    ccModule.BroadCastMessage(viewer$" gave everybody a weapon! ("$weaponName$")");
}


function float GetDefaultZoneFriction(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_frictions); i++) {
        if( z.name == zone_frictions[i].zonename )
            return zone_frictions[i].friction;
    }
    return NormalFriction;
}

function SaveDefaultZoneFriction(ZoneInfo z)
{
    local int i;
    if( z.ZoneGroundFriction ~= NormalFriction ) return;
    for(i=0; i<ArrayCount(zone_frictions); i++) {
        if( zone_frictions[i].zonename == '' || z.name == zone_frictions[i].zonename ) {
            zone_frictions[i].zonename = z.name;
            zone_frictions[i].friction = z.ZoneGroundFriction;
            return;
        }
    }
}

function vector GetDefaultZoneGravity(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_gravities); i++) {
        if( z.name == zone_gravities[i].zonename )
            return zone_gravities[i].gravity;
        if( zone_gravities[i].zonename == '' )
            break;
    }
    return NormalGravity;
}

function SaveDefaultZoneGravity(ZoneInfo z)
{
    local int i;
    if( z.ZoneGravity.X ~= NormalGravity.X && z.ZoneGravity.Y ~= NormalGravity.Y && z.ZoneGravity.Z ~= NormalGravity.Z ) return;
    for(i=0; i<ArrayCount(zone_gravities); i++) {
        if( z.name == zone_gravities[i].zonename )
            return;
        if( zone_gravities[i].zonename == '' ) {
            zone_gravities[i].zonename = z.name;
            zone_gravities[i].gravity = z.ZoneGravity;
            return;
        }
    }
}

function SetMoonPhysics(bool enabled) {
    local ZoneInfo Z;
    ForEach AllActors(class'ZoneInfo', Z)
    {
        if (enabled && Z.ZoneGravity != MoonGrav ) {
            SaveDefaultZoneGravity(Z);
            Z.ZoneGravity = MoonGrav;
        }
        else if ( (!enabled) && Z.ZoneGravity == MoonGrav ) {
            Z.ZoneGravity = GetDefaultZoneGravity(Z);
        }
    }
}

function SetIcePhysics(bool enabled) {
    local ZoneInfo Z;
    ForEach AllActors(class'ZoneInfo', Z) {
        if (enabled && Z.ZoneGroundFriction != IceFriction ) {
            SaveDefaultZoneFriction(Z);
            Z.ZoneGroundFriction = IceFriction;
        }
        else if ( (!enabled) && Z.ZoneGroundFriction == IceFriction ) {
            Z.ZoneGroundFriction = GetDefaultZoneFriction(Z);
        }
    }
}

function int EnableIcePhysics(string viewer)
{
    if (iceTimer>0) {
        return TempFail;
    }
    ccModule.BroadCastMessage(viewer@"made the ground freeze!");
    SetIcePhysics(True);
    iceTimer = IceTimerDefault;
    return Success;
}

function int EnableMoonPhysics(string viewer)
{
    if (gravityTimer>0) {
        return TempFail;
    }
    ccModule.BroadCastMessage(viewer@"reduced gravity!");
    SetMoonPhysics(True);
    gravityTimer = GravityTimerDefault;
    return Success;
}

function Weapon FindMeleeWeaponInPawnInventory(Pawn p)
{
	local actor Link;
    local Weapon weap;

	for( Link = p; Link!=None; Link=Link.Inventory )
	{
		if( Weapon(Link.Inventory) != None )
		{
            weap = Weapon(Link.Inventory);
			if (weap.bMeleeWeapon==True){
                return weap;
            }
		}
	}
    
    return None;
}

function ForcePawnToMeleeWeapon(Pawn p)
{
    local Weapon meleeweapon;
    
    if (p.Weapon == None || p.Weapon.bMeleeWeapon==True) {
        return;  //No need to do a lookup if it's already melee or nothing
    }
    
    meleeweapon = FindMeleeWeaponInPawnInventory(p);
    
    p.Weapon.GotoState('DownWeapon');
	p.PendingWeapon = None;
	p.Weapon = meleeweapon;
	p.Weapon.BringUp();
}

function ForceAllPawnsToMelee()
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        ForcePawnToMeleeWeapon(p);
    }
}

function int StartMeleeOnlyTime(String viewer)
{
    if (meleeTimer > 0) {
        return TempFail;
    }
    
    ForceAllPawnsToMelee();
    
    ccModule.BroadCastMessage(viewer@"requests melee weapons only!");
    
    meleeTimer = MeleeTimerDefault;
    
    return Success;
}


function bool GetDefaultZoneWater(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_waters); i++) {
        if( z.name == zone_waters[i].zonename )
            return zone_waters[i].water;
    }
    return True;
}

function SaveDefaultZoneWater(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_waters); i++) {
        if( zone_waters[i].zonename == '' || z.name == zone_waters[i].zonename ) {
            zone_waters[i].zonename = z.name;
            zone_waters[i].water = z.bWaterZone;
            return;
        }
    }
}

function SetFlood(bool enabled) {
    local ZoneInfo Z;
    ForEach AllActors(class'ZoneInfo', Z) {
        if (enabled && Z.bWaterZone != True ) {
            SaveDefaultZoneWater(Z);
            Z.bWaterZone = True;
        }
        else if ( (!enabled) && Z.bWaterZone == True ) {
            Z.bWaterZone = GetDefaultZoneWater(Z);
        }
    }
}

function UpdateAllPawnsSwimState()
{
    local PlayerPawn p;
    
    foreach AllActors(class'PlayerPawn',p) {
        ccModule.BroadCastMessage("State before update was "$p.GetStateName());
        if (p.Region.Zone.bWaterZone) {
            p.setPhysics(PHYS_Swimming);
		    p.GotoState('PlayerSwimming');
        } else {
            p.setPhysics(PHYS_Falling);
		    p.GotoState('PlayerWalking');
        
        }
    }

}

function int StartFlood(string viewer)
{
    if (floodTimer>0) {
        return TempFail;
    }
    ccModule.BroadCastMessage(viewer@"started a flood!");
    SetFlood(True);
    UpdateAllPawnsSwimState();
    floodTimer = FloodTimerDefault;
    return Success;
}

//Find highest or lowest score player.
//If multiple have the same score, it'll use the first one with that score it finds
function Pawn findPawnByScore(bool highest, int avoidTeam)
{
    local Pawn cur;
    local Pawn p;
    local bool avoid;
    
    avoid = (avoidTeam!=255);
    
    cur = None;
    foreach AllActors(class'Pawn',p) {
        //ccModule.BroadCastMessage(p.PlayerReplicationInfo.PlayerName$" is on team "$p.PlayerReplicationInfo.Team);
        if (cur==None){
            if (avoid==False || (avoid==True && p.PlayerReplicationInfo.Team!=avoidTeam)) {
                cur = p;
            }
        } else {
            if (highest){
                if (p.PlayerReplicationInfo.Score > cur.PlayerReplicationInfo.Score) {
                    if (avoid==False || (avoid==True && p.PlayerReplicationInfo.Team!=avoidTeam)) {
                        cur = p;
                    }
                }
            } else {
                if (p.PlayerReplicationInfo.Score < cur.PlayerReplicationInfo.Score) {
                    if (avoid==False || (avoid==True && p.PlayerReplicationInfo.Team!=avoidTeam)) {
                        cur = p;
                    }
                }            
            }
        }
    }
    return cur;
}

function GiveShieldBeltToPawn(Pawn p)
{
    local UT_ShieldBelt belt;
    belt = Spawn(class'UT_ShieldBelt');
        
    belt.SetOwner(p);
    belt.Inventory = p.Inventory;
    p.Inventory = belt;
    belt.PickupFunction(p);
}

function int LastPlaceShield(String viewer)
{
    local Pawn p;

    p = findPawnByScore(False,255); //Get lowest score player
    if (p == None) {
        return TempFail;
    }
    
    //Actually give them the shield belt
    GiveShieldBeltToPawn(p);
    
    ccModule.BroadCastMessage(viewer@"gave a Shield Belt to "$p.PlayerReplicationInfo.PlayerName$", who is in last place!");
    return Success;
}

function int LastPlaceDamage(String viewer)
{
    local Pawn p;

    p = findPawnByScore(False,255); //Get lowest score player
    if (p == None) {
        return TempFail;
    }
    
    //Actually give them the damage bonus
    GiveUDamageToPawn(p);
    
    ccModule.BroadCastMessage(viewer@"gave a Damage Amplifier to "$p.PlayerReplicationInfo.PlayerName$", who is in last place!");
    return Success;


}

function int FirstPlaceSlow(String viewer)
{
    local Pawn p;

    if (speedTimer>0) {
        return TempFail;
    }
    
    p = findPawnByScore(True,255); //Get Highest score player
    
    if (p == None) {
        return TempFail;
    }

    p.GroundSpeed = (class'TournamentPlayer'.Default.GroundSpeed / 3);

    speedTimer = SingleSlowTimerDefault;

    ccModule.BroadCastMessage(viewer$" made "$p.PlayerReplicationInfo.PlayerName$" slow as punishment for being in first place!");
    
    return Success;   
}

//If teams, should find highest on winning team, and lowest on losing team
function int BlueRedeemerShell(String viewer)
{
    local Pawn high,low;
    local WarShell missile;
    local int avoidTeam;
    
    
    high = findPawnByScore(True,255);  //Target individual player who is doing best
    
    if (Level.Game.bTeamGame==True){
        avoidTeam = high.PlayerReplicationInfo.Team;
    } else {
        avoidTeam = 255;
    }
    
    low = findPawnByScore(False,avoidTeam);  //Find worst player who is on a different team (if a team game)
    
    if (high==None || low == None || high == low){
        return TempFail;
    }
    
    missile = Spawn(class'WarShell',low,,high.Location);
    missile.SetOwner(low);
    missile.Instigator = low;  //Instigator is the one who gets credit for the kill
    missile.GotoState('Flying');
    missile.Explode(high.Location,high.Location);

    ccModule.BroadCastMessage(viewer$" dropped a redeemer shell on "$high.PlayerReplicationInfo.PlayerName$"'s head, since they are in first place!");
    
    return Success;
}

function int FindTeamWithLeastPlayers()
{
    local Pawn p;
    local int pCount[256]; //Technically there are team ids up to 255, but really 0 to 3 and 255 are used
    local int i;
    local int lowTeam;
    
    lowTeam = 0;
    
    if (Level.Game.bTeamGame==False){
        return 255;
    }
    
    foreach AllActors(class'Pawn',p) {
        pCount[p.PlayerReplicationInfo.Team]++;
    }
    
    for (i = 0; i < 256;i++){        
        if (pCount[i]!=0 && pCount[i] < pCount[lowTeam]) {
            lowTeam = i;
        }
    }
    //ccModule.BroadCastMessage("Lowest team is "$lowTeam);
    return lowTeam;

}

//Stolen from DeathMatchPlus class with minor tweaks to force the bot name and the team they're on
function Bot SpawnBot(out NavigationPoint StartSpot, String botname)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;
    local DeathMatchPlus game;
    local int lowTeam;
    
    game = DeathMatchPlus(Level.Game);
    
    if (game==None)
    {
        return None;
    }
    
    lowTeam = FindTeamWithLeastPlayers();


	game.Difficulty = game.BotConfig.Difficulty;

	if ( game.Difficulty >= 4 )
	{
		game.bNoviceMode = false;
		game.Difficulty = game.Difficulty - 4;
	}
	else
	{
		if ( game.Difficulty > 3 )
		{
			game.Difficulty = 3;
			game.bThreePlus = true;
		}
		game.bNoviceMode = true;
	}
	BotN = game.BotConfig.ChooseBotInfo();
	
	// Find a start spot.
	StartSpot = game.FindPlayerStart(None, lowTeam);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return None;
	}

	// Try to spawn the bot.
	NewBot = Spawn(game.BotConfig.CHGetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		NewBot = Spawn(game.BotConfig.CHGetBotClass(0),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot != None )
	{
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID = game.CurrentID++;

		NewBot.PlayerReplicationInfo.Team = lowTeam;
		game.BotConfig.CHIndividualize(NewBot, BotN, game.NumBots);
        
        //Individualize uses the random selections for skins, including the team.  Redo the SetMultiSkin, but force the team to the correct one
        NewBot.Static.SetMultiSkin(NewBot,game.BotConfig.BotSkins[BotN],game.BotConfig.BotFaces[BotN],lowTeam);
        
		NewBot.ViewRotation = StartSpot.Rotation;
        NewBot.PlayerReplicationInfo.PlayerName = botname;
		// broadcast a welcome message.
		BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$game.EnteredMessage, false );

		game.ModifyBehaviour(NewBot);
		game.AddDefaultInventory( NewBot );
		game.NumBots++;
		if ( game.bRequireReady && (game.CountDown > 0) )
			NewBot.GotoState('Dying', 'WaitingForStart');
		NewBot.AirControl = game.AirControl;

		if ( (Level.NetMode != NM_Standalone) && (game.bNetReady || game.bRequireReady) )
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewBot.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0], NewBot.MultiSkins[1], NewBot.MultiSkins[2], NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);	
				}						
		}
	}

	return NewBot;
}

//Stolen from DeathMatchPlus class, with minor tweaks
function Bot AddBot(string botname)
{
	local bot NewBot;
	local NavigationPoint StartSpot;
    local DeathMatchPlus game;
    local int lowTeam;
    
    game = DeathMatchPlus(Level.Game);
    
    if (game==None)
    {
        return None;
    }
    game.BotConfig.DesiredName = botname;
    game.MinPlayers = Max(game.MinPlayers+1, game.NumPlayers + game.NumBots + 1);
    
    
	NewBot = SpawnBot(StartSpot,botname);
	if ( NewBot == None )
	{
		log("Failed to spawn bot.");
		return None;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	NewBot.PlayerReplicationInfo.bIsABot = True;


	// Log it.
	if (game.LocalLog != None)
	{
		game.LocalLog.LogPlayerConnect(NewBot);
		game.LocalLog.FlushLog();
	}
	if (game.WorldLog != None)
	{
		game.WorldLog.LogPlayerConnect(NewBot);
		game.WorldLog.FlushLog();
	}
    
    return NewBot;

}

function int SpawnNewBot(String viewer,name Orders)
{
    local Bot NewBot;
    local int i;
    local bool stored;
    
    NewBot = AddBot(viewer);
    
    if (NewBot == None){
        //ccModule.BroadCastMessage("Failed to spawn a bot somehow");
        return TempFail;
    }
    
    if (numAddedBots>=MaxAddedBots) {
        //ccModule.BroadCastMessage("Too many bots! "$numAddedBots$">="$MaxAddedBots);
        return TempFail;
    }
    
    //Add bot to list of "added bots", so that they can be removed on death (In ScoreKill)
    stored = False;
    for (i=0;i<MaxAddedBots && stored==False;i++) {
        if (added_bots[i]==None){
            added_bots[i]=NewBot;
            stored=True;
            numAddedBots++;
            //ccModule.BroadCastMessage(NewBot.PlayerReplicationInfo.PlayerName$" stored in slot "$i);
        }
    }
    
    if (stored==False) {
        //No space to store this bot!  Remove the bot again and fail.  This shouldn't happen.
        NewBot.Destroy();
        return TempFail;
    }
    
    NewBot.SetOrders(Orders,None);
    
    ccModule.BroadCastMessage(viewer$" added themself to the game as a bot!");
    
    return Success;
}

function int StartVampireMode(string viewer)
{
    if (vampireTimer>0) {
        return TempFail;
    }
    ccModule.BroadCastMessage(viewer@"made everyone have a taste for blood!");
    vampireTimer = VampireTimerDefault;
    return Success;
}


function int doCrowdControlEvent(string code, string param[5], string viewer, int type) {
    local int i;

    switch(code) {
        case "sudden_death":  //Everyone loses all armour and goes down to one health
            return SuddenDeath(viewer);
        case "full_heal":  //Everyone gets brought up to 100 health (not brought down if overhealed though)
            return FullHeal(viewer);
        case "full_armour": //Everyone gets a shield belt
            return FullArmour(viewer); 
        case "give_health": //Give an arbitrary amount of health.  Allows overhealing, up to 199
            return GiveHealth(viewer,Int(param[0]));
        case "third_person":  //Switches to behind view for everyone
            return ThirdPerson(viewer);
        case "bonus_dmg":   //Gives everyone a damage bonus item (triple damage)
            return GiveDamageItem(viewer);
        case "full_fat":   //Makes everyone really fat for a minute
            return FullFat(viewer);
        case "skin_and_bones":  //Makes everyone really skinny for a minute
            return SkinAndBones(viewer);
        case "gotta_go_fast":  //Makes everyone really fast for a minute
            return GottaGoFast(viewer);
        case "gotta_go_slow":  //Makes everyone really slow for 15 seconds (A minute was too much!)
            return GottaGoSlow(viewer);
        case "thanos":  //Every player has a 50% chance of being killed
            return ThanosSnap(viewer);
        case "swap_player_position":  //Picks two random players and swaps their positions
            return swapPlayer(viewer);
        case "no_ammo":  //Removes all ammo from all players
            return NoAmmo(viewer);
        case "give_ammo":  //Gives X boxes of a particular ammo type to all players
            return giveAmmo(viewer,param[0],Int(param[1]));
        case "nudge":  //All players get nudged slightly in a random direction
            return doNudge(viewer);
        case "drop_selected_item":  //Destroys the currently equipped weapon (Except for melee, translocator, and enforcers)
            return DropSelectedWeapon(viewer);
        case "give_weapon":  //Gives all players a specific weapon
            return GiveWeapon(viewer,param[0]);
        case "give_instagib":  //This is separate so that it can be priced differently
            return GiveWeapon(viewer,"SuperShockRifle");
        case "give_redeemer":  //This is separate so that it can be priced differently
            return GiveWeapon(viewer,"WarHeadLauncher");
        case "ice_physics":  //Makes the floor very slippery (This is kind of stuttery in multiplayer...) for a minute
            return EnableIcePhysics(viewer);
        case "low_grav":  //Makes the world entirely low gravity for a minute
            return EnableMoonPhysics(viewer);
        case "melee_only": //Force everyone to use melee for the duration (continuously check weapon and switch to melee choice)
            return StartMeleeOnlyTime(viewer);
        case "flood": //Make the entire map a water zone for a minute!
            return StartFlood(viewer);
        case "last_place_shield": //Give last place player a shield belt
            return LastPlaceShield(viewer);
        case "last_place_bonus_dmg": //Give last place player a bonus damage item
            return LastPlaceDamage(viewer);
        case "first_place_slow": //Make the first place player really slow   
            return FirstPlaceSlow(viewer);
        case "blue_redeemer_shell": //Blow up first place player
            return BlueRedeemerShell(viewer);
        case "spawn_a_bot_attack": //Summon a bot that attacks, then disappears after a death   
            return SpawnNewBot(viewer,'Attack');        
        case "spawn_a_bot_defend": //Summon a bot that defends, then disappears after a death
            return SpawnNewBot(viewer,'Defend');        
        case "vampire_mode":  //Inflicting damage heals you for the damage dealt (Can grab damage via MutatorTakeDamage)
            return StartVampireMode(viewer);
        case "force_weapon_use": //Give everybody a weapon, then force them to use it for the duration.  Periodic ammo top-ups probably needed      
        default:
            ccModule.BroadCastMessage("Got Crowd Control Effect -   code: "$code$"   viewer: "$viewer );
            break;
        
    }
    
    
    
    return Success;
}

function handleMessage( string msg) {
  
    local int id,type;
    local string code,viewer;
    local string param[5];
    
    local int result;
    
    local JsonMsg jmsg;
    local string val;
    local int i,j;

    if (isCrowdControl(msg)) {
        jmsg=ParseJson(msg);
        
        for (i=0;i<jmsg.count;i++) {
            if (jmsg.e[i].valCount>0) {
                val = jmsg.e[i].value[0];
                //PlayerMessage("Key: "$jmsg.e[i].key);
                switch (jmsg.e[i].key) {
                    case "code":
                        code = val;
                        break;
                    case "viewer":
                        viewer = val;
                        break;
                    case "id":
                        id = Int(val);
                        break;
                    case "type":
                        type = Int(val);
                        break;
                    case "parameters":
                        for (j=0;j<5;j++) {
                            param[j] = jmsg.e[i].value[j];
                        }
                        break;
                }
            }
        }
        
        result = doCrowdControlEvent(code,param,viewer,type);
        
        sendReply(id,result);
        
    } else {
        ccModule.BroadCastMessage("Got a weird message: "$msg);
    }

}

function bool isCrowdControl( string msg) {
    local string tmp;
    //Validate if it looks json-like
    if (InStr(msg,"{")!=0){
        //PlayerMessage("Message doesn't start with curly");
        return False;
    }
    
    //Explicitly check last character of string to see if it's a closing curly
    tmp = Mid(msg,Len(msg)-1,1);
    //if (InStr(msg,"}")!=Len(msg)-1){
    if (tmp != "}"){
        //PlayerMessage("Message doesn't end with curly.  Ends with '"$tmp$"'.");
        return False;    
    }
    
    //Check to see if it looks like it has the right fields in it
    
    //id field
    if (InStr(msg,"id")==-1){
        //PlayerMessage("Doesn't have id");
        return False;
    }
    
    //code field
    if (InStr(msg,"code")==-1){
        //PlayerMessage("Doesn't have code");
        return False;
    }
    //viewer field
    if (InStr(msg,"viewer")==-1){
        //PlayerMessage("Doesn't have viewer");
        return False;
    }

    return True;
}

function sendReply(int id, int status) {
    local string resp;
    local byte respbyte[255];
    local int i;
    
    resp = "{\"id\":"$id$",\"status\":"$status$"}"; 
    
    for (i=0;i<Len(resp);i++){
        respbyte[i]=Asc(Mid(resp,i,1));
    }
    
    //PlayerMessage(resp);
    SendBinary(Len(resp)+1,respbyte);
}


//I cannot believe I had to manually write my own version of ReceivedBinary
function ManualReceiveBinary() {
    local byte B[255]; //I have to use a 255 length array even if I only want to read 1
    local int count,i;
    //PlayerMessage("Manually reading, have "$DataPending$" bytes pending");
    
    if (DataPending!=0) {
        count = ReadBinary(255,B);
        for (i = 0; i < count; i++) {
            if (B[i] == 0) {
                if (Len(pendingMsg)>0){
                    handleMessage(pendingMsg);
                }
                pendingMsg="";
            } else {
                pendingMsg = pendingMsg $ Chr(B[i]);
                //PlayerMessage("ReceivedBinary: " $ B[i]);
            }
        }
    }
    
}
event Opened(){
    ccModule.BroadCastMessage("Crowd Control connection opened");
}

event Closed(){
    ccModule.BroadCastMessage("Crowd Control connection closed");
    ListenPort = 0;
    reconnectTimer = ReconDefault;
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

function Resolved( IpAddr Addr )
{
    if (ListenPort == 0) {
        ListenPort=BindPort();
        if (ListenPort==0){
            ccModule.BroadCastMessage("Failed to bind port for Crowd Control");
            reconnectTimer = ReconDefault;
            return;
        }   
    }

    Addr.port=CrowdControlPort;
    if (False==Open(Addr)){
        ccModule.BroadCastMessage("Could not connect to Crowd Control client");
        reconnectTimer = ReconDefault;
        return;

    }

    //Using manual binary reading, which is handled by ManualReceiveBinary()
    //This means that we can handle if multiple crowd control messages come in
    //between reads.
    LinkMode=MODE_Binary;
    ReceiveMode = RMODE_Manual;

}
function ResolveFailed()
{
    ccModule.BroadCastMessage("Could not resolve Crowd Control address");
    reconnectTimer = ReconDefault;
}