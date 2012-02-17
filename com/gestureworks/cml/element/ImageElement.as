package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.BitmapFactory;
	import flash.events.Event;
	
	public class ImageElement extends BitmapFactory
	{				
		public function ImageElement() 
		{						
			super();
		}
		
		override protected function bitmapComplete():void 
		{						
			dispatchEvent(new Event(displayEvents));
		}
		
	}
}