class UT99CrowdControlLink extends TcpLink transient;

var string crowd_control_addr;
var CrowdControl ccModule;

var int ListenPort;
var IpAddr addr;
var int ticker;
var int reconnectTimer;
var string pendingMsg;

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

const ReconDefault = 5;

var int behindTimer;
const BehindTimerDefault = 15;

var int fatnessTimer;
const FatnessTimerDefault = 60;

var int speedTimer;
const SpeedTimerDefault = 60;
const SlowTimerDefault = 15;

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
    ccModule = cc;
    crowd_control_addr = addr; 
    
    //Initialize the pending message buffer
    pendingMsg = "";
    
    //Initialize the ticker
    ticker = 0;
    

    Resolve(crowd_control_addr);

    reconnectTimer = ReconDefault;
    SetTimer(0.1,True);

}

function Timer() {
    
    ticker++;
    if (IsConnected()) {
        ManualReceiveBinary();
    }
    
    if (ticker%10 != 0) {
        return;
    }

    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            Resolve(crowd_control_addr);
        }
    }

    if (behindTimer > 0) {
        behindTimer--;
        if (behindTimer <= 0) {
            SetAllPlayersBehindView(False);
        }
    }

    if (fatnessTimer > 0) {
        fatnessTimer--;
        if (fatnessTimer <= 0) {
            SetAllPlayersFatness(120);
        }
    }    

    if (speedTimer > 0) {
        speedTimer--;
        if (speedTimer <= 0) {
            SetAllPlayersGroundSpeed(class'TournamentPlayer'.Default.GroundSpeed);
        }
    }  
    

}

function RemoveAllArmor(Pawn p)
{
    // If there is armor in our inventory chain, unlink it and destroy it
	local actor Link;
    local Inventory armor;
	local bool ItemExisted;


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

//This is a bit more complicated than anticipated, due to armor being carried in inventory
function int FullArmour(string viewer)
{
    //TBD
    ccModule.BroadCastMessage("Everyone has been brought to 100 armor by "$viewer$"!");
    
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

function int DisableJump(String viewer)
{
    local Pawn p;
    
    foreach AllActors(class'Pawn',p) {
        //TBD
    }
    
    ccModule.BroadCastMessage(viewer$" says NO JUMPING!");
    
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

function int GiveDamageItem(String viewer)
{
    local Pawn p;
    local UDamage dam;
    local inventory inv;
    
    foreach AllActors(class'Pawn',p) {
        dam = Spawn(class'UDamage');
        
        dam.SetOwner(p);
        dam.Inventory = p.Inventory;
        p.Inventory = dam;
        dam.Activate();
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
    a = None;
    b = None;
    
    while (a == None || b == None || a==b) {
        a = findRandomPawn();
        b = findRandomPawn();
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
    ccModule.BroadCastMessage("Removing ammo from "$p.PlayerReplicationInfo.PlayerName);
	for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if ( Ammo(Inv) != None ) {
			Ammo(Inv).AmmoAmount = 0;
            ccModule.BroadCastMessage("Removing "$Inv.Name$" from "$p.PlayerReplicationInfo.PlayerName);

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

function int doCrowdControlEvent(string code, string param[5], string viewer, int type) {
    local int i;

    switch(code) {
        case "sudden_death":
            return SuddenDeath(viewer);
        case "full_heal":
            return FullHeal(viewer);
        case "full_armour":
            return FullArmour(viewer); //Not actually implemented
        case "give_health":
            return GiveHealth(viewer,Int(param[0]));
        case "give_armour":
            return GiveArmour(viewer,Int(param[0])); //Not actually implemented
        case "disable_jump":
            return DisableJump(viewer); //Not actually implemented
        case "third_person":
            return ThirdPerson(viewer);
        case "double_dmg":
            return GiveDamageItem(viewer);
        case "full_fat":
            return FullFat(viewer);
        case "skin_and_bones":
            return SkinAndBones(viewer);
        case "gotta_go_fast":
            return GottaGoFast(viewer);
        case "gotta_go_slow":
            return GottaGoSlow(viewer);
        case "thanos":
            return ThanosSnap(viewer);
        case "swap_player_position":
            return swapPlayer(viewer);
        case "no_ammo":
            return NoAmmo(viewer);
        case "give_ammo":
            return giveAmmo(viewer,param[0],Int(param[1]));
        case "ice_physics":
        case "nudge":
        case "low_grav":
        case "drop_selected_item":
        //case "give_weaponXYZ"
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
