class UT99CCManagerWindow extends UTMenu.ManagerWindow
      config(user);

function Created()
{
    Super.Created();
    log("Created UT99CCManagerWindow");
}

defaultproperties
{
      LadderTypes(0)="UT99CrowdControl.UT99CCLadderDM"
      LadderTypes(1)="UT99CrowdControl.UT99CCLadderDOM"
      LadderTypes(2)="UT99CrowdControl.UT99CCLadderCTF"
      LadderTypes(3)="UT99CrowdControl.UT99CCLadderAS"
      LadderTypes(4)="UT99CrowdControl.UT99CCLadderChal"
}