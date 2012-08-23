
package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.*;
	import flash.events.TouchEvent;
	import flash.geom.*;
	import flash.text.*;
    
	/**
	 * The Scrollpane element scrolls the text when event happens.
	 * It has the following parameters:squareLineStroke , squareOutLineColor, squareColor, ellipseOutLineColor, ellipseColor, ellipseLineStroke, verticalEllipseOutLineColor ,verticalEllipseColor, verticalEllipseLineStroke,bgOutLineColor, bgColor, bgLineStroke, verticalBgOutLineColor, verticalBgColor, verticalBgLineStroke ,scrollBarColor, scrollBarOutLineColor , scrollBarLineStroke , verticalScrollBarColor , verticalScrollBarOutLineColor, verticalScrollbarLineStroke, horizontal .
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var sp:ScrollPane = new ScrollPane();
	   addChild(sp);
	   sp.x = 100;
	   sp.y = 100;
	 *
	 * </codeblock>
	 * @author Uma
	 */			
		
public class ScrollPane extends Container
{
	
	/**
	* ScrollPane constructor
	*/
	public function ScrollPane():void
		{
			super();
			init();
		}
		
	/**
	* CML display initialization callback
	*/
	public override function displayComplete():void
	   {
	   super.displayComplete();
	   init();
	   }	
    
	/**
     *  Defines horizontal Scroll bar of Square.
     */
	public var scrollbar_H:TouchSprite = new TouchSprite();
	
	/**
	 * Defines Vertical scroll bar of Square.
	 */
	public var scrollbar_V:TouchSprite = new TouchSprite();
	
	/**
	 * Defines horizontal background of square.
	 */
	public var background_H:TouchSprite = new TouchSprite(); 
	
	/**
	 * Defines vertical background of square.
	 */
	public var background_V:TouchSprite = new TouchSprite(); 
	
	/**
	 *  Defines square.
	 */
	public var square:Sprite = new Sprite();
	
	/**
	 *  Defines horizontal ellipse display object of square.
	 */
	public var ell_H:Sprite = new Sprite();
	
	/**
	 * Defines vertical ellipse display object of square.
	 */
	public var ell_V:Sprite = new Sprite();   
	
	private var _squareLineStroke:Number = 3;
	/**
	 * Sets line stroke of square.
	 * @default = 3;
	 */ 
	public function get squareLineStroke():Number
	{
		return _squareLineStroke;
	}
	public function set squareLineStroke(value:Number):void
	{
		_squareLineStroke = value;
	}
	
	private var _squareOutLineColor:uint = 0xCCCCCC;
	/**
	 * Sets out line color of square.
	 * @default = 0xCCCCCC;
	 */ 
	public function get squareOutLineColor():uint
	{
		return _squareOutLineColor;
	}
	public function set squareOutLineColor(value:uint):void
	{
		_squareOutLineColor = value;
	}
	
	private var _squareColor:uint = 0x909090;
	/**
	 * Sets color of square.
	 * @default = 0x909090 ;
	 */ 
	public function get squareColor():uint
	{
		return _squareColor;
	}
	public function set squareColor(value:uint):void
	{
		_squareColor = value;
	}
	
	private var _ellipseOutLineColor:uint = 0x505050;
	/**
	 * Sets out line color of horizontal display object ellipse of square.
	 * @default = 0x505050;
	 */ 
	public function get ellipseOutLineColor():uint
	{
		return _ellipseOutLineColor;
	}
	public function set ellipseOutLineColor(value:uint):void
	{
		_ellipseOutLineColor = value;
	}
	
	private var _ellipseColor:uint = 0x000000;
	/**
	 * Sets color of horizontal display object ellipse of square.
	 * @default = 0x000000;
	 */ 
	public function get ellipseColor():uint
	{
		return _ellipseColor;
	}
	public function set ellipseColor(value:uint):void
	{
		_ellipseColor = value;
	}
	
	private var _ellipseLineStroke:Number = 3;
	/**
	 * Sets line stroke of horizontal display object ellipse of square.
	 * @default = 3;
	 */ 
	public function get ellipseLineStroke():uint
	{
		return _ellipseLineStroke;
	}
	public function set ellipseLineStroke(value:uint):void
	{
		_ellipseLineStroke = value;
	}
	
