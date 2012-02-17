package com.gestureworks.cml.element
{	
	import com.gestureworks.core.DisplayList;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;


	public class Button extends Container
	{		
		public function Button()
		{
			super();
		}		
		
		private var _mouseDown:String;
		/**
		 * Sets button state association with mouse down event
		 */
		public function get mouseDown():String {return _mouseDown;}
		public function set mouseDown(value:String):void 
		{
			trace(value);
			
			_mouseDown = value;			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);												
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);									
		}
		
			
		private function onMouseDown(e:MouseEvent):void
		{
			trace(childList.getKey(mouseDown));

		}
		
		
		
	}
}