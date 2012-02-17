package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	
	/**
	 * ...
	 * @author  
	 */
	
	public class EvalButton extends ElementFactory
	{
		
		public function EvalButton() 
		{
			super();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			graphics.beginFill(0);
			graphics.drawCircle(0, 0, 30);
			graphics.endFill();
			
			//addEventListener(TouchEvent.TOUCH_BEGIN
				
			// entry point
		}
		
	}

}