package com.gestureworks.cml.elements
{
	
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Sprite;
	
	/**
	 * The Switch element is acts as a switch button.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	   
		var switch:Switch = new Switch();
		switch.backgroundColor = 0x333333;
		switch.backgroundoutlineColor = 0xFF0000;
		switch.backgroundlineStroke = 3;
		switch.buttonColor = 0x000000;
		switch.buttonoutlineColor = 0x000000;
		switch.buttonlineStroke = 1;
		switch.backgroundWidth = 100;
		switch.backgroundHeight = 50;
		switch.backgroundEllipseWidth = 25;
		switch.backgroundEllipseHeight = 25;
		switch.buttonWidth = 50;
		switch.buttonHeight = 50;
		switch.buttonEllipseWidth = 25;
		switch.buttonEllipseHeight = 25;
		switch.x = 20;
		switch.y = 20;
	    addChild(switch);

	 * </codeblock>
	 * 
	 * @author Uma
	 * @see Toggle
	 * @see Button
	 */
	public class Switch extends TouchContainer
	{
		private var minButtonPos:Number;
		private var maxButtonPos:Number;
		
		/**
		 * Switch Constructor.
		 */
		public function Switch()
		{
			super();
		}

		/**
		 * Defines the background which is a rectangle
		 */
		public var background:Sprite = new Sprite();
		
		/**
		 * Defines the button of background
		 */
		public var button:Sprite = new Sprite();
		
		/**
		 * Defines the button state
		 */
		public var toggleState:Boolean = false;
		
		private var _backgroundColor:uint = 0xFFFFFF;
		
		/**
		 * Sets the background inside color of the Rounded Rectangle
		 * @default 0xFFFFFF
		 */
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		private var _backgroundoutlineColor:uint = 0x333333;
		
		/**
		 * Sets the background outline color of Rounded Rectangle
		 * @default 0x333333
		 */
		public function get backgroundoutlineColor():uint
		{
			return _backgroundoutlineColor;
		}
		
		public function set backgroundoutlineColor(value:uint):void
		{
			_backgroundoutlineColor = value;
		}
		
		private var _backgroundlineStroke:Number = 3;
		
		/**
		 * Sets the background linestroke of the Rounded Rectangle
		 *  @default 3
		 */
		public function get backgroundlineStroke():Number
		{
			return _backgroundlineStroke;
		}
		
		public function set backgroundlineStroke(value:Number):void
		{
			_backgroundlineStroke = value;
		}
		
		private var _buttonColor:uint = 0x000000;
		
		/**
		 * Sets the button inside color of the Rounded Rectangle
		 * @default 0x000000
		 */
		public function get buttonColor():uint
		{
			return _buttonColor;
		}
		
		public function set buttonColor(value:uint):void
		{
			_buttonColor = value;
		}
		
		private var _buttonoutlineColor:uint = 0x000000;
		
		/**
		 * Sets the button outline color of Rounded Rectangle
		 * @default 0x000000
		 */
		public function get buttonoutlineColor():uint
		{
			return _buttonoutlineColor;
		}
		
		public function set buttonoutlineColor(value:uint):void
		{
			_buttonoutlineColor = value;
		}
		
		private var _buttonlineStroke:Number = 1;
		
		/**
		 * Sets the button line stroke of the Rounded Rectangle
		 *  @default 1
		 */
		public function get buttonlineStroke():Number
		{
			return _buttonlineStroke;
		}
		
		public function set buttonlineStroke(value:Number):void
		{
			_buttonlineStroke = value;
		}
		
		private var _backgroundX:Number = 0;
		
		/**
		 * Sets the background X position of Rounded Rectangle
		 * @default 0
		 */
		public function get backgroundX():uint
		{
			return _backgroundX;
		}
		
		public function set backgroundX(value:uint):void
		{
			_backgroundX = value;
		}
		
		private var _backgroundY:Number = 0;
		
		/**
		 * Sets the background Y position of Rounded Rectangle
		 * @default 0
		 */
		public function get backgroundY():uint
		{
			return _backgroundY;
		}
		
		public function set backgroundY(value:uint):void
		{
			_backgroundY = value;
		}
		
		private var _backgroundWidth:Number = 100;
		
		/**
		 * Sets the background Width  of Rounded Rectangle
		 * @default 100
		 */
		public function get backgroundWidth():uint
		{
			return _backgroundWidth;
		}
		
		public function set backgroundWidth(value:uint):void
		{
			_backgroundWidth = value;
			
		}
		
		private var _backgroundHeight:Number = 50;
		
		/**
		 * Sets the background Height of Rounded Rectangle
		 *  @default 50
		 */
		public function get backgroundHeight():Number
		{
			return _backgroundHeight;
		}
		
		public function set backgroundHeight(value:Number):void
		{
			_backgroundHeight = value;
			
		}
		
		private var _backgroundEllipseWidth:Number = 25;
		
		/**
		 * Sets the background Ellipse Width  of Rounded Rectangle
		 * @default 25
		 */
		public function get backgroundEllipseWidth():uint
		{
			return _backgroundEllipseWidth;
		}
		
		public function set backgroundEllipseWidth(value:uint):void
		{
			_backgroundEllipseWidth = value;
			
		}
		
		private var _backgroundEllipseHeight:Number = 25;
		
		/**
		 * Sets the background Ellipse Height of Rounded Rectangle
		 *  @default 25
		 */
		public function get backgroundEllipseHeight():Number
		{
			return _backgroundEllipseHeight;
		}
		
		public function set backgroundEllipseHeight(value:Number):void
		{
			_backgroundEllipseHeight = value;
			
		}
		
		private var _buttonX:Number = 0;
		
		/**
		 * Sets the button X position of Rounded Rectangle
		 * @default 0
		 */
		public function get buttonX():Number
		{
			return _buttonX;
		}
		
		public function set buttonX(value:Number):void
		{
			_buttonX = value;
		//	displayButton();
		}
		
		private var _buttonY:Number = 0;
		
		/**
		 * Sets the button Y position of Rounded Rectangle
		 * @default 0
		 */
		public function get buttonY():Number
		{
			return _buttonY;
		}
		
		public function set buttonY(value:Number):void
		{
			_buttonY = value;
			
		}
		
		private var _buttonWidth:Number = 50;
		
		/**
		 * Sets the button Width  of Rounded Rectangle
		 * @default 50
		 */
		public function get buttonWidth():Number
		{
			return _buttonWidth;
		}
		
		public function set buttonWidth(value:Number):void
		{
			_buttonWidth = value;
			
		}
		
		private var _buttonHeight:Number = 50;
		
		/**
		 * Sets the button Height of Rounded Rectangle
		 *  @default 50
		 */
		public function get buttonHeight():Number
		{
			return _buttonHeight;
		}
		
		public function set buttonHeight(value:Number):void
		{
			_buttonHeight = value;
			
		}
		
		private var _buttonEllipseWidth:Number = 25;
		
		/**
		 * Sets the button Ellipse Width  of Rounded Rectangle
		 * @default 25
		 */
		public function get buttonEllipseWidth():Number
		{
			return _buttonEllipseWidth;
		}
		
		public function set buttonEllipseWidth(value:Number):void
		{
			_backgroundEllipseWidth = value;
		//	displayButton();
		}
		
		private var _buttonEllipseHeight:Number = 25;
		
		/**
		 * Sets the button Ellipse Height of Rounded Rectangle
		 *  @default 25
		 */
		public function get buttonEllipseHeight():Number
		{
			return _buttonEllipseHeight;
		}
		
		public function set buttonEllipseHeight(value:Number):void
		{
			_buttonEllipseHeight = value;
			
		}
		
		private var touchSprite:TouchSprite = new TouchSprite();
					
		/**
		 * Initializes the configuration and display of the Switch
		 */
		override public function init():void
		{
			displayButton();
		}
		
		/**
		 * creates graphics for background and button
		 */
		public function displayButton():void
		{
			this.mouseChildren = true;
			
		//	background.graphics.lineStyle(backgroundlineStroke, backgroundoutlineColor);
			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRoundRect(backgroundX, backgroundY, backgroundWidth, backgroundHeight, backgroundEllipseWidth, backgroundEllipseHeight);
			background.graphics.endFill();
			
		//	button.graphics.lineStyle(buttonlineStroke, buttonoutlineColor);
			button.graphics.beginFill(buttonColor);
			button.graphics.drawRoundRect(buttonX, buttonY, buttonWidth, buttonHeight, buttonEllipseWidth, buttonEllipseHeight);
			button.graphics.endFill();
			button.visible = true;
			
			touchSprite.gestureReleaseInertia = false;
			touchSprite.gestureEvents = true;
			touchSprite.mouseChildren = false;
			touchSprite.nativeTransform = false;
			touchSprite.affineTransform = true;
			touchSprite.gestureList = {"n-drag": true, "n-tap": true};
			touchSprite.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			touchSprite.addEventListener(GWGestureEvent.RELEASE, onEnd);
				
			var touchSpriteBg:TouchSprite = new TouchSprite();
			touchSpriteBg.releaseInertia = false;
			touchSpriteBg.gestureEvents = true;
			touchSpriteBg.mouseChildren = false;
			touchSpriteBg.nativeTransform = false;
			touchSpriteBg.affineTransform = true;
			touchSpriteBg.gestureList = { "n-tap": true };
			touchSpriteBg.addEventListener(GWGestureEvent.TAP, onTap);
					
			touchSpriteBg.addChild(background);
			addChild(touchSpriteBg);
			
			addChild(touchSprite);
			touchSprite.addChild(button);
			
			minButtonPos = background.x;
			maxButtonPos = background.width - button.width;
		}

		private function gestureDragHandler(event:GWGestureEvent):void
		{
			if ((event.value.drag_dx + button.x) > maxButtonPos)
			{
				button.x = maxButtonPos;
				toggleState = true;
			}
			else if ((event.value.drag_dx + button.x) < minButtonPos)
			{
				button.x = minButtonPos;
				toggleState = false;
			}
			else
			{
				button.x += event.value.drag_dx;
			}
		}
		
		private function onTap(event:GWGestureEvent):void
		{
			if (!toggleState) {
				button.x = maxButtonPos; 
				toggleState = true;
			}
			else {
				button.x = minButtonPos;
				toggleState = false;
			}
		    dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "state", toggleState));
		}
		
		private function onEnd(event:* = null):void
		{
			if (button.x + button.width/2 >= (background.width/2)){
				button.x = maxButtonPos;
				toggleState = true;
			}	
			else {
				button.x = minButtonPos;
				toggleState = false;
			}
				
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "state", toggleState));				
		}
		
	
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			background = null;
			button = null;
			touchSprite = null;
		}
	}
}