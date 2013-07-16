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
	 * The Toggle element acts as a toggle button. It adds a crossline graphic inside of square when toggled.
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
	 * </codeblock>
	 */
	public class Toggle extends ElementFactory
	{
		
		/**
		 * Constructor
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
		
		
		private var _width:Number = 100;
		/**
		 * Sets width of the display object in pixels
		 * @default 100
		 */
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		
		private var _height:Number = 100;
		/**
		 * Sets height of the display object in pixels
		 * @default 100
		 */		
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}			
		
		
		private var _backgroundLineAlpha:Number = 1.0;
		/**
		 * Sets alpha of the background line 
		 * @default 100
		 */		
		public function get backgroundLineAlpha():Number{return _backgroundLineAlpha;}
		public function set backgroundLineAlpha(value:Number):void
		{
			_backgroundLineAlpha = value;
			draw();
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
		 * @default 0x333333
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
		 * @default 0x00ff00
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
		 *  @default  1
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
		 *  @default 1
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
		
		private var _toggleColor:uint = 0x00FF00;
		
		/**
		 * Sets the toggle color of the background
		 *  @default 0x00FF00
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
		override public function init():void
		{
			draw();
		
		}
		
		/**
		 * Draws the background and x graphic in background 
		 */
		
		public function draw():void
		{
			background.graphics.clear();
			if (backgroundLineStoke) 
				background.graphics.lineStyle(backgroundLineStoke, backgroundLineColor, backgroundLineAlpha);
			background.graphics.beginFill(backgroundColor);
			background.graphics.drawRect(0, 0, _width, _height);
			background.graphics.endFill();
			
			addChild(background);
			
			toggleGraphic.graphics.clear();
			toggleGraphic.graphics.lineStyle(toggleLineStoke, _toggleColor);
			toggleGraphic.graphics.moveTo(0, _height);
			toggleGraphic.graphics.lineTo(_width, 0);
			toggleGraphic.graphics.moveTo(0, 0);
			toggleGraphic.graphics.lineTo(_width, _height);
			
			toggleGraphic.visible = false
			addChild(toggleGraphic);
	
			
			if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchBegin);
			else if (GestureWorks.activeNativeTouch)
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			else
				this.addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		
		}
		
		/**
		 * Visibility of x graphic in background 
		 */
		
		private function onTouchBegin(event:TouchEvent):void
		{
			toggleGraphic.visible = !toggleGraphic.visible;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", toggleGraphic.visible));
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			background = null;
            toggleGraphic = null;
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchBegin);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		}
	
	}
}