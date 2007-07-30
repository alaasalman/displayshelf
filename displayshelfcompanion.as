import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import mx.utils.ObjectUtil;
import mx.collections.*;
import mx.binding.utils.BindingUtils;
import mx.effects.*;
import mx.events.*;
import flash.external.ExternalInterface;


private var rcvXML:XML = null;
private var oneSecondTimer:Timer = null;
private var fadeEffect:Fade = null;

private var fadeEffectMax:Number = 1;
private var fadeEffectMin:Number = 0;

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
    
    shelf.addEventListener("animateeffectend", onShelfIndexChanged);
    
    
    fadeEffect = new Fade(smallpanel);
    fadeEffect.addEventListener("effectEnd", onFadeEffectEnd);
    
    /* for first time display of swf, since no animation is fired */
    onShelfIndexChanged(null);
            
}
private function onShelfIndexChanged(event:EffectEvent):void
{
    oneSecondTimer.reset();
    oneSecondTimer.start();
}

private function onFadeEffectEnd(event:EffectEvent):void
{
    /* once we fade in, we have to fade out again for smooth transition. An exception is for first panel exposure */
    if(smallpanel.alpha == 0)
    {
        setSmallPanelData();
        fadeOut(smallpanel);
    }
    
    if(bigpanel.alpha == 0)
    {
        bigpanel.visible = false;
        gobacklb.visible = false;
        longdescta.visible = false;
    }
}


private function onTimerExpire(event:TimerEvent):void
{
    
           
    trace(smallpanel.alpha);
    /* first expore of panel, fade out */
    if(smallpanel.alpha == 0)
    {
        setSmallPanelData();
        fadeOut(smallpanel);
    }
    else /* not first expore, so fade in */
    {
        fadeIn(smallpanel);
    }
    
}

private function setSmallPanelData():void
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

private function setBigPanelData():void
{
    if(shelf.dataProvider.getItemAt(sel.value).attribute('linkto').toString() == "")
    {
        visitpagebiglb.enabled = false;
        visitpagebiglb.visible = false;
    }
    else
    {
        visitpagebiglb.enabled = true;
        visitpagebiglb.visible = true;
    }
    
    gobacklb.visible = true;
    
    bigpanel.title = shelf.dataProvider.getItemAt(sel.value).attribute('title');
    longdescta.text = shelf.dataProvider.getItemAt(sel.value).attribute('longdesc');
    
}
private function onReadMoreClicked(event:MouseEvent):void
{
    fadeIn(smallpanel);
    
    bigpanel.visible = true;
    gobacklb.visible = true;
    longdescta.visible = true;
    
    setBigPanelData();
    fadeOut(bigpanel);
    
    shelf.enabled = false;
    sel.enabled = false;
    sel.visible = false;
    sellabel.visible = false;
}

private function onVisitPageClicked(event:MouseEvent):void
{
    if(ExternalInterface.available)
    {
        var urlToOpen:String = shelf.dataProvider.getItemAt(sel.value).attribute('linkto').toString();
        ExternalInterface.call("window.open", urlToOpen);
    }
}

private function onGoBackClicked(event:MouseEvent):void
{
    fadeIn(bigpanel);

    shelf.enabled = true;
    sel.enabled = true;
    sel.visible = true;
}

private function fadeIn(target:Object):void
{
    fadeEffect.target = target;
    fadeEffect.alphaFrom = target.alpha;
    fadeEffect.alphaTo = fadeEffectMin;
    fadeEffect.play();
    
}

private function fadeOut(target:Object):void
{
    fadeEffect.target = target;
    fadeEffect.alphaFrom = target.alpha;
    fadeEffect.alphaTo = fadeEffectMax;
    fadeEffect.play();
}
