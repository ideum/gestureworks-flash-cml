package com.gestureworks.cml.element
{	
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * View
	 * Views are the main display container, default set to the stage size 
	 * @author Charles Veasey
	 */	
	
	public class View extends Container
	{		
		public function View() 
		{
			super();
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);				
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);			
			this.width = stage.width;
			this.height = stage.height;
		}		
		
		
	}
}