package com.gestureworks.cml.components
{
	//----------------adobe--------------//
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.core.GestureWorks;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import org.tuio.TuioTouchEvent;
	//---------- gestureworks ------------//
	/**
	 * PanoramicViewer provides interaction with a panorama, allowing the entire element to be viewed and scaled while maintaining the same touch, pinch, and zoom interaction as the standalone element does.
	 * It is composed of the following elements: panoramic, front, back, menu,hideFrontOnFlip, autoTextLayout and frame. The video and front may be the same thing. 
	 * The width and height of the component is automatically set to the dimensions of the video element unless it is 
	 * previously specifed by the component.
	 * 
	 * @author ...josh
	 */ 
	
	public class PanoramicViewer extends Component
	{	
		/**
		 * constructor
		 */
		public function PanoramicViewer()
		{
			super();
		}

		private var _panoramic:*;
		/**
		 * Sets the panoramic element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get panoramic():* {return _panoramic}
		public function set panoramic(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_panoramic = value;
			else 
				_panoramic = searchChildren(value);					
		}			
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!panoramic)
				panoramic = searchChildren(".panoramic_element");
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
			if (!panoramic)
				panoramic = searchChildren(PanoramicElement);
		
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
			if (!width && panoramic)
				width = panoramic.width;
			if (!height && panoramic)
				height = panoramic.height;
				
			super.updateLayout();
		}
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void {
			super.dispose();
			panoramic = null;					
		}
	}
}