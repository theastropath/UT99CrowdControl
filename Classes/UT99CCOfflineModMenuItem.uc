//======================================
// UT99CCOfflineModMenuItem: Mod Menu Item.
//======================================
class UT99CCOfflineModMenuItem expands UMenuModMenuItem;
function Execute()
{
  MenuItem.Owner.Root.CreateWindow(class'UT99CCOfflineConfigWindow',10,10,200,500);
}
defaultproperties
{
  MenuCaption="&Offline Crowd Control Settings"
  MenuHelp="Configure the Offline Crowd Control mutator"
}