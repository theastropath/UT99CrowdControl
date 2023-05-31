//======================================
// UT99CCSettingsModMenuItem: Mod Menu Item.
//======================================
class UT99CCSettingsModMenuItem expands UMenuModMenuItem;
function Execute()
{
  MenuItem.Owner.Root.CreateWindow(class'UT99CCSettingsConfigWindow',10,10,150,100);
}
defaultproperties
{
  MenuCaption="&Crowd Control Tournament Settings"
  MenuHelp="Configure what options apply to the Crowd Control Tournament"
}