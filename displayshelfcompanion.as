import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import mx.utils.ObjectUtil;
import mx.collections.*;
import mx.binding.utils.BindingUtils;
import mx.effects.*;


var rcvXML:XML = null;
var oneSecondTimer:Timer = null;

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
    
    BindingUtils.bindSetter(testFunc, shelf, "selectedIndex");
            
}
private function testFunc(value:String): void
{
    oneSecondTimer.reset();
    oneSecondTimer.start();
}

private function onTimerExpire(event:TimerEvent): void
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
    
            
    var fadeEffect:Fade = new Fade(smallpanel);
    
    fadeEffect.alphaFrom = 0.0;
    fadeEffect.alphaTo = 0.6;
    fadeEffect.play();
    
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
