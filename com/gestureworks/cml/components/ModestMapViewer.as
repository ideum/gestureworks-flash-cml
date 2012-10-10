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
	import com.gestureworks.events.GWGestureEvent;
	
	/**
	 * The ModestMapViewer is a component that is meant to display a map generated from ModestMaps on the front side and meta-data on the back side.
	 * It is composed of the following elements: map, front, back, menu, and frame. The image and front may be the same thing. 
	 * The map is required. The width and height of the component is automatically set to the dimensions of the map unless it is 
	 * previously specifed by the component.
	 * 
	 *  @author ...
	 */
	
	public class ModestMapViewer extends Component 
	{			
		/**
		 * constructor
		 */
		public function ModestMapViewer() 
		{
			super();
			mouseChildren = true;
			disableNativeTransform = false;
			disableAffineTransform = false;			
		}
		
		
		private var _map:*;
		/**
		 * Sets the map element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get map():* {return _map}
		public function set map(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_map = value;
			else 
				_map = searchChildren(value);					
		}			
	
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!map){
				map = searchChildren(".map_element");
				trace("Adding map event listener.");
				map.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".map_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");
			
			// automatically try to find elements based on AS3 class
			if (!map){
				map = searchChildren(ModestMapElement);
				map.addEventListener(StateEvent.CHANGE, onStateEvent);
			}	
			
			super.init();
		}
		
		/**
		 * CML initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}		
		
		override protected function updateLayout(event:*=null):void 
		{
			// update width and height to the size of the image, if not already specified
			if (!width && map)
				width = map.width;
			if (!height && map)
				height = map.height;
				
			super.updateLayout();
		}	
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			super.onStateEvent(event);
			if (event.value == "loaded") {
				map.updateFrame();
				updateLayout();
			}
		}
		
		private function onDouble(e:*):void {
			map.switchMapProvider();
		}
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			if (map)
			{
				map.removeEventListener(StateEvent.CHANGE, onStateEvent);
				map = null;
			}				
		}
		
	}
	
}