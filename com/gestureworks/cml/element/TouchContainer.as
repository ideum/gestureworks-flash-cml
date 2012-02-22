package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.TouchContainerDisplay;
	
	public class TouchContainer extends TouchContainerDisplay
	{	
		public function TouchContainer()
		{
			super();
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
		
	}
}