Class UT99CCEffects extends Info;

var Mutator baseMutator;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;


const IceFriction = 0.25;
const NormalFriction = 8;
var vector NormalGravity;
var vector FloatGrav;
var vector MoonGrav;


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

var int forceWeaponTimer;
const ForceWeaponTimerDefault = 60;
var class<Weapon> forcedWeapon;

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

var int cfgMinPlayers;

var bool bFat,bFast;
var string targetPlayer;

replication
{
    reliable if ( Role == ROLE_Authority )
        behindTimer,fatnessTimer,speedTimer,iceTimer,gravityTimer,meleeTimer,floodTimer,vampireTimer,forceWeaponTimer,bFat,bFast,forcedWeapon,numAddedBots,targetPlayer,GetEffectList;
}

function Init(Mutator baseMut)
{
    local int i;
    local DeathMatchPlus game;

    game = DeathMatchPlus(Level.Game);
    
    baseMutator = baseMut;
    
    NormalGravity=vect(0,0,-950);
    FloatGrav=vect(0,0,0.15);
    MoonGrav=vect(0,0,-100);  
    
    for (i=0;i<MaxAddedBots;i++){
        added_bots[i]=None;
    }

    if (game!=None)
    {
        cfgMinPlayers = game.MinPlayers;
    }
    
}

function SendCCMessage(string msg)
{
    local PlayerPawn p;
    local color c;
    
    c.R=0;
    c.G=255;
    c.B=0;

    foreach AllActors(class'PlayerPawn',p){
        p.ClearProgressMessages();
        p.SetProgressTime(4);
        p.SetProgressColor(c,0);
        p.SetProgressMessage(msg,0);
    }
}

function Broadcast(string msg)
{
    baseMutator.BroadCastMessage(msg);
    SendCCMessage(msg);
}


simulated function GetEffectList(out string effects[15], out int numEffects)
{
    local int i;

    if (behindTimer > 0) {
        effects[i]="Third-Person: "$behindTimer;
        i++;
    }
    if (fatnessTimer > 0) {
        if(bFat){
            effects[i]="Full Fat: "$fatnessTimer;
        } else {
            effects[i]="Skin and Bones: "$fatnessTimer;
        }
        i++;
    }
    if (speedTimer > 0) {
        if(bFast){
            effects[i]="Gotta Go Fast: "$speedTimer;
        } else {
            effects[i]="Gotta Go Slow";
            if (targetPlayer!=""){
                effects[i]=effects[i]$" ("$targetPlayer$")";
            }
            effects[i]=effects[i]$": "$speedTimer;
        }
        i++;
    }
    if (iceTimer > 0) {
        effects[i]="Ice Physics: "$iceTimer;
        i++;
    }
    if (gravityTimer > 0) {
        effects[i]="Low-Grav: "$gravityTimer;
        i++;
    }
    if (meleeTimer > 0) {
        effects[i]="Melee-Only: "$meleeTimer;
        i++;
    }
    if (floodTimer > 0) {
        effects[i]="Flood: "$floodTimer;
        i++;
    }
    if (vampireTimer > 0) {
        effects[i]="Vampire: "$vampireTimer;
        i++;
    }
    if (forceWeaponTimer > 0) {
        effects[i]="Forced "$forcedWeapon.default.ItemName$": "$forceWeaponTimer;
        i++;
    }
    if (numAddedBots > 0) {
        effects[i]="Added Bots: "$numAddedBots;
        i++;
    }

    numEffects=i;
}

