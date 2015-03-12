package com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.Flickr;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
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
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Flickr
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */
	public class FlickrViewer extends Component
	{
		private var _flickr:*;
		private var _isLoaded:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function FlickrViewer() {
			super();
			mouseChildren = true;
			nativeTransform = true;
			affineTransform = true;
		}
		
		/**
		 * Sets the flickr element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */
		public function get flickr():* { return _flickr; }
		public function set flickr(value:*):void {
			if (!value)
				return;
			
			if (value is DisplayObject)
				_flickr = value;
			else
				_flickr = searchChildren(value);
		}
		
		/**
		 * Returns the whether is the Flickr element is loaded
		 */
		public function get isLoaded():Boolean {
			return _isLoaded;
		}
		
		/**
		 * Initialization method
		 */
		override public function init():void {
			// hide while loading
			visible = false;
			
			// automatically try to find elements based on AS3 class
			if (!flickr)
				flickr = searchChildren(Flickr);
			
			// listen for load complete
			if (flickr) {
				flickr.addEventListener(StateEvent.CHANGE, onLoadComplete);
			}

			super.init();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateLayout():void {
			if (flickr) {
				width = flickr.width;
				height = flickr.height;	
			}	
			super.updateLayout();	
		}
		
		/**
		 * Load complete event handler
		 * @private
		 * @param	e
		 */
		private function onLoadComplete(e:StateEvent):void {
			if (e.property == "isLoaded") {
				flickr.removeEventListener(StateEvent.CHANGE, onLoadComplete);
				_isLoaded = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "isLoaded", isLoaded));
				updateLayout();
				visible = true;
			}
		}
		
		/**
		 * Enables load complete listener
		 */
		public function listenLoadComplete():void {
			if (flickr) {
				flickr.addEventListener(StateEvent.CHANGE, onLoadComplete);		
			}
		}				
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			flickr = null;
		}
	
	}

}