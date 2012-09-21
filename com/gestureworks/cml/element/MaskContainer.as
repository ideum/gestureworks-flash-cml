package com.gestureworks.cml.element 
{
	import away3d.events.MouseEvent3D;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.core.TouchSprite;
	import flash.events.Event;
	import flash.events.GestureEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.cml.events.StateEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	/**
	 * The MaskContainer is a class that takes in one or multiple images and applies a mask designated in CML to them, similar to a GraphicElement.
	 * If there are multiple images, the class automatically cycles through them using double-tap. Gesture responsiveness may be turned off in CML.
	 * This element is touch-enabled already, and does not need to be wrapped in a touchContainer.
	 * ...
	 * @author josh
	 */
	public class MaskContainer extends TouchContainer
	{
		private const PItoRAD:Number = Math.PI / 180;
		private const RADtoPI:Number = 180 / Math.PI;
		
		private const LOADED:String = "LOADED";
		
		protected var graphicArray:List;
		
		protected var overallMask:GraphicElement;
		protected var hitShape:GraphicElement
		protected var borderShape:GraphicElement;	
		protected var wShape:GraphicElement;
		
		private var counter:Number = 0;
		
		private var _x:Number;
		private var _y:Number;
		
		protected var _mShape:GraphicElement;
		public function get mShape():GraphicElement { return _mShape; }
		
		public function MaskContainer() 
		{
			super();
			
			graphicArray = new List();
			disableNativeTransform = true;
			gestureEvents = true;
			gestureList = { "n-drag":true, "n-rotate":true, "n-scale":true, "double_tap_n":true };
		}
		
		//Mask SHAPE (STRING)
		private var _maskShape:String = "rectangle";
		/**
		 * The string property to designate the shape the mask will be. "rectangle" or "circle" are options.
		 */
		public function get maskShape():String { return _maskShape; }
		public function set maskShape(value:String):void {
			value = value.toLowerCase();
			_maskShape = value;
		}
		
		//Mask Radius
		private var _maskRadius:Number = 0;
		/**
		 * The property for the mask radius if the shape is a circle.
		 */
		public function get maskRadius():Number { return _maskRadius; }
		public function set maskRadius(value:Number):void {
			_maskRadius = value;
		}
		
		//Mask width
		private var _maskWidth:Number = 0;
		/**
		 * Mask width for rectangles.
		 */
		public function get maskWidth():Number { return _maskWidth; }
		public function set maskWidth(value:Number):void {
			_maskWidth = value;
		}
		
		//Mask height
		private var _maskHeight:Number = 0;
		/**
		 * Mask height for rectangles.
		 */
		public function get maskHeight():Number { return _maskHeight; }
		public function set maskHeight(value:Number):void {
			_maskHeight = value;
		}
		
		//MaskBorderColor
		private var _maskBorderColor:uint = 0x000000;
		/**
		 * Mask border color, if a border is desired around the mask element.
		 * @default: 0x000000;
		 */
		public function get maskBorderColor():uint { return _maskBorderColor; }
		public function set maskBorderColor(value:uint):void {
			_maskBorderColor = value;
		}
		
		//MaskBorderThickness
		private var _maskBorderStroke:Number = 0;
		/**
		 * The thickness of the border in pixels.
		 * @default: 0;
		 */
		public function get maskBorderStroke():Number { return maskBorderStroke; }
		public function set maskBorderStroke(value:Number):void {
			_maskBorderStroke = value;
		}
		
		//MaskBorderAlpha
		private var _maskBorderAlpha:Number = 0;
		/**
		 * Alpha for the border of the mask if desired. Must be set between 0 and 1 to be visible.
		 * @default: 0;
		 */
		public function get maskBorderAlpha():Number { return _maskBorderAlpha; }
		public function set maskBorderAlpha(value:Number):void {
			_maskBorderAlpha = value;
		}
		
		override public function displayComplete():void {
			super.displayComplete();
			
			graphicArray.array = childList.getValueArray();
			
			for (var i:Number = graphicArray.length - 1; i > -1; i--) {
				trace("Removing item: " + graphicArray.array[i] + " at " + i);
				removeChild(graphicArray.array[i]);
			}
			
			createMasks();
		}
		
		override public function init():void
		{
			displayComplete();
		}
		
		private function createMasks():void {
			overallMask = new GraphicElement();
			
			_mShape = new GraphicElement();
			borderShape = new GraphicElement();
			wShape = new GraphicElement();
			hitShape = new GraphicElement();
			
			switch(_maskShape) {
				case "rectangle":
					_mShape.graphics.beginFill(0xffffff, 0);
					_mShape.graphics.drawRect(_maskBorderStroke/2, _maskBorderStroke/2, _maskWidth, _maskHeight);
					_mShape.graphics.endFill();
					
					borderShape.graphics.beginFill(_maskBorderColor, _maskBorderAlpha);
					borderShape.graphics.lineStyle(0, 0, 0);
					borderShape.graphics.drawRect(0, 0, _maskWidth + _maskBorderStroke, _maskHeight + _maskBorderStroke);
					borderShape.graphics.endFill();
					
					wShape.graphics.beginFill(_maskBorderColor, _maskBorderAlpha);
					wShape.graphics.lineStyle(_maskBorderStroke, _maskBorderColor, _maskBorderAlpha);
					wShape.graphics.drawRect(0, 0, _maskWidth + _maskBorderStroke, _maskHeight + _maskBorderStroke);
					wShape.graphics.endFill();
					
					hitShape.graphics.beginFill(0xffffff, 0);
					hitShape.graphics.lineStyle(0, 0, 0);
					hitShape.graphics.drawRect(0, 0, _maskWidth + _maskBorderStroke, _maskHeight + _maskBorderStroke);
					hitShape.graphics.endFill();
					break;
				case "circle":
					_mShape.graphics.beginFill(0xffffff, 0);
					_mShape.graphics.drawCircle(0, 0, _maskRadius);
					_mShape.graphics.endFill();
					
					borderShape.graphics.beginFill(_maskBorderColor, _maskBorderAlpha);
					borderShape.graphics.lineStyle(_maskBorderStroke, _maskBorderColor, _maskBorderAlpha);
					borderShape.graphics.drawCircle(0, 0, _maskRadius + (_maskBorderStroke * 2));
					borderShape.graphics.endFill();
					
					wShape.graphics.beginFill(_maskBorderColor, _maskBorderAlpha);
					wShape.graphics.lineStyle(_maskBorderStroke, _maskBorderColor, _maskBorderAlpha);
					wShape.graphics.drawCircle(0, 0, _maskRadius + (_maskBorderStroke * 2));
					wShape.graphics.endFill();
					
					hitShape.graphics.beginFill(0x000000, 0);
					hitShape.graphics.lineStyle(0, 0, 0);
					hitShape.graphics.drawCircle(0, 0, _maskRadius + (_maskBorderStroke * 2));
					hitShape.graphics.endFill();
					break;
			}
			
			addChild(borderShape);
			addChild(wShape);
			borderShape.mask = wShape;
			addChild(_mShape);
			
			
			addChild(graphicArray.array[counter]);
			graphicArray.array[counter].visible = true;
			graphicArray.array[counter].mask = mShape;
			this.width = graphicArray.array[counter].width;
			this.height = graphicArray.array[counter].height;
			
			addChild(hitShape);
			
			overallMask.graphics.beginFill(0x000000, 0);
			overallMask.graphics.lineStyle(0, 0, 0);
			overallMask.graphics.drawRect(0, 0, this.width, this.height);
			overallMask.graphics.endFill();
			addChild(overallMask);
			this.mask = overallMask;
			
			addEventListener(GWGestureEvent.DRAG, dragHandler);
			addEventListener(GWGestureEvent.ROTATE, rotateHandler);
			addEventListener(GWGestureEvent.SCALE, scaleHandler);
			addEventListener(GWTouchEvent.TOUCH_BEGIN, gestureHandler);
			addEventListener(GWGestureEvent.DOUBLE_TAP, cycleMasks);
			
			if (this.parent) {
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", LOADED));
			}
		}
		
		private function gestureHandler(e:*):void {
			//trace("Gesture handling");
			_x = e.localX;
			_y = e.localY;
		}
		
		private function dragHandler(event:GWGestureEvent):void 
		{
			//trace("Dragging");
			var ang2:Number = rotation * (Math.PI / 180);
			var COS2:Number = Math.cos(ang2);
			var SIN2:Number = Math.sin(ang2);
			
				_mShape.x += event.value.drag_dx;
				borderShape.x += event.value.drag_dx;
				hitShape.x += event.value.drag_dx;
				wShape.x += event.value.drag_dx;
			
			if (_mShape.x < 0) {
				_mShape.x = 0;
				borderShape.x = 0;
				hitShape.x = 0;
				wShape.x = 0;
			}
			if (_mShape.x + _mShape.width > this.width) {
				_mShape.x = width - _mShape.width;
				borderShape.x = width - borderShape.width;
				hitShape.x = width - hitShape.width;
				wShape.x = width - wShape.width;
			}
				//_mShape.y += (event.value.drag_dy * COS2 - event.value.drag_dx * SIN2);//e.value.dy;
				_mShape.y += event.value.drag_dy;
				//borderShape.y += (event.value.drag_dy * COS2 - event.value.drag_dx * SIN2);//e.value.dy;
				borderShape.y += event.value.drag_dy;
				//hitShape.y += (event.value.drag_dy * COS2 - event.value.drag_dx * SIN2);//e.value.dy;
				hitShape.y += event.value.drag_dy;
				wShape.y += event.value.drag_dy;
			
			if (_mShape.y < 0) {
				_mShape.y = 0;
				borderShape.y = 0;
				hitShape.y = 0;
				wShape.y = 0;
			}
			if (_mShape.y + (_mShape.height * 2) > height) {
				_mShape.y = height - _mShape.height;
				borderShape.y = height - borderShape.height;
				hitShape.y = height - hitShape.height;
				wShape.y = height - wShape.height;
			}
		}
		
		private function rotateHandler(e:GWGestureEvent):void 
		{
			trace("mask rotation");
			trace(_x, _y);
			
			var m:Matrix = hitShape.transform.matrix;
			m.tx -= _x;
			m.ty -= _y;
			
			m.rotate(e.value.rotate_dtheta * PItoRAD);
			m.tx += _x;
			m.ty += _y;
			hitShape.transform.matrix = m;
			
			trace(hitShape.x, hitShape.y);
			
			_mShape.x = hitShape.x;
			borderShape.x = hitShape.x;
			wShape.x = hitShape.x;
			
			_mShape.y = hitShape.y;
			borderShape.y = hitShape.y;
			wShape.y = hitShape.y;
			
			_mShape.rotation = hitShape.rotation;
			borderShape.rotation = hitShape.rotation;
			wShape.rotation = hitShape.rotation;
		}
		
		private function scaleHandler(e:GWGestureEvent):void 
		{
			//trace("mask scale");
			_mShape.scaleX += e.value.scale_dsx;
			_mShape.scaleY += e.value.scale_dsy;
			
			borderShape.scaleX += e.value.scale_dsx;
			borderShape.scaleY += e.value.scale_dsy;
			
			hitShape.scaleX += e.value.scale_dsx;
			hitShape.scaleY += e.value.scale_dsy;
			wShape.scaleX += e.value.scale_dsx;
			wShape.scaleY += e.value.scale_dsy;
		}
		
		public function cycleMasks(e:GWGestureEvent):void {
			removeChild(graphicArray.array[counter]);
			counter++;
			
			if (counter >= graphicArray.length - 1) {
				counter = 0;
			}
			addChild(graphicArray.array[counter]);
			graphicArray.array[counter].mask = mShape;
			graphicArray.array[counter].visible = true;
		}
		
		override public function dispose():void {
			super.dispose();
			
			removeEventListener(GWGestureEvent.DRAG, dragHandler);
			removeEventListener(GWGestureEvent.ROTATE, rotateHandler);
			removeEventListener(GWGestureEvent.SCALE, scaleHandler);
			removeEventListener(GWTouchEvent.TOUCH_BEGIN, gestureHandler);
			removeEventListener(GWGestureEvent.DOUBLE_TAP, cycleMasks);
			
			graphicArray = null;
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			hitShape = null;
			_mShape = null;
			borderShape = null;
			wShape = null;
		}
	}

}