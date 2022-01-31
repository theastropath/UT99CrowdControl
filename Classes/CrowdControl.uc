class CrowdControl extends Mutator;

var bool initialized;
var UT99CrowdControlLink ccLink;
var string crowd_control_addr;

function InitCC()
{
    if (initialized==True)
    {
        return;
    }
    
    crowd_control_addr = "127.0.0.1"; //For now
    
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
   if (Other.PlayerReplicationInfo != None)
      BroadcastMessage("The player"@Other.PlayerReplicationInfo.PlayerName@"respawned!");

   if (NextMutator != None)
      NextMutator.ModifyPlayer(Other);
}
