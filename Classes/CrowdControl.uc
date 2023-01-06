class CrowdControl extends Mutator config(CrowdControl);

var bool initialized;
var UT99CrowdControlLink ccLink;
var config string crowd_control_addr;

var UT99CCHudSpawnNotify sn;

replication
{
    reliable if (Role==ROLE_Authority)
        sn;
}

function InitCC()
{
    if (Role!=ROLE_Authority)
    {
        return;
    }
    if (initialized==True)
    {
        return;
    }
    
    if (crowd_control_addr==""){
        crowd_control_addr = "127.0.0.1"; //Default to locally hosted
    }
    SaveConfig();
    
    ccLink = Spawn(class'UT99CrowdControlLink');
    ccLink.Init(self,crowd_control_addr);
    
    BroadcastMessage("Crowd Control has initialized!");
    
    initialized = True;
}

simulated function PreBeginPlay()
{
   initialized = False;
   InitCC();
   Level.Game.RegisterDamageMutator(self);
   sn=Spawn(class'UT99CrowdControl.UT99CCHudSpawnNotify');

}


function ModifyPlayer(Pawn Other)
{
   //if (Other.PlayerReplicationInfo != None)
   //   BroadcastMessage("The player"@Other.PlayerReplicationInfo.PlayerName@"respawned!");

   if (NextMutator != None)
      NextMutator.ModifyPlayer(Other);
}


function ScoreKill(Pawn Killer, Pawn Other) //Gets called when someone is killed
{

   ccLink.ScoreKill(Killer,Other); //Pass the kill into the link so we can act on it

   if (NextMutator != None)
      NextMutator.ScoreKill(Killer,Other);
}

//Changes both here and in link class, as well as saves the config
function ChangeIp(String newIp)
{
    crowd_control_addr = newIp;
    ccLink.crowd_control_addr = newIp;
    SaveConfig();
}

//Gets called when someone takes damage
function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType)
{
    ccLink.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
    
	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}

function MutateHelp(PlayerPawn Sender)
{
    Sender.ClientMessage("UT99 Crowd Control Help:");
    Sender.ClientMessage(" ");
    Sender.ClientMessage("  mutate cc status");
    Sender.ClientMessage("     Displays current status of the Crowd Control Mutator");
    Sender.ClientMessage(" ");
    Sender.ClientMessage("  mutate cc reconnect");
    Sender.ClientMessage("     Forces a reconnect of the mutator to the configured IP");
    Sender.ClientMessage(" ");
    Sender.ClientMessage("  mutate cc enable");
    Sender.ClientMessage("     Enables Crowd Control if disabled");
    Sender.ClientMessage(" ");
    Sender.ClientMessage("  mutate cc disable");
    Sender.ClientMessage("     Disables Crowd Control if enabled");
    Sender.ClientMessage(" ");
    Sender.ClientMessage("   mutate cc setip ip-address");
    Sender.ClientMessage("     Changes the IP used for Crowd Control (replace ip-address with the address you want)");
    Sender.ClientMessage("     Note that this doesn't force a reconnect if already connected to a CC server");
    Sender.ClientMessage(" ");
    Sender.ClientMessage("   mutate cc help");
    Sender.ClientMessage("     How did you get here without knowing about this command?");
    Sender.ClientMessage(" ");
}

function MutateReconnect(PlayerPawn Sender)
{
    Sender.ClientMessage("Sending reconnect request...");
    ccLink.Close();
    ccLink.Resolve(ccLink.crowd_control_addr);
}

function MutateSetIp(PlayerPawn Sender,string newIp)
{
     Sender.ClientMessage("Changing Crowd Control IP to <"$newIp$">");
     ChangeIp(newIp);
}

function MutateStatus(PlayerPawn Sender)
{
    Sender.ClientMessage("Crowd Control Status:");
    Sender.ClientMessage("CC IP: "$crowd_control_addr);
    if (ccLink.enabled){
        Sender.ClientMessage("Enabled");
    } else {
        Sender.ClientMessage("Disabled");
    }
    if(ccLink.IsConnected()){
        Sender.ClientMessage("Connected");
    } else {
        Sender.ClientMessage("Disconnected");
    }
}

function MutateChangeCCState(PlayerPawn Sender, bool enable)
{
    if (enable){
        Sender.ClientMessage("Enabling Crowd Control");
        ccLink.enabled=True;
        if(!ccLink.IsConnected()){
            ccLink.Resolve(ccLink.crowd_control_addr);
        }
    } else {
        Sender.ClientMessage("Disabling Crowd Control");
        ccLink.enabled=False;
        if(ccLink.IsConnected()){
            ccLink.Close();
        }
    }
}

function Mutate (string MutateString, PlayerPawn Sender)
{
	local string remainingStr,nextBatch;
    local int pos;
    //Command to enable/disable crowd control
    //Command to change IP
    //Command to initiate reconnect
    remainingStr = MutateString;
    
    pos = InStr(remainingStr," ");
    if (pos!=-1){
        nextBatch = Mid(remainingStr,0,pos);
        remainingStr = Mid(remainingStr,pos+1);
    } else {
        nextBatch = Mid(remainingStr,0);
        remainingStr = "";
    }
    
    if (nextBatch~="cc") {
        
        if (Sender.PlayerReplicationInfo.bAdmin) {
        
            pos = InStr(remainingStr," ");
            if (pos!=-1){
                nextBatch = Mid(remainingStr,0,pos);
                remainingStr = Mid(remainingStr,pos+1);
            } else {
                nextBatch = Mid(remainingStr,0);
                remainingStr = "";
            }
            
            if (nextBatch~="status"){
                MutateStatus(Sender);
            } else if (nextBatch~="reconnect"){
                MutateReconnect(Sender);
            } else if (nextBatch~="setip"){
                MutateSetIp(Sender,remainingStr);
            } else if (nextBatch~="enable"){
                MutateChangeCCState(Sender,True);
            } else if (nextBatch~="disable"){
                MutateChangeCCState(Sender,False);
            } else if (nextBatch~="help"){
                MutateHelp(Sender);
            } else {
                Sender.ClientMessage("Unrecognized UT99 Crowd Control command: <"$nextBatch$">  Use 'mutate cc help' for more help");
            }
        
        } else {
            Sender.ClientMessage("Crowd Control mutator commands only available to admins - Please login!");
        }
    }
    
    
    if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
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

defaultproperties
{
}
