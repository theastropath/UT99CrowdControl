class UT99CCLadderDOM extends UTMenu.UTLadderDOM;

//This only hits the tutorial... sigh
function StartMap(string StartMap, int Rung, string GameType)
{
	local Class<GameInfo> GameClass;

	GameClass = Class<GameInfo>(DynamicLoadObject(GameType, Class'Class'));
	GameClass.Static.ResetGame();

	StartMap = StartMap
				$"?Game="$GameType
				$"?Mutator=UT99CrowdControl.CrowdControl"
				$"?Tournament="$Rung
				$"?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName
				$"?Team=0";

	Root.SetMousePos((Root.WinWidth*Root.GUIScale)/2, (Root.WinHeight*Root.GUIScale)/2);
	Root.Console.CloseUWindow();
	if ( TournamentGameInfo(GetPlayerOwner().Level.Game) != None )
		TournamentGameInfo(GetPlayerOwner().Level.Game).LadderTransition(StartMap);
	else
		GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}


function NextPressed()
{
	local TeamBrowser TB;
	local string MapName;

	if (PendingPos > ArrowPos)
		return;

	if (SelectedMatch == 0)
	{
		MapName = LadderObj.CurrentLadder.Default.MapPrefix$Ladder.Static.GetMap(0);
		if (class'UTLadderStub'.Static.IsDemo())
		{
			if (class'UTLadderStub'.Static.DemoHasTuts())
			{
				CloseUp();
				StartMap(MapName, 0, "Botpack.TrainingDOM");
			}
		} else {
			CloseUp();
			StartMap(MapName, 0, "Botpack.TrainingDOM");
		}
	} else {
		if (LadderObj.CurrentLadder.Default.DemoDisplay[SelectedMatch] == 1)
			return;

		HideWindow();
		TB = UT99CCTeamBrowser(Root.CreateWindow(class'UT99CCTeamBrowser', 100, 100, 200, 200, Root, True));
		TB.LadderWindow = Self;
		TB.Ladder = LadderObj.CurrentLadder;
		TB.Match = SelectedMatch;
		TB.GameType = GameType;
		TB.Initialize();
	}
}

function BackPressed()
{
	Root.CreateWindow(class'UT99CCManagerWindow', 100, 100, 200, 200, Root, True);
	Close();
}