class CrowdControl extends Mutator config(CrowdControl);

var bool initialized;
var UT99CrowdControlLink ccLink;
var config string crowd_control_addr;

function InitCC()
{
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

function PreBeginPlay()
{
   initialized = False;
   InitCC();
}

function ModifyPlayer(Pawn Other)
{
   //if (Other.PlayerReplicationInfo != None)
   //   BroadcastMessage("The player"@Other.PlayerReplicationInfo.PlayerName@"respawned!");

   if (NextMutator != None)
      NextMutator.ModifyPlayer(Other);
}
