class UT99CCLadderChal extends UTMenu.UTLadderChal;


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

	if (PendingPos > ArrowPos)
		return;

	HideWindow();
	EB = UT99CCEnemyBrowser(Root.CreateWindow(class'UT99CCEnemyBrowser', 100, 100, 200, 200, Root, True));
	EB.LadderWindow = Self;
	EB.Ladder = Ladder;
	EB.Match = SelectedMatch;
	if (SelectedMatch == 3)
		EB.GameType = "Botpack.ChallengeDMP";
	else
		EB.GameType = GameType;
	EB.Initialize();
}

function BackPressed()
{
	Root.CreateWindow(class'UT99CCManagerWindow', 100, 100, 200, 200, Root, True);
	Close();
}