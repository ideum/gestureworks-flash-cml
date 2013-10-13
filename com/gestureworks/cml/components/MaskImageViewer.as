package com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.utils.*;

	/**
	 * The MaskImageViewer component is primarily meant to display a MaskContainer element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>maskCon</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the MaskContainer element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Josh
	 * @see Component
	 * @see com.gestureworks.cml.element.MaskContainer
	 * @see com.gestureworks.cml.element.TouchContainer
	 */	 
	public class MaskImageViewer extends Component//ComponentKit
	{	
		/**
		 * Constructor
		 */
		public function MaskImageViewer()
		{
			super();
		}
		
		private var _maskCon:*;
		/**
		 * Sets the image mask element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get maskCon():* {return _maskCon}
		public function set maskCon(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_maskCon = value;
			else 
				_maskCon = searchChildren(value);					
		}			
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!maskCon){
				_maskCon = searchChildren(".mask_element");
				addEventListener(GWGestureEvent.ROTATE, onRotate);
			}
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".mask_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!maskCon){
				_maskCon = searchChildren(MaskContainer);
				addEventListener(GWGestureEvent.ROTATE, onRotate);
				addEventListener(GWGestureEvent.MANIPULATE, onRotate);
			}							
			maskCon.addEventListener(StateEvent.CHANGE, onStateEvent);
			super.init();
		}
		
		override protected function updateLayout(event:* = null):void 
		{
			// update width and height to the size of the image, if not already specified
			if (!width && maskCon)
				width = maskCon.width;
			if (!height && maskCon)
				height = maskCon.height;
				
			super.updateLayout(event);
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	

			super.onStateEvent(event);
			if (event.value == "LOADED") {
				maskCon.removeEventListener(StateEvent.CHANGE, onStateEvent);
				updateLayout();
			}
		}
		
		private function onRotate(e:GWGestureEvent):void {
			_maskCon.dragAngle = this.rotation;
		}
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void
		{
			super.dispose();
			maskCon = null;
			
			removeEventListener(GWGestureEvent.ROTATE, onRotate);
			removeEventListener(GWGestureEvent.MANIPULATE, onRotate);
		}
	}
}