package com.gestureworks.cml.components
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.Flickr;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	
	/**
	 * The FlickrViewer component displays an Flickr on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Flickr element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Flickr
	 */
	public class FlickrViewer extends Component
	{
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			
			//search for local instance
			if (!front){
				front = displayByTagName(Flickr);
			}	
			
			//listen for flickr load
			if (front) {
				if (Flickr(front).isLoaded) {
					Flickr(front).resize(front.width, front.height);
				}
				else{
					front.addEventListener(StateEvent.CHANGE, onLoad);
				}
			}
			
			super.init();	
		}	
		
		/**
		 * Update layout on flickr load
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