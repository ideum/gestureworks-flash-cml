package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	
	/** 
	 * The Image class loads and displays an external bitmap file.	 
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock "> 
		
		var img:Image = new Image();
		img.src = "my_image.png";
		img.init();
		addChild(img);
		
	 *	</codeblock> 
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.factories.BitmapFactory
	 */	 	
	public class Image extends BitmapFactory
	{	
		
		/**
		 * Constructor
		 */
		public function Image() 
		{						
			super();
		}
		
		/**
		 * Initialisation method
		 */
		public function init():void {}
		
		/**
		 * Bitmap load complete callback. Dispatches Event.COMPLETE
		 */		
		override protected function bitmapComplete():void 
		{						
			//dispatchEvent(new Event(Event.COMPLETE, true, true));
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
		}
	}
}