package  com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.Slider;
	import com.gestureworks.cml.elements.YouTube;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The YouTubeViewer component is primarily meant to display a YouTube element and its associated meta-data.
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
	 * <p>The width and height of the component are automatically set to the dimensions of the YouTube element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.YouTube
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */		
	public class YouTubeViewer extends Component
	{
		private var seekTo:Number = 0;
		/**
		 * youtube Constructor
		 */
		public function YouTubeViewer() 
		{
			super();
		}
		
		private var _video:*;
		/**
		 * Sets the Youtube element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get video():* {return _video}
		public function set video(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_video = value;
			else
				_video = searchChildren(value);
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on AS3 class
			if (!video)
				video = searchChildren(YouTube);
			
			if (video)
				video.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			super.init();
		}
		
		override public function updateLayout():void 
		{
			// update width and height to the size of the video, if not already specified
			if (!width && video)
				width = video.width;
			if (!height && video)
				height = video.height;
				
			super.updateLayout();
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			super.onStateEvent(event);
			
			if (event.value == "close" && video)
				video.stop();
			else if (event.value == "play" && video)
				video.resume();
			else if (event.value == "pause" && video)
				video.pause();		
			else if (event.property == "position" && video) {
				if (menu) {
					if (menu.slider && YouTube(video).isPlaying) {
						Slider(menu.slider).input(event.value * 100);
					}
				}
			}
			else if (menu.slider && event.target is Slider) {
				video.pause();
				seekTo = event.value;
				//video.seek(seekTo, false);
				addEventListener(GWTouchEvent.TOUCH_END, onRelease);
			}
		}
		
		private function onRelease(e:*):void {
			removeEventListener(GWTouchEvent.TOUCH_END, onRelease);
			video.seek(seekTo, true);
			video.resume();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			_video = null;
		}
	}

}