class UT99CCObjectiveBrowser extends UTMenu.ObjectiveBrowser;

function StartMap(string StartMap, int Rung, string GameType)
{
	local Class<GameInfo> GameClass;

	GameClass = Class<GameInfo>(DynamicLoadObject(GameType, Class'Class'));
	GameClass.Static.ResetGame();

	StartMap = StartMap
				$"?Game="$GameType
				$"?Mutator="$class'UT99CCSettingsClientWindow'.Static.GenerateMutatorList()
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

	HideWindow();
	TB = UT99CCTeamBrowser(Root.CreateWindow(class'UT99CCTeamBrowser', 100, 100, 200, 200, Root, True));
	TB.LadderWindow = LadderWindow;
	TB.ObjectiveWindow = Self;
	TB.LadderWindow = LadderWindow;
	TB.Ladder = Ladder;
	TB.Match = Match;
	TB.GameType = GameType;
	TB.Initialize();
}
