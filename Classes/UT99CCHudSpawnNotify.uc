class UT99CCHudSpawnNotify extends SpawnNotify;

replication
{
    reliable if (Role==ROLE_Authority)
        AddHUDMutator;
}

simulated function PreBeginPlay()
{
  local HUD h;

  Super.PreBeginPlay();

  foreach AllActors(class'Engine.HUD',h){
    log("HUD "$h$" already exists, let's add the CC HUD to that");
    AddHUDMutator(h);
  }
}

simulated function AddHUDMutator(Actor A)
{
    local UT99CCHud h;
    log("Spawn notified! "$A);
    h=Spawn(class'UT99CrowdControl.UT99CCHud',A);
    if ( HUD(A).HUDMutator == none)
    {
        HUD(A).HUDMutator = h;
    }
    else
    {
        HUD(A).HUDMutator.AddMutator(h);
    }
}

simulated event Actor SpawnNotification( Actor A )
{
    AddHUDMutator(A);
    return A;
}

defaultproperties
{
    ActorClass=class'Engine.HUD'
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=False
}
