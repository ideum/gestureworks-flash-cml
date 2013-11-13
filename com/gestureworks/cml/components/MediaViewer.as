package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
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
	 * @see com.gestureworks.cml.elements.Media
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */	 
	public class MediaViewer extends Component 
	{
		private var _media:*;
		
		/**
		 * Constructor
		 */
		public function MediaViewer() {
			super();			
		}
		
		/**
		 * Sets the media element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get media():* { return _media; }
		public function set media(value:*):void {
			if (!value) return;
			
			if (value is DisplayObject)
				_media = value;
			else 
				_media = searchChildren(value);					
		}				
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			// automatically try to find elements based on AS3 class
			if (!media)
				media = searchChildren(Media);

			super.init();
		}				
		
		/**
		 * @inheritDoc
		 */
		override protected function updateLayout(event:*=null):void {
			// update width and height to the size of the media, if not already specified
			if (!width && media)
				width = media.width;
			if (!height && media)
				height = media.height;
				
			super.updateLayout();
		}		
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void {				
			super.onStateEvent(event);
			if (event.value == "close" && media)
				media.stop();
			else if (event.value == "play" && media)
				media.resume();
			else if (event.value == "pause" && media)
				media.pause();				
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();	
			_media = null;
		}
		
	}
}