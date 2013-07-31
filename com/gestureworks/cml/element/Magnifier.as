package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
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
	 * @author josh
	 */
	public class Magnifier extends TouchContainer
	{
		private const PItoRAD:Number = Math.PI / 180;
		
		[Embed(source = "../../../../../lib/shaders/magnify.pbj", mimeType = "application/octet-stream")]
		private var MagnifierShader:Class;
		
		[Embed(source = "../../../../../lib/assets/openexhibits_assets.swf", symbol = "org.openexhibits.assets.DefaultMagnifier")]
		private var DefaultGraphic:Class;
		
		[Embed(source = "../../../../../lib/assets/openexhibits_assets.swf", symbol = "org.openexhibits.assets.mDefaultMagnifier")]
		private var mDefaultGraphic:Class;
		
		[Embed(source = "../../../../../lib/assets/openexhibits_assets.swf", symbol = "org.openexhibits.assets.NotchMagnifier")]
		private var NotchGraphic:Class;
		
		private var _border:Sprite;
		private var mBorder:Sprite;
		
		private const ZERO_POINT:Point = new Point(0,0);
		
		private var shader:Shader;
		private var shaderFilter:ShaderFilter;
		
		private var canvas:BitmapData;
		private var canvasContainer:Bitmap;
		public var bitmapData:BitmapData;
		
		private var mSprite:Sprite;
		
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
		
		/**
		 * Dispose method to nullify the children
		 */
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
			
		}
		
		/**
		 * CML call back Initialisation
		 */
		override public function displayComplete():void {
			//super.displayComplete();
			
			mouseChildren = false;
			disableNativeTransform = true;
			disableAffineTransform = true;
			gestureEvents = true;
			
			readyBitmaps();
			
			if (_graphic == "notch") {
				_border = new NotchGraphic as Sprite;
				mBorder = null;
				var nRad:Number = _radius + 15;
				var nNum:Number = (nRad * 2) / _border.width;
				_border.width *= nNum;
				_border.height *= nNum;
				
				this.width = _border.width;
				this.height = _border.height;
				
			} else if (_graphic == "default") {
				
				_border = new DefaultGraphic as Sprite;
				mBorder = new mDefaultGraphic as Sprite;
				var dRad:Number = _radius + 15;
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
			
			applyFilter();
		}
		
		override public function init():void {
			displayComplete();
		}
		
		private function readyBitmaps():void {
			bitmapData = new BitmapData(stage.width, stage.height, true, 0xffffff);
			
			
			bitmapData.draw(this.stage);
			
			canvas = new BitmapData(stage.width, stage.height, false, 0x0);
			
			canvasContainer = new Bitmap(canvas);
			addChild(canvasContainer);
	
			//Set the centre of the canvas container to 0,0
			canvasContainer.x = -_radius;
			canvasContainer.y = -_radius;
		}
		
		private function applyFilter():void {
			
			shader = new Shader();
			shader.byteCode = new MagnifierShader();
			shaderFilter = new ShaderFilter(shader);
			
			applyMask();
			init2();
		}
		
		private function applyMask():void {
			
			if (_graphic == "notch") {
				
				var tempRad:Number = (radius + 15);
				
				mSprite = new Sprite();
				mSprite.graphics.beginFill(0xffffff, 1);
				mSprite.graphics.drawCircle(0, 0, tempRad);
				mSprite.graphics.endFill();
				
				addChild(mSprite);
			
				addChild(_border);
			
				this.mask = mSprite;
			} else if (_graphic == "default") {
				mBorder.width = _border.width;
				mBorder.height = _border.height;
				
				addChild(mBorder);
				
				addChild(_border);
				
				this.mask = mBorder;
			} else if (_graphic == "none") {
				
				mSprite = new Sprite();
				mSprite.graphics.beginFill(0xffffff, 1);
				mSprite.graphics.drawCircle(0, 0, _radius);
				mSprite.graphics.endFill();
				
				addChild(mSprite);
				
				this.mask = mSprite;
			}
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
			_radius += (e.value.scale_dsx + e.value.scale_dsy) * 20;
			width = _radius * 2;
			height = _radius * 2;
			
			var tempRad:Number = _radius + 15;
			
			if (_graphic == "notch") {
				mSprite.width = tempRad * 2;
				mSprite.height = tempRad * 2;
				
				mSprite.x += e.value.scale_dsx * 40;
				mSprite.y += e.value.scale_dsy * 40;
				
				_border.width = tempRad * 2;
				_border.height = tempRad * 2;
				
				_border.x = mSprite.x;
				_border.y = mSprite.y;
			} else if (_graphic == "default") {
				var num:Number = (tempRad * 2) * (_border.height / _border.width) / _border.height;
				_border.height *= num;
				num = (tempRad * 2) / _border.width;
				_border.width *= num;
				
				mBorder.width = _border.width;
				mBorder.height = _border.height;
				
				width = _border.width;
				height = _border.height;
				
				mBorder.x += e.value.scale_dsx * 40;
				mBorder.y += e.value.scale_dsy * 40;
				_border.x = mBorder.x;
				_border.y = mBorder.y;
			} else if (_graphic == "none") {
				mSprite.width = _radius * 2;
				mSprite.height = _radius * 2;
				
				mSprite.x += e.value.scale_dsx * 40;
				mSprite.y += e.value.scale_dsy * 40;
			}
		}
		
		private function rotateFilter(e:GWGestureEvent):void {
			magnification += e.value.rotate_dtheta * 0.1;
			if (_graphic == "notch") {
				_border.rotation += e.value.rotate_dtheta;
				mSprite.rotation = _border.rotation;
			} else if (_graphic == "default") {
				var m:Matrix = _border.transform.matrix;
				
				m.rotate(e.value.rotate_dtheta * PItoRAD);
				m.tx = _border.x;
				m.ty = _border.y;
				
				_border.transform.matrix = m;
				
				mBorder.x = _border.x;
				mBorder.y = _border.y;
				mBorder.rotation = _border.rotation;
			}
		}
		
		private function dragHandler(e:GWGestureEvent):void {
			x += e.value.drag_dx;
			y += e.value.drag_dy;
		}
	}

}