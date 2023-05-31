//================================
// UT99CCSettingsClientWindow.
//================================
class UT99CCSettingsClientWindow expands UWindowDialogClientWindow config(CrowdControl);
var UWindowCheckBox StreamedCrowdControl,OfflineCrowdControl,Randomizer;

var config bool streamed,offline,rando;

function Created()
{
  StreamedCrowdControl = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 15, 150, 1));
  StreamedCrowdControl.SetText("Streaming Crowd Control: ");
  StreamedCrowdControl.bChecked = streamed;
  
  OfflineCrowdControl = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 35, 150, 1));
  OfflineCrowdControl.SetText("Offline Crowd Control: ");
  OfflineCrowdControl.bChecked = offline;
  
  Randomizer = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 55, 150, 1));
  Randomizer.SetText("Randomizer: ");
  Randomizer.bChecked = rando;
}


function Notify(UWindowDialogControl C, byte E)
{
    switch(E) {
        case DE_Change: // the message sent by sliders and checkboxes
            switch(C) {
                case StreamedCrowdControl:
                    streamed=StreamedCrowdControl.bChecked;
                    break;
                case OfflineCrowdControl:
                    offline=OfflineCrowdControl.bChecked;
                    break;
                case Randomizer:
                    rando=Randomizer.bChecked;
                    break;
            }
    }
    SaveConfig();
}

static function String GenerateMutatorList()
{
    local string mutList;
    local bool added;
    
    added = False;
    mutList = "";
    
    if (class'UT99CCSettingsClientWindow'.Default.streamed){
        added=True;
        mutList$="UT99CrowdControl.CrowdControl";
    }
    
    if (class'UT99CCSettingsClientWindow'.Default.offline){
        if(added){
            mutList$=",";
        }
        mutList$="UT99CrowdControl.OfflineCrowdControl";
        added=True;
    }
    if (class'UT99CCSettingsClientWindow'.Default.rando){
        if(added){
            mutList$=",";
        }
        mutList$="UT99CrowdControl.Randomizer";
        added=True;
    }
    
    return mutList;
    
}

defaultproperties
{
    streamed=True
    offline=False
    rando=False
}
