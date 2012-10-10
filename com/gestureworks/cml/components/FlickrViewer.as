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
	 * The FlickrViewer is a component that is primarily meant to display an image pulled from Flickr on the front side and meta-data on the back side.
	 * It is composed of the following elements: image, front, back, menu, and frame. The image and front may be the same thing. 
	 * The image is required. The width and height of the component is automatically set to the dimensions of the image unless it is 
	 * previously specifed by the component.
	 * 
	 * @author..
	 */
	public class FlickrViewer extends Component 
	{			
		/**
		 * constructor
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
		 * initialisation method
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
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!image)
				image = searchChildren(FlickrElement);
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
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			image = null;				
		}
		
	}
	
}