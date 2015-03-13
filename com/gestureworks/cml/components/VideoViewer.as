package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.Video;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * The VideoViewer component displays a Video on the front side and meta-data on the back side. The width and height of the component are 
	 * automatically set to the dimensions of the Video element unless it is previously specifed by the component.
	 * @author Ideum
	 * @see Component 
	 * @see com.gestureworks.cml.elements.Video
	 */			
	public class VideoViewer extends Component 
	{		
		/**
		 * Constructor
		 */
		public function VideoViewer() {
			super();		
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			
			//search for local instance
			if (!front){
				front = displayByTagName(Video);
			}
			
			if (front) {
				if (!(Video(front).isLoaded)) {
					front.addEventListener(StateEvent.CHANGE, onLoad);
				}
			}
				
			super.init();
		}
		
		/**
		 * Update layout on video load
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
					Video(front).stop();
				}
				else if (event.value == "play"){
					Video(front).resume();
				}
				else if (event.value == "pause"){
					Video(front).pause();		
				}
			}
		}		
	}
}