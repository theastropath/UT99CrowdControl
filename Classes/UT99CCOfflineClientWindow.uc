//================================
// UT99CCOfflineClientWindow.
//================================
class UT99CCOfflineClientWindow expands UWindowDialogClientWindow config(CrowdControl);
//var UWindowCheckBox StreamedCrowdControl,OfflineCrowdControl,Randomizer;

//var bool streamed,offline,rando;
var UWindowEditControl FrequencyEdit,ChanceEdit,NameEdit;


struct EffectControls {
    var UMenuLabelControl  NameLabel;
    var UWindowEditControl QuantMinEdit, QuantMaxEdit;
    var UWindowEditControl DurMinEdit, DurMaxEdit;
    var UWindowCheckBox EnabledEdit;
};

var EffectControls effControls[50];


function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, i;
    local float ControlOffset;
    
    local OfflineCrowdControl.EffectConfig effConfig;

    Super.Created();
    //DesiredWidth = 500;
    
    
    //ControlWidth = WinWidth/2.5;
    ControlWidth = WinWidth/10;
	ControlLeft = (WinWidth/5 - ControlWidth)/2;
	ControlRight = WinWidth/5 + ControlLeft;
    CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
    
    ControlOffset=5.0;

	FrequencyEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
	FrequencyEdit.SetText("Effect Frequency: ");
	FrequencyEdit.SetHelpText("How frequently should effects try to go off?");
	FrequencyEdit.SetFont(F_Normal);
	FrequencyEdit.SetNumericOnly(True);
	FrequencyEdit.SetNumericFloat(False);
	FrequencyEdit.SetMaxLength(3);
	FrequencyEdit.Align = TA_Left;
    FrequencyEdit.SetValue(String(class'UT99CrowdControl.OfflineCrowdControl'.Default.effectFrequency));
    ControlOffset+=20.0;	
    
    ChanceEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
	ChanceEdit.SetText("Effect Chance: ");
	ChanceEdit.SetHelpText("At every interval of the configured frequency, what percentage of the time should an effect actually be fired?");
	ChanceEdit.SetFont(F_Normal);
	ChanceEdit.SetNumericOnly(True);
	ChanceEdit.SetNumericFloat(True);
	ChanceEdit.SetMaxLength(4);
	ChanceEdit.Align = TA_Left;
    ChanceEdit.SetValue(String(class'UT99CrowdControl.OfflineCrowdControl'.Default.effectChance));
    ControlOffset+=20.0;

    NameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
	NameEdit.SetText("Mutator Name: ");
	NameEdit.SetHelpText("How should the mutator refer to itself in effects?");
	NameEdit.SetFont(F_Normal);
	NameEdit.SetNumericOnly(False);
	NameEdit.SetNumericFloat(False);
	NameEdit.Align = TA_Left;
    NameEdit.SetValue(class'UT99CrowdControl.OfflineCrowdControl'.Default.defaultMutatorName);
    ControlOffset+=20.0;
    
    //Extra spacing between main settings and effect settings
    ControlOffset+=20.0;
    
    for (i=0;i<ArrayCount(effControls);i++){
        effConfig = class'UT99CrowdControl.OfflineCrowdControl'.Static.GetEffectInfo(i);
        
        if (effConfig.EffectName==""){
            break;
        }
        
        effControls[i].NameLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl',ControlLeft, ControlOffset, WinWidth, 1));
        effControls[i].NameLabel.SetText(effConfig.EffectName);
        effControls[i].NameLabel.SetFont(F_Bold);
        ControlOffset+=20.0;
        
        if (effConfig.quantityMin!=0 && effConfig.quantityMax!=0){
            effControls[i].QuantMinEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
            effControls[i].QuantMinEdit.SetText("Min Quantity: ");
            effControls[i].QuantMinEdit.SetFont(F_Normal);
            effControls[i].QuantMinEdit.SetNumericOnly(True);
            effControls[i].QuantMinEdit.SetNumericFloat(False);
            effControls[i].QuantMinEdit.SetMaxLength(3);
            effControls[i].QuantMinEdit.Align = TA_Left;
            effControls[i].QuantMinEdit.SetValue(String(effConfig.quantityMin));
            ControlOffset+=20.0;
            
            effControls[i].QuantMaxEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
            effControls[i].QuantMaxEdit.SetText("Max Quantity: ");
            effControls[i].QuantMaxEdit.SetFont(F_Normal);
            effControls[i].QuantMaxEdit.SetNumericOnly(True);
            effControls[i].QuantMaxEdit.SetNumericFloat(False);
            effControls[i].QuantMaxEdit.SetMaxLength(3);
            effControls[i].QuantMaxEdit.Align = TA_Left;
            effControls[i].QuantMaxEdit.SetValue(String(effConfig.quantityMax));
            ControlOffset+=20.0;
        }
        
        if (effConfig.durationMin!=0 && effConfig.durationMax!=0){
            effControls[i].DurMinEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
            effControls[i].DurMinEdit.SetText("Min Duration: ");
            effControls[i].DurMinEdit.SetFont(F_Normal);
            effControls[i].DurMinEdit.SetNumericOnly(True);
            effControls[i].DurMinEdit.SetNumericFloat(False);
            effControls[i].DurMinEdit.SetMaxLength(3);
            effControls[i].DurMinEdit.Align = TA_Left;
            effControls[i].DurMinEdit.SetValue(String(effConfig.durationMin));
            ControlOffset+=20.0;
            
            effControls[i].DurMaxEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, WinWidth, 1));
            effControls[i].DurMaxEdit.SetText("Max Duration: ");
            effControls[i].DurMaxEdit.SetFont(F_Normal);
            effControls[i].DurMaxEdit.SetNumericOnly(True);
            effControls[i].DurMaxEdit.SetNumericFloat(False);
            effControls[i].DurMaxEdit.SetMaxLength(3);
            effControls[i].DurMaxEdit.Align = TA_Left;
            effControls[i].DurMaxEdit.SetValue(String(effConfig.durationMax));
            ControlOffset+=20.0;
        }
        
        effControls[i].EnabledEdit = UWindowCheckBox(CreateControl(class'UWindowCheckBox', ControlLeft, ControlOffset, winWidth, 1));
        effControls[i].EnabledEdit.SetText("Enabled: ");
        effControls[i].EnabledEdit.bChecked = False;
        effControls[i].EnabledEdit.Align = TA_Left;
        effControls[i].EnabledEdit.bChecked = effConfig.enabled;
        
        ControlOffset+=40.0;
    }
    DesiredHeight = ControlOffset;

}


