package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Image;
	
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
		override public function updateLayout():void {
			//if not set, update dimensions to image size
			if (!width && image) {
				width = image.width;
			}
			if (!height && image) {
				height = image.height; 
			}			
			super.updateLayout();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			image = null;
		}
	}
	
}