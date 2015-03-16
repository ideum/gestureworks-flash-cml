package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.Audio;
	import com.gestureworks.cml.events.StateEvent;
		
	/**
	 * The AudioPlayer component displays an Audio element on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Audio element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Audio
	 */	 	
	public class AudioPlayer extends Component 
	{					
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			
			//search for local instance
			if (!front) {
				front = displayByTagName(Audio);
			}
			
			if (front && !(Audio(front).isLoaded)) {
				front.addEventListener(StateEvent.CHANGE, onLoad);
			}
			
			super.init();
		}		
		
		/**
		 * Update layout on audio load
		 * @param	event
		 */
		private function onLoad(event:StateEvent):void {
			if (event.property == MediaStatus.LOADED) {
				front.removeEventListener(StateEvent.CHANGE, onLoad);
				updateLayout();
			}
		}		
		
		/**
		 * Playback event handler
		 * @param	event
		 */
		override protected function onStateEvent(event:StateEvent):void {	
			
			super.onStateEvent(event);
			
			if(front){
				if (event.value == "close"){
					Audio(front).stop();
				}
				else if (event.value == "play"){
					Audio(front).resume();
				}
				else if (event.value == "pause"){
					Audio(front).pause();		
				}
			}
		}		
	}
}