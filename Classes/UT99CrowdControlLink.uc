class UT99CrowdControlLink extends TcpLink transient;

var string crowd_control_addr;
var CrowdControl ccModule;
var UT99CCEffects ccEffects;

var int ListenPort;
var IpAddr addr;
var int ticker;
var int reconnectTimer;
var string pendingMsg;
var bool enabled;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CrowdControlPort = 43384;

const ReconDefault = 5;


function Init(CrowdControl cc, string addr)
{
    
    ccModule = cc;
    crowd_control_addr = addr; 
    enabled = True;
    
    ccEffects = Spawn(class'UT99CCEffects');
    ccEffects.Init(self);
    
    //Initialize the pending message buffer
    pendingMsg = "";
    
    //Initialize the ticker
    ticker = 0;

    Resolve(crowd_control_addr);

    reconnectTimer = ReconDefault;
    SetTimer(0.1,True);

}

function Timer() {
    
    ticker++;
    if (IsConnected()) {
        if (enabled){
            ManualReceiveBinary();
        }
    }
    
    ccEffects.ContinuousUpdates();
    
    if (ticker%10 != 0) {
        return;
    }

    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            if (enabled){
                Resolve(crowd_control_addr);
            }
        }
    }
    
    ccEffects.PeriodicUpdates();

}

//Called every time there is a kill
function ScoreKill(Pawn Killer,Pawn Other)
{
    ccEffects.ScoreKill(Killer,Other);
}


//Called every time damage is dealt
function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, 
						out Vector Momentum, name DamageType)
{
    ccEffects.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}

function handleMessage(string msg) {

    local int id,type;
    local string code,viewer;
    local string param[5];

    local int result;

    local Json jmsg;
    local int i;

    if (isCrowdControl(msg)) {
        jmsg = class'Json'.static.parse(Level, msg);
        code = jmsg.get("code");
        viewer = jmsg.get("viewer");
        id = int(jmsg.get("id"));
        type = int(jmsg.get("type"));
        // maybe a little cleaner than using get_vals and having to worry about matching the array sizes?
        for(i=0; i<ArrayCount(param); i++) {
            param[i] = jmsg.get("parameters", i);
        }

        result = ccEffects.doCrowdControlEvent(code,param,viewer,type);

        sendReply(id,result);

    } else {
        ccModule.BroadCastMessage("Got a weird message: "$msg);
    }

}

function bool isCrowdControl( string msg) {
    local string tmp;
    //Validate if it looks json-like
    if (InStr(msg,"{")!=0){
        //PlayerMessage("Message doesn't start with curly");
        return False;
    }
    
    //Explicitly check last character of string to see if it's a closing curly
    tmp = Mid(msg,Len(msg)-1,1);
    //if (InStr(msg,"}")!=Len(msg)-1){
    if (tmp != "}"){
        //PlayerMessage("Message doesn't end with curly.  Ends with '"$tmp$"'.");
        return False;    
    }
    
    //Check to see if it looks like it has the right fields in it
    
    //id field
    if (InStr(msg,"id")==-1){
        //PlayerMessage("Doesn't have id");
        return False;
    }
    
    //code field
    if (InStr(msg,"code")==-1){
        //PlayerMessage("Doesn't have code");
        return False;
    }
    //viewer field
    if (InStr(msg,"viewer")==-1){
        //PlayerMessage("Doesn't have viewer");
        return False;
    }

    return True;
}

function sendReply(int id, int status) {
    local string resp;
    local byte respbyte[255];
    local int i;
    
    resp = "{\"id\":"$id$",\"status\":"$status$"}"; 
    
    for (i=0;i<Len(resp);i++){
        respbyte[i]=Asc(Mid(resp,i,1));
    }
    
    //PlayerMessage(resp);
    SendBinary(Len(resp)+1,respbyte);
}


//I cannot believe I had to manually write my own version of ReceivedBinary
function ManualReceiveBinary() {
    local byte B[255]; //I have to use a 255 length array even if I only want to read 1
    local int count,i;
    //PlayerMessage("Manually reading, have "$DataPending$" bytes pending");
    
    if (DataPending!=0) {
        count = ReadBinary(255,B);
        for (i = 0; i < count; i++) {
            if (B[i] == 0) {
                if (Len(pendingMsg)>0){
                    handleMessage(pendingMsg);
                }
                pendingMsg="";
            } else {
                pendingMsg = pendingMsg $ Chr(B[i]);
                //PlayerMessage("ReceivedBinary: " $ B[i]);
            }
        }
    }
    
}
event Opened(){
    ccModule.BroadCastMessage("Crowd Control connection opened");
}

event Closed(){
    ccModule.BroadCastMessage("Crowd Control connection closed");
    ListenPort = 0;
    reconnectTimer = ReconDefault;
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

function Resolved( IpAddr Addr )
{
    if (ListenPort == 0) {
        ListenPort=BindPort();
        if (ListenPort==0){
            ccModule.BroadCastMessage("Failed to bind port for Crowd Control");
            reconnectTimer = ReconDefault;
            return;
        }   
    }

    Addr.port=CrowdControlPort;
    if (False==Open(Addr)){
        ccModule.BroadCastMessage("Could not connect to Crowd Control client");
        reconnectTimer = ReconDefault;
        return;

    }

    //Using manual binary reading, which is handled by ManualReceiveBinary()
    //This means that we can handle if multiple crowd control messages come in
    //between reads.
    LinkMode=MODE_Binary;
    ReceiveMode = RMODE_Manual;

}
function ResolveFailed()
{
    ccModule.BroadCastMessage("Could not resolve Crowd Control address");
    reconnectTimer = ReconDefault;
}