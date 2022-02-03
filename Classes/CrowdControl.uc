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
   Level.Game.RegisterDamageMutator(self);
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

//Gets called when someone takes damage
function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType)
{
    ccLink.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
    
	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}