	private var _verticalEllipseOutLineColor:uint = 0x505050;
	/**
	 * Sets out line color of vertical display object ellipse of square.
	 * @default = 0x505050;
	 */ 
	public function get verticalEllipseOutLineColor():uint
	{
		return _verticalEllipseOutLineColor;
	}
	public function set verticalEllipseOutLineColor(value:uint):void
	{
		_verticalEllipseOutLineColor = value;
	}
	
	private var _verticalEllipseColor:uint = 0x000000;
	/**
	 * Sets color of vertical display object ellipse of square.
	 * @default = 0x000000;
	 */ 
	public function get verticalEllipseColor():uint
	{
		return _verticalEllipseColor;
	}
	public function set verticalEllipseColor(value:uint):void
	{
		_verticalEllipseColor = value;
	}
	
	private var _verticalEllipseLineStroke:Number = 3;
	/**
	 * Sets line stroke of vertical display object ellipse of square.
	 * @default = 3;
	 */ 
	public function get verticalEllipseLineStroke():uint
	{
		return _verticalEllipseLineStroke;
	}
	public function set verticalEllipseLineStroke(value:uint):void
	{
		_verticalEllipseLineStroke = value;
	}
		
	private var _bgOutLineColor:uint = 0x000000;
	/**
	 * Sets out line color of background of square.
	 * @default = 0x000000;
	 */ 
	public function get bgOutLineColor():uint
	{
		return _bgOutLineColor;
	}
	public function set bgOutLineColor(value:uint):void
	{
		_bgOutLineColor = value;
	}
	
	private var _bgColor:uint = 0x000000;
	/**
	 * Sets color of background of square.
	 * @default = 0x000000;
	 */ 
	public function get bgColor():uint
	{
		return _bgColor;
	}
	public function set bgColor(value:uint):void
	{
		_bgColor = value;
	}
	
	private var _bgLineStroke:Number = 3;
	/**
	 * Sets line stroke of background of square.
	 * @default = 3;
	 */ 
	public function get bgLineStroke():uint
	{
		return _bgLineStroke;
	}
	public function set bgLineStroke(value:uint):void
	{
		_bgLineStroke = value;
	}
	
	private var _verticalBgOutLineColor:uint = 0x000000;
	/**
	 * Sets out line color of vertical background of square.
	 * @default = 0x000000;
	 */ 
	public function get verticalBgOutLineColor():uint
	{
		return _verticalBgOutLineColor;
	}
	public function set verticalBgOutLineColor(value:uint):void
	{
		_verticalBgOutLineColor = value;
	}
	
	private var _verticalBgColor:uint = 0x000000;
	/**
	 * Sets color of vertical background of square.
	 * @default = 0x000000;
	 */ 
	public function get verticalBgColor():uint
	{
		return _verticalBgColor;
	}
	public function set verticalBgColor(value:uint):void
	{
		_verticalBgColor = value;
	}
	
	private var _verticalBgLineStroke:Number = 3;
	/**
	 * Sets line stroke of background of square.
	 * @default = 3;
	 */ 
	public function get verticalBgLineStroke():uint
	{
		return _verticalBgLineStroke;
	}
	public function set verticalBgLineStroke(value:uint):void
	{
		_verticalBgLineStroke = value;
	}
	
	private var _scrollBarColor:uint = 0x383838;
	/**
	 * Sets color of horizontal scrollbar of square.
	 * @default = 0x383838;
	 */ 
	public function get scrollBarColor():uint
	{
		return _scrollBarColor;
	}
	public function set scrollBarColor(value:uint):void
	{
		_scrollBarColor = value;
	}
	
	private var _scrollBarOutLineColor:uint = 0x383838;
	/**
	 * Sets out line color of horizontal scrollbar of square.
	 * @default = 0x383838;
	 */ 
	public function get scrollBarOutLineColor():uint
	{
		return _scrollBarOutLineColor;
	}
	public function set scrollBarOutLineColor(value:uint):void
	{
		_scrollBarOutLineColor = value;
	}
	
	private var _scrollBarLineStroke:Number = 3;
	/**
	 * Sets line stroke of horizontal scrollbar of square.
	 * @default = 3;
	 */ 
	public function get scrollBarLineStroke():uint
	{
		return _scrollBarLineStroke;
	}
	public function set scrollBarLineStroke(value:uint):void
	{
		_scrollBarLineStroke = value;
	}
	
