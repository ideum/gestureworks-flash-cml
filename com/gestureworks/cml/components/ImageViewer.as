package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	
	/**
	 * ...
	 * @author Charles Veasey
	 */
	public class ImageViewer extends Component 
	{
		
		public function ImageViewer() 
		{
			super();			
		}
		
		override public function displayComplete():void
		{
			//this.addEventListener(StateEvent.CHANGE, onStateEvent)
			
			// hide all but first and not menu
			/*
			for (var i:int = 1; i < childList.length; i++) 
			{
				if (!(childList.getIndex(i) is Menu))
					hideIndex(i);
			}
			*/
		}		
		
		/*
		private function onStateEvent(event:StateEvent):void
		{			
			if (event.value == "info")
				toggle();
			else if (event.value == "flip")
				toggle();
			else if (event.value == "close")
				this.visible = false;
		}		
	
		
		private function toggle():void
		{
			if (childList.hasNext() 
				&& !(childList.getIndex(childList.currentIndex + 1) is GestureList)
				&& !(childList.getIndex(childList.currentIndex + 1) is Menu))
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
							
		}		
		*/		
		
	}
	
}