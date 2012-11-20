package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	
	/**
	 * The ImageViewer component is primarily meant to display an Image element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>image</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the Image element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.element.Image
	 * @see com.gestureworks.cml.element.TouchContainer
	 */
	public class ImageViewer extends Component 
	{		
		/**
		 * image viewer Constructor
		 */
		public function ImageViewer() 
		{
			super();
			mouseChildren = true;
			disableNativeTransform = false;
			disableAffineTransform = false;			
		}
		
		
		private var _image:*;
		/**
		 * Sets the image element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get image():* {return _image}
		public function set image(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_image = value;
			else 
				_image = searchChildren(value);					
		}			
	
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!image)
				image = searchChildren(".image_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".image_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!image)
				image = searchChildren(Image);
			
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
			// update width and height to the size of the image, if not already specified
			if (!width && image)
				width = image.width;
			if (!height && image)
				height = image.height;	
				
			super.updateLayout();
		}	
		
		
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			image = null;
		}
		
		
		override public function clone():* 
		{	
			var clone:ImageViewer = CloneUtils.clone(this, this.parent, cloneExclusions);		
				
			CloneUtils.copyChildList(this, clone);		

			if (image)
				clone.image = String(image.id);				
			
			if (front)
				clone.front = String(front.id);
			
			if (back)
				clone.back = String(back.id);
			
			if (background)
				clone.background = String(background.id);
			
			if (menu)	
				clone.menu = String(menu.id);
			
			if (frame)
				clone.frame = String(frame.id);				
				
				
			clone.displayComplete();
			
			
			for (var i:int = 0; i < clone.textFields.length; i++) 
			{					
				clone.textFields[i].x = textFields[i].x;
				clone.textFields[i].y = textFields[i].y;
				
				trace("textX", clone.textFields[i].x);
				trace("textY", clone.textFields[i].y);
			}				

			return clone;
		}			
		
	}
	
}