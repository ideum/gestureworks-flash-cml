package com.gestureworks.cml.components {
	import com.gestureworks.cml.elements.HTML;
	
	/**
	 * The HTMLViewer component displays an HTML element on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the HTML element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.HTML
	 */	
	public class HTMLViewer extends Component {
		/**
		 * @inheritDoc
		 */
		override public function init():void {					
			//search for local instance
			if (!front){
				front = displayByTagName(HTML);
			}	
			super.init();
		}		
	}
}