package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	
	/** 
	 * The Image class loads and displays an external bitmap file.
	 * 
	 * @includeExample ImageElementExample.as -noswf
	 *
	 * @author Charles Veasey
	 * @langversion 3.0
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * 
	 * @see com.gestureworks.cml.factories.BitmapFactory
	 * @see com.gestureworks.cml.factories.ElementFactory
	 * @see com.gestureworks.cml.factories.ObjectFactory
	 */	 	
	public class ImageElement extends BitmapFactory
	{				
		public function ImageElement() 
		{						
			super();
		}
		public function init():void
		{
			
		}
		
		override protected function bitmapComplete():void 
		{						
			dispatchEvent(new Event(Event.COMPLETE, true, true));
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}