class UT99CCLadderDOM extends UTMenu.UTLadderDOM;

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
				$"?Team=0";

	Root.SetMousePos((Root.WinWidth*Root.GUIScale)/2, (Root.WinHeight*Root.GUIScale)/2);
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
function BackPressed()
{
	Root.CreateWindow(class'UT99CCManagerWindow', 100, 100, 200, 200, Root, True);
	Close();
}