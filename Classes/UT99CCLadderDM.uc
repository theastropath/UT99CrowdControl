class UT99CCLadderDM extends UTMenu.UTLadderDM;

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
				$"?Team=255";

	Root.Console.CloseUWindow();
	if ( TournamentGameInfo(GetPlayerOwner().Level.Game) != None )
		TournamentGameInfo(GetPlayerOwner().Level.Game).LadderTransition(StartMap);
	else
		GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}

function NextPressed()
{
	local EnemyBrowser EB;
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
				StartMap(MapName, 0, "Botpack.TrainingDM");
			}
		} else {
			CloseUp();
			StartMap(MapName, 0, "Botpack.TrainingDM");
		}
	} else {
		HideWindow();
		EB = UT99CCEnemyBrowser(Root.CreateWindow(class'UT99CCEnemyBrowser', 100, 100, 200, 200, Root, True));
		EB.LadderWindow = Self;
		EB.Ladder = LadderObj.CurrentLadder;
		EB.Match = SelectedMatch;
		EB.GameType = GameType;
		EB.Initialize();
	}
}

function BackPressed()
{
	Root.CreateWindow(class'UT99CCManagerWindow', 100, 100, 200, 200, Root, True);
	Close();
}