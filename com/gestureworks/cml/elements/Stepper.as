package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.TouchEvent;
	import flash.text.*;

	/**
	 * The Stepper element provides a graphical user interface tool to increment and decrement numbers.
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
		// float stepper
		var st:Stepper = new Stepper();
		
		// change the stepper from float to integer, text color, text value
		st.textColor = 0x0000FF;
		st.text = 0.1;
		st.float = true;
		st.x = 600;
		st.y = 300;
				
		// background graphics
		st.backgroundLineColor = 0x000000;
		st.backgroundLineStroke = 2;
		st.backgroundColor = 0xCCCCCC;
		
		// triangles graphics
		st.topTriangleColor = 0x000000;
		st.topTriangleAlpha = 2;
		st.bottomTriangleColor = 0x000000;
		st.bottomTriangleAlpha = 2;
		
		// text
		var text:Text = new Text();
		text.x = 600;
		text.y = 260;
		text.text = "Stepper-Float";
		text.width = 2000;
		text.color = 0x00FF00;
		text.selectable = false;
		text.font = "OpenSansBold";
		addChild(text);
		
		st.init();
		addChild(st);
		
		
		// integer stepper
		var st1:Stepper = new Stepper();
		
		// change the stepper from integer to float, text color, text value
		st1.textColor = 0x0000FF;
		st1.text = 1;
		st1.float = false;
		st1.x = 1000;
		st1.y = 300;
		
		// background graphics
		st1.backgroundLineColor = 0x000000;
		st1.backgroundLineStroke = 2;
		st1.backgroundColor = 0xCCCCCC;
		
		// triangles graphics
		st1.topTriangleColor = 0x000000;
		st1.topTriangleAlpha = 2;
		st1.bottomTriangleColor = 0x000000;
		st1.bottomTriangleAlpha = 2;

		// text
		var text1:Text = new Text();
		text1.x = 1000;
		text1.y = 260;
		text1.text = "Stepper-Integer";
		text1.multiline = true;
		text1.wordWrap = true;
		text1.width = 2000;
		text1.color = 0x00FF00;
		text1.selectable = false;
		text1.font = "OpenSansBold";
		addChild(text1);
		
		st1.init();
		addChild(st1);	 
	
	 *
	 * </codeblock>
	 * 
	 * @author Uma
	 * @see Slider
	 */
	public class Stepper extends TouchContainer
	{
		/**
		 * Constructor
		 */
		public function Stepper()
		{
			super();
			mouseChildren = true;
		}
		
		/**
		 * Defines the background which is a rectangle
		 */
		public var background:Sprite = new Sprite();
		
		/**
		 * Defines the bottom square of background
		 */
		public var bottomSquare:TouchSprite = new TouchSprite();
		
		/**
		 * Defines the top square of background
		 */
		public var topSquare:TouchSprite = new TouchSprite();
		
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
		public var txt:Text = new Text();
		
		/**
		 * Defines the input text Field
		 */
		public var inputTxt:Text = new Text();
		
		private var _text:Number = 0.1;
		
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
		 * @default 3
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
		 * @default 0x000000
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
		 * @default 0xCCCCCC
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
		 * @default 0x000000
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
		 * @default 1
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
		 * @default 0x000000
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
		 * @default 1
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
		 * @default 0x0000FF
		 */
		public function get textColor():Number
		{
			return _textColor;
		}
		
		public function set textColor(value:Number):void
		{
			_textColor = value;
		}
		
	    private var _float:Boolean = true;
		/**
		 * Sets the boolean flag for decimal or integers.
		 */
		public function get float():Boolean
	    { 
	     return _float;
	    }
	    public function set float(value:Boolean):void
	    {
	    _float = value;
	    }
		
		private var ts:TouchSprite = new TouchSprite();
		
		/**
		 * Initializes the configuration and display of Numbers
		 */
		override public function init():void
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
			topTriangle.graphics.moveTo(90, 2);
			topTriangle.graphics.lineTo(80, 22);
			topTriangle.graphics.lineTo(100, 22);
			topTriangle.graphics.endFill();
			
			topSquare.graphics.beginFill(0xCCCCCC);
			topSquare.graphics.drawRect(70, 2, 30, 22);
			topSquare.graphics.endFill();
			
			bottomTriangle.graphics.beginFill(bottomTriangleColor, bottomTriangleAlpha);
			bottomTriangle.graphics.moveTo(90, 48);
			bottomTriangle.graphics.lineTo(80, 27);
			bottomTriangle.graphics.lineTo(100, 27);
			bottomTriangle.graphics.endFill();
			
			bottomSquare.graphics.beginFill(0xCCCCCC);
			bottomSquare.graphics.drawRect(70, 25, 30, 23);
			bottomSquare.graphics.endFill();
			
		   	ts.gestureEvents = true;
			ts.gestureList = {"n-drag": true, "n-tap": true};
			topSquare.gestureList = {"n-tap": true};
			bottomSquare.gestureList = {"n-tap": true};

			ts.addEventListener(GWGestureEvent.DRAG, onDrag);
			ts.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			topSquare.addEventListener(GWGestureEvent.TAP, upArrow);
			bottomSquare.addEventListener(GWGestureEvent.TAP, downArrow);

			addEventListener(GWTouchEvent.TOUCH_TAP, onTap);

			inputTxt.x = 30;
			inputTxt.y = 10;
			inputTxt.width = 50;
			inputTxt.height = 25;
			inputTxt.font = "OpenSansBold";
			if (float)
			{
			inputTxt.text = text.toString();
			}
			else
			{
			text = Number(text.toFixed(0));
			inputTxt.text = text.toString();
			}
			inputTxt.type = "dynamic";
			inputTxt.restrict = "0.1-0.9 0-9";
			inputTxt.textColor = textColor;
			inputTxt.selectable = false;
			background.addChild(inputTxt);
						
			addChild(ts);
			ts.addChild(background);
			addChild(topSquare);
			topSquare.addChild(topTriangle);
			addChild(bottomSquare);
			bottomSquare.addChild(bottomTriangle);
        }
		
		/**
		 * creates input textfield when tap event happens.
		 * @param	event
		 */
		private function onTap(event:TouchEvent):void
		{
		    ts.mouseChildren = true;
			inputTxt.type = "input";
			inputTxt.textColor = 0x0000FF;
			//stage.focus = true;
		}
		
		/**
		 * creates dynamic textfield when focus out event happens.
		 * @param	event
		 */
		private function onFocusOut(event:FocusEvent):void
		{
			ts.mouseChildren = false;
			inputTxt.selectable = false;
			inputTxt.textColor = 0x0000FF;
    	    inputTxt.type = "dynamic";
			text = Number(inputTxt.text);
			//text++;
			inputTxt.text = text.toString();
		}
		
		/**
		 * Increments and decrements text when dragged.
		 * * @param	event
		 */
		private function onDrag(event:GWGestureEvent):void
		{
			inputTxt.selectable = true;
			ts.mouseChildren = false;
			var K:Number = 20;
			var value:Number = 20;
			var value1:Number = 10;
			var Dy:Number = event.value.drag_dy - value;
			var dy:Number = event.value.drag_dy - value1;
     
		 if(float)
            {
			text = Number(inputTxt.text);
			text = text + Dy / K;
			text = NumberUtils.roundNumber(text , 10);
			text++;
			inputTxt.text = text.toString();
           }
          else
           {
			text = int(inputTxt.text);
			text = int(text + dy / K);
			text++;
			inputTxt.text = text.toString();
           }
		}
		
		/**
		 * Increments text when up arrow pressed.
		 * @param	event
		 */
		private function upArrow(event:GWGestureEvent):void
		{
			if (float)
			{
				text = Number(inputTxt.text);
				text = NumberUtils.roundNumber(text , 10);
				text++;
				inputTxt.text = text.toString();
			}
			else
			{
				text = int(inputTxt.text);
				text++;
				inputTxt.text = text.toString();
			}
		}
		
		/**
		 * Decrement text when down arrow pressed.
		 * @param	event
		 */
		private function downArrow(event:GWGestureEvent):void
		{
			if (float)
			{
				text = Number(inputTxt.text);
				text = NumberUtils.roundNumber(text , 10);
				text--;
				inputTxt.text = text.toString();
			}
			else
			{
				text = int(inputTxt.text);
				text--;
				inputTxt.text = text.toString();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose(): void
		{
			super.dispose();
			background = null;
			bottomSquare = null;
			topSquare = null;
			topTriangle = null;
			bottomTriangle = null;
			txt = null;
			inputTxt = null;
			ts = null;
		}
		
}
}