package com.gestureworks.cml.components
{
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	
	public class FlipBookViewer extends Component {	
		private var _flipBook:*;
		
		/**
		 * Constructor
		 */
		public function FlipBookViewer() {
			super();
			nativeTransform = true;
		}
		
		/**
		 * Sets flipBook element.
		 */
		public function get flipBook():* {return _flipBook}
		public function set flipBook(value:*):void {
			if (!value) return;
			_flipBook = value;
		}			
	
		/**
		 * @inheritDoc
		 */
		override public function init():void {	
			// automatically try to find elements based on AS3 class
			if (!flipBook)
				flipBook = searchChildren(FlipBook);
			
			if (flipBook)
				flipBook.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			super.init();	
		}
		
		/**
		 * @inheritDoc
		 */					
		override protected function updateLayout(event:*=null):void {
			if (flipBook) {
				// update width and height to the size of the flipBook, if not already specified
				if (!width)
					width = flipBook.width;
				if (!height)
					height = flipBook.height;	
			}	
			super.updateLayout();				
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_flipBook = null;
		}	
	}
}