package com.gestureworks.cml.element
{
	//----------------adobe--------------//
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.geom.*;
	import flash.ui.Mouse;
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.events.*;
	//---------- gestureworks ------------//
	import com.gestureworks.cml.factories.ElementFactory;
	//---------------open zoom-------------//
	import org.openzoom.flash.components.MultiScaleImage;
	import org.openzoom.flash.components.SceneNavigator;
	import org.openzoom.flash.descriptors.IMultiScaleImageDescriptor;
	import org.openzoom.flash.events.ViewportEvent;
	import org.openzoom.flash.viewport.constraints.CenterConstraint;
	import org.openzoom.flash.viewport.constraints.CompositeConstraint;
	import org.openzoom.flash.viewport.constraints.ScaleConstraint;
	import org.openzoom.flash.viewport.constraints.VisibilityConstraint;
	import org.openzoom.flash.viewport.constraints.ZoomConstraint;
	import org.openzoom.flash.viewport.controllers.TouchController;
	import org.openzoom.flash.viewport.transformers.TweenerTransformer;
	import org.openzoom.flash.utils.math.clamp;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks
	
	 /**
	 * <p>The GigaPixelDisplay component is the main component for the GigaPixelViewer module.  It contains all the neccessary display objects for the module.</p>
	 *
	 * <p>
	 * The GigaPixelElement is an element that uses the OpenZoom API to create interactive high resolution zoomable image that can be placed inside other elements.  
	 * The element is touch enabled already, and should not need to be placed inside a touchContainer to receive touch events.
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
	
	 
	public class GigapixelElement extends ElementFactory
	{
		//------ image settings ------//
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
		private var image:MultiScaleImage
    	private var sceneNavigator:SceneNavigator
    	private var scaleConstraint:ScaleConstraint;
	
	
		public function GigapixelElement()
		{
			super();
		}
		
		private var _minScaleConstraint:Number = 0.001;
		public function get minScaleConstraint():Number { return _minScaleConstraint; }
		public function set minScaleConstraint(value:Number):void {
			if(!isNaN(value) && value >=0){
				_minScaleConstraint = value;
			}
		}
		
		private var _srcXML:String = "";
		[Deprecated(replacement="src")]
		public function get srcXML():String{return _srcXML;}
		public function set srcXML(value:String):void
		{			
			_srcXML = value;
			_src = value;
		}
		
		private var _src:String = "";
		/**
		 * Sets the src xml file
		 * @default 50
		 */		
		public function get src():String{return _srcXML;}
		public function set src(value:String):void
		{			
			_src = value;
		}

		private var _loaded:String = "";
		public function get loaded():String { return _loaded; }
		
		override public function displayComplete():void
		{			
			//trace("panoramicViewer complete")
			initUI();
			setupUI();
		}

	
		private function initUI():void
		{
			//trace("initUI");
			// set easing
			// duration
		}
		
		private function setupUI():void
		{ 
			//---------- build gigapixel image ------------------------//

			image = new MultiScaleImage();
				image.mouseChildren = true;
				image.addEventListener(Event.COMPLETE, image_completeHandler)
	
			// Add transformer for smooth zooming
			var transformer:TweenerTransformer = new TweenerTransformer()
				transformer.easing = "EaseOut";//"easeOutElastic"
				transformer.duration = 1 // seconds
			image.transformer = transformer
			image.controllers = [new TouchController()]
	
				var constraint:CompositeConstraint = new CompositeConstraint()
				var zoomConstraint:ZoomConstraint = new ZoomConstraint()
					zoomConstraint.minZoom = 0.1 //????
					scaleConstraint = new ScaleConstraint()
					scaleConstraint.minScale = _minScaleConstraint;
				var centerConstraint:CenterConstraint = new CenterConstraint()
				var visibilityConstraint:VisibilityConstraint = new VisibilityConstraint()
					visibilityConstraint.visibilityRatio = 0.6
					constraint.constraints = [zoomConstraint, scaleConstraint, centerConstraint, visibilityConstraint]
	
			image.constraint = constraint
			image.source = _src //"./resources/images/deepzoom/" + imagexml;
			//image.width = width;
			
			if (width != 0 && height == 0) {
				var aspectW:Number = image.sceneHeight / image.sceneWidth;
				height = aspectW * width;
			} else if (height !=0 && width == 0) {
				var aspectH:Number = image.sceneWidth / image.sceneHeight;
				width = height * aspectH;
			}
			
			image.width = width;
			image.height = height;
			
			trace("Scene info: " + image.sceneWidth + " x " + image.sceneHeight);
			trace(width + " x " + height);
			addChild(image);
			_loaded = "loaded";
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _loaded));
		}
		
		// -- giga pixel image event handler ----//
		private function image_completeHandler(event:Event):void
		{
			//trace("------------------------g image loaded");
			var descriptor:IMultiScaleImageDescriptor = image.source as IMultiScaleImageDescriptor
			if (descriptor)
			{
				scaleConstraint.maxScale = descriptor.width/image.sceneWidth
				//scaleConstraint.maxScale = 3.5;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			scaleConstraint = null;
			
			while (this.numChildren > 0){
				this.removeChildAt(0);
			}
			
			if (image)
			{
				image.removeEventListener(Event.COMPLETE, image_completeHandler);
				image = null;
			}	
		}
	}
}