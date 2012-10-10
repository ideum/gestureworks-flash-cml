package  com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;	
	
	
	/**
	 * The YouTubeViewer is a component that is primarily meant to play audio and video files on the front side and meta-data on the back side.
	 * It is composed of the following elements: video, front, back, backBackground, hideFrontOnFlip, menu, and frame. The wav and front may be the same thing. 
	 * The wav is required. The width and height of the component is automatically set to the dimensions of the wav element unless it is 
	 * previously specifed by the component.
	 * 
	 *@author ...josh
	 */
	
	public class YouTubeViewer extends Component
	{
		/**
		 * youtube constructor
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
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!video)
				video = searchChildren(".youtube_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".video_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!video)
				video = searchChildren(YouTubeElement);
		
			super.init();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void 
		{
			init();
		}
		
		override protected function updateLayout(event:*=null):void 
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
		}
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			video = null;
		}
	}

}