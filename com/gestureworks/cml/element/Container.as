package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.managers.*;	
	import com.gestureworks.cml.loaders.*;	
	
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
		
		
			
		public function showIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}
		
		public function hideIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}		
			
		public function showKey(key:String):void
		{
			childList.getKey(key).visible = true;
		}
				
		public function hideKey(key:String):void
		{
			childList.getKey(key).visible = false;
		}
		
		public function getKey(key:String):*
		{
			return childList.getKey(key);
		}
			
		public function getIndex(index:int):*
		{
			return childList.getIndex(index);
		}
		
	
	}
}