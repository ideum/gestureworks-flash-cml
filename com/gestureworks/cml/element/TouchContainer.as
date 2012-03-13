package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.TouchContainerDisplay;
	
	public class TouchContainer extends TouchContainerDisplay
	{	
		public function TouchContainer()
		{
			super();
			//mouseChildren = false;
		}
		
		/*
		override public function get mouseChildren():Boolean 
		{
			return super.mouseChildren;
		}
		
		override public function set mouseChildren(value:Boolean):void 
		{
			//trace("mouseChildren in touch container:", value)
			super.mouseChildren = value;
		}*/

		
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
	
		
		private var _scale:Number = 1;
		/**
		 * Scales display object
		 */	
		public function get scale():Number{return _scale;}
		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = scale;
			scaleY = scale;
		}		
		
		
	}
}