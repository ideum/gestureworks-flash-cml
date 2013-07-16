package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
		
	/**
	 * The MP3Player component is primarily meant to display an MP3 element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>mp3</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the MP3 element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.element.MP3
	 * @see com.gestureworks.cml.element.TouchContainer
	 */	 	
	public class MP3Player extends Component 
	{		
		/**
		 * Constructor
		 */
		public function MP3Player() 
		{
			super();			
		}
		
		
		///////////////////////////////////////////////////////////////////////
		// Public Properties
		//////////////////////////////////////////////////////////////////////
		
		private var _mp3:*;
		/**
		 * Sets the mp3 element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get mp3():* {return _mp3}
		public function set mp3(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_mp3 = value;
			else 
				_mp3 = searchChildren(value);					
		}				
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!mp3)
				mp3 = searchChildren(".mp3_element");
			/*if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");*/
			if (!front)
				front = searchChildren(".image_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!mp3)
				mp3 = searchChildren(MP3);
			
			if (mp3) {
				mp3.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
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
			// update width and height to the size of the mp3, if not already specified
			if (!width && mp3)
				width = mp3.width;
			if (!height && mp3)
				height = mp3.height;
				
			super.updateLayout();
		}	
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			super.onStateEvent(event);
			if (event.value == "close" && mp3)
				mp3.stop();
			else if (event.value == "play" && mp3)
				mp3.resume();
			else if (event.value == "pause" && mp3)
				mp3.pause();
			else if (event.property == "position" && mp3) {
				if (menu) {
					if (menu.slider) {
						Slider(menu.slider).input(event.value * 100);
					}
				}
			}
			else if (menu.slider && event.target is Slider) {
				mp3.pause();
				mp3.seek(event.value);
				addEventListener(GWTouchEvent.TOUCH_END, onRelease);
			}
		}	
		
		private function onRelease(e:*):void {
			removeEventListener(GWTouchEvent.TOUCH_END, onRelease);
			mp3.resume();
		}
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			mp3 = null;					
		}
		
	}
}