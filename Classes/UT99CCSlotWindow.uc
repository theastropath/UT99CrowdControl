class UT99CCSlotWindow extends UTMenu.SlotWindow;

function RestoreGame(int i)
{
	local LadderInventory LadderObj;
	local string Temp, Name, PlayerSkin;
	local Class<TournamentPlayer> PlayerClass;
	local int Pos, Team, Face;

	if (Saves[i] == "")
		return;

	// Check ladder object.
	LadderObj = LadderInventory(GetPlayerOwner().FindInventoryType(class'LadderInventory'));
	if (LadderObj == None)
	{
		// Make them a ladder object.
		LadderObj = GetPlayerOwner().Spawn(class'LadderInventory');
		LadderObj.GiveTo(GetPlayerOwner());
	}

	// Fill the ladder object.

	// Slot...
	LadderObj.Slot = i;

	// Difficulty...
	LadderObj.TournamentDifficulty = int(Left(Saves[i], 1));
	LadderObj.SkillText = class'NewCharacterWindow'.Default.SkillText[LadderObj.TournamentDifficulty];

	// Team
	Temp = Right(Saves[i], Len(Saves[i]) - 2);
	Pos = InStr(Temp, "\\");
	Team = int(Left(Temp, Pos));
	LadderObj.Team = class'Ladder'.Default.LadderTeams[Team];

	// DMRank
	Temp = Right(Saves[i], Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DMRank = int(Left(Temp, Pos));

	// DMPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DMPosition = int(Left(Temp, Pos));

	// DOMRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DOMRank = int(Left(Temp, Pos));

	// DOMPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.DOMPosition = int(Left(Temp, Pos));

	// CTFRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.CTFRank = int(Left(Temp, Pos));

	// CTFPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.CTFPosition = int(Left(Temp, Pos));

	// ASRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ASRank = int(Left(Temp, Pos));

	// ASPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ASPosition = int(Left(Temp, Pos));

	// ChalRank
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ChalRank = int(Left(Temp, Pos));

	// ChalPosition
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.ChalPosition = int(Left(Temp, Pos));

	// Sex
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	LadderObj.Sex = Left(Temp, Pos);

	// Face
	Temp = Right(Temp, Len(Temp) - Pos - 1);
	Pos = InStr(Temp, "\\");
	Face = int(Left(Temp, Pos));
	LadderObj.Face = Face;

	// Name
	Temp = Right(Temp, Len(Temp) - 2);
	Name = Temp;
	GetPlayerOwner().ChangeName(Name);
	GetPlayerOwner().UpdateURL("Name", Name, True);

	if (LadderObj.Sex ~= "M")
	{
		PlayerClass = LadderObj.Team.static.GetMaleClass();
		PlayerSkin = LadderObj.Team.Default.MaleSkin;
	} else {
		PlayerClass = LadderObj.Team.static.GetFemaleClass();
		PlayerSkin = LadderObj.Team.Default.FemaleSkin;
	}

	IterateFaces(PlayerSkin, GetPlayerOwner().GetItemName(string(PlayerClass.Default.Mesh)));
	GetPlayerOwner().UpdateURL("Class", string(PlayerClass), True);
	GetPlayerOwner().UpdateURL("Skin", PlayerSkin, True);
	GetPlayerOwner().UpdateURL("Face", Faces[Face], True);
	GetPlayerOwner().UpdateURL("Voice", PlayerClass.Default.VoiceType, True);
	GetPlayerOwner().UpdateURL("Team", "255", True);

	// Goto Manager
	HideWindow();
	Root.CreateWindow(class'UT99CrowdControl.UT99CCManagerWindow', 100, 100, 200, 200, Root, True);
}