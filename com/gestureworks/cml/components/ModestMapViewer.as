package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.ModestMap;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The ModestMapViewer component displays an ModestMap on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the ModestMap element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.ModestMap
	 */	
	public class ModestMapViewer extends Component 
	{
		/**
		 * Initialization function
		 */
		override public function init():void {			

			//search for local instance
			if (!front){
				front = displayByTagName(ModestMap);
			}	
			
			//listen for map load
			if (front) {
				front.addEventListener(StateEvent.CHANGE, onLoad);
			}
			
			super.init();
		}	
		
		/**
		 * Update layout on image load
		 * @param	event
		 */
		private function onLoad(event:StateEvent):void {
			if (event.property == MediaStatus.LOADED) {
				front.removeEventListener(StateEvent.CHANGE, onLoad);
				updateLayout();
			}
		}		
	}
	
}