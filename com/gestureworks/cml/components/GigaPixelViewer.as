﻿package com.gestureworks.cml.components
{
	//----------------adobe--------------//
	import flash.events.Event;
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
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.element.Component;
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList
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
 
	 /**
	 * <p>The GigaPixelDisplay component is the main component for the GigaPixelViewer module.  It contains all the neccessary display objects for the module.</p>
	 *
	 * <p>
	 * The GigaPixelViewer is a module that uses the OpenZoom API to create interactive high resolution zoomable image window.  
	 * Multiple touch object windows can independently display individual images with different sizes and orientations.  
	 * The image windows can be interactively moved around stage, scaled and rotated using multitouch gestures additionaly the image can be panned and zoomed using multitouch gesture inside the image window.
	 * Multitouch frame gestures can be activated and deactivated using the module XML settings.</p>
	 *
	 * <strong>Import Components :</strong>
	 * <pre>
	 * GigaPixelParser
	 * TouchGesturePhysics
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
		private var frame:TouchSprite;
		private var panoramic:TouchSprite;

		//------ image settings ------//
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
		private var image:MultiScaleImage
    	private var sceneNavigator:SceneNavigator
    	private var scaleConstraint:ScaleConstraint;
	
	
		public function GigaPixelViewer()
		{
			super();
		}

		override public function dispose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			//trace("panoramicViewer complete")
			initUI();
			setupUI();
		}

	
		private function initUI():void
		{
			trace("initUI");
			// set easing
			// duration
		}
		
		private function setupUI():void
		{ 
			trace("setupUI");
			this.childList.getCSSClass("touch_frame", 0).childList.getCSSClass("frame", 0).width = width;
			this.childList.getCSSClass("touch_frame", 0).childList.getCSSClass("frame", 0).height = height;
			
			//touch container
			//touch_giga_image = this.childList.getCSSClass("gigapixel_image", 0)
				//panoramic.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
				//panoramic.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
			//addChild(touch_giga_image);
			
			//---------- build gigapixel image ------------------------//

				image = new MultiScaleImage();
					image.mouseChildren = true;
					//image.gestureEvents = true;
					//image.disableNativeTransform = true;
					//image.disableAffineTransform = true;
					//image.gestureList = { "1-finger-drag":true,"2-finger-scale":true};
					
					//trace(image.view)
					// smooth panning
				
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
					var centerConstraint:CenterConstraint = new CenterConstraint()
					var visibilityConstraint:VisibilityConstraint = new VisibilityConstraint()
						visibilityConstraint.visibilityRatio = 0.6
						constraint.constraints = [zoomConstraint, scaleConstraint, centerConstraint, visibilityConstraint]
		
				image.constraint = constraint
				image.source = _srcXML //"./resources/images/deepzoom/" + imagexml;
				image.width = width;
				image.height = height;
				
				addChild(image);

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
		
		private var _srcXML:String = "";
		/**
		 * Sets the src xml file
		 * @default 50
		 */		
		public function get srcXML():String{return _srcXML;}
		public function set srcXML(value:String):void
		{			
			_srcXML = value;
		}	
	}
}