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
		
		private var _position:String;
		/**
		 * 
		 */
		public function get position():String {return _position;}
		public function set position(value:String):void 
		{
			_position = value;
		}
		
		private var _paddingX:Number;
		/**
		 * 
		 */
		public function get paddingX():Number {return _paddingX;}
		public function set paddingX(value:Number):void 
		{
			_paddingX = value;
		}	
		
		private var _paddingY:Number;
		/**
		 * 
		 */
		public function get paddingY():Number {return _paddingY;}
		public function set paddingY(value:Number):void 
		{
			_paddingY = value;
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