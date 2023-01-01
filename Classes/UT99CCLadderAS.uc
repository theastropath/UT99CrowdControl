class UT99CCLadderAS extends UTMenu.UTLadderAS;

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
	local ObjectiveBrowser OB;

	if (PendingPos > ArrowPos)
		return;

	HideWindow();
	OB = UT99CCObjectiveBrowser(Root.CreateWindow(class'UT99CCObjectiveBrowser', 100, 100, 200, 200, Root, True));
	OB.LadderWindow = Self;
	OB.Ladder = Ladder;
	OB.Match = SelectedMatch;
	OB.GameType = GameType;
	OB.Initialize();
}

function BackPressed()
{
	Root.CreateWindow(class'UT99CCManagerWindow', 100, 100, 200, 200, Root, True);
	Close();
}