	private var _verticalScrollBarColor:uint = 0x383838;
	/**
	 * Sets color of vertical scrollbar of square.
	 * @default = 0x383838;
	 */ 
	public function get verticalScrollBarColor():uint
	{
		return _verticalScrollBarColor;
	}
	public function set verticalScrollBarColor(value:uint):void
	{
		_verticalScrollBarColor = value;
	}
	
	private var _verticalScrollBarOutLineColor:uint = 0x383838;
	/**
	 * Sets out line color of horizontal scrollbar of square.
	 * @default = 0x383838;
	 */ 
	public function get verticalScrollBarOutLineColor():uint
	{
		return _verticalScrollBarOutLineColor;
	}
	public function set verticalScrollBarOutLineColor(value:uint):void
	{
		_verticalScrollBarOutLineColor = value;
	}
	
	private var _verticalScrollbarLineStroke:Number = 3;
	/**
	 * Sets line stroke of horizontal scrollbar of square.
	 * @default = 3;
	 */ 
	public function get verticalScrollbarLineStroke():uint
	{
		return _verticalScrollbarLineStroke;
	}
	public function set verticalScrollbarLineStroke(value:uint):void
	{
		_verticalScrollbarLineStroke = value;
	}
	
	private var _horizontal:Boolean = true;
	/**
	* Defines the flag for vertical or horizontal  background 
	*/
	public function get horizontal():Boolean
	{ 
	  return _horizontal;
	}
	public function set horizontal(value:Boolean):void
	{
	  _horizontal = value;
	}
	
	
	public function init():void
		{   
			displayPane();
		}
	
	/**
	*  Creates vertical or horizontal scrollbar and scrollpane
	*/
    private function displayPane():void
		{
			
	 this.mouseChildren = true;
    
	square.graphics.lineStyle(squareLineStroke, squareOutLineColor);
	square.graphics.beginFill(squareColor);
	square.graphics.drawRect(0, 0, 500 , 300);
	square.graphics.endFill();
	square.x = 100;
	square.y = 100;

	ell_H.graphics.lineStyle(ellipseLineStroke, ellipseOutLineColor);
	ell_H.graphics.beginFill(ellipseColor);
	ell_H.graphics.drawEllipse(0, 0, 700, 270);
	//ell.graphics.drawEllipse(10, 10, 475, 250);
	ell_H.graphics.endFill();
	
	square.scrollRect = new Rectangle(0 , 0 , 500 , 300);

	/*
	var txt:TextElement = new TextElement(); 
	txt.x = 20;
	txt.y = 20;
	txt.width = 450;
	txt.height = 230;
	txt.wordWrap = true;
	txt.border = true;
	txt.type = "input";
	txt.scrollRect = new Rectangle(0 , 0 , 500, 300); */
 
   	ell_V.graphics.lineStyle(verticalEllipseLineStroke, verticalEllipseOutLineColor);
	ell_V.graphics.beginFill(verticalEllipseColor);
	ell_V.graphics.drawEllipse(70, 10, 300, 470);
	ell_V.graphics.endFill();
	 
    background_H.graphics.lineStyle(bgLineStroke, bgOutLineColor); 
    background_H.graphics.beginFill(bgColor);
    background_H.graphics.drawRoundRect(0, 0, square.width, 15, 25, 30);
	background_H.graphics.endFill();
	
	//background_H.x = square.x;
	background_H.y = square.height - background_H.height;
	background_H.width = square.width;
	 
	background_V.graphics.lineStyle(verticalBgLineStroke, verticalBgOutLineColor); 
    background_V.graphics.beginFill(verticalBgColor);
    background_V.graphics.drawRoundRect(0, 0, 15, 300, 25, 30);
	background_V.graphics.endFill();
		
	background_V.x = square.width - background_V.width;
	//background_V.y = square.y;

	scrollbar_H.graphics.lineStyle(scrollBarLineStroke, scrollBarOutLineColor);  
    scrollbar_H.graphics.beginFill(scrollBarColor);
    scrollbar_H.graphics.drawRoundRect(0, 0, 100, 15, 30, 50);
	scrollbar_H.graphics.endFill();
	
	scrollbar_H.x = background_H.x;
	scrollbar_H.y = background_H.y;

	scrollbar_V.graphics.lineStyle(verticalScrollbarLineStroke, verticalScrollBarOutLineColor); 
    scrollbar_V.graphics.beginFill(verticalScrollBarColor);
    scrollbar_V.graphics.drawRoundRect(0, 0, 15, 100, 30, 50);
	scrollbar_V.graphics.endFill();
		
	scrollbar_V.x = background_V.x; 
	scrollbar_V.y = background_V.y;
	
	if (horizontal)
	{
	scrollbar_H.gestureList = { "n-drag": true };
	scrollbar_H.addEventListener(GWGestureEvent.DRAG , onDrag);
	background_H.addEventListener(TouchEvent.TOUCH_BEGIN , onBegin);
	}
	else	
	{
	scrollbar_V.gestureList = { "n-drag": true };
	scrollbar_V.addEventListener(GWGestureEvent.DRAG , onDrag);
	background_V.addEventListener(TouchEvent.TOUCH_BEGIN , onBegin);
	} 
	
	addChild(square);

	if (horizontal)
	{
	square.addChild(background_H);
	square.addChild(scrollbar_H);
	square.addChild(ell_H);
	}
	else
	{
	square.addChild(background_V);
	square.addChild(scrollbar_V);
	square.addChild(ell_V);
	} 
	
	scrollbar_HminPos = background_H.x ;
	scrollbar_HmaxPos = background_H.width - scrollbar_H.width;
	
	scrollbar_VminPos = background_V.y;
	scrollbar_VmaxPos = background_V.height - scrollbar_V.height;

}  
	private var	scrollbar_HminPos:Number;
	private var	scrollbar_HmaxPos:Number;
	private var	scrollbar_VminPos:Number;
	private var	scrollbar_VmaxPos:Number;
	
