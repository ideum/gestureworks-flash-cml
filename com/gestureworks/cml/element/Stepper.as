package com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.events.MouseEvent;
	import flash.text.*;
	
	/**
	 * The Stepper element provides increment and decrement of Numbers.
	 * It has the following parameters: backgroundLinecolor, backgroundLineStroke, backgroundColor, topTriangleColor, topTriangleAlpha, bottomTriangleAlpha, bottomTriangleColor, textColor, text .
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var st:Stepper = new Stepper();
	   addChild(st);
	   st.x = 50;
	   st.y = 50;
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
		 * Defines the background which is a rectangle
		 */
		public var background:TouchSprite = new TouchSprite();
		
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
		
		private var _text:Number = 1;
		
		/**
		 * Sets the default Number in Text Field
		 * @default = 0;
		 */
		public function get text():Number
		{
			return _text;
		}
		
		public function set text(value:Number):void
		{
			_text = value;
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
		
		private var _backgroundLineColor:uint = 0xCCCCCC;
		
		/**
		 * Sets the background line color
		 * @default = 0xCCCCCC;
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
		
		/**
		 * Initializes the configuration and display of Numbers
		 */
		private function init():void
		{
			displayNum();
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
			
			bottomTriangle.graphics.beginFill(bottomTriangleColor, bottomTriangleAlpha);
			bottomTriangle.graphics.moveTo(90, 50);
			bottomTriangle.graphics.lineTo(80, 25);
			bottomTriangle.graphics.lineTo(100, 25);
			bottomTriangle.graphics.endFill();
			
			topTriangle.addEventListener(GWGestureEvent.TAP, upArrow);
			bottomTriangle.addEventListener(GWGestureEvent.TAP, downArrow);
					
			topTriangle.addEventListener(MouseEvent.MOUSE_UP, incrementText);
			bottomTriangle.addEventListener(MouseEvent.MOUSE_DOWN, decrementText);
			
			txt.x = 40;
			txt.y = 10;
			txt.visible = true;
			txt.text = text.toString();
			background.addChild(txt);
			txt.textColor = textColor;
			
			addChild(background);
			addChild(topTriangle);
			addChild(bottomTriangle);
		}
		
		/**
		 * Increments text when up arrow pressed
		 * @param	event
		 */
		private function upArrow(event:GWGestureEvent):void
		{
			text++;
			txt.text = text.toString();
		}
		
		/**
		 * Decrement text when down arrow pressed
		 * @param	event
		 */
		
		private function downArrow(event:GWGestureEvent):void
		{
			text--;
			txt.text = text.toString();
		}
		
		/**
		 * handles mouse event increment text when up arrow pressed
		 * @param	event
		 */
		private function incrementText(event:MouseEvent):void
		{
			text++;
			txt.text = text.toString();
		}
		
		/**
		 * handles mouse event decrement text when down arrow pressed
		 * @param	event
		 */
		private function decrementText(event:MouseEvent):void
		{
			text--;
			txt.text = text.toString();
		}
	}
}