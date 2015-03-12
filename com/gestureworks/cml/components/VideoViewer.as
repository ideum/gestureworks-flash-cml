package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Video;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * The VideoViewer component is primarily meant to display a Video element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>video</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the Video element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * 
	 * @author Ideum
	 * @see Component 
	 * @see com.gestureworks.cml.elements.Video
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */			
	public class VideoViewer extends Component 
	{		
		private var _video:Video;
		
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
			// automatically try to find elements based on AS3 class
			if (!video){
				video = searchChildren(Video);
			}
			
			video.addEventListener(StateEvent.CHANGE, onStateEvent);											
			super.init();
		}
		
		/**
		 * Video element
		 */		
		public function get video():* {return _video}
		public function set video(value:*):void {
			if (value is XML || value is String) {
				value = getElementById(value);
			}
			
			if (value is Video) {
				_video = value; 
				front = _video;
			}
		}	
			
		/**
		 * @inheritDoc
		 */
		override public function updateLayout():void {
			//if not set, update dimensions to image size
			if (!width && video){
				width = video.width;
			}
			if (!height && video){
				height = video.height;
			}
				
			super.updateLayout();
		}
		
		/**
		 * Playback event handler
		 * @param	event
		 */
		override protected function onStateEvent(event:StateEvent):void{	
			super.onStateEvent(event);
			if (event.value == "close" && video)
				video.stop();
			else if (event.value == "play" && video)
				video.resume();
			else if (event.value == "pause" && video)
				video.pause();				
		}		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_video = null;
		}
	}
}