//One Second timer updates
function PeriodicUpdates()
{
    if (behindTimer > 0) {
        behindTimer--;
        if (behindTimer <= 0) {
            SetAllPlayersBehindView(False);
            Broadcast("Returning to first person view...");

        }
    }

    if (fatnessTimer > 0) {
        fatnessTimer--;
        if (fatnessTimer <= 0) {
            SetAllPlayersFatness(120);
            Broadcast("Returning to normal fatness...");
        }
    }    

    if (speedTimer > 0) {
        speedTimer--;
        if (speedTimer <= 0) {
            SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed);
            Broadcast("Returning to normal move speed...");
        }
    }  
    
    if (iceTimer > 0) {
        iceTimer--;
        if (iceTimer <= 0) {
            SetIcePhysics(False);
            Broadcast("The ground thaws...");
        }
    }  
    
    if (gravityTimer > 0) {
        gravityTimer--;
        if (gravityTimer <= 0) {
            SetMoonPhysics(False);
            Broadcast("Gravity returns to normal...");
        }
    }  

    if (meleeTimer > 0) {
        meleeTimer--;
        if (meleeTimer <= 0) {
            Broadcast("You may use ranged weapons again...");
        }
    }  
    
    if (floodTimer > 0) {
        floodTimer--;
        if (floodTimer <= 0) {
            SetFlood(False);
            UpdateAllPawnsSwimState();

            Broadcast("The flood drains away...");
        }
    }  

    if (vampireTimer > 0) {
        vampireTimer--;
        if (vampireTimer <= 0) {
            Broadcast("You no longer feed on the blood of others...");
        }
    }  
    
    if (forceWeaponTimer > 0) {
        forceWeaponTimer--;
        if (forceWeaponTimer <= 0) {
            Broadcast("You can use any weapon again...");
            forcedWeapon = None;
        }
    }  

}

//Updates every tenth of a second
function ContinuousUpdates()
{
    local DeathMatchPlus game;
    
    game = DeathMatchPlus(Level.Game);
    
    //Want to force people to melee more frequently than once a second
    if (meleeTimer > 0) {
        ForceAllPawnsToMelee();
    }
    
    if (forceWeaponTimer > 0) {
        TopUpWeaponAmmoAllPawns(forcedWeapon);
        ForceAllPawnsToSpecificWeapon(forcedWeapon);  
    }
    
    if (game!=None){
        if (numAddedBots==0 || Level.Game.bGameEnded){
            game.MinPlayers = cfgMinPlayers;
        } else {
            game.MinPlayers = Max(cfgMinPlayers+numAddedBots, game.NumPlayers + numAddedBots);
        }
    }
}



//Called every time there is a kill
function ScoreKill(Pawn Killer,Pawn Other)
{
    local int i;
    local DeathMatchPlus game;

    game = DeathMatchPlus(Level.Game);

    //Broadcast(Killer.PlayerReplicationInfo.PlayerName$" just killed "$Other.PlayerReplicationInfo.PlayerName);
    
    //Check if the killed pawn is a bot that we don't want to respawn
    for (i=0;i<MaxAddedBots;i++){
        if (added_bots[i]!=None && added_bots[i]==Other) {
            added_bots[i]=None;
            numAddedBots--;
            if (game!=None)
            {
                game.MinPlayers = Max(cfgMinPlayers+numAddedBots, game.NumPlayers + game.NumBots - 1);
            }

            //Broadcast("Should be destroying added bot "$Other.PlayerReplicationInfo.PlayerName);
            Broadcast("Crowd Control viewer "$Other.PlayerReplicationInfo.PlayerName$" has left the match");
            Other.SpawnGibbedCarcass();
            Other.Destroy(); //This may cause issues if there are more mutators caring about ScoreKill.  Probably should schedule this deletion for later instead...
            break;
        }
    }    
}


