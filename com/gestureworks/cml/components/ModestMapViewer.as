package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.ModestMap;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The ModestMapViewer component is primarily meant to display a ModestMap element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>map</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the ModestMap element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.ModestMap
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */	 	
	public class ModestMapViewer extends Component 
	{			
		/**
		 * Constructor
		 */
		public function ModestMapViewer() 
		{
			super();
			mouseChildren = true;
			nativeTransform = true;
			affineTransform = true;			
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
			// automatically try to find elements based on AS3 class
			if (!map){
				map = searchChildren(ModestMap);
			}	
			
			if (map) {
				map.addEventListener(StateEvent.CHANGE, onStateEvent);
				map.addEventListener(GWGestureEvent.DOUBLE_TAP, onDouble);				
			}
			
			super.init();
		}
		
		override public function updateLayout():void 
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
			map.switchMapProvider(e);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			_map = null;		
		}
		
	}
	
}