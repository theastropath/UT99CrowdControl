class UT99CCLadderDM extends UTMenu.UTLadderDM;

//This only hits the tutorial... sigh
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
				$"?Team=255";

	Root.Console.CloseUWindow();
	if ( TournamentGameInfo(GetPlayerOwner().Level.Game) != None ){
		//TournamentGameInfo(GetPlayerOwner().Level.Game).LadderTransition(StartMap);
                LadderTransition(TournamentGameInfo(GetPlayerOwner().Level.Game),StartMap);
	}else{
		GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
        }
}

function LadderTransition(TournamentGameInfo i, optional string NextURL)
{
    local PlayerPawn P;

    if ( NextURL == "" )
        NextURL = "UT-Logo-Map.unr"$"?Game=Botpack.LadderTransition";
		
    if ( i.Level.NetMode == NM_Standalone )
    {
        ForEach i.AllActors( class'PlayerPawn', P)
            if ( Viewport(P.Player) != None )
            {
                P.ClientTravel( NextURL, TRAVEL_Absolute, True);
                return;
            }
    }

    i.Level.ServerTravel( NextURL, True);
    i.Level.NextSwitchCountdown = i.FMin( 0.5 * i.Level.TimeDilation, i.Level.NextSwitchCountdown);
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