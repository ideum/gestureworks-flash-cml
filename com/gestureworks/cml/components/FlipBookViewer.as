package com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.FlipBook;
	
	/**
	 * The FlipBookViewer component displays an FlipBook on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the FlipBook element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.FlipBook
	 */	
	public class FlipBookViewer extends Component {				
	
		/**
		 * @inheritDoc
		 */
		override public function init():void {	
			
			//search for local instance
			if (!front){
				front = displayByTagName(FlipBook);
			}	
						
			super.init();
		}
	}
}