class UT99CCNewCharacterWindow extends UTMenu.NewCharacterWindow;

function NextPressed()
{
	local ManagerWindow ManagerWindow;

	if (LadderObj.Sex ~= "F")
	{
		SexButton.Text = MaleText;
	} else {
		SexButton.Text = FemaleText;
	}
	SexPressed();

	// Go to the ladder selection screen.
	LadderObj.DMRank = 0;
	LadderObj.DMPosition = -1;
	LadderObj.CTFRank = 0;
	LadderObj.CTFPosition = -1;
	LadderObj.DOMRank = 0;
	LadderObj.DOMPosition = -1;
	LadderObj.ASRank = 0;
	LadderObj.ASPosition = -1;
	LadderObj.ChalRank = 0;
	LadderObj.ChalPosition = 0;

	LadderObj = None;
	Super.Close();
	ManagerWindow = ManagerWindow(Root.CreateWindow(class'UT99CrowdControl.UT99CCManagerWindow', 100, 100, 200, 200, Root, True));
}