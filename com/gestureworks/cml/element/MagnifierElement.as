package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import org.tuio.*;
	/**
	 * ...
	 * @author josh
	 */
	public class MagnifierElement extends TouchContainer
	{
		//[Embed(source = "../../../gwas/lib/magnify.pbj", mimeType = "application/octet-stream")]
		//var magnifierShader:Class;
		
		private const ZERO_POINT:Point = new Point(0,0);
		
		private var shader:Shader;
		private var shaderFilter:ShaderFilter;
		
		private var canvas:BitmapData;
		private var canvasContainer:Bitmap;
		public var bitmapData:BitmapData;
	
		private var urlRequest:URLRequest;
		private var urlLoader:URLLoader;
		
		private var mSprite:Sprite;
		
		private var timer:Timer;
		
		public function MagnifierElement() 
		{
			super();
		}
		
		private var _radius:Number = 100;
		/**
		 * Radius of the total area of the lens, including distortion effects if any.
		 * @default: 100
		 */
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void {
			_radius = value;
		}
		
		private var _distortionRadius:Number = 30;
		/**
		 * Set the amount of distortion or "fish-eye" effect the lens goes through before focusing cleanly.
		 * This amount is subtracted from the radius to create the focal area, so if the radius is 100,
		 * and the distortionRadius is 30, then the "focused" area will have a radius of 70. If the distortion and
		 * radius are equal, there will be no in-focus area. The maximum is whatever the radius is, the minimum is 0.
		 * @default: 30
		 */
		public function get distortionRadius():Number { return _distortionRadius; }
		public function set distortionRadius(value:Number):void {
			if (value > radius)
				value = radius;
			else if (value < 0) {
				value = 0;
			}
			_distortionRadius = value;
		}
		
		private var _magnification:Number = 5;
		/**
		 * The value of magnification of the lens, this can be increased or decreasted by performing a rotation
		 * gesture on the lens, and its starting value can be set in CML. The max magnification is 50, the minimum is 1.
		 * @default: 5;
		 */
		public function get magnification():Number { return _magnification; }
		public function set magnification(value:Number):void {
			if (value > 50) {
				value = 50;
			} else if (value < 1) {
				value = 1;
			}
			_magnification = value;
		}
		
		override public function dispose():void {
			super.dispose();
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			if (timer) {
				timer.stop();
				timer = null;
				
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
			}
			
			removeEventListener(GWGestureEvent.ROTATE, rotateFilter);
			removeEventListener(GWGestureEvent.DRAG, dragHandler);
			removeEventListener(GWGestureEvent.SCALE, scaleHandler);
			
			mSprite = null;
			shaderFilter = null;
			shader = null;
			canvasContainer = null;
			canvas = null;
			bitmapData = null;
			
			if (urlRequest) urlRequest = null;
			if (urlLoader) urlLoader = null;
			
		}
		
		override public function displayComplete():void {
			super.displayComplete();
			
			mouseChildren = false;
			disableNativeTransform = true;
			disableAffineTransform = true;
			gestureEvents = true;
			gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
			
			readyBitmaps();
			
			urlRequest = new URLRequest("../lib/magnify.pbj");
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, applyFilter);
			urlLoader.load(urlRequest);
			
			//applyFilter();
			applyMask();
			init2();
		}
		
		private function readyBitmaps():void {
			bitmapData = new BitmapData(stage.width, stage.height, true, 0xffffff);
			
			bitmapData.draw(CMLParser.instance.defaultContainer);
			
			canvas = new BitmapData(stage.width, stage.height, false, 0x0);
			
			canvasContainer = new Bitmap(canvas);
			addChild(canvasContainer);
	
			//Set the centre of the canvas container to 0,0
			canvasContainer.x = -_radius;
			canvasContainer.y = -_radius;
		}
		
		private function applyFilter(e:Event):void {
			urlLoader.removeEventListener(Event.COMPLETE, applyFilter);
			
			shader = new Shader(e.target.data);
			shaderFilter = new ShaderFilter(shader);
			urlLoader = null;
			urlRequest = null;
		}
		
		private function applyMask():void {
			mSprite = new Sprite();
			mSprite.graphics.beginFill(0xffffff, 1);
			mSprite.graphics.drawCircle(0, 0, _radius);
			mSprite.graphics.endFill();
			
			addChild(mSprite);
			this.mask = mSprite;
		}
		
		private function init2():void {
			//Initialize the timer to render things on the stage. Runs at ~30 FPS.
			timer = new Timer(34);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			// Initialize custom touch events.
			addEventListener(GWGestureEvent.ROTATE, rotateFilter);
			addEventListener(GWGestureEvent.DRAG, dragHandler);
			addEventListener(GWGestureEvent.SCALE, scaleHandler);
			
			timer.start();
			width = _radius * 2;
			height = _radius * 2;
		}
		
		private function onTimer(e:TimerEvent):void {
			this.visible = false;
			bitmapData.fillRect(bitmapData.rect, 0);
			bitmapData.draw(stage);
			this.visible = true;
			updateFilter();
		}
		
		public function updateFilter():void {
			canvas.copyPixels(bitmapData, this.getRect(stage), ZERO_POINT);
			
			shader.data.center.value = [_radius, _radius];
			shader.data.innerRadius.value = [_radius - _distortionRadius];
			shader.data.outerRadius.value = [_radius];
			shader.data.magnification.value = [_magnification];
			shaderFilter = new ShaderFilter(shader);
			canvasContainer.filters = [shaderFilter];
		}
		
		private function scaleHandler(e:GWGestureEvent):void {
			//trace("Handling scale");
			_radius += e.value.scale_dsx + e.value.scale_dsy;
			width += (e.value.scale_dsx + e.value.scale_dsy) * 2;
			height += (e.value.scale_dsx + e.value.scale_dsy) * 2;
			mSprite.width = _radius * 2;
			mSprite.height = _radius * 2;
			
			mSprite.x += e.value.scale_dsx * 2;
			mSprite.y += e.value.scale_dsy * 2;
		}
		
		private function rotateFilter(e:GWGestureEvent):void {
			//trace("Magnifying");
			magnification += e.value.rotate_dtheta * 0.1;
		}
		
		private function dragHandler(e:GWGestureEvent):void {
			//trace("Drag");
			x += e.value.drag_dx;
			y += e.value.drag_dy;
		}
	}

}