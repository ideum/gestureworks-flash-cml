package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	
	/**
	 * The FlickrViewer component is primarily meant to display a Flickr element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>flickr</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the Flickr element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Josh
	 * @see Component
	 * @see com.gestureworks.cml.element.Flickr 
	 * @see com.gestureworks.cml.element.TouchContainer
	 */
	public class FlickrViewer extends Component 
	{			
		/**
		 * Constructor
		 */
		public function FlickrViewer() 
		{
			super();
			mouseChildren = true;
			disableNativeTransform = false;
			disableAffineTransform = false;			
		}
		
		private var _image:*;
		/**
		 * Sets the image element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get image():* {return _image}
		public function set image(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_image = value;
			else 
				_image = searchChildren(value);					
		}	
		
		/**
		 * Initialisation method
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!image)
				image = searchChildren(".flickr_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".flickr_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!image)
				image = searchChildren(Flickr);
			image.addEventListener(StateEvent.CHANGE, onStateEvent);
			
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
			// update width and height to the size of the image, if not already specified
			if (!width && image)
				width = image.width;
			if (!height && image)
				height = image.height;
				
			super.updateLayout();
		}	
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			super.onStateEvent(event);
			if (event.value == "loaded") {
				image.removeEventListener(StateEvent.CHANGE, onStateEvent);
				trace("Traced flickrElement load.");
				image.updateFrame();
				updateLayout();
			}
		}
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			image = null;				
		}
		
	}
	
}