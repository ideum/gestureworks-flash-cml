package com.gestureworks.cml.element
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.core.GestureWorks;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * The Toggle is a element that acts as a toggle button.
	 * It has the following parameters: fillColor, backgroundLineColor, backgroundLineStoke, toggleColor and toggleLineStoke.
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var toggle:Toggle = new Toggle();
	   toggle.fillColor = 0x333333;
	   toggle.backgroundLineColor = 0xFF0000;
	   toggle.toggleLineStoke = 4;
	   toggle.x = 100;
	   toggle.y = 100;
	   addChild(toggle);
	
	   toggle.addEventListener(StateEvent.CHANGE, onToggle);
	
	   var txt:TextElement = new TextElement;
	   txt.text = "hello";
	   txt.x = 200;
	   txt.y = 130;
	   txt.visible = false;
	   addChild(txt);
	
	   function onToggle(event:StateEvent):void
	   {
	   trace("toggle text", event.value);
	
	   if (event.value == "true")
	   txt.visible = true;
	   else
	   txt.visible = false;
	   }
	 *
	 *
	 * </codeblock>
	 */
	public class Toggle extends ElementFactory
	{
		
		/**
		 * Toggle constructor. Allows user to define toggle button.
		 */
		public function Toggle()
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
		
		/**
		 * Defines the square background
		 */
		public var background:Sprite = new Sprite();
		
		/**
		 * The "x" graphic in the background
		 */
		public var toggleGraphic:Sprite = new Sprite();
		
		private var _backgroundColor:uint = 0x333333;
		
		/**
		 * Sets the inside color of the background
		 * @default = 0x333333;
		 */
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
			draw();
		}
		
		private var _backgroundLineColor:uint = 0x00ff00;
		
		/**
		 * Sets the color of the background line color
		 * @default = 0x00ff00;
		 */
		public function get backgroundLineColor():uint
		{
			return _backgroundLineColor;
		}
		
		public function set backgroundLineColor(value:uint):void
		{
			_backgroundLineColor = value;
			draw();
		}
		
		private var _backgroundLineStoke:Number = 1;
		
		/**
		 * Sets the background Line Stoke
		 *  @default = 1;
		 */
		public function get backgroundLineStoke():Number
		{
			return _backgroundLineStoke;
		}
		
		public function set backgroundLineStoke(value:Number):void
		{
			_backgroundLineStoke = value;
			draw();
		}
		
		private var _toggleLineStoke:Number = 1;
		
		/**
		 * Sets the toggle Line Stoke of the background
		 *  @default = 1;
		 */
		public function get toggleLineStoke():Number
		{
			return _toggleLineStoke;
		}
		
		public function set toggleLineStoke(value:Number):void
		{
			_toggleLineStoke = value;
			draw();
		}
		
		private var _toggleColor:uint = 0x00ff00;
		
		/**
		 * Sets the toggle color of the background
		 *  @default = 1;
		 */
		public function get toggleColor():uint
		{
			return _toggleColor;
		}
		
		public function set toggleColor(value:uint):void
		{
			_toggleColor = value;
			draw();
		}
		
		/**
		 * Initializes the configuration and display of the toggle
		 */
		public function init():void
		{
			draw();
		
		}
		
		/**
		 * draws the background and x graphic in background 
		 */
		
		public function draw():void
		{
			
			background.graphics.lineStyle(backgroundLineStoke, backgroundLineColor);
			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRect(50, 50, 100, 100);
			background.graphics.endFill();
			
			addChild(background);
			
			toggleGraphic.graphics.lineStyle(toggleLineStoke, toggleColor);
			toggleGraphic.graphics.moveTo(50, 150);
			toggleGraphic.graphics.lineTo(150, 50);
			toggleGraphic.graphics.moveTo(50, 50);
			toggleGraphic.graphics.lineTo(150, 150);
			
			toggleGraphic.visible = false
			addChild(toggleGraphic);
			
			if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchBegin);
			else if (GestureWorks.supportsTouch)
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			else
				this.addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		
		}
		
		/**
		 * visibility of x graphic in background 
		 */
		
		private function onTouchBegin(event:TouchEvent):void
		{
			toggleGraphic.visible = !toggleGraphic.visible;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", toggleGraphic.visible));
		}
	
	}
}