import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import mx.utils.ObjectUtil;
import mx.collections.*;
import mx.binding.utils.BindingUtils;
import mx.effects.*;
import mx.events.*;


var rcvXML:XML = null;
var oneSecondTimer:Timer = null;
var fadeEffect:Fade = null;

var fadeEffectMax:Number = 1;
var fadeEffectMin:Number = 0;

public function onGetPhotos(event:ResultEvent):void
{
    //trace(ObjectUtil.toString(event));
	
	rcvXML = new XML(event.result.toString());
			
			
	var xmlList:XMLList = new XMLList(rcvXML.Image);
			
    shelf.dataProvider = xmlList;
            
                        
    BindingUtils.bindProperty(shelf, "selectedIndex", sel, "value");
    BindingUtils.bindProperty(sel, "value", shelf, "selectedIndex");
            
    
    oneSecondTimer = new Timer(1000, 1);
    oneSecondTimer.addEventListener("timer", onTimerExpire);
    
    BindingUtils.bindSetter(onShelfIndexChanged, shelf, "selectedIndex");
    
    fadeEffect = new Fade(smallpanel);
    fadeEffect.addEventListener("effectEnd", onFadeEffectEnd);
            
}
private function onShelfIndexChanged(index:String): void
{
    oneSecondTimer.reset();
    oneSecondTimer.start();
}

private function onFadeEffectEnd(event:EffectEvent): void
{
    if(smallpanel.alpha == 0)
    {
        setPanelData();
        fadeEffect.alphaFrom = smallpanel.alpha;
        fadeEffect.alphaTo = fadeEffectMax;
        fadeEffect.play();
    }
}


private function onTimerExpire(event:TimerEvent): void
{
    
           
    trace(smallpanel.alpha);
    /* first expore of panel, fade from 0 to 0.6 */
    if(smallpanel.alpha == 0)
    {
        setPanelData();
        fadeEffect.alphaFrom = smallpanel.alpha;
        fadeEffect.alphaTo = fadeEffectMax;
        fadeEffect.play();
    }
    else /* not first expore, so fade from 0.6 to 0 */
    {
        fadeEffect.alphaFrom = smallpanel.alpha;
        fadeEffect.alphaTo = fadeEffectMin;
        fadeEffect.play();
    }
    
}

private function setPanelData(): void
{
    if(shelf.dataProvider.getItemAt(sel.value).attribute('longdesc').toString() == "")
    {
        readmorelb.enabled = false;
        readmorelb.visible = false;
    }
    else
    {
        readmorelb.enabled = true;
        readmorelb.visible = true;
    }
    
    if(shelf.dataProvider.getItemAt(sel.value).attribute('linkto').toString() == "")
    {
        visitpagelb.enabled = false;
        visitpagelb.visible = false;
    }
    else
    {
        visitpagelb.enabled = true;
        visitpagelb.visible = true;
    }
    
    smallpanel.title = shelf.dataProvider.getItemAt(sel.value).attribute('title');
    shortdescl.text = shelf.dataProvider.getItemAt(sel.value).attribute('shortdesc');
    
    smallpanel.x = shelf.getSelectedTile().x;
    smallpanel.y = shelf.getSelectedTile().y + shelf.getSelectedTile().height/2;
}
private function onReadMoreClicked(event:MouseEvent): void
{
    
}

private function onVisitPageClicked(event:MouseEvent): void
{
    
}

private function onGoBackClicked(event:MouseEvent): void
{
    
}
