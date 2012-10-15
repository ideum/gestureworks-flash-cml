package com.gestureworks.cml.components 
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
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component 
	 * @see com.gestureworks.cml.element.Video
	 * @see com.gestureworks.cml.element.TouchContainer
	 */			
	public class VideoViewer extends Component 
	{		
		/**
		 * Constructor
		 */
		public function VideoViewer() 
		{
			super();			
		}
		
		
		///////////////////////////////////////////////////////////////////////
		// Public Properties
		//////////////////////////////////////////////////////////////////////
		
		private var _video:*;
		/**
		 * Sets the video element.
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
				video = searchChildren(".video_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".image_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!video)
				video = searchChildren(Video);
			
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
		 * Dispose methods
		 */
		override public function dispose():void 
		{
			super.dispose();
			video = null;
		}
	}
}