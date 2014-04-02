package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import gui.DefaultMagnifier;
	import gui.NotchMagnifier;
	import org.tuio.*;
	
	/**
	 * The Magnifier element provides a touch enabled element with an optional graphical lens that will increase the magnification when placed over any display object on the stage.
	 * 
	 * <p>Note that if the stage does not have a background image or display object of some sort, the MagnifierElement will simply retain visual data from the last object it was
	 * held over until brought to another display object.</p>
	 * 
	 * <p>The MagnifierElement has an optional fish-eye effect that can be altered using distortionRadius. The magnifier has two optional graphics, or can be left on its own with
	 * "default", "notch", or "none".</p>
	 * 
	 * <p>Rotation gestures on the magnifier will zoom it in.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	    var magnifier:Magnifier = new Magnifier();
		magnifier.x = 550;
		magnifier.y = 150;
		magnifier.radius = 100;
		magnifier.magnification = 2;
		magnifier.distortionRadius = 40;
		magnifier.graphic = "default";
		
		addChild(magnifier);
		
		magnifier.init();
	 *
	 * </codeblock>
	 * @author Ideum
	 */
	public class Magnifier extends TouchContainer
	{
		private const PItoRAD:Number = Math.PI / 180;
		
		[Embed(source="../../../../lib/shaders/magnify.pbj", mimeType="application/octet-stream")]
		private var MagnifierShader:Class;
		
		private var _border:Sprite;
		
		private const ZERO_POINT:Point = new Point(0,0);
		
		private var shader:Shader;
		private var shaderFilter:ShaderFilter;
		
		private var backgroundSourceCanvas:BitmapData;
		private var backgroundCanvasContainer:Bitmap;
		public var backgroundBitmapData:BitmapData;
		
		private var backgroundMaskSprite:Sprite;
		
		private var timer:Timer;
		
		/**
		 * Constructor
		 */
		public function Magnifier() 
		{
			super();
		}
		
		private var _graphic:String;
		/**
		 * Sets the graphic type: default, notch, or none.
		 */
		public function get graphic():String { return _graphic; }
		public function set graphic(value:String):void {
			_graphic = value;
		}
		
		private var _radius:Number = 100;
		/**
		 * Radius of the total area of the lens, including distortion effects if any.
		 * @default 100
		 */
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void {
			_radius = value;
		}
		
		private var _radiusOffset:Number = 0;
		private var _radiusOffsetHeight:Number = 0;
		
		private var _distortionRadius:Number = 30;
		/**
		 * Set the amount of distortion or "fish-eye" effect the lens goes through before focusing cleanly.
		 * This amount is subtracted from the radius to create the focal area, so if the radius is 100,
		 * and the distortionRadius is 30, then the "focused" area will have a radius of 70. If the distortion and
		 * radius are equal, there will be no in-focus area. The maximum is whatever the radius is, the minimum is 0.
		 * 
		 * Setting a graphic will hide the distortion unless it is made fairly large.
		 * @default 30
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
		 * @default 5;
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
		
		private var _zoomRotateFactor:Number = 0.01;
		/**
		 * Sets how fast rotating zooms in.
		 * @default 0.01
		 */
		public function get zoomRotateFactor():Number {
			return _zoomRotateFactor;
		}
		public function set zoomRotateFactor(value:Number):void {
			_zoomRotateFactor = value;
		}
		
		private var _zoomMin:Number = 1.0;
		/**
		 * The minimum zoom in value.
		 * @default 1.0
		 */
		public function get zoomMin():Number {
			return _zoomMin;
		}
		public function set zoomMin(value:Number):void {
			_zoomMin = value;
		}
		
		private var _zoomMax:Number = 5.0;
		/**
		 * The maximum zoom out value.
		 * @default 1.0
		 */
		public function get zoomMax():Number { 
			return _zoomMax;
		}
		public function set zoomMax(value:Number):void {
			_zoomMax = value;
		}
		
		private var _maxObjectScale:Number = 3.0;
		public function get maxObjectScale():Number {
			return _maxObjectScale;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			
			if (timer) {
				timer.stop();				
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer = null;
			}
			
			backgroundMaskSprite = null;
			shaderFilter = null;
			shader = null;
			backgroundCanvasContainer = null;
			backgroundSourceCanvas = null;
			backgroundBitmapData = null;
			_border = null;			
		}
		
		override public function init():void {
			mouseChildren = false;
			nativeTransform = false;
			affineTransform = false;
			gestureEvents = true;
			
			if (_graphic == "notch") {
				_border = new NotchMagnifier();
				_radiusOffset = 15;
				_radiusOffsetHeight = 15;
				var nRad:Number = _radius + _radiusOffset;
				var nNum:Number = (nRad * 2) / _border.width;
				_border.width *= nNum;
				_border.height *= nNum;
				_border.alpha = 1.0;
				
				this.width = _border.width;
				this.height = _border.height;
				
			} else if (_graphic == "default") {
				
				_border = new DefaultMagnifier();
				_radiusOffset = 15;
				_radiusOffsetHeight = _radiusOffset * 3;
				var dRad:Number = _radius + _radiusOffset;
				var dNum:Number = (dRad * 2) * (_border.height / _border.width) / _border.height;
				_border.height *= dNum;
				dNum = (dRad * 2) / _border.width;
				_border.width *= dNum;
				
				this.width = _border.width;
				this.height = _border.height;
			} else {
				this.width = _radius * 2;
				this.height = _radius * 2;
			}
			
			readyBitmaps();
			
			applyFilter();
		}
		
		private function readyBitmaps():void {
			
			backgroundBitmapData = new BitmapData(stage.width, stage.height, true, 0xffffff);
			
			backgroundBitmapData.draw(this.stage);
			
			backgroundSourceCanvas = new BitmapData(stage.width, stage.height, false, 0x0);
			
			backgroundCanvasContainer = new Bitmap(backgroundSourceCanvas);
			addChild(backgroundCanvasContainer);
		}
		
		private function applyFilter():void {

			shader = new Shader();
			shader.byteCode = new MagnifierShader();
			shaderFilter = new ShaderFilter(shader);

			applyMask();
			init2();
		}
		
		private function applyMask():void {
				
			backgroundMaskSprite = new Sprite();
			backgroundMaskSprite.graphics.beginFill(0xffffff, 0);
			backgroundMaskSprite.graphics.drawCircle(0, 0, radius);
			backgroundMaskSprite.graphics.endFill();
			
			addChild(backgroundMaskSprite);
		
			backgroundCanvasContainer.mask = backgroundMaskSprite;
			
			if (_graphic == "notch" || _graphic == "default") {
				
				addChild(_border);
				
			} else if (_graphic == "none") {
				// No functionality for default
			}
		}
		
		private function init2():void {
			//Initialize the timer to render things on the stage. Runs at ~30 FPS.
			timer = new Timer(34);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			gestureList = { "n-drag":true, "n-rotate":true, "n-scale":true };
			
			// Initialize custom touch events.
			addEventListener(GWGestureEvent.ROTATE, rotateFilter);
			addEventListener(GWGestureEvent.DRAG, dragHandler);
			addEventListener(GWGestureEvent.SCALE, scaleHandler);
			
			updateBackgroundSpriteScale();
			
			timer.start();
			width = _radius * 2;
			height = _radius * 2;
		}
		
		private function onTimer(e:TimerEvent):void {

			this.visible = false;
			backgroundBitmapData.fillRect(backgroundBitmapData.rect, 0x0000FF);
			backgroundBitmapData.draw(stage);
			this.visible = true;
			updateFilter();
		}
		
		public function updateFilter():void {

			if (!backgroundSourceCanvas) {
				return;
			}
			
			var offset:Number = radius + _radiusOffset;
			
			var point:Point = new Point(backgroundCanvasContainer.x, backgroundCanvasContainer.y);
			
			var worldPoint:Point = localToGlobal(point);
			
			var rect:Rectangle = new Rectangle(worldPoint.x, worldPoint.y, offset * 2.1, offset * 2.1);
			
			backgroundSourceCanvas.copyPixels(backgroundBitmapData, rect, ZERO_POINT);
			
			var magnifyRadius:Number = _radius;
			var magnifyDistortionRadius:Number = _distortionRadius;
			shader.data.center.value = [magnifyRadius, magnifyRadius];
			
			shader.data.innerRadius.value = [magnifyRadius - magnifyDistortionRadius];
			shader.data.outerRadius.value = [magnifyRadius];
			shader.data.magnification.value = [_magnification];
			shaderFilter = new ShaderFilter(shader);
			backgroundCanvasContainer.filters = [shaderFilter];
		}
		
		private function updateBackgroundSpriteScale():void {
			
			backgroundCanvasContainer.x = (-_radius - _radiusOffset);
			backgroundCanvasContainer.y = (-_radius - _radiusOffsetHeight);
		}
		
		private function scaleHandler(e:GWGestureEvent):void {
			
			// Scale currently has issues with 
			return;
		}
		
		private function rotateFilter(e:GWGestureEvent):void {
			
			if (_border) {
				_border.rotation += e.value.rotate_dtheta;
			}
			
			magnification += e.value.rotate_dtheta * _zoomRotateFactor;
			
			magnification = Math.min(_zoomMax, magnification);
			magnification = Math.max(_zoomMin, magnification);
		}
		
		private function dragHandler(e:GWGestureEvent):void {
			
			x += e.value.drag_dx;
			y += e.value.drag_dy;
			
			onTimer(null);
		}
	}

}