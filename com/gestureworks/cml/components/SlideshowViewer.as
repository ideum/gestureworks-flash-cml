package  com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	
	/**
	 * The SlideshowViewer component is primarily meant to display a Slideshow element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>slideshow</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the YouTube element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.element.Slideshow
	 * @see com.gestureworks.cml.element.Stack
	 */		
	public class SlideshowViewer extends Component
	{
		/**
		 * slideshow Constructor
		 */
		public function SlideshowViewer() 
		{
			super();
		}
		
		private var _slideshow:*;
		/**
		 * Sets the slideshow element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get slideshow():* {return _slideshow}
		public function set slideshow(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_slideshow = value;
			else
				_slideshow = searchChildren(value);
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!slideshow) {
				slideshow = searchChildren(".slideshow_element");
				//slideshow.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".slideshow_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!slideshow){
				slideshow = searchChildren(Slideshow);
				//slideshow.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
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
			// update width and height to the size of the slideshow, if not already specified
			if (!width && slideshow)
				width = slideshow.width;
			if (!height && slideshow)
				height = slideshow.height;
				
			super.updateLayout();
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			super.onStateEvent(event);
			
			trace("EVENT", event.value);
			
			if (event.value == "close" && slideshow)
				slideshow.stop();
			else if (event.value == "forward" && slideshow)
				slideshow.forward();
			else if (event.value == "play" && slideshow)
				slideshow.play();
			else if (event.value == "pause" && slideshow)
				slideshow.pause();		
			else if (event.value == "back" && slideshow)
				slideshow.reverse();
			else if (event.value == "loaded" && slideshow)
				updateLayout();
		}
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			slideshow = null;
		}
	}

}