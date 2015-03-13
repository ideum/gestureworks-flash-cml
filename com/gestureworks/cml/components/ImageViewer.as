package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.Image;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * The ImageViewer component displays an Image on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Image element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Image
	 */
	public class ImageViewer extends Component 
	{								
		/**
		 * @inheritDoc
		 */
		override public function init():void {							
			
			//search for local instance
			if (!front){
				front = displayByTagName(Image);
			}	
			
			//listen for image load
			if (front) {
				if (Image(front).isLoaded) {
					Image(front).resize(front.width, front.height);
				}
				else{
					front.addEventListener(StateEvent.CHANGE, onLoad);
				}
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