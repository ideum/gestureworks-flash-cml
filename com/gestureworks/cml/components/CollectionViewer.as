package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Collection;
	import com.gestureworks.cml.events.StateEvent;
	
	
	/**
	 * The CollectionViewer component displays an Collection on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Collection element 
	 * unless it is previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Collection
	 */
	public class CollectionViewer extends Component 
	{
		/**
		 * @inheritDoc
		 */
		override public function init():void {							
			
			//search for local instance
			if (!front){
				front = displayByTagName(Collection);
			}	
						
			super.init();	
		}			
	}
}