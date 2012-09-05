package com.gestureworks.cml.element
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.events.*;
	import flash.geom.*;
	import org.openzoom.flash.components.MultiScaleImage;
	import org.openzoom.flash.components.SceneNavigator;
	import org.openzoom.flash.descriptors.IMultiScaleImageDescriptor;
	import org.openzoom.flash.viewport.constraints.CenterConstraint;
	import org.openzoom.flash.viewport.constraints.CompositeConstraint;
	import org.openzoom.flash.viewport.constraints.ScaleConstraint;
	import org.openzoom.flash.viewport.constraints.VisibilityConstraint;
	import org.openzoom.flash.viewport.constraints.ZoomConstraint;
	import org.openzoom.flash.viewport.controllers.TouchController;
	import org.openzoom.flash.viewport.transformers.TweenerTransformer;	
	 
	public class GigapixelElement extends ElementFactory
	{
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
		 * @default 
		 */		
		public function get src():String{return _srcXML;}
		public function set src(value:String):void
		{			
			_src = value;
		}

		private var _loaded:Boolean;
		public function get loaded():Boolean { return _loaded; }
		
		override public function displayComplete():void
		{			
			init();
		}
		
		public function init():void
		{ 
			image = new MultiScaleImage();
			image.mouseChildren = true;
			image.addEventListener(Event.COMPLETE, image_completeHandler)
	
			// Add transformer for smooth zooming
			var transformer:TweenerTransformer = new TweenerTransformer()
			transformer.easing = "EaseOut";
			transformer.duration = 1 // seconds
			
			image.transformer = transformer;
			image.controllers = [new TouchController()]
	
			var constraint:CompositeConstraint = new CompositeConstraint()
			var zoomConstraint:ZoomConstraint = new ZoomConstraint()
			zoomConstraint.minZoom = 0.1;
			
			scaleConstraint = new ScaleConstraint()
			scaleConstraint.minScale = _minScaleConstraint;
				
			var centerConstraint:CenterConstraint = new CenterConstraint()
			var visibilityConstraint:VisibilityConstraint = new VisibilityConstraint()
			visibilityConstraint.visibilityRatio = 0.6;
			constraint.constraints = [zoomConstraint, scaleConstraint, centerConstraint, visibilityConstraint];
	
			image.constraint = constraint;
			image.source = _src;
			
			if (width != 0 && height == 0) {
				var aspectW:Number = image.sceneHeight / image.sceneWidth;
				height = aspectW * width;
			} else if (height !=0 && width == 0) {
				var aspectH:Number = image.sceneWidth / image.sceneHeight;
				width = height * aspectH;
			}
			
			image.width = width;
			image.height = height;
			
			addChild(image);
			
			_loaded = true;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "loaded", loaded));
		}
		
		
		private function image_completeHandler(event:Event):void
		{
			var descriptor:IMultiScaleImageDescriptor = image.source as IMultiScaleImageDescriptor;
			if (descriptor)
				scaleConstraint.maxScale = descriptor.width / image.sceneWidth;
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