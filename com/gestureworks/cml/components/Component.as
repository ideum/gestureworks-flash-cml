package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.element.TouchContainer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Component extends TouchContainer 
	{
		
		public function Component() 
		{
			super();
		}
		
		override public function displayComplete():void
		{
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
		}
		

		private function onStateEvent(event:StateEvent):void
		{				
			if (event.value == "close") 
				this.visible = false;
		}			
	}

}