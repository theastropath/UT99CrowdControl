class UT99CCEnemyBrowser extends UTMenu.EnemyBrowser;
function StartMap(string StartMap, int Rung, string GameType)
{
	local int Team;
	local Class<GameInfo> GameClass;

	GameClass = Class<GameInfo>(DynamicLoadObject(GameType, Class'Class'));
	GameClass.Static.ResetGame();

	if ((GameType == "Botpack.DeathMatchPlus") ||
		(GameType == "Botpack.DeathMatchPlusTest"))
		Team = 255;
	else
		Team = 0;

	StartMap = StartMap
				$"?Game="$GameType
				$"?Mutator="$class'UT99CCSettingsClientWindow'.Static.GenerateMutatorList()
				$"?Tournament="$Rung
				$"?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName
				$"?Team="$Team;

	Root.SetMousePos((Root.WinWidth*Root.GUIScale)/2, (Root.WinHeight*Root.GUIScale)/2);
	Root.Console.CloseUWindow();
	if ( TournamentGameInfo(GetPlayerOwner().Level.Game) != None )
		TournamentGameInfo(GetPlayerOwner().Level.Game).LadderTransition(StartMap);
	else
		GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}