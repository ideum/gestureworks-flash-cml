package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;	
	
	/**
	 * The MediaViewer component is primarily meant to display a Media element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>media</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the Media element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.element.Media
	 * @see com.gestureworks.cml.element.TouchContainer
	 */	 
	public class MediaViewer extends Component 
	{		
		/**
		 * media viewer Constructor
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
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!media)
				media = searchChildren(Media);

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
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();								
		}
		
	}
}