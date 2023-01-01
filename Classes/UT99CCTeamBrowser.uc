class UT99CCTeamBrowser extends UTMenu.TeamBrowser;

function NextPressed()
{
	local EnemyBrowser EB;

	HideWindow();
	EB = UT99CCEnemyBrowser(Root.CreateWindow(class'UT99CCEnemyBrowser', 100, 100, 200, 200, Root, True));
	EB.LadderWindow = LadderWindow;
	EB.TeamWindow = Self;
	EB.Ladder = Ladder;
	EB.Match = Match;
	EB.GameType = GameType;
	EB.Initialize();
}