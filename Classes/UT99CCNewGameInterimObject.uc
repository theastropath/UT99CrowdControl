class UT99CCNewGameInterimObject extends UTMenu.NewGameInterimObject;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    log("UT99CCNewGameInterimObject PostBeginPlay");
}

defaultproperties
{
      GameWindowType="UT99CrowdControl.UT99CCNewCharacterWindow"
}