function Notify(UWindowDialogControl C, byte E)
{
    local int i;
    
    if (c==FrequencyEdit) {
        class'OfflineCrowdControl'.static.SetEffectFrequency(GetPlayerOwner(),int(FrequencyEdit.GetValue()));
    } else if (c==ChanceEdit) {
        class'OfflineCrowdControl'.static.SetEffectChance(GetPlayerOwner(),float(ChanceEdit.GetValue()));
    } else if (c==NameEdit) {
        class'OfflineCrowdControl'.static.SetMutatorName(GetPlayerOwner(),NameEdit.GetValue());
    } else {
        for (i=0;i<ArrayCount(effControls);i++){
            if (C==effControls[i].EnabledEdit) {
                class'OfflineCrowdControl'.static.SetEffectEnabled(GetPlayerOwner(),i,effControls[i].EnabledEdit.bChecked);
                break;
            } else if (C==effControls[i].QuantMinEdit) {
                class'OfflineCrowdControl'.static.SetEffectQuantity(GetPlayerOwner(),i,int(effControls[i].QuantMinEdit.GetValue()),-1);
                break;            
            } else if (C==effControls[i].QuantMaxEdit) {
                class'OfflineCrowdControl'.static.SetEffectQuantity(GetPlayerOwner(),i,-1,int(effControls[i].QuantMaxEdit.GetValue()));
                break;            
            } else if (C==effControls[i].DurMinEdit) {
                class'OfflineCrowdControl'.static.SetEffectDuration(GetPlayerOwner(),i,int(effControls[i].DurMinEdit.GetValue()),-1);
                break;
            } else if (C==effControls[i].DurMaxEdit) {
                class'OfflineCrowdControl'.static.SetEffectDuration(GetPlayerOwner(),i,-1,int(effControls[i].DurMaxEdit.GetValue()));
                break;
            }
        }
    }
}


defaultproperties
{

}
