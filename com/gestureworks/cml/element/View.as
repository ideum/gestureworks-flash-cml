package com.gestureworks.cml.element
{	
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
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
		
        public function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);			
			this.width = stage.width;
			this.height = stage.height;
		}		
		override public function dispose():void
		{
			super.dispose();
			removeEventListener(Event.ADDED_TO_STAGE, init);	
		}
		
	}
}