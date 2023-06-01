//===================================================
// UT99CCOfflineConfigWindow: Actual Configuration Window.
//===================================================
class UT99CCOfflineConfigWindow expands UWindowFramedWindow;
function BeginPlay()
{
  Super.BeginPlay();
  WindowTitle = "Offline Crowd Control Settings";
  //ClientClass = class'UT99CCOfflineClientWindow';
  ClientClass = class'UT99CrowdControl.UT99CCOfflineScrollClient';
  bSizable = False;
}
function Created()
{
  Super.Created();
  SetSize(300, 600);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}
defaultproperties
{
}