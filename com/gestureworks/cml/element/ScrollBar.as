package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.*;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * This tag scrolls the content and allows the user to set the location of scrollbar from vertical to horizontal or horizontal to vertical.
	 * The change of scrollbar position can be accomplished by setting the horizontal flag to true or false.
	 * It has the following parameters: backgroundLinecolor, backgroundLineStroke, backgroundColor,background_VLineStroke, background_VLineColor, background_VColor, topTriangle_VColor, bottomTriangle_VColor, leftTriangleColor,rightTriangleColor,square1LineStroke, square1LineColor, square1Color, square2LineStroke, square2LineColor, square2Color, topSquare_VLineStroke, topSquare_VLineColor,topSquare_VColor, bottomSquare_VLineStroke, bottomSquare_VLineColor,bottomSqaureColor, horizontal.
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var sb:ScrollBar = new ScrollBar();
	   sb.x = 100;
	   sb.y = 100;
	   addChild(sb);
	   
	 *
	 * </codeblock>
	 * @author Uma
	 */
	
	public class ScrollBar extends Container
	{
		/**
		 * ScrollBar constructor
		 */
		public function ScrollBar():void
		{
			super();
		//	init();
		}
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			super.displayComplete();
			init();
		}
		
		/**
		 * Defines the horizontal background which is a rectangle
		 */
		public var background:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the scrollbar of horizontal background
		 */
		public var scrollbar:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the left triangle of horizontal background
		 */
		public var leftTriangle:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the left triangle of horizontal background
		 */
		public var rightTriangle:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the right square of horizontal background
		 */
		public var square2:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the left square of horizontal background
		 */
		private var square1:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the vertical background
		 */
		public var background_V:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the scrollbar of vertical background
		 */
		public var scrollbar_V:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the top triangle of vertical background
		 */
		public var topTriangle_V:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the bottom triangle of vertical background
		 */
		public var bottomTriangle_V:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the top square of vertical background
		 */
		public var topSquare_V:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the bottom square of vertical background
		 */
		public var bottomSquare_V:TouchSprite = new TouchSprite();
		
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
		
		private var _backgroundLineStroke:Number = 0;
		
		/**
		 * Sets the line stroke of horizontal background
		 * @default = 1;
		 */
		public function get backgroundLineStroke():Number
		{
			return _backgroundLineStroke;
		}
		
		public function set backgroundLineStroke(value:Number):void
		{
			_backgroundLineStroke = value;
		}
		
		private var _backgroundLineColor:uint = 0x383838;
		
		/**
		 * Sets the horizontal background line color
		 * @default = 0x383838;
		 */
		public function get backgroundLineColor():uint
		{
			return _backgroundLineColor;
		}
		
		public function set backgroundLineColor(value:uint):void
		{
			_backgroundLineColor = value;
		}
		
		private var _backgroundColor:uint = 0x383838;
		
		/**
		 * Sets the color of horizontal background
		 * @default = 0x383838;
		 */
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		private var _background_VLineStroke:Number = 0;
		
		/**
		 * Sets the line stroke of vertical background
		 * @default = 1;
		 */
		public function get background_VLineStroke():Number
		{
			return _background_VLineStroke;
		}
		
		public function set background_VLineStroke(value:Number):void
		{
			_background_VLineStroke = value;
		}
		
		private var _background_VLineColor:uint = 0x383838;
		
		/**
		 * Sets the vertical background line color
		 * @default = 0x383838;
		 */
		public function get background_VLineColor():uint
		{
			return _background_VLineColor;
		}
		
		public function set background_VLineColor(value:uint):void
		{
			_background_VLineColor = value;
		}
		
		private var _background_VColor:uint = 0x383838;
		
		/**
		 * Sets the color of vertical background
		 * @default = 0x383838;
		 */
		public function get background_VColor():uint
		{
			return _background_VColor;
		}
		
		public function set background_VColor(value:uint):void
		{
			_background_VColor = value;
		}
		
		private var _scrollbar_VColor:uint = 0x000000;
		
		/**
		 * Sets the scroll bar color of vertical background
		 * @default = 0x000000;
		 */
		public function get scrollbar_VColor():uint
		{
			return _scrollbar_VColor;
		}
		
		public function set scrollbar_VColor(value:uint):void
		{
			_scrollbar_VColor = value;
		}
		
		private var _scrollbar_VLineStroke:uint = 0;
		
		/**
		 * Sets the scroll bar line stroke of vertical background
		 * @default = 3;
		 */
		public function get scrollbar_VLineStroke():uint
		{
			return _scrollbar_VLineStroke;
		}
		
		public function set scrollbar_VLineStroke(value:uint):void
		{
			_scrollbar_VLineStroke = value;
		}
		
		private var _scrollbar_VLineColor:uint = 0x000000;
		
		/**
		 * Sets the scroll bar line color of vertical background
		 * @default = 3;
		 */
		public function get scrollbar_VLineColor():uint
		{
			return _scrollbar_VLineColor;
		}
		
		public function set scrollbar_VLineColor(value:uint):void
		{
			_scrollbar_VLineColor = value;
		}
		
		private var _scrollbarColor:uint = 0x000000;
		
		/**
		 * Sets the scroll bar color of vertical background
		 * @default = 0x000000;
		 */
		public function get scrollbarColor():uint
		{
			return _scrollbarColor;
		}
		
		public function set scrollbarColor(value:uint):void
		{
			_scrollbarColor = value;
		}
		
		private var _scrollbarLineStroke:uint = 0;
		
		/**
		 * Sets the scroll bar line stroke of horizontal background
		 * @default = 3;
		 */
		public function get scrollbarLineStroke():uint
		{
			return _scrollbarLineStroke;
		}
		
		public function set scrollbarLineStroke(value:uint):void
		{
			_scrollbarLineStroke = value;
		}
		
		private var _scrollbarLineColor:uint = 0x000000;
		
		/**
		 * Sets the scroll bar color of horizontal background
		 * @default = 3;
		 */
		public function get scrollbarLineColor():uint
		{
			return _scrollbarLineColor;
		}
		
		public function set scrollbarLineColor(value:uint):void
		{
			_scrollbarLineColor = value;
		}
		
		private var _square1Color:uint = 0xA0A0A0;
		
		/**
		 * Sets the square color of horizontal background
		 * @default = 0xA0A0A0;
		 */
		public function get square1Color():uint
		{
			return _square1Color;
		}
		
		public function set square1Color(value:uint):void
		{
			_square1Color = value;
		}
		
		private var _square1LineStroke:uint = 0;
		
		/**
		 * Sets the square line stroke of horizontal background
		 * @default = 3;
		 */
		public function get square1LineStroke():uint
		{
			return _square1LineStroke;
		}
		
		public function set square1LineStroke(value:uint):void
		{
			_square1LineStroke = value;
		}
		
		private var _square1LineColor:uint = 0xA0A0A0;
		
		/**
		 * Sets the square line color of horizontal background
		 * @default = 3;
		 */
		public function get square1LineColor():uint
		{
			return _square1LineColor;
		}
		
		public function set square1LineColor(value:uint):void
		{
			_square1LineColor = value;
		}
		
		private var _square2Color:uint = 0xA0A0A0;
		
		/**
		 * Sets the right square color of horizontal background
		 * @default = 0xA0A0A0;
		 */
		public function get square2Color():uint
		{
			return _square2Color;
		}
		
		public function set square2Color(value:uint):void
		{
			_square2Color = value;
		}
		
		private var _square2LineStroke:uint = 0;
		
		/**
		 * Sets the right square line stroke of horizontal background
		 * @default = 3;
		 */
		public function get square2LineStroke():uint
		{
			return _square2LineStroke;
		}
		
		public function set square2LineStroke(value:uint):void
		{
			_square2LineStroke = value;
		}
		
		private var _square2LineColor:uint = 0xA0A0A0;
		
		/**
		 * Sets the right square line color of horizontal background
		 * @default = 3;
		 */
		public function get square2LineColor():uint
		{
			return _square2LineColor;
		}
		
		public function set square2LineColor(value:uint):void
		{
			_square2LineColor = value;
		}
		
		private var _bottomSquare_VColor:uint = 0xA0A0A0;
		
		/**
		 * Sets the right square color of vertical background
		 * @default = 0xA0A0A0;
		 */
		public function get bottomSquare_VColor():uint
		{
			return _bottomSquare_VColor;
		}
		
		public function set bottomSquare_VColor(value:uint):void
		{
			_bottomSquare_VColor = value;
		}
		
		private var _bottomSquare_VLineStroke:uint = 0;
		
		/**
		 * Sets the right square line stroke of vertical background
		 * @default = 3;
		 */
		public function get bottomSquare_VLineStroke():uint
		{
			return _bottomSquare_VLineStroke;
		}
		
		public function set bottomSquare_VLineStroke(value:uint):void
		{
			_bottomSquare_VLineStroke = value;
		}
		
		private var _bottomSquare_VLineColor:uint = 0xA0A0A0;
		
		/**
		 * Sets the right square line color of vertical background
		 * @default = 3;
		 */
		public function get bottomSquare_VLineColor():uint
		{
			return _bottomSquare_VLineColor;
		}
		
		public function set bottomSquare_VLineColor(value:uint):void
		{
			_bottomSquare_VLineColor = value;
		}
		
		private var _topSquare_VColor:uint = 0xA0A0A0;
		
		/**
		 * Sets the right square color of vertical background
		 * @default = 0xA0A0A0;
		 */
		public function get topSquare_VColor():uint
		{
			return _topSquare_VColor;
		}
		
		public function set topSquare_VColor(value:uint):void
		{
			_topSquare_VColor = value;
		}
		
		private var _topSquare_VLineStroke:uint = 0;
		
		/**
		 * Sets the right square line stroke of vertical background
		 * @default = 3;
		 */
		public function get topSquare_VLineStroke():uint
		{
			return _topSquare_VLineStroke;
		}
		
		public function set topSquare_VLineStroke(value:uint):void
		{
			_topSquare_VLineStroke = value;
		}
		
		private var _topSquare_VLineColor:uint = 0xA0A0A0;
		
		/**
		 * Sets the right square line color of vertical background
		 * @default = 3;
		 */
		public function get topSquare_VLineColor():uint
		{
			return _topSquare_VLineColor;
		}
		
		public function set topSquare_VLineColor(value:uint):void
		{
			_topSquare_VLineColor = value;
		}
		
		private var _topTriangle_VColor:uint = 0x000000;
		
		/**
		 * Sets the top triangle color of vertical background
		 * @default = 0xA0A0A0;
		 */
		public function get topTriangle_VColor():uint
		{
			return _topTriangle_VColor;
		}
		
		public function set topTriangle_VColor(value:uint):void
		{
			_topTriangle_VColor = value;
		}
		
		private var _bottomTriangle_VColor:uint = 0x000000;
		
		/**
		 * Sets the top triangle color of vertical background
		 * @default = 0xA0A0A0;
		 */
		public function get bottomTriangle_VColor():uint
		{
			return _bottomTriangle_VColor;
		}
		
		public function set bottomTriangle_VColor(value:uint):void
		{
			_bottomTriangle_VColor = value;
		}
		
		private var _leftTriangleColor:uint = 0x000000;
		
		/**
		 * Sets the top triangle color of horizontal background
		 * @default = 0xA0A0A0;
		 */
		public function get leftTriangleColor():uint
		{
			return _leftTriangleColor;
		}
		
		public function set leftTriangleColor(value:uint):void
		{
			_leftTriangleColor = value;
		}
		
		private var _rightTriangleColor:uint = 0x000000;
		
		/**
		 * Sets the top triangle color of horizontal background
		 * @default = 0xA0A0A0;
		 */
		public function get rightTriangleColor():uint
		{
			return _rightTriangleColor;
		}
		
		public function set rightTriangleColor(value:uint):void
		{
			_rightTriangleColor = value;
		}
		
		/**
		 * Initializes the configuration and display of scrollbar
		 */
	   public function init():void
		{
			displayScroll();
		}
		
		/**
		 * creates vertical or horizontal scrollbar
		 */
		private function displayScroll():void
		{
			background.graphics.lineStyle(backgroundLineStroke, backgroundLineColor);
			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRect(0, 0, 700, 30);
			background.graphics.endFill();
			
			background_V.graphics.lineStyle(background_VLineStroke, background_VLineColor);
			background_V.graphics.beginFill(background_VColor);
			background_V.graphics.drawRect(0, 0, 30, 700);
			background_V.graphics.endFill();
			
			scrollbar.graphics.lineStyle(scrollbarLineStroke, scrollbarLineColor);
			scrollbar.graphics.beginFill(scrollbarColor);
			scrollbar.graphics.drawRect(40, 0, 200, 30);
			scrollbar.graphics.endFill();
					
			scrollbar_V.graphics.lineStyle(scrollbar_VLineStroke, scrollbar_VLineColor);
			scrollbar_V.graphics.beginFill(scrollbar_VColor);
			scrollbar_V.graphics.drawRect(0, 0, 30, 200);
			scrollbar_V.graphics.endFill();
			
			scrollbar_V.y = 40;
			
			square1.graphics.lineStyle(square1LineStroke, square1LineColor);
			square1.graphics.beginFill(square1Color);
			square1.graphics.drawRect(0, 0, 40, 30);
			square1.graphics.endFill();
			
			topSquare_V.graphics.lineStyle(topSquare_VLineStroke, topSquare_VLineColor);
			topSquare_V.graphics.beginFill(topSquare_VColor);
			topSquare_V.graphics.drawRect(0, 0, 30, 40);
			topSquare_V.graphics.endFill();
			
			leftTriangle.graphics.beginFill(leftTriangleColor);
			leftTriangle.graphics.moveTo(30, 0);
			leftTriangle.graphics.lineTo(5, 15);
			leftTriangle.graphics.lineTo(30, 30);
			
			topTriangle_V.graphics.beginFill(topTriangle_VColor);
			topTriangle_V.graphics.moveTo(0, 30);
			topTriangle_V.graphics.lineTo(30, 30);
			topTriangle_V.graphics.lineTo(15, 0);
			
			square2.graphics.lineStyle(square2LineStroke, square2LineColor);
			square2.graphics.beginFill(square2Color);
			square2.graphics.drawRect(660, 0, 40, 30);
			square2.graphics.endFill();
			
			bottomSquare_V.graphics.lineStyle(bottomSquare_VLineStroke, bottomSquare_VLineColor);
			bottomSquare_V.graphics.beginFill(bottomSquare_VColor);
			bottomSquare_V.graphics.drawRect(0, 660, 30, 40);
			bottomSquare_V.graphics.endFill();
					
			rightTriangle.graphics.beginFill(rightTriangleColor);
			rightTriangle.graphics.moveTo(670, 0);
			rightTriangle.graphics.lineTo(695, 15);
			rightTriangle.graphics.lineTo(670, 30);
			
			bottomTriangle_V.graphics.beginFill(bottomTriangle_VColor);
			bottomTriangle_V.graphics.moveTo(0, 670);
			bottomTriangle_V.graphics.lineTo(30, 670);
			bottomTriangle_V.graphics.lineTo(15, 700);
			
			if (horizontal)
			{
				scrollbar.gestureList = {"n-drag": true};
				scrollbar.addEventListener(GWGestureEvent.DRAG, onDrag);
				square1.addEventListener(TouchEvent.TOUCH_BEGIN , leftArrow);
				square2.addEventListener(TouchEvent.TOUCH_BEGIN , rightArrow);
				background.addEventListener(TouchEvent.TOUCH_BEGIN, hBegin);
				
				//if (GestureWorks.activeTUIO)
					//this.addEventListener(TuioTouchEvent.TAP, leftArrow);
				//else if (GestureWorks.supportsTouch)
					//this.addEventListener(TouchEvent.TOUCH_BEGIN, leftArrow);
				//else
					//this.addEventListener(MouseEvent.CLICK, leftArrow);
				//
				//if (GestureWorks.activeTUIO)
					//this.addEventListener(TuioTouchEvent.TAP, rightArrow);
				//else if (GestureWorks.supportsTouch)
					//this.addEventListener(TouchEvent.TOUCH_BEGIN, rightArrow);
				//else
					//this.addEventListener(MouseEvent.CLICK, rightArrow);
			}
			else
			{
				scrollbar_V.gestureList = {"n-drag": true};
				scrollbar_V.addEventListener(GWGestureEvent.DRAG, onDrag);
				topSquare_V.addEventListener(TouchEvent.TOUCH_BEGIN , leftArrow);
				bottomSquare_V.addEventListener(TouchEvent.TOUCH_BEGIN , rightArrow);
				background_V.addEventListener(TouchEvent.TOUCH_BEGIN, vBegin);
				
				//if (GestureWorks.activeTUIO)
					//this.addEventListener(TuioTouchEvent.TAP, leftArrow);
				//else if (GestureWorks.supportsTouch)
					//this.addEventListener(TouchEvent.TOUCH_BEGIN, leftArrow);
				//else
					//this.addEventListener(MouseEvent.CLICK, leftArrow);
				//
				//if (GestureWorks.activeTUIO)
					//this.addEventListener(TuioTouchEvent.TAP, rightArrow);
				//else if (GestureWorks.supportsTouch)
					//this.addEventListener(TouchEvent.TOUCH_BEGIN, rightArrow);
				//else
					//this.addEventListener(MouseEvent.CLICK, rightArrow);
			}
			
			if (horizontal)
			{
				square1.addEventListener(MouseEvent.MOUSE_UP, lArrow);
				square2.addEventListener(MouseEvent.MOUSE_DOWN, rArrow);
			}
			else
			{
				topSquare_V.addEventListener(MouseEvent.MOUSE_UP, lArrow);
				bottomSquare_V.addEventListener(MouseEvent.MOUSE_DOWN, rArrow);
			}
			
			if (horizontal)
			{
				addChild(background);
				addChild(scrollbar);
				addChild(square1);
				addChild(square2);
				square1.addChild(leftTriangle);
				square2.addChild(rightTriangle);
			}
			else
			{
				addChild(background_V);
				addChild(scrollbar_V);
				addChild(topSquare_V);
				addChild(bottomSquare_V);
				topSquare_V.addChild(topTriangle_V);
				bottomSquare_V.addChild(bottomTriangle_V);
			}
			
			scrollbarminPos = square1.x;
			scrollbarmaxPos = background.width - square2.width - scrollbar.width - square1.width;
			
			scrollbar_VminPos = topSquare_V.y + topSquare_V.height;
			scrollbar_VmaxPos = background_V.height - scrollbar.height - scrollbar.width;
		
		}
		private var scrollbarminPos:Number;
		private var scrollbarmaxPos:Number;
		private var scrollbar_VminPos:Number;
		private var scrollbar_VmaxPos:Number;
		
		/**
		 * defines boundary for horizontal scrollbar.
		 * @param	event
		 */
		private function onDrag(event:GWGestureEvent):void
		{
			if (horizontal)
			{
				if ((event.value.drag_dx + event.target.x) > scrollbarmaxPos)
					event.target.x = scrollbarmaxPos;
				else if ((event.value.drag_dx + event.target.x) < scrollbarminPos)
					event.target.x = scrollbarminPos;
				else
					event.target.x += event.value.drag_dx;
			}
			else
			{
				if ((event.value.drag_dy + event.target.y) > scrollbar_VmaxPos)
					event.target.y = scrollbar_VmaxPos;
				else if ((event.value.drag_dy + event.target.y) < scrollbar_VminPos)
					event.target.y = scrollbar_VminPos;
				else
					event.target.y += event.value.drag_dy;
			}
		}
		
		/** handles touch event when left arrow pressed horizontally or vertically
		 *  @param	event
		 */
		private function leftArrow(event:TouchEvent):void
		{
			var offset:Number = 25;
			
			if (horizontal)
			{
				if (scrollbar.x > (background.x - square1.height / 2 + square1.width / 2))
					scrollbar.x = scrollbar.x - offset;
			}
			else
			{
				if (scrollbar_V.y > (background_V.y - topSquare_V.height / 2 + scrollbar_V.height / 2 - topSquare_V.height))
					scrollbar_V.y = scrollbar_V.y - offset;
			}
		}
		
		/** handles touch event when right arrow pressed horizontally or vertically
		 *  @param	event
		 */
		private function rightArrow(event:TouchEvent):void
		{
			var center:Number = scrollbar.x - scrollbar.width / 2;
			var offset:Number = -25;
			
			if (horizontal)
			{
				if (scrollbar.x < (background.width - scrollbar.width + square2.width / 2 - scrollbar.width / 2))
					scrollbar.x = scrollbar.x - offset;
			}
			else
			{
				if (scrollbar_V.y < (background_V.height - bottomSquare_V.height - scrollbar_V.height))
					scrollbar_V.y = scrollbar_V.y - offset;
			}
		}
		
		/** handles mouse event when left arrow pressed horizontally or vertically
		 *  @param	event
		 */
		private function lArrow(event:MouseEvent):void
		{
			var center:Number = scrollbar.x - scrollbar.width / 2;
			var offset:Number = 25;
			
			if (horizontal)
			{
				if (scrollbar.x > (background.x - square1.height / 2 + square1.width / 2))
					scrollbar.x = scrollbar.x - offset;
			}
			else
			{
				if (scrollbar_V.y > (background_V.y - topSquare_V.height / 2 + scrollbar_V.height / 2 - topSquare_V.height))
					scrollbar_V.y = scrollbar_V.y - offset;
			}
		}
		
		/** handles mouse event when right arrow pressed horizontally or vertically
		 *  @param	event
		 */
		private function rArrow(event:MouseEvent):void
		{
			var offset:Number = -25;
			
			if (horizontal)
			{
				if (scrollbar.x < (background.width - scrollbar.width + square2.width / 2 - scrollbar.width / 2))
					scrollbar.x = scrollbar.x - offset;
			}
			else
			{
				if (scrollbar_V.y < (background_V.height - bottomSquare_V.height - scrollbar_V.height))
					scrollbar_V.y = scrollbar_V.y - offset;
			}
		}
		
	    private function hBegin(event:TouchEvent):void
        {
		  var touchX:Number = event.localX;
		  var scrollBarCenter:Number = scrollbar.width/2;
		  var rightBoundary:Number = background.width - scrollBarCenter;
		  var leftBoundary:Number = scrollBarCenter;  

		  if (touchX > rightBoundary)
    	    scrollbar.x = background.width - scrollbar.width - square2.width - square2.height;
		  else if (touchX < leftBoundary)
		   scrollbar.x = background.x;
		  else			 
		   scrollbar.x = touchX - scrollBarCenter;	
	    }
	
		private function vBegin(event:TouchEvent):void
        {
		  var touchY:Number = event.localY;
		  var topBoundary:Number = scrollbar_V.height/2;
		  var bottomBoundary:Number = background_V.height - scrollbar_V.height; 

		  if (touchY < topBoundary)
		   scrollbar_V.y = topBoundary - scrollbar_V.height/2 + topSquare_V.height;
		  else if (touchY > bottomBoundary)
		   scrollbar_V.y = bottomBoundary - bottomSquare_V.height;
		  else
		   scrollbar_V.y = touchY - scrollbar_V.height/2;
	    }
		
		/**
		 * dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			background = null;
			scrollbar = null;
			leftTriangle = null;
			rightTriangle = null;
			square2 = null;
			square1 = null;
			background_V = null;
			scrollbar_V = null;
			topTriangle_V = null;
			bottomTriangle_V = null;
			topSquare_V = null;
			bottomSquare_V = null;
			scrollbar.removeEventListener(GWGestureEvent.DRAG, onDrag);
			square1.removeEventListener(TouchEvent.TOUCH_BEGIN, leftArrow);
			square2.removeEventListener(TouchEvent.TOUCH_BEGIN, rightArrow);
			scrollbar_V.removeEventListener(GWGestureEvent.DRAG, onDrag);
			topSquare_V.removeEventListener(TouchEvent.TOUCH_BEGIN, leftArrow);
			bottomSquare_V.removeEventListener(TouchEvent.TOUCH_BEGIN, rightArrow);
			square1.removeEventListener(MouseEvent.MOUSE_UP, lArrow);
			square2.removeEventListener(MouseEvent.MOUSE_DOWN, rArrow);
			topSquare_V.removeEventListener(MouseEvent.MOUSE_UP, lArrow);
			bottomSquare_V.removeEventListener(MouseEvent.MOUSE_DOWN, rArrow);
			this.removeEventListener(TuioTouchEvent.TAP, leftArrow);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, leftArrow);
			this.removeEventListener(MouseEvent.CLICK, leftArrow);
			this.removeEventListener(TuioTouchEvent.TAP, rightArrow);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, rightArrow);
			this.removeEventListener(MouseEvent.CLICK, rightArrow);
		}
	}
}