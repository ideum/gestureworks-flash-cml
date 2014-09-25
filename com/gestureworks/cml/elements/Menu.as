package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.elements.Button;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.layouts.ListLayout;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.utils.StateUtils;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * The Menu element constructs a custom menu using nested Buttons(s).
	 * It features auto-hiding and auto-positioning.
	 * 
	 * @author Ideum
	 * @see Button
	 * @see OrbMenu
	 * @see DropDownMenu
	 */
	public class Menu extends TouchContainer 
	{
		//position constants
		public static const TOP_LEFT:String = "topLeft";
		public static const TOP_RIGHT:String = "topRight";
		public static const BOTTOM_LEFT:String = "bottomLeft";
		public static const BOTTOM_RIGHT:String = "bottomRight";
		
		private var hideTimer:Timer;
		private var _autoHide:Boolean = false;		
		private var _autoHideTime:Number = 2500;
		private var _position:String = "bottomLeft";	
		private var _horizontal:Boolean = true; 
		
		private var containerWidth:Number; 
		private var containerHeight:Number; 
 
		/**
		 * Constructor
		 */
		public function Menu() 
		{
			super();
			mouseChildren = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {						
			addEventListener(StateEvent.CHANGE, onStateEvent);
			
			if (autoHide) {
				hideTimer = new Timer(autoHideTime);
				hideTimer.addEventListener(TimerEvent.TIMER, hideMenu);
			}
		}		
		
		/**
		 * Specifies whether the menu automatically hides when not in use
		 * @default false
		 */			
		public function get autoHide():Boolean { return _autoHide; }
		public function set autoHide(value:Boolean):void 
		{ 
			_autoHide = value;
			
			if (autoHide) 
				addEventListener(GWTouchEvent.TOUCH_BEGIN, startTimer);
		}
		
		/**
		 * Specifies whether the menu automatically hides when not in use
		 * @default false
		 */			
		public function get autoide():Boolean { return autoHide; }
		public function set autohide(value:Boolean):void {
			autoHide = value; 
		}
		
		/**
		 * Specifies the auto-hide time
		 * @default 2500
		 */	 		
		public function get autoHideTime():Number { return _autoHideTime; }
		public function set autoHideTime(value:Number):void { 
			_autoHideTime = value; 
		}
		
		/**
		 * Specifies where to position the menu relative to its parent. 
		 * @default bottomLeft
		 */	 		
		override public function get position():* { return _position; }
		override public function set position(value:*):void { 
			switch(String(value)) {
				case BOTTOM_LEFT:
				case BOTTOM_RIGHT:
				case TOP_LEFT:
				case TOP_RIGHT:
					_position = value;
					break;
				default:
					trace("Unsupported position: " + value + "; Reverting to default");
					break;
			} 
		}	
		
		/**
		 * Determines if layout is horizontal or vertical. Setting is ignored for custom layouts. 
		 * @default true
		 */
		public function get horizontal():Boolean { return _horizontal; }
		public function set horizontal(value:Boolean):void {
			_horizontal = value; 
		}
		
		/**
		 * If autoHide on, starts timer
		 */
		public function startTimer(event:* = null):void {	
			visible = true; 
			if (autoHide) {
				hideTimer.reset();
				hideTimer.start();
			}
		}	
		
		/**
		 * Hide menu when <code>autoHide</code> is enabled and <code>autoHideTime</code> expires
		 * @param	e
		 */
		private function hideMenu(e:TimerEvent):void {
			visible = false; 
		}
		
		/**
		 * Handle menu button states
		 * @param	e
		 */
		private function onStateEvent(e:StateEvent):void {
			for (var i:int = 0; i < numChildren; i++) {
				if(getChildAt(i) is Button) {
					Button(getChildAt(i)).onFlip(e);
				}
			}
		}	
		
		/**
		 * Reset menu buttons
		 */
		public function reset():void { 
			StateUtils.loadState(this, 0, true);
			for (var i:int = 0; i < this.numChildren; i++) {
				if (getChildAt(i) is Button) {
					Button(getChildAt(i)).reset();
				}
			}
		}
		
		/**
		 * Sets the layout depending on the position and provided dimensions
		 * @param	containerWidth
		 * @param	containerHeight
		 */
		public function updateLayout(containerWidth:Number = NaN, containerHeight:Number = NaN):void {	
			this.containerWidth = containerWidth;
			this.containerHeight = containerHeight;
			applyLayout();
		}
		
		/**
		 * When layout is not provided, generate default layout based on <code>position</code> and padding 
		 * @param	value
		 */
		override public function applyLayout(value:* = null):void {
			if (!layout) {				
				layout = new ListLayout();
				layout.type = horizontal ? "horizontal" : "vertical";
				layout.useMargins = true; 
				layout.marginX = paddingLeft + paddingRight;
				layout.marginY = paddingTop + paddingBottom;
			}
			Layout(layout).onComplete = positionMenu;
			super.applyLayout(value);
		}
		
		/**
		 * Positions menu after layout is applied according to <code>position</code> and padding 
		 */
		private function positionMenu():void {
			
			//default to parent dimensions when not specified
			if (isNaN(containerWidth) && parent) {
				containerWidth = parent.width;
			}
			if (isNaN(containerHeight) && parent) {
				containerHeight = parent.height;
			}
			
			var rect:Rectangle = getRect(this);
			switch(position) {
				case BOTTOM_LEFT:	
					x = paddingLeft;
					y = containerHeight - rect.height - paddingBottom;
					break;
				case BOTTOM_RIGHT:
					x = containerWidth - rect.width - paddingRight;
					y = containerHeight - rect.height - paddingBottom;
					break;
				case TOP_LEFT:
					x = paddingLeft;
					y = paddingTop;					
					break;
				case TOP_RIGHT:
					x = containerWidth - rect.width - paddingRight;
					y = paddingTop;
					break;
				default:
					break;
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {
			var clone:Menu = super.clone();			
			return clone;
		}		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			hideTimer.stop();
			hideTimer = null;
			super.dispose();
		}		
	}
}