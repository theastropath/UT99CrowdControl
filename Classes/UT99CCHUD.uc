class UT99CCHUD extends Mutator;

var UT99CCEffects ccEffects;

simulated event PostRender( canvas Canvas )
{
    local int numLines;
    local int effectNum;
    local int baseYPos;
    local int fontHeight;
    local string effects[15];
    local int numEffects;

    baseYPos=5*Canvas.ClipY/7 + Canvas.ClipY/401;

    if (Canvas.ClipX < 512){
        fontHeight=8;
    }else if (Canvas.ClipX < 640){
        fontHeight=16;
    }else if (Canvas.ClipX < 800){
        fontHeight=20;
    }else if (Canvas.ClipX < 1024){
        fontHeight=22;
    }else{
        fontHeight=30;
    }

    Canvas.Font = class'FontInfo'.Static.GetStaticBigFont( Canvas.ClipX );
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;

    if (ccEffects==None){
        foreach AllActors(class'UT99CCEffects',ccEffects){
            log("Found CCEffects "$ccEffects);
            break;
        }
    }
    if (ccEffects!=None){
        ccEffects.GetEffectList(effects,numEffects);
        if (numEffects>0){
            Canvas.SetPos(5, baseYPos+(numLines*fontHeight));
            Canvas.DrawText("Crowd Control Effects:");
            numLines++;
        
            for(effectNum=0;effectNum<ArrayCount(effects) && effects[effectNum]!="";effectNum++){
                Canvas.SetPos(5, baseYPos+(numLines*fontHeight));
                Canvas.DrawText(effects[effectNum]);
                numLines++;
            }
        }
    } else {
        log("ccEffects is still none!");
    }
        

    if (NextHUDMutator!=none && NextHUDMutator!=self){
        NextHUDMutator.PostRender(canvas);
    }
}