function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType)
{
    //Broadcast(InstigatedBy.PlayerReplicationInfo.PlayerName$" inflicted "$ActualDamage$" damage to "$Victim.PlayerReplicationInfo.PlayerName);
    
    //Check if vampire mode timer is running, and if it is, do the vampire thing
    //Don't allow healing off of damage to yourself
    if (vampireTimer > 0 && InstigatedBy!=None && Victim!=InstigatedBy) {
        InstigatedBy.Health += (ActualDamage/2); //Don't heal the full amount of damage
        
        //Don't let it overheal
        if (InstigatedBy.Health > 199) {
            InstigatedBy.Health = 199;
        }
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                               CROWD CONTROL UTILITY FUNCTIONS                                       ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

function RemoveAllArmor(Pawn p)
{
    // If there is armor in our inventory chain, unlink it and destroy it
	local actor Link;
    local Inventory armor;

	for( Link = p; Link!=None; Link=Link.Inventory )
	{
            if( Link.Inventory!=None && Link.Inventory.bIsAnArmor )
            {
                armor = Link.Inventory;
                if(Link.Inventory!=None){
                    Link.Inventory = Link.Inventory.Inventory;
                }
                armor.SetOwner(None);
                armor.Destroy();
            }
    }
}

function GiveInventoryToPawn(Class<Inventory> className, Pawn p)
{
    local Inventory inv;
    
    inv = Spawn(className);
    inv.Touch(p);
    inv.Destroy();
}

function SetAllPlayersFatness(int fatness)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        p.Fatness = fatness;
    }
}

function SetAllPlayersGroundSpeed(int speed)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        //Broadcast("Speed before: "$p.GroundSpeed$"  Speed After: "$speed);
        p.GroundSpeed = speed;
    }
}

function Swap(Actor a, Actor b)
{
    local vector newloc, oldloc;
    local rotator newrot;
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
        if (!p.IsA('StationaryPawn') && p.Health>0){
            pawns[num++] = p;
        }
    }

    if( num == 0 ) return None;
    return pawns[ Rand(num) ];    
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

