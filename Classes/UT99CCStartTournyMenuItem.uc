class UT99CCStartTournyMenuItem extends UMenuModMenuItem;

function Setup()
{
    /// Called when the menu item is created
    log("UT99CCStartTournyMenuItem Setup()");
}

function Execute()
{
    local UTConsole con;

    // Called when the menu item is chosen
    log("UT99CCStartTournyMenuItem Execute()");

    con = UTConsole(MenuItem.Owner.GetPlayerOwner().Player.Console);
    if (con==None){
        log("Didn't find a UTConsole");
    } else {
        log("Found UTConsole: "$con.name);
    }
    con.InterimObjectType="UT99CrowdControl.UT99CCNewGameInterimObject";
    con.UTLadderDMClass="UT99CrowdControl.UT99CCLadderDM";
    con.UTLadderDOMClass="UT99CrowdControl.UT99CCLadderDOM";
    con.UTLadderCTFClass="UT99CrowdControl.UT99CCLadderCTF";
    con.UTLadderASClass="UT99CrowdControl.UT99CCLadderAS";
    con.UTLadderChalClass="UT99CrowdControl.UT99CCLadderChal";
    con.SlotWindowType="UT99CrowdControl.UT99CCSlotWindow";
    con.StartNewGame();
}

defaultproperties
{
    MenuCaption="Start Crowd Control Tournament"
    MenuHelp="Start a new Crowd Control Tournament"
}