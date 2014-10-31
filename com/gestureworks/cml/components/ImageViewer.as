package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Image;
	import com.gestureworks.cml.elements.Image;
	import com.gestureworks.cml.events.*;
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
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Image
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */
	public class ImageViewer extends Component 
	{				
		private var _image:Image;		
		
		/**
		 * Constructor
		 */
		public function ImageViewer() {
			super();	
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {				
			// automatically try to find elements based on AS3 class
			if (!image){
				image = searchChildren(Image);
			}
			
			super.init();	
		}		
						
		/**
		 * Image element
		 */
		public function get image():* {return _image}
		public function set image(value:*):void {
			if (value is XML || value is String) {
				value = getElementById(value);
			}
			
			if (value is Image) {
				_image = value;
				front = _image; 
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		override protected function updateLayout(event:* = null):void {
			//if not set, update dimensions to image size
			if (!width && image) {
				width = image.width;
			}
			if (!height && image) {
				height = image.height; 
			}			
			super.updateLayout(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			image = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {	
			cloneExclusions.push("backs", "textFields");
			var clone:ImageViewer = CloneUtils.clone(this, this.parent, cloneExclusions);						
			
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
			
			if (fronts && fronts.length > 1) {
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
			
			if (backs && backs.length > 1) {
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
			return clone;
		}			
	}
	
}