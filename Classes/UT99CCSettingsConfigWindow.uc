//===================================================
// UT99CCSettingsConfigWindow: Actual Configuration Window.
//===================================================
class UT99CCSettingsConfigWindow expands UWindowFramedWindow;
function BeginPlay()
{
  Super.BeginPlay();
  WindowTitle = "Crowd Control Tournament Settings";
  ClientClass = class'UT99CCSettingsClientWindow';
  bSizable = False;
}
function Created()
{
  Super.Created();
  SetSize(220, 140);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}
defaultproperties
{
}