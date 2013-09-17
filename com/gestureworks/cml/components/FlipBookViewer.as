package com.gestureworks.cml.components
{
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	
	public class FlipBookViewer extends Component 
	{		
		/**
		 * useless viewer Constructor
		 */
		public function FlipBookViewer() 
		{
			super();
			mouseChildren = true;
			disableNativeTransform = false;
			disableAffineTransform = false;			
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
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			flipBook.removeEventListener(StateEvent.CHANGE, uselessComplete);
			//flipBook = null;
		}
		
	}
	
}