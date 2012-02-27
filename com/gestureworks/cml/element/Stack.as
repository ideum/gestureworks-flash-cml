package com.gestureworks.cml.element 
{
	
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;		
	
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
		 
		
		private var _toggle:String;
		/**
		 * Sets button state association with mouse over event
		 */		
		public function get toggle():String {return _toggle}
		public function set toggle(value:String):void 
		{			
			_toggle = value;		
		}			
		
		
		/**
		 * CML display initialization callback
		 * @internal do not call the super here
		 */
		override public function displayComplete():void
		{			
			// hide all but first button
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
		}		
		
		
		
		
		
		////////////////////////////////////////////////////
		/// EVENT HANDLER
		///////////////////////////////////////////////////		
		
		private function onToggle(event:*):void
		{
			if (childList.hasNext() && !(childList.getIndex(childList.currentIndex + 1) is GestureList))
			{
				childList.currentValue.visible = false
				childList.next().visible = true;
			}
			else
			{
				childList.currentValue.visible = false				
				childList.reset();
				childList.currentValue.visible = true				
			}
							
			//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchDown", true, true));			
		}
		
		
		
	}

}