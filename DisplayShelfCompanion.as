/*
Portions Copyright (c) 2007 Alaa Salman
Copyright (c) 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

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

/* 
 * Called when the rpc call is done. This takes care of the inialization as well.
 * Although this is not good practice in general, in our case is does the job well
 * considering that we only use this helper and that this whole flow is dependant on
 * the rpc call.
 */ 
public function onGetPhotos(event:ResultEvent):void
{
    rcvXML = new XML(event.result.toString());

	var xmlList:XMLList = new XMLList(rcvXML.Image);

    shelf.dataProvider = xmlList;
            
    BindingUtils.bindProperty(shelf, "selectedIndex", sel, "value");
    BindingUtils.bindProperty(sel, "value", shelf, "selectedIndex");
            
    
    oneSecondTimer = new Timer(1000, 1);
    oneSecondTimer.addEventListener("timer", onTimerExpire);
    
    shelf.addEventListener("animateeffectend", onAnimationEnd);
    
    
    fadeEffect = new Fade(smallpanel);
    fadeEffect.addEventListener("effectEnd", onFadeEffectEnd);
    
       
    shelf.addEventListener("change", onIndexChanged);
    
    /* for first time display of swf, since no change is fired */
    onAnimationEnd(null);
}

/* Index change event handler. */
private function onIndexChanged(event:Event):void
{
    oneSecondTimer.reset();
    fadeIn(smallpanel);
}

/* 
 * When the user selects a different image, we need to start the 
 * 1 second timer.
 */ 
private function onAnimationEnd(event:EffectEvent):void
{
    oneSecondTimer.reset();
    oneSecondTimer.start();
}

/*
 * Fade effect end event handler. We need this to properly set the other components.
 * Setting them after the fadeout is done makes them visually smoother.
 */
private function onFadeEffectEnd(event:EffectEvent):void
{
    /* once we fade in, we have to fade out again for smooth transition. An exception is for first panel exposure */
    
    if(bigpanel.alpha == 0)
    {
        bigpanel.visible = false;
        gobacklb.visible = false;
        longdescta.visible = false;
    }
}

/*Timer expire event handler */
private function onTimerExpire(event:TimerEvent):void
{
    /* first expose of panel, fade out */
    if(smallpanel.alpha == 0)
    {
        fadeOut(smallpanel);
        setSmallPanelData();
    }
    else /* not first expore, so fade in */
    {
        fadeIn(smallpanel);
    }
    
    /* call javascript function if calljs flash is set to true */
    if(Application.application.parameters.calljs == "true")
    {
        /* and check if javacall is there */
        if(shelf.dataProvider.getItemAt(sel.value).attribute('javacall').toString() != "")
        {
            /* In summary, we separate the function name and parameter list using String operations.
             * These are hardcoded since the structure is pretty much defined by js. Then we use 
             * the extraced function name and parameter list and call the js function passing the params
             * as a single string for the js function to do the parsing
             */ 
             
            var jsFunctionInXml:String = shelf.dataProvider.getItemAt(sel.value).attribute('javacall').toString();
            var functionParameters:String = jsFunctionInXml.substring(jsFunctionInXml.indexOf("(") + 1, jsFunctionInXml.length - 1);
            var functionName:String = jsFunctionInXml.substring(0, jsFunctionInXml.indexOf("("));
            var functionParametersArray:Array = functionParameters.split(",");
                        
            ExternalInterface.call(functionName, functionParametersArray);
        }
    }
    
}

/*
 * This is used to set some components on the small panel that depend
 * on the structure of the xml received.
 */ 
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
    
    smallpaneltitle.text = shelf.dataProvider.getItemAt(sel.value).attribute('title');
    
    
    shortdescl.text = shelf.dataProvider.getItemAt(sel.value).attribute('shortdesc');
    
    
    smallpanel.x = shelf.getSelectedTile().x;
    smallpanel.y = shelf.getSelectedTile().y + shelf.getSelectedTile().height/2;
    
    visitpagelb.x = smallpanelhbox.width - visitpagelb.width;
    smallpanel.validateNow();
    
}

/*
 * This is used to set some components on the big panel that depend
 * on the structure of the xml received.
 */
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
    
    bigpaneltitle.text = shelf.dataProvider.getItemAt(sel.value).attribute('title');
    longdescta.text = shelf.dataProvider.getItemAt(sel.value).attribute('longdesc');
    
    visitpagebiglb.x = bigpanelhbox.width - visitpagebiglb.width;

}

/*Read More event handler */
private function onReadMoreClicked(event:MouseEvent):void
{
    /* 
     * Fade in the small panel and 'visible-ize' the big panel with a fade out.
     * We also disable the displayshelf and selection slider.
     */
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

/*Visit Page event handler.*/
private function onVisitPageClicked(event:MouseEvent):void
{
    if(ExternalInterface.available)
    {
        /*get url passed in xml */
        var urlToOpen:String = shelf.dataProvider.getItemAt(sel.value).attribute('linkto').toString();
        
        /*a shortcut to open a new window with the url provided */
        ExternalInterface.call("window.open", urlToOpen);
    }
}

/*Go Back event handler */
private function onGoBackClicked(event:MouseEvent):void
{
    fadeIn(bigpanel);

    /*disable shelf along with selection slider.*/
    shelf.enabled = true;
    sel.enabled = true;
    
    /*We also have to hide it because for some strange reason, it shows up over the panel */
    sel.visible = true;
    sellabel.visible = true;
    fadeOut(smallpanel);
}

/* Utility function to fadeIn an object. */
private function fadeIn(target:Object):void
{
    fadeEffect.target = target;
    fadeEffect.alphaFrom = target.alpha;
    fadeEffect.alphaTo = fadeEffectMin;
    fadeEffect.play();
}

/* Utility function to fadeOut an object. */
private function fadeOut(target:Object):void
{
    fadeEffect.target = target;
    fadeEffect.alphaFrom = target.alpha;
    fadeEffect.alphaTo = fadeEffectMax;
    fadeEffect.play();
}