function class<Actor> GetAmmoClassByName(String ammoName)
{
    local class<Actor> ammoClass;
    
    switch(ammoName){
        case "flakammo":
            ammoClass = class'FlakAmmo';
            break;
        case "bioammo":
            ammoClass = class'BioAmmo';
            break;
        case "warheadammo":
            ammoClass = class'WarHeadAmmo';
            break;
        case "pammo":
            ammoClass = class'PAmmo';
            break;
        case "shockcore":
            ammoClass = class'ShockCore';
            break;
        case "bladehopper":
            ammoClass = class'BladeHopper';
            break;
        case "rocketpack":
            ammoClass = class'RocketPack';
            break;
        case "bulletbox":
            ammoClass = class'BulletBox';
            break;
        case "miniammo":
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
        item.bHeldItem=True;
        item.RespawnTime=0.0;
        p.Inventory = item;
}

function bool IsWeaponRemovable(Weapon w)
{
    if (w==None){
        return False;
    }
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

function class<Weapon> GetWeaponClassByName(String weaponName)
{
    local class<Weapon> weaponClass;
    
    switch(weaponName){
        case "translocator":
            weaponClass = class'Translocator';
            break;
        case "ripper":
            weaponClass = class'Ripper';
            break;
        case "WarHeadLauncher":
            weaponClass = class'WarHeadLauncher';
            break;
        case "biorifle":
            weaponClass = class'UT_BioRifle';
            break;
        case "flakcannon":
            weaponClass = class'UT_FlakCannon';
            break;
        case "sniperrifle":
            weaponClass = class'SniperRifle';
            break;
        case "shockrifle":
            weaponClass = class'ShockRifle';
            break;
        case "pulsegun":
            weaponClass = class'PulseGun';
            break;
        case "minigun":
            weaponClass = class'Minigun2';
            break;
        case "rocketlauncher":
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
        if (!p.IsA('StationaryPawn')){
            ForcePawnToMeleeWeapon(p);
        }
    }
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
        //Broadcast("State before update was "$p.GetStateName());
        if (p.Health>0){
            if (p.Region.Zone.bWaterZone) {
                p.setPhysics(PHYS_Swimming);
                p.GotoState('PlayerSwimming');
            } else {
                p.setPhysics(PHYS_Falling);
                p.GotoState('PlayerWalking');
            
            }
        }
    }

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
        if (p.IsA('StationaryPawn')){
            continue; //Skip turrets and things like that
        }
        //Broadcast(p.PlayerReplicationInfo.PlayerName$" is on team "$p.PlayerReplicationInfo.Team);
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

function int FindTeamByTeamScore(bool HighTeam)
{
    local int i,team;
    local TeamGamePlus game;
    team = 0;

    if (Level.Game.bTeamGame==False){
        return 255;
    }
    
    game = TeamGamePlus(Level.Game);
    
    if (game == None){
        return 255;
    }
    
    for (i=0;i<4;i++) {
        if (HighTeam) {
            if (game.Teams[i].Score > game.Teams[team].Score){
                team = i;
            }
        } else {
            if (game.Teams[i].Score < game.Teams[team].Score){
                team = i;
            }        
        }
    }
    
    return team;
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
        if (!p.IsA('StationaryPawn')){
            pCount[p.PlayerReplicationInfo.Team]++;
        }
    }
    
    for (i = 0; i < 256;i++){        
        if (pCount[i]!=0 && pCount[i] < pCount[lowTeam]) {
            lowTeam = i;
        }
    }
    //Broadcast("Lowest team is "$lowTeam);
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
    local float skill;
    
    game = DeathMatchPlus(Level.Game);
    
    if (game==None)
    {
        return None;
    }
    
    lowTeam = FindTeamWithLeastPlayers();
    
    //Adjust skill based on whether or not the bot is going on the winning team
    skill = game.BotConfig.Difficulty; //TODO: Actually adjust this difficulty


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
        
        NewBot.InitializeSkill(skill);
        
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

function ForcePawnToSpecificWeapon(Pawn p, class<Weapon> weaponClass)
{
    local Weapon specificweapon;
    
    if (p.Weapon.Class == weaponClass) {
        return;  //No need to do a lookup if it's already melee or nothing
    }
    
    specificweapon = FindSpecificWeaponInPawnInventory(p, weaponClass);
    
    p.Weapon.GotoState('DownWeapon');
	p.PendingWeapon = None;
	p.Weapon = specificweapon;
	p.Weapon.BringUp();
}

function Weapon FindSpecificWeaponInPawnInventory(Pawn p,class<Weapon> weaponClass)
{
	local actor Link;

	for( Link = p; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory!= None && Link.Inventory.Class == weaponClass )
		{
            return Weapon(Link.Inventory);
		}
	}
    
    return None;
}

function TopUpWeaponAmmoAllPawns(class<Weapon> weaponClass)
{
    local Pawn p;
    local Weapon w;
    
    foreach AllActors(class'Pawn',p) {
        if (p.IsA('StationaryPawn') || p.IsA('Spectator') || p.Health<=0){
            continue;
        }
        w=None;
        w = FindSpecificWeaponInPawnInventory(p,weaponClass);
        
        if (w!=None){
            if (w.AmmoType!=None && w.AmmoType.AmmoAmount==0){
                w.AmmoType.AddAmmo(w.PickupAmmoCount);
            }
        } else {
            GiveWeaponToPawn(p,weaponClass);
        }
        
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                CROWD CONTROL EFFECT FUNCTIONS                                       ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////



function int SuddenDeath(string viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        if (!p.IsA('StationaryPawn') && p.Health>0){
            p.Health = 1;
            RemoveAllArmor(p);
        }
    }
    
    Broadcast(viewer$" has initiated sudden death!  All health reduced to 1, no armour!");

    return Success;
}

function int FullHeal(string viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        if (p.Health>0){
            //Don't reduce health if someone is overhealed
            if (p.Health < 100) {
                p.Health = 100;
            }
        }
    }
    
    Broadcast("Everyone has been fully healed by "$viewer$"!");
  
    return Success;

}

//Shield Belt for everybody!
function int FullArmour(string viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        GiveInventoryToPawn(class'UT_ShieldBelt',p);
    }
   
    Broadcast(viewer$" has given everyone a shield belt!");
   
    return Success;
}

