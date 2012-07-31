package com.gestureworks.cml.element 
{
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.GestureWorks;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Stack extends TouchContainer 
	{
		
		public function Stack() 
		{
			super();
		}
		 
		
		private var _toggle:String = "up";
		/**
		 * sets toggle event by string name:
		 * mouseOver, mouseDown, mouseUp, touchDown, touchUp, down, and up 
		 * (the last two auto-switch between input device)
		 * @default up
		 */		
		public function get toggle():String {return _toggle}
		public function set toggle(value:String):void 
		{			
			_toggle = value;		
		}			
		
		
		private var _loop:Boolean = true;
		/**
		 * Specifies whether the stack loops to the beginning and continues while toggling
		 */		
		public function get loop():Boolean {return _loop}
		public function set loop(value:Boolean):void 
		{			
			_loop = value;		
		}	
		
		
		// public methods //
		
		/**
		 * Initialization method
		 */
		public function init():void
		{
			displayComplete();
		}
		
		/**
		 * Resets the stack order
		 */		
		public function reset():void
		{
			childList.reset();
		}
		
		/**
		 * CML initialization method
		 * @internal do not call the super here
		 */
		override public function displayComplete():void
		{			
			// hide all but first child
			for (var i:int = 1; i < childList.length; i++) 
			{
				hideIndex(i);
			}
			
			childList.reset();
			
			if (toggle == "mouseOver")
				this.addEventListener(MouseEvent.MOUSE_OVER, onToggle);	
			
			else if (toggle == "mouseDown")
				this.addEventListener(MouseEvent.MOUSE_DOWN, onToggle);
				
			else if (toggle == "mouseUp")
				this.addEventListener(MouseEvent.MOUSE_UP, onToggle);	
				
			else if (toggle == "touchDown")
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onToggle);
				
			else if (toggle == "touchUp")
				this.addEventListener(TouchEvent.TOUCH_END, onToggle);
				
			else if (toggle == "down")
			{
				if (GestureWorks.activeTUIO)
					this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onToggle);
				else if (GestureWorks.supportsTouch)
					this.addEventListener(TouchEvent.TOUCH_BEGIN, onToggle);
				else
					this.addEventListener(MouseEvent.MOUSE_DOWN, onToggle);
			}
			else if (toggle == "up")
			{
				if (GestureWorks.activeTUIO)
					this.addEventListener(TuioTouchEvent.TOUCH_UP, onToggle);
				else if (GestureWorks.supportsTouch)
					this.addEventListener(TouchEvent.TOUCH_END, onToggle);
				else
					this.addEventListener(MouseEvent.MOUSE_UP, onToggle);
			}			
		}		
			

		// event handlers // 
		
		private function onToggle(event:*):void
		{			
			if (childList.hasNext() && !(childList.getIndex(childList.currentIndex + 1) is GestureList))
			{
				childList.currentValue.visible = false
				childList.next().visible = true;
			}
			else if (loop)
			{
				childList.currentValue.visible = false				
				childList.reset();
				childList.currentValue.visible = true				
			}
							
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "toggle", cmlIndex, true, true));			
		}
		
	}
}