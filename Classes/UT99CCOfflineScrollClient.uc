class UT99CCOfflineScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UT99CrowdControl.UT99CCOfflineClientWindow';
		
	FixedAreaClass = None;
    
    bShowHorizSB=False;
    bShowVertSB=True;
    
	Super.Created();
}

defaultproperties
{
}