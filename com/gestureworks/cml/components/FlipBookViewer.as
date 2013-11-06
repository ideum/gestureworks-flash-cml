package com.gestureworks.cml.components
{
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	
	public class FlipBookViewer extends Component 
	{		
		/**
		 * useless viewer Constructor
		 */
		public function FlipBookViewer() 
		{
			super();
			mouseChildren = true;
			nativeTransform = true;
			affineTransform = true;			
		}
		
		
		
		private var _flipBook:*;
		// Find our Useless machine element.
		public function get flipBook():* {return _flipBook}
		public function set flipBook(value:*):void 
		{
			if (!value) return;
			
			_flipBook = value;
		}			
	
		/**
		 * Initialization function
		 */
		override public function init():void 
		{	
			// automatically try to find elements based on AS3 class
			if (!flipBook)
				flipBook = searchChildren(FlipBook);
			
			if (flipBook)
				flipBook.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			super.init();	
		}
		
		private function uselessComplete(e:StateEvent):void {
			
		}	
					
		override protected function updateLayout(event:*=null):void 
		{
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
		override public function dispose():void 
		{
			super.dispose();
			_flipBook = null;
		}
		
	}
	
}