package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.ContainerDisplay;
	import com.gestureworks.cml.interfaces.IContainer;
	
	public class Container extends ContainerDisplay implements IContainer
	{				
		
		public function Container()
		{
			super();
		}	
		
		private var _layout:String;
		/**
		 * 
		 */
		public function get layout():String {return _layout;}
		public function set layout(value:String):void 
		{
			_layout = value;
		}
		

	}
}