function int GiveHealth(string viewer,int amount)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        if (p.Health>0){
            p.Health = Min(p.Health + amount,199); //Let's allow this to overheal, up to 199
        }
    }
    
    Broadcast("Everyone has been given "$amount$" health by "$viewer$"!");
    
    return Success;
}

function SetAllPlayersBehindView(bool val)
{
    local PlayerPawn p;
    
    foreach AllActors(class'PlayerPawn',p) {
        p.BehindView(val);
    }
}

function int ThirdPerson(String viewer, int duration)
{
    SetAllPlayersBehindView(True);
    
    if (duration==0){
        duration = BehindTimerDefault;
    }
    
    behindTimer = duration;

    Broadcast(viewer$" wants you to have an out of body experience!");
  
    return Success;

}

function int GiveDamageItem(String viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        GiveInventoryToPawn(class'UDamage',p);
    }
    
    Broadcast(viewer$" gave everyone a damage powerup!");
   
    return Success;
}

function int FullFat(String viewer, int duration)
{
    if (fatnessTimer>0) {
        return TempFail;
    }
  
    SetAllPlayersFatness(255);

    if (duration==0){
        duration = FatnessTimerDefault;
    }    
    
    fatnessTimer = duration;
    bFat=True;
    Broadcast(viewer$" fattened everybody up!");
 
    return Success;
}

function int SkinAndBones(String viewer, int duration)
{
    if (fatnessTimer>0) {
        return TempFail;
    }

    SetAllPlayersFatness(1);
    
    if (duration==0){
        duration = FatnessTimerDefault;
    }
    fatnessTimer = duration;
    bFat=False;
    Broadcast(viewer$" made everyone really skinny!");
   
    return Success;
}


function int GottaGoFast(String viewer, int duration)
{
    if (speedTimer>0) {
        return TempFail;
    }

    SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed * 3);
    if (duration==0){
        duration = SpeedTimerDefault;
    }
    speedTimer = duration;
    bFast=True;
    targetPlayer="";
    Broadcast(viewer$" made everyone fast like Sonic!");
   
    return Success;   
}

function int GottaGoSlow(String viewer, int duration)
{
    if (speedTimer>0) {
        return TempFail;
    }

    SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed / 3);

    if (duration==0){
        duration = SlowTimerDefault;
    }
    speedTimer = duration;
    bFast=False;
    targetPlayer="";
    Broadcast(viewer$" made everyone slow like a snail!");
   
    return Success;   
}

function int ThanosSnap(String viewer)
{
    local Pawn p;
    local String origDamageString;
    
    origDamageString = Level.Game.SpecialDamageString;
    Level.Game.SpecialDamageString = "%o got snapped by "$viewer;
    
    foreach AllActors(class'Pawn',p) {
        if (p.IsA('StationaryPawn')){
            continue;
        }
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
    
    Broadcast(viewer$" snapped their fingers!");
  
    return Success;

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
    
    Broadcast(viewer@"thought "$a.PlayerReplicationInfo.PlayerName$" would look better if they were where"@b.PlayerReplicationInfo.PlayerName@"was");

    return Success;
}


function int NoAmmo(String viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        if (!p.IsA('StationaryPawn')){
            RemoveAllAmmoFromPawn(p);
        }
    }
    
    Broadcast(viewer$" stole all your ammo!");
    
    return Success;
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
    
    Broadcast(viewer$" gave everybody some ammo! ("$class<ammo>(ammoClass).default.ItemName$")");

    return Success;
}

function int doNudge(string viewer) {
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
        
    Broadcast(viewer@"nudged you a little bit");

    return Success;
}


