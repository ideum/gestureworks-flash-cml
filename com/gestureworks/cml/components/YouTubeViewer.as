package  com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.YouTube;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * The YouTubeViewer component displays an YouTube on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the YouTube element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.YouTube
	 */	
	public class YouTubeViewer extends Component
	{		
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			
			//search for local instance
			if (!front){
				front = displayByTagName(YouTube);
			}	
			
			super.init();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void{	
			super.onStateEvent(event);
			
			if(front){
				if (event.value == "close"){
					YouTube(front).stop();
				}
				else if (event.value == "play"){
					YouTube(front).resume();
				}
				else if (event.value == "pause"){
					YouTube(front).pause();		
				}
			}
		}

	}

}