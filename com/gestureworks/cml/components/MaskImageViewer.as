package com.gestureworks.cml.components
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.MaskContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;

	/**
	 * The MaskImageViewer component displays an MaskImage on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the MaskImage element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.MaskImage
	 */
	public class MaskImageViewer extends Component
	{				
		/**
		 * @inheritDoc
		 */
		override public function init():void{						
			
			//search for local instance
			if (!front){
				front = displayByTagName(MaskContainer);
			}	
			
			//listen for image load
			if (front) {
				front.addEventListener(StateEvent.CHANGE, onLoad);
			}
			
			super.init();			
		}
		
		/**
		 * Update layout on image load
		 * @param	event
		 */
		private function onLoad(event:StateEvent):void {
			if (event.property == MediaStatus.LOADED) {
				front.removeEventListener(StateEvent.CHANGE, onLoad);
				updateLayout();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set rotation(value:Number):void {
			super.rotation = value;
			MaskContainer(front).dragAngle = value; 
		}
	}
}