function int DropSelectedWeapon(string viewer) {
    local Pawn p;
    local Weapon w;

    //This won't do anything if people are being forced to a weapon, so postpone it
    if (forceWeaponTimer>0) {
        return TempFail;
    }        

    foreach AllActors(class'Pawn',p) {
        if (p.IsA('StationaryPawn')){
            continue;
        }
        if (IsWeaponRemovable(p.Weapon)){
            w=p.Weapon;
            p.DeleteInventory(p.Weapon);
            w.bHidden=True;
            //w.bDeleteMe=True;
            w.Destroy();
        }
    }
    
    Broadcast(viewer$" stole your current weapon!");
   
    return Success;

}



function int GiveWeapon(String viewer, String weaponName)
{
    local class<Weapon> weaponClass;
    local Pawn p;

    weaponClass = GetWeaponClassByName(weaponName);
    
    foreach AllActors(class'Pawn',p) {  //Probably could just iterate over PlayerPawns, but...
        if (p.IsA('StationaryPawn') || p.IsA('Spectator') || p.Health<=0){
            continue;
        }
        GiveWeaponToPawn(p,weaponClass);
    }
    
    Broadcast(viewer$" gave everybody a weapon! ("$weaponClass.default.ItemName$")");
  
    return Success;
}



function int EnableIcePhysics(string viewer, int duration)
{
    if (iceTimer>0) {
        return TempFail;
    }
    
    if (duration==0){
        duration = IceTimerDefault;
    }
    
    Broadcast(viewer@"made the ground freeze!");
    SetIcePhysics(True);
    iceTimer = duration;

    return Success;
}

function int EnableMoonPhysics(string viewer, int duration)
{
    if (gravityTimer>0) {
        return TempFail;
    }
    if (duration==0){
        duration = GravityTimerDefault;
    }
    Broadcast(viewer@"reduced gravity!");
    SetMoonPhysics(True);
    gravityTimer = duration;

    return Success;
}

function int StartMeleeOnlyTime(String viewer, int duration)
{
    if (meleeTimer > 0) {
        return TempFail;
    }
    if (forceWeaponTimer>0) {
        return TempFail;
    }    
    ForceAllPawnsToMelee();
    
    Broadcast(viewer@"requests melee weapons only!");
    if (duration==0){
        duration = MeleeTimerDefault;
    }
    meleeTimer = duration;
    
    return Success;
}


function int StartFlood(string viewer, int duration)
{
    if (floodTimer>0) {
        return TempFail;
    }
    Broadcast(viewer@"started a flood!");

    SetFlood(True);
    UpdateAllPawnsSwimState();
    if (duration==0){
        duration = FloodTimerDefault;
    }
    floodTimer = duration;
    return Success;
}


function int LastPlaceShield(String viewer)
{
    local Pawn p;

    p = findPawnByScore(False,255); //Get lowest score player
    if (p == None) {
        return TempFail;
    }
    
    //Actually give them the shield belt
    GiveInventoryToPawn(class'UT_ShieldBelt',p);

    Broadcast(viewer@"gave a Shield Belt to "$p.PlayerReplicationInfo.PlayerName$", who is in last place!");

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
    GiveInventoryToPawn(class'UDamage',p);
    
    Broadcast(viewer@"gave a Damage Amplifier to "$p.PlayerReplicationInfo.PlayerName$", who is in last place!");

    return Success;


}

function int FirstPlaceSlow(String viewer, int duration)
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
    
    if (duration == 0){
        duration = SingleSlowTimerDefault;
    }
    speedTimer = duration;
    targetPlayer=p.PlayerReplicationInfo.PlayerName;

    Broadcast(viewer$" made "$p.PlayerReplicationInfo.PlayerName$" slow as punishment for being in first place!");

    return Success;   
}

