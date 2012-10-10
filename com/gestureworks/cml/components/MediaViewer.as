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
	 * The MediaViewer is a component that is meant to load various types of media files on the front and metadata on the back.
	 * It is composed of the following elements: media, front, back, menu, and frame. The media and front may be the same thing. 
	 * The media is required. The width and height of the component is automatically set to the dimensions of the media element unless it is 
	 * previously specifed by the component.
	 * 
	 *  @author ...
	 */
	
	public class MediaViewer extends Component 
	{		
		/**
		 * media viewer constructor
		 */
		public function MediaViewer() 
		{
			super();			
		}
		
		private var _media:*;
		/**
		 * Sets the media element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get media():* {return _media}
		public function set media(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_media = value;
			else 
				_media = searchChildren(value);					
		}				
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!media)
				media = searchChildren(".media_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".image_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!media)
				media = searchChildren(MediaElement);

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
			// update width and height to the size of the media, if not already specified
			if (!width && media)
				width = media.width;
			if (!height && media)
				height = media.height;
				
			super.updateLayout();
		}		
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			super.onStateEvent(event);
			if (event.value == "close" && media)
				media.stop();
			else if (event.value == "play" && media)
				media.resume();
			else if (event.value == "pause" && media)
				media.pause();				
		}
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();								
		}
		
	}
}