package com.gestureworks.cml.element
{
	
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import flash.events.MouseEvent;
	import com.gestureworks.core.GestureWorks;
	
	/**
	 * The Switch is a UIelement that acts as a Switch button.
	 * It has the following parameters: backgroundfillColor, backgroundoutlineColor, backgroundlineStroke, backgroundX, backgroundY, backgroundWidth, backgroundHeight, backgroundEllipseWidth,backgroundEllipseHeight, buttonfillColor, buttonoutlineColor, buttonlineStroke, buttonX, buttonY, buttonWidth, buttonHeight, buttonEllipseWidth, buttonEllipseHeight.
	 *
	 * <code>
	 *
	 * var switch1:Switch = new Switch();
	
	   switch1.backgroundfillColor = 0x333333;
	   switch1.backgroundoutlineColor = 0xFF0000;
	   switch1.backgroundlineStroke = 3;
	   switch1.buttonfillColor = 0x000000;
	   switch1.buttonoutlineColor = 0x000000;
	   switch1.buttonlineStroke = 1;
	   switch1.backgroundX = 0;
	   switch1.backgroundY = 0;
	   switch1.backgroundWidth = 100;
	   switch1.backgroundHeight = 50;
	   switch1.backgroundEllipseWidth = 25;
	   switch1.backgroundEllipseHeight = 25;
	   switch1.buttonX = 0;
	   switch1.buttonY = 0;
	   switch1.buttonWidth = 50;
	   switch1.buttonHeight = 50;
	   switch1.buttonEllipseWidth = 25;
	   switch1.buttonEllipseHeight = 25;
	   switch1.x = 20;
	   switch1.y = 20;
	
	   addChild(switch1);
	 *
	 *
	 * </code>
	 */
	public class Switch extends ElementFactory
	{
		/**
		 * Switch constructor.Allow user to define switch button with drag and tap functionality.
		 */
		public function Switch()
		{
			super();
		}
		
		/**
		 * CML display initialization callback
		 */
		public override function displayComplete():void
		{
			super.displayComplete();
			init();
		}
		
		public var background:Sprite = new Sprite();
		public var button:Sprite = new Sprite();
		public var state:Boolean = false;
		
		private var _backgroundfillColor:uint = 0xFFFFFF;
		
		/**
		 * Sets the background inside color of the Rounded Rectangle
		 * @default = 0xFFFFFF;
		 */
		public function get backgroundfillColor():uint
		{
			return _backgroundfillColor;
		}
		
		public function set backgroundfillColor(value:uint):void
		{
			_backgroundfillColor = value;
			displayButton();
		}
		
		private var _backgroundoutlineColor:uint = 0x333333;
		
		/**
		 * Sets the background outline color of Rounded Rectangle
		 * @default = 0x333333;
		 */
		public function get backgroundoutlineColor():uint
		{
			return _backgroundoutlineColor;
		}
		
		public function set backgroundoutlineColor(value:uint):void
		{
			_backgroundoutlineColor = value;
			displayButton();
		}
		
		private var _backgroundlineStroke:Number = 3;
		
		/**
		 * Sets the background linestroke of the Rounded Rectangle
		 *  @default = 3;
		 */
		public function get backgroundlineStroke():Number
		{
			return _backgroundlineStroke;
		}
		
		public function set backgroundlineStroke(value:Number):void
		{
			_backgroundlineStroke = value;
			displayButton();
		}
		
		private var _buttonfillColor:uint = 0x000000;
		
		/**
		 * Sets the button inside color of the Rounded Rectangle
		 * @default = 0x000000;
		 */
		public function get buttonfillColor():uint
		{
			return _buttonfillColor;
		}
		
		public function set buttonfillColor(value:uint):void
		{
			_buttonfillColor = value;
			displayButton();
		}
		
		private var _buttonoutlineColor:uint = 0x000000;
		
		/**
		 * Sets the button outline color of Rounded Rectangle
		 * @default = 0x000000;
		 */
		public function get buttonoutlineColor():uint
		{
			return _buttonoutlineColor;
		}
		
		public function set buttonoutlineColor(value:uint):void
		{
			_buttonoutlineColor = value;
			displayButton();
		}
		
		private var _buttonlineStroke:Number = 1;
		
		/**
		 * Sets the button line stroke of the Rounded Rectangle
		 *  @default = 1;
		 */
		public function get buttonlineStroke():Number
		{
			return _buttonlineStroke;
		}
		
		public function set buttonlineStroke(value:Number):void
		{
			_buttonlineStroke = value;
			displayButton();
		}
		
		private var _backgroundX:Number = 0;
		
		/**
		 * Sets the background X position of Rounded Rectangle
		 * @default = 0;
		 */
		public function get backgroundX():uint
		{
			return _backgroundX;
		}
		
		public function set backgroundX(value:uint):void
		{
			_backgroundX = value;
			displayButton();
		}
		
		private var _backgroundY:Number = 0;
		
		/**
		 * Sets the background Y position of Rounded Rectangle
		 * @default = 0;
		 */
		public function get backgroundY():uint
		{
			return _backgroundY;
		}
		
		public function set backgroundY(value:uint):void
		{
			_backgroundY = value;
			displayButton();
		}
		
		private var _backgroundWidth:Number = 100;
		
		/**
		 * Sets the background Width  of Rounded Rectangle
		 * @default = 100;
		 */
		public function get backgroundWidth():uint
		{
			return _backgroundWidth;
		}
		
		public function set backgroundWidth(value:uint):void
		{
			_backgroundWidth = value;
			displayButton();
		}
		
		private var _backgroundHeight:Number = 50;
		
		/**
		 * Sets the background Height of Rounded Rectangle
		 *  @default = 50;
		 */
		public function get backgroundHeight():Number
		{
			return _backgroundHeight;
		}
		
		public function set backgroundHeight(value:Number):void
		{
			_backgroundHeight = value;
			displayButton();
		}
		
		private var _backgroundEllipseWidth:Number = 25;
		
		/**
		 * Sets the background Ellipse Width  of Rounded Rectangle
		 * @default = 25;
		 */
		public function get backgroundEllipseWidth():uint
		{
			return _backgroundEllipseWidth;
		}
		
		public function set backgroundEllipseWidth(value:uint):void
		{
			_backgroundEllipseWidth = value;
			displayButton();
		}
		
		private var _backgroundEllipseHeight:Number = 25;
		
		/**
		 * Sets the background Ellipse Height of Rounded Rectangle
		 *  @default = 25;
		 */
		public function get backgroundEllipseHeight():Number
		{
			return _backgroundEllipseHeight;
		}
		
		public function set backgroundEllipseHeight(value:Number):void
		{
			_backgroundEllipseHeight = value;
			displayButton();
		}
		
		private var _buttonX:Number = 0;
		
		/**
		 * Sets the button X position of Rounded Rectangle
		 * @default = 0;
		 */
		public function get buttonX():uint
		{
			return _buttonX;
		}
		
		public function set buttonX(value:uint):void
		{
			_buttonX = value;
			displayButton();
		}
		
		private var _buttonY:Number = 0;
		
		/**
		 * Sets the button Y position of Rounded Rectangle
		 * @default = 0;
		 */
		public function get buttonY():uint
		{
			return _buttonY;
		}
		
		public function set buttonY(value:uint):void
		{
			_buttonY = value;
			displayButton();
		}
		
		private var _buttonWidth:Number = 50;
		
		/**
		 * Sets the button Width  of Rounded Rectangle
		 * @default = 50;
		 */
		public function get buttonWidth():uint
		{
			return _buttonWidth;
		}
		
		public function set buttonWidth(value:uint):void
		{
			_buttonWidth = value;
			displayButton();
		}
		
		private var _buttonHeight:Number = 50;
		
		/**
		 * Sets the button Height of Rounded Rectangle
		 *  @default = 50;
		 */
		public function get buttonHeight():Number
		{
			return _buttonHeight;
		}
		
		public function set buttonHeight(value:Number):void
		{
			_buttonHeight = value;
			displayButton();
		}
		
		private var _buttonEllipseWidth:Number = 25;
		
		/**
		 * Sets the button Ellipse Width  of Rounded Rectangle
		 * @default = 25;
		 */
		public function get buttonEllipseWidth():uint
		{
			return _buttonEllipseWidth;
		}
		
		public function set buttonEllipseWidth(value:uint):void
		{
			_backgroundEllipseWidth = value;
			displayButton();
		}
		
		private var _buttonEllipseHeight:Number = 25;
		
		/**
		 * Sets the button Ellipse Height of Rounded Rectangle
		 *  @default = 25;
		 */
		public function get buttonEllipseHeight():Number
		{
			return _buttonEllipseHeight;
		}
		
		public function set buttonEllipseHeight(value:Number):void
		{
			_buttonEllipseHeight = value;
			displayButton();
		}
		
		/**
		 * Initializes the configuration and display of the Switch
		 */
		public function init():void
		{
			displayButton();
		}
		
		public function displayButton():void
		{
			
			this.mouseChildren = true;
			
			background.graphics.lineStyle(backgroundlineStroke, backgroundoutlineColor);
			background.graphics.beginFill(backgroundfillColor);
			background.graphics.drawRoundRect(backgroundX, backgroundY, backgroundWidth, backgroundHeight, backgroundEllipseWidth, backgroundEllipseHeight);
			background.graphics.endFill();
			
			button.graphics.lineStyle(buttonlineStroke, buttonoutlineColor);
			button.graphics.beginFill(buttonfillColor);
			button.graphics.drawRoundRect(buttonX, buttonY, buttonWidth, buttonHeight, buttonEllipseWidth, buttonEllipseHeight);
			button.graphics.endFill();
			button.visible = true;
			
			var touchSprite:TouchSprite = new TouchSprite();
			touchSprite.gestureReleaseInertia = false;
			touchSprite.gestureEvents = true;
			touchSprite.mouseChildren = false;
			touchSprite.disableNativeTransform = true;
			touchSprite.disableAffineTransform = false;
			touchSprite.gestureList = {"n-drag": true, "n-tap": true};
			touchSprite.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			//touchSprite.addEventListener(TouchEvent.TOUCH_END, onEnd);
			//touchSprite.addEventListener(TouchEvent.TOUCH_OUT, onEnd);
			
			if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TOUCH_UP, onEnd);
			else if (GestureWorks.supportsTouch)
				this.addEventListener(TouchEvent.TOUCH_END, onEnd);
			else
				this.addEventListener(MouseEvent.MOUSE_UP, onEnd);
			
			if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TOUCH_OUT, onEnd);
			else if (GestureWorks.supportsTouch)
				this.addEventListener(TouchEvent.TOUCH_OUT, onEnd);
			else
				this.addEventListener(MouseEvent.MOUSE_OUT, onEnd);
			
			var touchSpriteBg:TouchSprite = new TouchSprite();
			touchSpriteBg.gestureReleaseInertia = false;
			touchSpriteBg.gestureEvents = true;
			touchSpriteBg.mouseChildren = false;
			touchSpriteBg.disableNativeTransform = true;
			touchSpriteBg.disableAffineTransform = false;
			touchSpriteBg.gestureList = {"n-tap": true};
			touchSpriteBg.addEventListener(GWGestureEvent.TAP, onTap);
			
			touchSpriteBg.addChild(background);
			addChild(touchSpriteBg);
			
			addChild(touchSprite);
			touchSprite.addChild(button);
			
			minButtonPos = background.x;
			maxButtonPos = background.width - button.width;
		}
		
		private var minButtonPos:Number;
		private var maxButtonPos:Number;
		
		private function gestureDragHandler(event:GWGestureEvent):void
		{
			
			if ((event.value.dx + button.x) > maxButtonPos)
			{
				button.x = maxButtonPos;
				state = true;
			}
			else if ((event.value.dx + button.x) < minButtonPos)
			{
				button.x = minButtonPos;
				state = false;
			}
			else
			{
				button.x += event.value.dx;
			}
			
			if (event.value.localY < background.y || event.value.localY > background.height)
				onEnd();
		}
		
		private function onTap(event:GWGestureEvent):void
		{
			
			if (button.x < button.width)
				button.x = maxButtonPos;
			else
				button.x = minButtonPos;
		}
		
		private function onEnd(event:* = null):void
		{
			
			if (button.x + button.width / 2 >= (background.width / 2))
				button.x = maxButtonPos;
			else
				button.x = minButtonPos;
		
		}
	}
}