//If teams, should find highest on winning team, and lowest on losing team
function int BlueRedeemerShell(String viewer)
{
    local Pawn high,low;
    local WarShell missile;
    local int avoidTeam;
    
    
    high = findPawnByScore(True,FindTeamByTeamScore(False));  //Target individual player who is doing best on a team that isn't in last place
    
    if (high==None){
        return TempFail;
    }
    
    if (Level.Game.bTeamGame==True){
        avoidTeam = high.PlayerReplicationInfo.Team;
    } else {
        avoidTeam = 255;
    }
    
    low = findPawnByScore(False,avoidTeam);  //Find worst player who is on a different team (if a team game)
    
    if (low == None || high == low){
        return TempFail;
    }
    
    missile = Spawn(class'WarShell',low,,high.Location);
    missile.SetOwner(low);
    missile.Instigator = low;  //Instigator is the one who gets credit for the kill
    missile.GotoState('Flying');
    missile.Explode(high.Location,high.Location);

    Broadcast(viewer$" dropped a redeemer shell on "$high.PlayerReplicationInfo.PlayerName$"'s head, since they are in first place!");

    return Success;
}


function int SpawnNewBot(String viewer,name Orders)
{
    local Bot NewBot;
    local int i;
    local bool stored;
    
    NewBot = AddBot(viewer);
    
    if (NewBot == None){
        //Broadcast("Failed to spawn a bot somehow");
        return TempFail;
    }
    
    if (numAddedBots>=MaxAddedBots) {
        //Broadcast("Too many bots! "$numAddedBots$">="$MaxAddedBots);
        return TempFail;
    }
    
    //Add bot to list of "added bots", so that they can be removed on death (In ScoreKill)
    stored = False;
    for (i=0;i<MaxAddedBots && stored==False;i++) {
        if (added_bots[i]==None){
            added_bots[i]=NewBot;
            stored=True;
            numAddedBots++;
            //Broadcast(NewBot.PlayerReplicationInfo.PlayerName$" stored in slot "$i);
        }
    }
    
    if (stored==False) {
        //No space to store this bot!  Remove the bot again and fail.  This shouldn't happen.
        NewBot.Destroy();
        return TempFail;
    }
    
    NewBot.SetOrders(Orders,None);
    
    Broadcast(viewer$" added themself to the game as a bot!");
 
    return Success;
}

function int StartVampireMode(string viewer, int duration)
{
    if (vampireTimer>0) {
        return TempFail;
    }
    Broadcast(viewer@"made everyone have a taste for blood!");
    if (duration==0){
        duration = VampireTimerDefault;
    }
    vampireTimer = duration;
    return Success;
}


function ForceAllPawnsToSpecificWeapon(class<Weapon> weaponClass)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        if (!p.IsA('StationaryPawn') && p.Health>0){
            ForcePawnToSpecificWeapon(p, weaponClass);
        }
    }
}


function int ForceWeaponUse(String viewer, String weaponName, int duration)
{
    local class<Weapon> weaponClass;
    local Pawn p;

    if (forceWeaponTimer>0) {
        return TempFail;
    }
    if (meleeTimer > 0) {
        return TempFail;
    }
    
    weaponClass = GetWeaponClassByName(weaponName);
    
    foreach AllActors(class'Pawn',p) {  //Probably could just iterate over PlayerPawns, but...
        if (p.IsA('StationaryPawn') || p.IsA('Spectator') || p.Health<=0){
            continue;
        }
        GiveWeaponToPawn(p,weaponClass);
        
    }
    if (duration==0){
        duration = ForceWeaponTimerDefault;
    }
    forceWeaponTimer = duration;
    forcedWeapon = weaponClass;
     
    Broadcast(viewer$" forced everybody to use a specific weapon! ("$forcedWeapon.default.ItemName$")");
  
    return Success;

}

function int ResetDominationControlPoints(String viewer)
{
    local Domination game;
    local ControlPoint cp;
    local bool resetAny;

    game = Domination(Level.Game);
    
    if (game == None){
        return TempFail;
    }
    
    foreach AllActors(class'BotPack.ControlPoint', cp) {
        if (cp.ControllingTeam!=None){
            //baseMutator.BroadCastMessage("Control Point controlled by "$cp.ControllingTeam.TeamName);
            resetAny=True;
            cp.Controller=None;
            cp.UpdateStatus();
        //} else {
            //baseMutator.BroadCastMessage("Control Point controlled by nobody");
        }
    }

    //Don't trigger if none of the control points were owned yet
    if (resetAny==False){
        return TempFail;
    }
    Broadcast(viewer$" reset all the control points!");
    return Success;
}

