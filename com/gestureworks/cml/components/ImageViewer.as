package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.utils.document;
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
	 * @see com.gestureworks.cml.elements.Image
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */
	public class ImageViewer extends Component 
	{		
		
		private var initialScale:Number; 
		private var infoBtn:Button;
		private var closeBtn:Button;
		
		/**
		 * image viewer Constructor
		 */
		public function ImageViewer() 
		{
			super();
			mouseChildren = true;
			nativeTransform = true;
			affineTransform = true;			
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
			// automatically try to find elements based on AS3 class
			if (!image)
				image = searchChildren(Image);
			
			if (image)
				image.addEventListener(StateEvent.CHANGE, onLoadComplete);
				
			super.init();	
			
			infoBtn = menu.getChildAt(0);
			closeBtn = menu.getChildAt(1);
		}
		
		private function onLoadComplete(e:StateEvent):void
		{
			if (e.property == "isLoaded") {
				image.removeEventListener(StateEvent.CHANGE, onLoadComplete);
				isLoaded = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "isLoaded", isLoaded));
			}
		}
		
		public var isLoaded:Boolean = true;
			
		override protected function updateLayout(event:*=null):void 
		{
			if (image) {
				// update width and height to the size of the image, if not already specified
				//if (!width && image)
					width = image.width;
				//if (!height && image)
					height = image.height;	
			}	
			super.updateLayout();
			menu.updateLayout(width, height);
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			image = null;
		}
		
		override public function clone():* 
		{	
			cloneExclusions.push("backs", "textFields");
			var clone:ImageViewer = CloneUtils.clone(this, this.parent, cloneExclusions);		
				
			//CloneUtils.copyChildList(this, clone);	// commented out b/c it was duplicating childlist (2012/2/6)
			
			if (image) {
				clone.image = String(image.id);
			}
			
			if (front){
				clone.front = String(front.id);
			}
			
			if (back) {
				clone.back = String(back.id);
			}
			
			if (background){
				clone.background = String(background.id);
			}
			
			if (menu)	{
				clone.menu = String(menu.id);
			}
			
			if (frame) {
				clone.frame = String(frame.id);
			}
			
			if (fronts.length > 1) {
				clone.fronts = [];
				for (var l:int = 0; l < fronts.length; l++) 
				{
					for (var m:int = 0; m < clone.numChildren; m++) 
					{
						if (fronts[l].name == clone.getChildAt(m).name) {
							clone.fronts[l] = clone.getChildAt(m);
						}
					}
				}
			}
			
			if (backs.length > 1) {
				clone.backs = [];
				for (var j:int = 0; j < backs.length; j++) 
				{
					for (var k:int = 0; k < clone.numChildren; k++) 
					{
						if (backs[j].name == clone.getChildAt(k).name) {
							clone.backs[j] = clone.getChildAt(k);
						}
					}
				}
			}
			clone.init();				
			clone.updateLayout();	
			
			return clone;
		}
		
		override public function set scale(value:Number):void {
			super.scale = value;
			if (!initialScale) {
				initialScale = value;
				
				minScale = value;
				if (_image.landscape == true)
					maxScale = 1920 / width;
				else
					maxScale = 1920 / height;
				
				//maxScale = 920 / width;
				//infoBtn.scale = .5 / value;
				//closeBtn.scale = .5 / value;
			}
		}
		
		public function resetScale():void {
			scale = initialScale;
		}
	}
	
}