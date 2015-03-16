package com.gestureworks.cml.components
{	
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.Gigapixel;
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.DisplayObject;
	import org.openzoom.flash.components.SceneNavigator;
	import org.openzoom.flash.viewport.constraints.ScaleConstraint;
	
	/**
	 * The GigapixelViewer component displays an Gigapixel on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Gigapixel element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Gigapixel
	 */
	public class GigapixelViewer extends Component
	{
		private var _minScaleConstraint:Number = 0.001;
		
		//------ image settings ------//
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
    	private var sceneNavigator:SceneNavigator;
    	private var scaleConstraint:ScaleConstraint;

		/**
		 * @inheritDoc
		 */
		override public function init():void {									
			//search for local instance
			if (!front){
				front = displayByTagName(Gigapixel);
			}		
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
				width = Gigapixel(front).height;
				height = Gigapixel(front).width;
				updateLayout();
			}
		}		
		
		/**
		 * Sets minimum contraint for scale
		 */
		public function get minScaleConstraint():Number { return _minScaleConstraint; }
		public function set minScaleConstraint(value:Number):void {
			if (!isNaN(value) && value >= 0) {
				_minScaleConstraint = value;
			}
		}				
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			sceneNavigator = null;
			scaleConstraint = null;
		}
	}
}