
package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.core.GestureWorks;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.*;
	import flash.text.*;
	import org.tuio.TuioTouchEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
    
	/**
	 * ScrollPane scrolls the text or image and allows the user to change the scrollbar location and set the path of image through the imageUrl attribute.
	 * By default has vertical and horizontal scrollbar and these locations can be changed by setting the horizontal or vertical flag to true or false.
	 * The text or image scrolls horizontally or vertically through the touch events.
	 * It has the following parameters:squareLineStroke , squareOutlineColor, squareColor,bgOutLineColor, bgColor, bgLineStroke, verticalBgOutLineColor, bgWidth, vBgHeight, verticalBgColor, verticalBgLineStroke ,scrollBarColor, scrollBarOutLineColor , scrollBarLineStroke , verticalScrollBarColor , verticalScrollBarOutLineColor, verticalScrollbarLineStroke,squareWidth, squareHeight, bgX, bgY, bgHeight, bgEllipseHeight, bgEllipseWidth, vBgX, vBgY, vBgwidth, vBgEllipseWidth, vBgEllipseHeight ,scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, scrollbarEllipseHeight, scrollbarEllipseWidth, vScrollbarX, vScrollbarY, vScrollbarWidth, vScrollbarHeight, vScrollbarEllipseWidth, vScrollbarEllipseHeight, horizontal .
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
		//	init();
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
	
	private var _squareOutlineColor:uint = 0xCCCCCC;
	/**
	 * Sets out line color of square.
	 * @default = 0xCCCCCC;
	 */ 
	public function get squareOutlineColor():uint
	{
		return _squareOutlineColor;
	}
	public function set squareOutlineColor(value:uint):void
	{
		_squareOutlineColor = value;
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
		
	private var _bgOutlineColor:uint = 0x000000;
	/**
	 * Sets out line color of background of square.
	 * @default = 0x000000;
	 */ 
	public function get bgOutlineColor():uint
	{
		return _bgOutlineColor;
	}
	public function set bgOutlineColor(value:uint):void
	{
		_bgOutlineColor = value;
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
	
	private var _verticalBgOutlineColor:uint = 0x000000;
	/**
	 * Sets out line color of vertical background of square.
	 * @default = 0x000000;
	 */ 
	public function get verticalBgOutlineColor():uint
	{
		return _verticalBgOutlineColor;
	}
	public function set verticalBgOutlineColor(value:uint):void
	{
		_verticalBgOutlineColor = value;
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
	
	private var _scrollBarOutlineColor:uint = 0x383838;
	/**
	 * Sets out line color of horizontal scrollbar of square.
	 * @default = 0x383838;
	 */ 
	public function get scrollBarOutlineColor():uint
	{
		return _scrollBarOutlineColor;
	}
	public function set scrollBarOutlineColor(value:uint):void
	{
		_scrollBarOutlineColor = value;
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
	
	private var _verticalScrollBarOutlineColor:uint = 0x383838;
	/**
	 * Sets out line color of horizontal scrollbar of square.
	 * @default = 0x383838;
	 */ 
	public function get verticalScrollBarOutlineColor():uint
	{
		return _verticalScrollBarOutlineColor;
	}
	public function set verticalScrollBarOutlineColor(value:uint):void
	{
		_verticalScrollBarOutlineColor = value;
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
	
	private var _squareWidth:Number = 600;
	/**
	* Sets the square width
	* @default = 600;
	*/
	public function get squareWidth():Number
	{
	 return _squareWidth;
	}
		
	public function set squareWidth(value:Number):void
	{
	 _squareWidth = value;
	}
	
	private var _squareHeight:Number = 600;
	/**
	* Sets the square height  
	* @default = 600;
	*/
	public function get squareHeight():Number
	{
	 return _squareHeight;
	}
		
	public function set squareHeight(value:Number):void
	{
	 _squareHeight = value;
	}
	
	private var _bgX:Number = 0;
	/**
	* Sets the horizontal background x position
	* @default = 0;
	*/
	public function get bgX():Number
	{
	 return _bgX;
	}
		
	public function set bgX(value:Number):void
	{
	 _bgX = value;
	}
	
	private var _bgY:Number = 605;
	/**
	* Sets the horizontal background y position
	* @default = 0;
	*/
	public function get bgY():Number
	{
	 return _bgY;
	}
		
	public function set bgY(value:Number):void
	{
	 _bgY = value;
	}
	
	private var _bgHeight:Number = 15;
	/**
	* Sets the horizontal background y position
	* @default = 0;
	*/
	public function get bgHeight():Number
	{
	 return _bgHeight;
	}
		
	public function set bgHeight(value:Number):void
	{
	 _bgHeight = value;
	}
	
	private var _bgWidth:Number = 600;
	/**
	* Sets the horizontal background width
	* @default = 600;
	*/
	public function get bgWidth():Number
	{
	 return _bgWidth;
	}
		
	public function set bgWidth(value:Number):void
	{
	 _bgWidth = value;
	}
	
	private var _bgEllipseHeight:Number = 30;
	/**
	* Sets the horizontal background y position
	* @default = 0;
	*/
	public function get bgEllipseHeight():Number
	{
	 return _bgEllipseHeight;
	}
		
	public function set bgEllipseHeight(value:Number):void
	{
	 _bgEllipseHeight = value;
	}
	
	private var _bgEllipseWidth:Number = 20;
	/**
	* Sets the horizontal background y position
	* @default = 0;
	*/
	public function get bgEllipseWidth():Number
	{
	 return _bgEllipseWidth;
	}
		
	public function set bgEllipseWidth(value:Number):void
	{
	 _bgEllipseWidth = value;
	}
		
	private var _vBgX:Number = 605;
	/**
	* Sets the vertical background x position
	* @default = 0;
	*/
	public function get vBgX():Number
	{
	 return _vBgX;
	}
		
	public function set vBgX(value:Number):void
	{
	 _vBgX = value;
	}
	
	private var _vBgY:Number = 0;
	/**
	* Sets the vertical background y position
	* @default = 0;
	*/
	public function get vBgY():Number
	{
	 return _vBgY;
	}
		
	public function set vBgY(value:Number):void
	{
	 _vBgY = value;
	}
	
	private var _vBgWidth:Number = 15;
	/**
	* Sets the vertical background width
	* @default = 0;
	*/
	public function get vBgWidth():Number
	{
	 return _vBgWidth;
	}
		
	public function set vBgWidth(value:Number):void
	{
	 _vBgWidth = value;
	}
	
	private var _vBgHeight:Number = 600;
	/**
	* Sets the vertical background width
	* @default = 600;
	*/
	public function get vBgHeight():Number
	{
	 return _vBgHeight;
	}
		
	public function set vBgHeight(value:Number):void
	{
	 _vBgHeight = value;
	}
	
	private var _vBgEllipseWidth:Number = 30;
	/**
	* Sets the vertical background ellipse width
	* @default = 0;
	*/
	public function get vBgEllipseWidth():Number
	{
	 return _vBgEllipseWidth;
	}
		
	public function set vBgEllipseWidth(value:Number):void
	{
	 _vBgEllipseWidth = value;
	}
	
	private var _vBgEllipseHeight:Number = 20;
	/**
	* Sets the vertical background ellipse height
	* @default = 0;
	*/
	public function get vBgEllipseHeight():Number
	{
	 return _vBgEllipseHeight;
	}
		
	public function set vBgEllipseHeight(value:Number):void
	{
	 _vBgEllipseHeight = value;
	}
	
	private var _scrollbarX:Number = 0;
	/**
	* Sets the scrollbar x position of background
	* @default = 0;
	*/
	public function get scrollbarX():Number
	{
	 return _scrollbarX;
	}
		
	public function set scrollbarX(value:Number):void
	{
	 _scrollbarX = value;
	}
	
	private var _scrollbarY:Number = 605;
	/**
	* Sets the scrollbar y position of background
	* @default = 0;
	*/
	public function get scrollbarY():Number
	{
	 return _scrollbarY;
	}
		
	public function set scrollbarY(value:Number):void
	{
	 _scrollbarY = value;
	}
	
	private var _scrollbarWidth:Number = 100;
	/**
	* Sets the scrollbar width of background
	* @default = 100;
	*/
	public function get scrollbarWidth():Number
	{
	 return _scrollbarWidth;
	}
		
	public function set scrollbarWidth(value:Number):void
	{
	 _scrollbarWidth = value;
	}
	
	private var _scrollbarHeight:Number = 15;
	/**
	* Sets the scrollbar height of background
	* @default = 15;
	*/
	public function get scrollbarHeight():Number
	{
	 return _scrollbarHeight;
	}
		
	public function set scrollbarHeight(value:Number):void
	{
	 _scrollbarHeight = value;
	}
	
	private var _scrollbarEllipseHeight:Number = 30;
	/**
	* Sets the scrollbar ellipse height of background
	* @default = 50;
	*/
	public function get scrollbarEllipseHeight():Number
	{
	 return _scrollbarEllipseHeight;
	}
		
	public function set scrollbarEllipseHeight(value:Number):void
	{
	 _scrollbarEllipseHeight = value;
	}
	
	private var _scrollbarEllipseWidth:Number = 20;
	/**
	* Sets the scrollbar ellipse width of background
	* @default = 50;
	*/
	public function get scrollbarEllipseWidth():Number
	{
	 return _scrollbarEllipseWidth;
	}
		
	public function set scrollbarEllipseWidth(value:Number):void
	{
	 _scrollbarEllipseWidth = value;
	}
	
	private var _vScrollbarX:Number = 605;
	/**
	* Sets the vertical scrollbar x position of background
	* @default = 0;
	*/
	public function get vScrollbarX():Number
	{
	 return _vScrollbarX;
	}
		
	public function set vScrollbarX(value:Number):void
	{
	 _vScrollbarX = value;
	}
	
	private var _vScrollbarY:Number = 0;
	/**
	* Sets the vertical scrollbar y position of background
	* @default = 0;
	*/
	public function get vScrollbarY():Number
	{
	 return _vScrollbarY;
	}
		
	public function set vScrollbarY(value:Number):void
	{
	 _vScrollbarY = value;
	}
	
	private var _vScrollbarWidth:Number = 15;
	/**
	* Sets the vertical scrollbar width of background
	* @default = 15;
	*/
	public function get vScrollbarWidth():Number
	{
	 return _vScrollbarWidth;
	}
		
	public function set vScrollbarWidth(value:Number):void
	{
	 _vScrollbarWidth = value;
	}
	
	private var _vScrollbarHeight:Number = 100;
	/**
	* Sets the vertical scrollbar height of background
	* @default = 100;
	*/
	public function get vScrollbarHeight():Number
	{
	 return _vScrollbarHeight;
	}
		
	public function set vScrollbarHeight(value:Number):void
	{
	 _vScrollbarHeight = value;
	}
	
	private var _vScrollbarEllipseWidth:Number = 30;
	/**
	* Sets the vertical scrollbar ellipse width of background
	* @default = 30;
	*/
	public function get vScrollbarEllipseWidth():Number
	{
	 return _vScrollbarEllipseWidth;
	}
		
	public function set vScrollbarEllipseWidth(value:Number):void
	{
	 _vScrollbarEllipseWidth = value;
	}
	
	private var _vScrollbarEllipseHeight:Number = 20;
	/**
	* Sets the vertical scrollbar ellipse height of background
	* @default = 50;
	*/
	public function get vScrollbarEllipseHeight():Number
	{
	 return _vScrollbarEllipseHeight;
	}
		
	public function set vScrollbarEllipseHeight(value:Number):void
	{
	 _vScrollbarEllipseHeight = value;
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
	
	private var _vertical:Boolean = true;
	/**
	* Defines the flag for vertical background 
	*/
	public function get vertical():Boolean
	{ 
	  return _vertical;
	}
	public function set vertical(value:Boolean):void
	{
	  _vertical = value;
	}
	
	private var _imageUrl:String = "library/assets/demos/Train_wreck_at_Montparnasse_1895.jpg";
	/**
	* Sets the image path
	* @default = 50;
	*/
	public function get imageUrl():String
	{
	 return _imageUrl;
	}
		
	public function set imageUrl(value:String):void
	{
	 _imageUrl = value;
	}
	
    private var Loader0:Loader = new Loader();
	
	/**
	* Initializes the configuration and display of scrollbar
	*/
	public function init():void
	{   
		displayPane();
	}
	
	/**
	*  Creates vertical or horizontal scrollbar
	*/
    private function displayPane():void
	{
			
	this.mouseChildren = true;
    
	square.graphics.lineStyle(squareLineStroke, squareOutlineColor);
	square.graphics.beginFill(squareColor);
	square.graphics.drawRect(0, 0, squareWidth , squareHeight);
	square.graphics.endFill();
	square.x = 100;
	square.y = 100;
	
	var square1:Sprite = new Sprite();
	square1.graphics.lineStyle(squareLineStroke, squareOutlineColor);
	square1.graphics.beginFill(squareColor);
	square1.graphics.drawRect(0, 0, squareWidth , squareHeight);
	square1.graphics.endFill();
	square1.x = 100;
	square1.y = 100;
	
	Loader0.load(new URLRequest(imageUrl));

	square1.scrollRect = new Rectangle(0, 0, squareWidth, squareHeight);
	
    background_H.graphics.lineStyle(bgLineStroke, bgOutlineColor); 
    background_H.graphics.beginFill(bgColor);
	background_H.graphics.drawRoundRect(bgX, bgY, bgWidth, bgHeight, bgEllipseWidth, bgEllipseHeight);
	background_H.graphics.endFill();

	background_V.graphics.lineStyle(verticalBgLineStroke, verticalBgOutlineColor); 
    background_V.graphics.beginFill(verticalBgColor);
    background_V.graphics.drawRoundRect(vBgX, vBgY, vBgWidth, vBgHeight, vBgEllipseWidth, vBgEllipseHeight);
	background_V.graphics.endFill();

	scrollbar_H.graphics.lineStyle(scrollBarLineStroke, scrollBarOutlineColor);  
    scrollbar_H.graphics.beginFill(scrollBarColor);
    scrollbar_H.graphics.drawRoundRect(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, scrollbarEllipseWidth, scrollbarEllipseHeight);
	scrollbar_H.graphics.endFill();

	scrollbar_V.graphics.lineStyle(verticalScrollbarLineStroke, verticalScrollBarOutlineColor); 
    scrollbar_V.graphics.beginFill(verticalScrollBarColor);
    scrollbar_V.graphics.drawRoundRect(vScrollbarX, vScrollbarY, vScrollbarWidth, vScrollbarHeight, vScrollbarEllipseWidth, vScrollbarEllipseHeight);
	scrollbar_V.graphics.endFill();

	if(horizontal)
	{
	scrollbar_H.gestureEvents = true;
	scrollbar_H.gestureList = {"n-drag": true};
	scrollbar_H.addEventListener(GWGestureEvent.DRAG , hDrag);
	//background_H.addEventListener(TouchEvent.TOUCH_BEGIN , hBegin);
	
		if (GestureWorks.activeTUIO)
			background_H.addEventListener(TuioTouchEvent.TOUCH_DOWN, hBegin);
		else if (GestureWorks.supportsTouch)
			background_H.addEventListener(TouchEvent.TOUCH_BEGIN, hBegin);
		else
			background_H.addEventListener(MouseEvent.MOUSE_DOWN, hBegin);
	}
	if(vertical)	
	{
	scrollbar_V.gestureEvents = true;
	scrollbar_V.gestureList = {"n-drag": true};
	scrollbar_V.addEventListener(GWGestureEvent.DRAG , vDrag);
	//background_V.addEventListener(TouchEvent.TOUCH_BEGIN , vBegin);
	
		if (GestureWorks.activeTUIO)
		    background_V.addEventListener(TuioTouchEvent.TOUCH_DOWN, vBegin);
		else if (GestureWorks.supportsTouch)
			background_V.addEventListener(TouchEvent.TOUCH_BEGIN, vBegin);
		else
			background_V.addEventListener(MouseEvent.MOUSE_DOWN, vBegin);
	} 

	addChild(square);
	addChild(square1);
    square1.addChild(Loader0);
		
 	if(horizontal)
	{
	square.addChild(background_H);
	square.addChild(scrollbar_H);
   	}
	if(vertical)
	{
	square.addChild(background_V);
	square.addChild(scrollbar_V);
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
	 * Creates boundary for the horizontal scrollpane.
	 * @param	event
	 */
    private function hDrag(event:GWGestureEvent):void
	{
		var offset:Number = 25;
		var dx:Number = event.value.drag_dx - scrollbar_H.x;
	
		if ((event.value.drag_dx + event.target.x) > scrollbar_HmaxPos)
		 event.target.x = scrollbar_HmaxPos ;
		else if ((event.value.drag_dx + event.target.x) < scrollbar_HminPos)
		 event.target.x = scrollbar_HminPos;
		else 
		 event.target.x += event.value.drag_dx;
		 Loader0.x = dx + offset;
	}	
	
	/**
	 * Creates boundary for the vertical scrollpane.
	 * @param	event
	 */
    private function vDrag(event:GWGestureEvent):void
	{
		 var offset:Number = 10;
		 var dy:Number = event.value.drag_dy - scrollbar_V.y;
		
		if ((event.value.drag_dy + event.target.y) > scrollbar_VmaxPos)
		 event.target.y = scrollbar_VmaxPos ;
		else if ((event.value.drag_dy + event.target.y) < scrollbar_VminPos)
		 event.target.y = scrollbar_VminPos;
	    else 
		 event.target.y += event.value.drag_dy;
		 Loader0.y = dy + offset;
	}

	/**
	 * Handles horizontal touch events.
	 * @param	event
	 */
	private function hBegin(event:TouchEvent):void
    {
		 var offset:Number = 10;
		 
		 var touchX:Number = event.localX;
		 var scrollBarCenter:Number = scrollbar_H.width/2;
		 var rightBoundary:Number = background_H.width - scrollBarCenter;
		 var leftBoundary:Number = scrollBarCenter;  

		if (touchX > rightBoundary)
    	 scrollbar_H.x =  background_H.width - scrollbar_H.width;
		else if (touchX < leftBoundary)
		 scrollbar_H.x = background_H.x;
		else			 
		 scrollbar_H.x = touchX - scrollBarCenter;	
	   	 Loader0.x = offset - event.localX ;
	}

	/**
	 * Handles vertical touch events.
	 * @param	event
	 */
	private function vBegin(event:TouchEvent):void
    {
		 var offset:Number = 10;
		   	 	 
		 var touchY:Number = event.localY;
		 var topBoundary:Number = scrollbar_V.height/2;
		 var bottomBoundary:Number = background_V.height - scrollbar_V.height; 

		if (touchY < topBoundary)
		 scrollbar_V.y = topBoundary - scrollbar_V.height/2;
		else if (touchY > bottomBoundary)
		 scrollbar_V.y = bottomBoundary;
		else
		 scrollbar_V.y = touchY - scrollbar_V.height / 2;
		 Loader0.y = offset - event.localY;
	}

	/**
	 * dispose method
	 */
	override public function dispose(): void
	{
		super.dispose();
		Loader0 = null;
		square = null;
		background_V = null;
		background_H = null;
		scrollbar_V = null;
		scrollbar_H = null;
		background_H.removeEventListener(TouchEvent.TOUCH_BEGIN , hBegin);
		background_V.removeEventListener(TouchEvent.TOUCH_BEGIN , vBegin);
		scrollbar_H.removeEventListener(GWGestureEvent.DRAG , hDrag);
		scrollbar_V.removeEventListener(GWGestureEvent.DRAG , vDrag);
		this.removeEventListener(TuioTouchEvent.TOUCH_MOVE , vBegin);
		this.removeEventListener(TouchEvent.TOUCH_BEGIN, vBegin);
		this.removeEventListener(MouseEvent.MOUSE_MOVE, vBegin);
		this.removeEventListener(MouseEvent.MOUSE_MOVE, hBegin);
		this.removeEventListener(TouchEvent.TOUCH_BEGIN, hBegin);
		this.removeEventListener(TuioTouchEvent.TOUCH_MOVE , hBegin);
	}
}
}