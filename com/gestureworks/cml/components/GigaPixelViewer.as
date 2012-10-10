package com.gestureworks.cml.components
{
	//----------------adobe--------------//
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.core.*;
	import flash.display.*;
	import flash.events.*;
	import org.openzoom.flash.components.*;
	import org.openzoom.flash.viewport.constraints.*;
	import org.tuio.*;
	//---------- gestureworks ------------//
	//---------------open zoom-------------//
	
	 /**
	 * <p>The GigaPixelDisplay component is the main component for the GigaPixelViewer module.  It contains all the neccessary display objects for the module.</p>
	 *
	 * <p>
	 * The GigaPixelViewer is a module that uses the GigapixelElement to create interactive high resolution zoomable image windows.  
	 * Multiple windows can independently display individual images with different sizes and orientations. The Gigapixel Elements are already touch enabled and should not be placed in touchContainers.  
	 * The image windows can be interactively moved around stage, scaled and rotated using multitouch gestures additionaly the image can be panned and zoomed using multitouch gesture inside the image window.
	 * Multitouch frame gestures can be activated and deactivated using the module XML settings.</p>
	 *
	 * <strong>Import Components :</strong>
	 * <pre>
	 * GigaPixelParser
	 * </pre>
	 *
	 * <listing version="3.0">
	 * var gpDisplay:GigaPixelDisplay = new GigaPixelDisplay();
	 *
	 * 		gpDisplay.id = Number;
	 *
	 * addChild(gpDisplay);</listing>
	 *
	 * @see id.module.GigaPixelViewer
	 * 
	 * @includeExample GigaPixelDisplay.as
	 * 
	 * @langversion 3.0
	 * @playerversion AIR 2
	 * @playerversion Flash 10.1
	 * @playerversion Flash Lite 4
	 * @productversion GestureWorks 2.0
	 */
	
	 
	public class GigaPixelViewer extends Component
	{
		private var info:*;

		//------ image settings ------//
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
    	private var sceneNavigator:SceneNavigator;
    	private var scaleConstraint:ScaleConstraint;
	
		/**
		 * gigaPixelViewer constructor
		 */
	  	public function GigaPixelViewer()
		{
			super();
		}
		
		private var _gigapixel:*;
		/**
		 * Sets the gigapixel element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get gigapixel():* {return _gigapixel}
		public function set gigapixel(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_gigapixel = value;
			else 
				_gigapixel = searchChildren(value);					
		}
		
		private var _minScaleConstraint:Number = 0.001;
		public function get minScaleConstraint():Number { return _minScaleConstraint; }
		public function set minScaleConstraint(value:Number):void {
			if(!isNaN(value) && value >=0){
				_minScaleConstraint = value;
			}
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!gigapixel)
				gigapixel = searchChildren(".gigapixel_element");
				gigapixel.addEventListener(StateEvent.CHANGE, onStateEvent);
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".gigapixel_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!gigapixel)
				gigapixel = searchChildren(GigapixelElement);
				gigapixel.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			super.init();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{			
			init();
		}		
		
		override protected function updateLayout(event:* = null):void 
		{
			// update width and height to the size of the image, if not already specified
			if (!width && gigapixel)
				width = gigapixel.width;
			if (!height && gigapixel)
				height = gigapixel.height;
				
			super.updateLayout(event);
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			var info:* = childList.getCSSClass("info_container", 0)
			
			if (event.value == "info") {
				if (!info.visible) {
					info.visible = true;
					gigapixel.visible = false;
				}
				else {
					info.visible = false;
					gigapixel.visible = true;
				}
			}
			else if (event.value == "close") 	this.visible = false;
			else if (event.value == "loaded") {
				height = gigapixel.height;
				width = gigapixel.width;
				gigapixel.removeEventListener(StateEvent.CHANGE, onStateEvent);
				
				updateLayout();
			}
		}
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void
		{
			super.dispose();
			info = null;
			if (gigapixel)
			{
				gigapixel.removeEventListener(StateEvent.CHANGE, onStateEvent);
				gigapixel = null;
			}		
		}
	}
}