package com.gestureworks.cml.layouts 
{
	import away3d.core.light.DirectionalLight;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.events.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class StackLayout extends LayoutFactory 
	{
		
		public function StackLayout() 
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
		
		private var arr:Array = [];
		
		/**
		 * Apply layout type to container object
		 * Object passed must implement IContainer
		 * @param	type
		 * @param	container
		 */
		override public function layout(container:IContainer):void
		{
			var c:* = container;
			
			
			// hide all but first button
			for (var i:int = 1; i < c.childList.length; i++) 
			{
				c.hideIndex(i);
			}
			
			c.childList.reset();
			
			if (toggle == "mouseOver")
				c.addEventListener(MouseEvent.MOUSE_OVER, onToggle);	
			
			else if (toggle == "mouseDown")
				c.addEventListener(MouseEvent.MOUSE_DOWN, onToggle);
				
			else if (toggle == "mouseUp")
				c.addEventListener(MouseEvent.MOUSE_UP, onToggle);	
				
			else if (toggle == "touchDown")
				c.addEventListener(TouchEvent.TOUCH_BEGIN, onToggle);
			
			// list of containers - used for event referencing
			arr[c.cmlIndex] = c;
		}		
		
		
		////////////////////////////////////////////////////
		/// EVENT HANDLER
		///////////////////////////////////////////////////		
		
		private function onToggle(event:*):void
		{			
			var cmlIndex:int = event.currentTarget.cmlIndex;
			var c:* = arr[cmlIndex];			
			
			if (c.childList.hasNext() && !(c.childList.getIndex(c.childList.currentIndex + 1) is GestureList))
			{
				c.childList.currentValue.visible = false
				c.childList.next().visible = true;
			}
			else
			{
				c.childList.currentValue.visible = false				
				c.childList.reset();
				c.childList.currentValue.visible = true				
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "toggle", cmlIndex, true, true));			
		}		
		
		
	}

}