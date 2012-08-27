package com.gestureworks.cml.element
{
	import com.codeazur.as3swf.utils.NumberUtils;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.globalization.NumberFormatter;
	import flash.globalization.NumberParseResult;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import flash.events.MouseEvent;
	import com.gestureworks.core.GestureWorks;
	import flash.text.*;
	
	/**
	 * The Stepper element provides increment and decrement of Numbers.
	 * It has the following parameters: backgroundLinecolor, backgroundLineStroke, backgroundColor, topTriangleColor, topTriangleAlpha, bottomTriangleAlpha, bottomTriangleColor, textColor, text .
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var st:Stepper = new Stepper();
	   st.x = 50;
	   st.y = 50;
	   addChild(st);
	   
	 *
	 * </codeblock>
	 * @author Uma
	 */
	public class Stepper extends ElementFactory
	{
		
		/**
		 * Stepper constructor.
		 */
		public function Stepper()
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
		 * Defines the square which is a rectangle.
		 */
		public var square:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the background which is a rectangle
		 */
		public var background:Sprite = new Sprite();
		
		/**
		 * Defines the bottom square of background
		 */
		public var bottomSquare:TouchSprite =  new TouchSprite();
		
		/**
		 * Defines the top square of background
		 */
		public 	var topSquare:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the top triangle of square
		 */
		public var topTriangle:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the bottom triangle of square
		 */
		public var bottomTriangle:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the text Field
		 */
		public var txt:TextElement = new TextElement();
		
		/**
		 * Defines the input text Field
		 */
		public var inputTxt:TextElement = new TextElement();
		
		private var _data:Number = 0.1;
		/**
		 * Sets the default Number in Text Field
		 * @default = 0;
		 */
		public function get data():Number
		{
			return _data;
		}
		
		public function set data(value:Number):void
		{
			_data = value;
		}
		
		
		private var _backgroundLineStroke:Number = 3;
		/**
		 * Sets the line stroke of background
		 * @default = 3;
		 */
		public function get backgroundLineStroke():Number
		{
			return _backgroundLineStroke;
		}
		
		public function set backgroundLineStroke(value:Number):void
		{
			_backgroundLineStroke = value;
		}
		
		private var _backgroundLineColor:uint = 0x000000;
		
		/**
		 * Sets the background line color
		 * @default = 0x000000;
		 */
		public function get backgroundLineColor():uint
		{
			return _backgroundLineColor;
		}
		
		public function set backgroundLineColor(value:uint):void
		{
			_backgroundLineColor = value;
		}
		
		private var _backgroundColor:uint = 0xCCCCCC;
		
		/**
		 * Sets the color of background
		 * @default = 0xCCCCCC;
		 */
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		private var _topTriangleColor:uint = 0x000000;
		
		/**
		 * Sets the top triangle color of background
		 * @default = 0x000000;
		 */
		public function get topTriangleColor():uint
		{
			return _topTriangleColor;
		}
		
		public function set topTriangleColor(value:uint):void
		{
			_topTriangleColor = value;
		}
		
		private var _topTriangleAlpha:Number = 1;
		
		/**
		 * Sets the top triangle alpha of background
		 * @default = 1;
		 */
		public function get topTriangleAlpha():Number
		{
			return _topTriangleAlpha;
		}
		
		public function set topTriangleAlpha(value:Number):void
		{
			_topTriangleAlpha = value;
		}
		
		private var _bottomTriangleColor:uint = 0x000000;
		
		/**
		 * Sets the bottom triangle color of background
		 * @default = 0x000000;
		 */
		public function get bottomTriangleColor():uint
		{
			return _bottomTriangleColor;
		}
		
		public function set bottomTriangleColor(value:uint):void
		{
			_bottomTriangleColor = value;
		}
		
		private var _bottomTriangleAlpha:Number = 1;
		
		/**
		 * Sets the bottom triangle alpha of background
		 * @default = 1;
		 */
		public function get bottomTriangleAlpha():Number
		{
			return _bottomTriangleAlpha;
		}
		
		public function set bottomTriangleAlpha(value:Number):void
		{
			_bottomTriangleAlpha = value;
		}
		
		private var _textColor:uint = 0x0000FF;
		
		/**
		 * Sets the text color
		 * @default = 0x0000FF;
		 */
		public function get textColor():Number
		{
			return _textColor;
		}
		
		public function set textColor(value:Number):void
		{
			_textColor = value;
		}
	
		private var lastY:Number;
		/**
		 * Initializes the configuration and display of Numbers
		 */
		private function init():void
		{
			displayNum();
			lastY = 50;
		}
		
		/**
		 * creats stepper with text Elements.
		 */
		private function displayNum():void
		{
			
			background.graphics.lineStyle(backgroundLineStroke, backgroundLineColor);
			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRect(0, 0, 100, 50);
			background.graphics.endFill();
							
			topTriangle.graphics.beginFill(topTriangleColor, topTriangleAlpha);
			topTriangle.graphics.moveTo(90, 0);
			topTriangle.graphics.lineTo(80, 23);
			topTriangle.graphics.lineTo(100, 23);
			topTriangle.graphics.endFill();
			
			topSquare.graphics.beginFill(0xCCCCCC);
			topSquare.graphics.drawRect(70, 2, 30, 22);
			topSquare.graphics.endFill();
					
			bottomTriangle.graphics.beginFill(bottomTriangleColor, bottomTriangleAlpha);
			bottomTriangle.graphics.moveTo(90, 50);
			bottomTriangle.graphics.lineTo(80, 25);
			bottomTriangle.graphics.lineTo(100, 25);
			bottomTriangle.graphics.endFill();
			
			bottomSquare.graphics.beginFill(0xCCCCCC);
			bottomSquare.graphics.drawRect(70, 25, 30, 23);
			bottomSquare.graphics.endFill();
			
		//	background.addEventListener(TouchEvent.TOUCH_MOVE , onMove);
									
			topSquare.addEventListener(GWGestureEvent.TAP, upArrow);
			bottomSquare.addEventListener(GWGestureEvent.TAP, downArrow);
			
		//	background.addEventListener(TouchEvent.TOUCH_BEGIN , onBegin);
					
			topSquare.addEventListener(MouseEvent.MOUSE_UP, incrementText);
			bottomSquare.addEventListener(MouseEvent.MOUSE_DOWN, decrementText);
			
				if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TOUCH_MOVE, onMove);
			else if (GestureWorks.supportsTouch)
				this.addEventListener(TouchEvent.TOUCH_MOVE, onMove);
			else
				this.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TOUCH_UP, onBegin);
			else if (GestureWorks.supportsTouch)
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			else
				this.addEventListener(MouseEvent.MOUSE_UP, onBegin);	
				
			
			txt.x = 25;
			txt.y = 10;
			txt.width = 40;
			txt.height = 25;
			txt.font = "OpenSansBold";
			txt.text = data.toString();
			txt.textColor = textColor;
			background.addChild(txt);
			
			inputTxt.x = 25;
			inputTxt.y = 10;
			inputTxt.width = 40;
			inputTxt.height = 25;
			inputTxt.font = "OpenSansBold";
			inputTxt.text = data.toString();
			inputTxt.type = "input";
			inputTxt.textColor = textColor;
			background.addChild(inputTxt);
			
			addChild(square);
			addChild(background);
			addChild(topSquare);
			topSquare.addChild(topTriangle);
			addChild(bottomSquare);
			bottomSquare.addChild(bottomTriangle);
		
		}
		
		/**
		 * input text field visible when touch event happens.
		 * @param	event
		 */
		private function onBegin(event:TouchEvent):void
		{
			txt.visible = false;
		    inputTxt.visible = true;
	    }
		
		/**
		 * Increments text when dragged
		 * * @param	event
		 */
		private function onMove(event:TouchEvent):void
		{
	        var Dy:Number;
			var K:Number = 30;
			Dy = event.localY - lastY;
            data = data + Dy/K;  
		    lastY = event.localY;
		
			data++;
			txt.text = data.toString();
																
			if(inputTxt)
			{
			var myText:String = "";
			myText = inputTxt.text;
			var value:Number = Number(myText);
			value++;
			inputTxt.text = value.toString();
			}
			
		}
		
		/**
		 * Increments text when up arrow pressed
		 * @param	event
		 */
		private function upArrow(event:GWGestureEvent):void
		{

			data++;
			txt.text = data.toString();
			
		    if(inputTxt)
			{
			var myText:String ="";
			myText = inputTxt.text;
			var value:Number = Number(myText);
			value++;
			inputTxt.text = value.toString();
			}
		
		}
		
		/**
		 * Decrement text when down arrow pressed
		 * @param	event
		 */
		
		private function downArrow(event:GWGestureEvent):void
		{

			data--;
			txt.text = data.toString();
      
		    if(inputTxt)
			{
			var myText:String ="";
			myText = inputTxt.text;
			var value:Number = Number(myText);
			value--;
			inputTxt.text = value.toString();
			}

		}
		
		/**
		 * handles mouse event increment text when up arrow pressed
		 * @param	event
		 */
		private function incrementText(event:MouseEvent):void
		{
            data++;
			txt.text = data.toString();

			if(inputTxt)
			{
			var myText:String ="";
			myText = inputTxt.text;
			var value:Number = Number(myText);
			value++;
			inputTxt.text = value.toString();
			}
	    }
		
		/**
		 * handles mouse event decrement text when down arrow pressed
		 * @param	event
		 */
		private function decrementText(event:MouseEvent):void
		{

			data--;
			txt.text = data.toString();
			
		    if (inputTxt)
			{
			var myText:String ="";
			myText = inputTxt.text;
			var value:Number = Number(myText);
			value--;
			inputTxt.text = value.toString();
			}
		}
		
		
}
}