package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
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
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
		
		/**
		 * Returns a clone of this Image
		 * @return
		 */
		override public function clone():* 
		{
			var clone:Image = CloneUtils.clone(this, null);
			
			if (bitmapData) {
				clone.bitmapData = new BitmapData(width, height, false, 0xFFFFFF);			
				clone.bitmapData = bitmapData.clone();
				clone.bitmap = new Bitmap(clone.bitmapData, PixelSnapping.NEVER, true);				
			}	
			
			return clone;			
		}
		
	}
}