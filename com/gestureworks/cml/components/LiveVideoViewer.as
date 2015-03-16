package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.LiveVideo;
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The LiveVideoViewer component displays an LiveVideo on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the LiveVideo element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.LiveVideo
	 */
	public class LiveVideoViewer extends Component 
	{											
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			
			//search for local instance
			if (!front){
				front = displayByTagName(LiveVideo);
			}	
						
			super.init();
		}	
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void{				
			super.onStateEvent(event);
			if (front && event.value == "close"){
				LiveVideo(front).stop();
			}
		}

		
	}
}