	/**
	 * Creates boundary for the scrollpane.
	 * @param	event
	 */
    private function onDrag(event:GWGestureEvent):void
	{
		 var offset:Number = 25;
		 var dx:Number = event.value.drag_dx - scrollbar_H.x;
		 var dy:Number = event.value.drag_dy - scrollbar_V.y;
			
		if (horizontal)
		{
		if ((event.value.drag_dx + event.target.x) > scrollbar_HmaxPos)
		 event.target.x = scrollbar_HmaxPos ;
		else if ((event.value.drag_dx + event.target.x) < scrollbar_HminPos)
		 event.target.x = scrollbar_HminPos;
	    else 
		 event.target.x += event.value.drag_dx;
		 ell_H.x = dx + offset;
		}
	
		else
		{
		if ((event.value.drag_dy + event.target.y) > scrollbar_VmaxPos)
		 event.target.y = scrollbar_VmaxPos ;
		else if ((event.value.drag_dy + event.target.y) < scrollbar_VminPos)
		 event.target.y = scrollbar_VminPos;
	    else 
		 event.target.y += event.value.drag_dy;
		 ell_V.y = dy;
		}	
	}	

	/**
	 * Handles horizontal or vertical touch events.
	 * @param	event
	 */
	private function onBegin(event:TouchEvent):void
    {
		 var offset:Number = 10;
		 
		 var touchX:Number = event.localX;
		 var scrollBarCenter:Number = scrollbar_H.width/2;
		 var rightBoundary:Number = background_H.width - scrollBarCenter;
		 var leftBoundary:Number = scrollBarCenter;  
	   	 	 
		 var touchY:Number = event.localY;
		 var topBoundary:Number = scrollbar_V.height/2;
		 var bottomBoundary:Number = background_V.height - scrollbar_V.height; 

		if (horizontal)
		{
		if (touchX > rightBoundary)
    	 scrollbar_H.x =  background_H.width - scrollbar_H.width;
		else if (touchX < leftBoundary)
		 scrollbar_H.x = background_H.x;
		else			 
		 scrollbar_H.x = touchX - scrollBarCenter;	
	     ell_H.x = offset - event.localX ;
		}
		
		else
		{
		if (touchY < topBoundary)
		 scrollbar_V.y = topBoundary - scrollbar_V.height/2;
		else if (touchY > bottomBoundary)
		 scrollbar_V.y = bottomBoundary;
		else
		 scrollbar_V.y = touchY - scrollbar_V.height / 2;
		 ell_V.y = offset - event.localY ;
		}
	}


}
}