function int ReturnCTFFlags(String viewer)
{
    local CTFGame game;
    local CTFFlag flag;
    local bool resetAny;

    game = CTFGame(Level.Game);
    
    if (game == None){
        return TempFail;
    }
    
    foreach AllActors(class'CTFFlag', flag){
        if (flag.bHome==False){
            flag.SendHome();
            resetAny=True;
        }
    }

    //Don't trigger if none of the control points were owned yet
    if (resetAny==False){
        return TempFail;
    }
    Broadcast(viewer$" returned the flags!");
    return Success;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL EFFECT MAPPING                                       ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


function int doCrowdControlEvent(string code, string param[5], string viewer, int type, int duration) {
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
            return ThirdPerson(viewer,duration);
        case "bonus_dmg":   //Gives everyone a damage bonus item (triple damage)
            return GiveDamageItem(viewer);
        case "full_fat":   //Makes everyone really fat for a minute
            return FullFat(viewer,duration);
        case "skin_and_bones":  //Makes everyone really skinny for a minute
            return SkinAndBones(viewer,duration);
        case "gotta_go_fast":  //Makes everyone really fast for a minute
            return GottaGoFast(viewer, duration);
        case "gotta_go_slow":  //Makes everyone really slow for 15 seconds (A minute was too much!)
            return GottaGoSlow(viewer, duration);
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
            return EnableIcePhysics(viewer, duration);
        case "low_grav":  //Makes the world entirely low gravity for a minute
            return EnableMoonPhysics(viewer, duration);
        case "melee_only": //Force everyone to use melee for the duration (continuously check weapon and switch to melee choice)
            return StartMeleeOnlyTime(viewer,duration);
        case "flood": //Make the entire map a water zone for a minute!
            return StartFlood(viewer, duration);
        case "last_place_shield": //Give last place player a shield belt
            return LastPlaceShield(viewer);
        case "last_place_bonus_dmg": //Give last place player a bonus damage item
            return LastPlaceDamage(viewer);
        case "first_place_slow": //Make the first place player really slow   
            return FirstPlaceSlow(viewer, duration);
        case "blue_redeemer_shell": //Blow up first place player
            return BlueRedeemerShell(viewer);
        case "spawn_a_bot_attack": //Summon a bot that attacks, then disappears after a death   
            return SpawnNewBot(viewer,'Attack');        
        case "spawn_a_bot_defend": //Summon a bot that defends, then disappears after a death
            return SpawnNewBot(viewer,'Defend');        
        case "vampire_mode":  //Inflicting damage heals you for the damage dealt (Can grab damage via MutatorTakeDamage)
            return StartVampireMode(viewer, duration);
        case "force_weapon_use": //Give everybody a weapon, then force them to use it for the duration.  Ammo tops up if run out  
            return ForceWeaponUse(viewer,param[0],duration);        
        case "force_instagib": //Give everybody an enhanced shock rifle, then force them to use it for the duration.  Ammo tops up if run out  
            return ForceWeaponUse(viewer,"SuperShockRifle",duration);        
        case "force_redeemer": //Give everybody a redeemer, then force them to use it for the duration.  Ammo tops up if run out  
            return ForceWeaponUse(viewer,"WarHeadLauncher",duration);
        case "reset_domination_control_points":
            return ResetDominationControlPoints(viewer);
        case "return_ctf_flags":
            return ReturnCTFFlags(viewer);        
        default:
            Broadcast("Got Crowd Control Effect -   code: "$code$"   viewer: "$viewer );
            break;
        
    }
    
    return Success;
}

defaultproperties
{
      bHidden=True
      bAlwaysRelevant=True
      bNetTemporary=False
}