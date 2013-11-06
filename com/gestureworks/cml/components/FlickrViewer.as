package com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
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
	 * @see com.gestureworks.cml.element.Flickr
	 * @see com.gestureworks.cml.element.TouchContainer
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
		 * Initialisation method
		 */
		override public function init():void {			
			// automatically try to find elements based on AS3 class
			if (!flickr)
				flickr = searchChildren(Flickr);
			flickr.addEventListener(StateEvent.CHANGE, onLoadComplete);
			super.init();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateLayout(event:*=null):void {
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
				isLoaded = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "isLoaded", isLoaded));
				updateLayout();
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
		override public function clone():* {
			cloneExclusions.push("backs", "fronts");
			var clone:FlickrViewer = CloneUtils.clone(this, this.parent, cloneExclusions);
						
			if (flickr) {
				clone.flickr = String(flickr.id);
			}
			
			if (front) {
				clone.front = String(front.id);
			}
			
			if (back) {
				clone.back = String(back.id);
			}
			
			if (background) {
				clone.background = String(background.id);
			}
			
			if (menu) {
				clone.menu = String(menu.id);
			}
			
			if (frame) {
				clone.frame = String(frame.id);
			}
			
			if (fronts && fronts.length > 1) {
				clone.fronts = [];
				for (var l:int = 0; l < fronts.length; l++) {
					for (var m:int = 0; m < clone.numChildren; m++) {
						if (fronts[l].name == clone.getChildAt(m).name) {
							clone.fronts[l] = clone.getChildAt(m);
						}
					}
				}
			}
			
			if (backs && backs.length > 1) {
				clone.backs = [];
				for (var j:int = 0; j < backs.length; j++) {
					for (var k:int = 0; k < clone.numChildren; k++) {
						if (backs[j].name == clone.getChildAt(k).name) {
							clone.backs[j] = clone.getChildAt(k);
						}
					}
				}
			}
			clone.init();
			
			if (clone.textFields) {
				for (var i:int = 0; i < clone.textFields.length; i++) {
					clone.textFields[i].x = textFields[i].x;
					clone.textFields[i].y = textFields[i].y;
				}
			}
			return clone;
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