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
		
		private var _paddingLeft:Number;
		/**
		 * 
		 */
		public function get paddingLeft():Number {return _paddingLeft;}
		public function set paddingLeft(value:Number):void 
		{
			_paddingLeft = value;
		}	
		
		private var _paddingRight:Number;
		/**
		 * 
		 */
		public function get paddingRight():Number {return _paddingRight;}
		public function set paddingRight(value:Number):void 
		{
			_paddingRight = value;
		}	
		
		private var _paddingTop:Number;
		/**
		 * 
		 */
		public function get paddingTop():Number {return _paddingTop;}
		public function set paddingTop(value:Number):void 
		{
			_paddingTop = value;
		}	
		
		private var _paddingBottom:Number;
		/**
		 * 
		 */
		public function get paddingBottom():Number {return _paddingBottom;}
		public function set paddingBottom(value:Number):void 
		{
			_paddingBottom = value;
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