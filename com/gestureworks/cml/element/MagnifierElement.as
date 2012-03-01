package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.MagnifierFactory;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.core.TouchSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import mx.utils.MatrixUtil;
	import flash.display.PixelSnapping;
	import flash.filters.DropShadowFilter;
	
	public class MagnifierElement extends MagnifierFactory
	{
		public var magnification:Number = 2;
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;
		private var outline:Shape;
		private var maskS:Shape;
		private var _initialized:Boolean;
		private var targetScale:Number = 1;
		private var targetWidth:Number = 0;
		private var zeroPoint:Point = new Point(0, 0);
		public var magX:Number;
		public var magY:Number;
		//public var id:int
		//public var cmlIndex:*
		//public var parseCML:*
		
		private var ts:TouchSprite
		
		public function MagnifierElement(target:* = null)
		{
			super();
			
			_target = target;
			mouseChildren = false;
			
			init();
			//if (stage) 
			//else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		//override protected function DisplayComplete():void 
		//{
		//}
		
		private function init(e:Event = null):void
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			target = target ? target : parent ? parent : this;
			outline = new Shape();
			maskS = new Shape();
			
			addChild(outline);
			addChild(maskS);
			this.mask = maskS;
			
			
			//ts.addChild(outline);
			//ts.addChild(maskS);
			//this.mask = maskS;
			
			
			//gestureEvents = true;
			//gestureList = {"n-drag": true, "n-scale": true};
			//nestedTransform = true;
			//disableNativeTransform = true;
			//disableAffineTransform = true;
			
			
			addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			//addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
					
			targetWidth = 250//width;
			//magX = x;
			//magY = y;
			//trace(magX, magY);
			
			filters = [new DropShadowFilter(6, 45, 0x000000, .5, 6, 6, 1, 3)];
			
			_initialized = true;
			updateUI();
			
			addEventListener(Event.ENTER_FRAME, captureBitmap);
		}
		
		private function gestureDragHandler(event:GWGestureEvent):void
		{
			magX += event.value.dx;
			magY += event.value.dy;
			
			//magX = (magX + (outline.width / 2) < 0) ? 0 - (outline.width / 2) : magX > stage.stageWidth - (outline.width / 2)  ? stage.stageWidth - (outline.width / 2) : magX;
			//magY = (magY + (outline.height / 2) < 0) ? 0 - (outline.height / 2) : magY > stage.stageHeight - (outline.height / 2)  ? stage.stageHeight - (outline.height / 2) : magY;
			
			x = magX;
			y = magY;
			
			
		}
		
		private function gestureScaleHandler(event:GWGestureEvent):void
		{			
			//targetScale += event.value.dsx;
			//targetScale = targetScale > 2 ? 2 : targetScale < .8 ? .8 : targetScale;
			targetWidth = width * targetScale;
			//updateUI();
		}
		
		
		override protected function updateUI():void
		//protected function updateUI():void
		{
			if (!_initialized) return;
			
			outline.graphics.clear();
			outline.graphics.lineStyle(lineStroke, color);
			outline.graphics.beginFill(fillColor, fillAlpha);
			
			maskS.graphics.clear();
			maskS.graphics.lineStyle(lineStroke, color);
			maskS.graphics.beginFill(fillColor, fillAlpha);
			
			if (isCircle)
			{
				outline.graphics.drawCircle(targetWidth / 2, targetWidth / 2, targetWidth / 2);
				maskS.graphics.drawCircle(targetWidth / 2, targetWidth / 2, targetWidth / 2);
			}
			else
			{
				outline.graphics.drawRect(0, 0, targetWidth, targetWidth);
				maskS.graphics.drawRect(0, 0, targetWidth, targetWidth);
			}
			
			outline.graphics.endFill();
			maskS.graphics.endFill();
		}
		
		public function captureBitmap(event:Event = null):void
		{						
			if (bitmap) destroyBitmap();
			
			var tempData:BitmapData;
			
			var resizeMatrix:Matrix = new Matrix();
			
			var rect:Rectangle = new Rectangle(x+(outline.width/4), y+(outline.width/4), outline.width/2, outline.height/2);
			var rect2:Rectangle = new Rectangle(x, y, outline.width/2, outline.height/2);
			if (rect.right < 0 || rect.bottom < 0) return;
			tempData = new BitmapData(rect.right, rect.bottom, true, 0);
			tempData.draw(target, resizeMatrix, null, null, rect);
			bitmapData = new BitmapData(outline.width, outline.height, true, 0);
			bitmapData.copyPixels(tempData, rect, zeroPoint, null, null, true);
			bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO, true);
			tempData.dispose();
			tempData = null;
			resizeMatrix = null;
			resizeMatrix = applyMatrixresizeMatrix(new Matrix(), magnification, outline.width / 2, outline.height / 2);
			bitmap.transform.matrix = resizeMatrix;
			bitmap.smoothing = true;
			bitmap.x = 0;
			bitmap.y = 0;
			
			addChildAt(bitmap, 0);
			//ts.addChildAt(bitmap, 0);
		}
		
		
		public function destroyBitmap():void
		{
			removeChild(bitmap);
			bitmap = null;
			
			bitmapData.dispose();
			bitmapData = null;
		}
		
		
		
		private function applyMatrixresizeMatrix(source:Matrix, scaleValue:Number, tx:Number, ty:Number):Matrix
		{
			source.tx -= tx;
			source.ty -= ty;
			source.scale(scaleValue, scaleValue);
			source.tx += tx;
			source.ty += ty;
			return source;
		}
	}
}