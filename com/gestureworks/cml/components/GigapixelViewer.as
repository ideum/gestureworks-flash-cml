package com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.core.*;
	import flash.display.*;
	import flash.events.*;
	import org.openzoom.flash.components.*;
	import org.openzoom.flash.viewport.constraints.*;
	import org.tuio.*;
	
	/**
	 * The GigapixelViewer component is primarily meant to display a Gigapixel element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>gigapixel</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the Gigapixel element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <p>Multiple windows can independently display individual images with different sizes and orientations. The Gigapixel elements are 
	 * already touch enabled and should not be placed in touchContainers. The image windows can be interactively moved around stage, scaled 
	 * and rotated using multitouch gestures additionaly the image can be panned and zoomed using multitouch gesture inside the image 
	 * window.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Gigapixel
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */
	public class GigapixelViewer extends Component
	{
		private var _minScaleConstraint:Number = 0.001;
		private var _gigapixel:*;
		
		//------ image settings ------//
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
    	private var sceneNavigator:SceneNavigator;
    	private var scaleConstraint:ScaleConstraint;
	
		/**
		 * Constructor
		 */
	  	public function GigapixelViewer() {
			super();
		}
		
		/**
		 * Sets the gigapixel element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get gigapixel():* { return _gigapixel; }
		public function set gigapixel(value:*):void {
			if (!value) return;
			
			if (value is DisplayObject)
				_gigapixel = value;
			else 
				_gigapixel = searchChildren(value);					
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
		override public function init():void {						
			// automatically try to find elements based on AS3 class
			if (!gigapixel) {
				gigapixel = searchChildren(Gigapixel);
			}
			if (gigapixel) {
				gigapixel.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			super.init();
		}		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateLayout(event:* = null):void {
			
			if (!width) {
				width = gigapixel.width;
			}
			if (!height) {
				height = gigapixel.height;	
			}
			super.updateLayout(event);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void {	
			super.onStateEvent(event);
			if (event.value == "loaded") {
				height = gigapixel.height;
				width = gigapixel.width;
				gigapixel.removeEventListener(StateEvent.CHANGE, onStateEvent);
				updateLayout();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_gigapixel = null;
			sceneNavigator = null;
			scaleConstraint = null;
		}
	}
}