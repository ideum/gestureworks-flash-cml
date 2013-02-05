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
	 
	/**
	 * The Gigapixel element loads a gigapixel image. Gigapixel images are 
	 * extremely high resolution images that can be navigated made by tiling smaller 
	 * images in a seamless, pyramid structured fashion. It has following 
	 * parameters:minScaleConstraint, src, loaded, image,smoothPanning. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		var gpElement:Gigapixel = new Gigapixel();
		gpElement.src = "space.xml";
		gpElement.x = 500;
		gpElement.width = 600;
		gpElement.height = 600;
		gpElement.mouseChildren = true;
		addChild(gpElement);
		gpElement.init();
		
	 * </codeblock>
	 * 
	 * @author Josh
	 * @see Panoramic
	 */
	public class Gigapixel extends TouchContainer
	{
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
		private var image:MultiScaleImage
    	private var sceneNavigator:SceneNavigator
    	private var scaleConstraint:ScaleConstraint;
		private var hotspots:Array = [];
		
		/**
		 * Constructor
		 */
		public function Gigapixel()
		{
			super();
		}
		
		private var _viewportX:Number = 0;
		public function get viewportX():Number {
			if (image) {
				_viewportX = image.viewportX
				return _viewportX;
			} else return _viewportX;
		}
		
		private var _viewportY:Number = 0;
		public function get viewportY():Number {
			if (image) {
				_viewportY = image.viewportY
				return _viewportY;
			} else return _viewportY;
		}
		
		private var _minScaleConstraint:Number = 0.001;
		/**
		 * sets the scaling
		 * @default = 0.001;
		 */
		public function get minScaleConstraint():Number { return _minScaleConstraint; }
		public function set minScaleConstraint(value:Number):void {
			if(!isNaN(value) && value >=0){
				_minScaleConstraint = value;
			}
		}
		
		private var _srcXML:String = "";
		[Deprecated(replacement = "src")]
		/**
		 * Sets the src xml file
		 * @default 
		 */	
		public function get srcXML():String{return _srcXML;}
		public function set srcXML(value:String):void
		{			
			_srcXML = value;
			_src = value;
		}
		
		private var _src:String = "";
		/**
		 * Sets the src xml file
		 */		
		public function get src():String{return _srcXML;}
		public function set src(value:String):void
		{			
			_src = value;
		}

		private var _loaded:Boolean;
		/**
		 * Indicated whether the gigaPixel image is loaded
		 */
		public function get loaded():Boolean { return _loaded; }
		
		public function get sceneWidth():Number { return image.sceneWidth; }
		public function get sceneHeight():Number { return image.sceneHeight; }
		
		public function get viewportWidth():Number { return image.viewportWidth; }
		public function get viewportHeight():Number { return image.viewportHeight; }
		
		public function localToScene(p:Point):Point {
			return image.localToScene(p);
		}
		
		
		/**
		 * CML call back Initialisation
		 */
		override public function displayComplete():void
		{			
			while (this.numChildren > 0) {
				if (this.getChildAt(0) is Hotspot) {
					hotspots.push(this.getChildAt(0));
				}
				removeChildAt(0);
				trace("Clearing markers to put them back later.");
			}
			
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
			
			for (var i:Number = 0; i < hotspots.length; i++) {
				if (!(contains(hotspots[i])))
					addChild(hotspots[i]);
				var point:Point = image.sceneToLocal(new Point(hotspots[i].sceneX, hotspots[i].sceneY));
				hotspots[i].x = point.x;
				hotspots[i].y = point.y;
				//trace("Adding hotspot:", i, hotspots[i].x, hotspots[i].y);
			}
			
			if (hotspots.length > 0)
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_loaded = true;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "loaded", loaded));
		}
		
		private function onEnterFrame(e:Event):void {
			for (var i:Number = 0; i < hotspots.length; i++) {
				if (!(contains(hotspots[i])))
					addChild(hotspots[i]);
				var point:Point = image.sceneToLocal(new Point(hotspots[i].sceneX, hotspots[i].sceneY));
				hotspots[i].x = point.x;
				hotspots[i].y = point.y;
				//trace("Adding hotspot:", i, hotspots[i].x, hotspots[i].y);
			}
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{ 
			displayComplete();
		}
		
		
		private function image_completeHandler(event:Event):void
		{
			var descriptor:IMultiScaleImageDescriptor = image.source as IMultiScaleImageDescriptor;
			if (descriptor)
				scaleConstraint.maxScale = descriptor.width / image.sceneWidth;
		}
		
		/**
		 * Dispose method and remove listener
		 */
		override public function dispose():void
		{
			super.dispose();
			scaleConstraint = null;
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
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