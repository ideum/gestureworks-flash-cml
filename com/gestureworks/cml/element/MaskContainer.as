package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.geom.Matrix;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.tweens.ITween;
	
	/**
	 * The MaskContainer element takes in one or multiple images and applies a mask designated in CML to all images in its child list.
	 * If there are multiple images, the class automatically cycles through them using double-tap. The gesture may be turned off in CML.
	 * This element is touch-enabled already, and does not need to be wrapped in a touchContainer.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 
	   var maskContainer:MaskContainer = new MaskContainer();
		maskContainer.maskShape = "rectangle";
		maskContainer.maskWidth = 100;
		maskContainer.maskHeight = 64;
		maskContainer.maskBorderColor = 0xff0000;
		maskContainer.maskBorderStroke = 2;
		maskContainer.maskBorderAlpha = 0.75;
		
		maskContainer.addChild(img);
		maskContainer.childToList("image", img);
		maskContainer.init();
	 
	 * </codeblock>
	 * 
	 * @author josh
	 * @see TouchContainer
	 */
		
	public class MaskContainer extends TouchContainer
	{
		private const PItoRAD:Number = Math.PI / 180;
		private const RADtoPI:Number = 180 / Math.PI;
		
		protected var _touchScreen:TouchContainer;
		public function get touchScreen():TouchContainer { return _touchScreen; }
		
		private const LOADED:String = "LOADED";
		
		protected var graphicArray:List;
		
		protected var overallMask:Graphic;
		protected var hitShape:Graphic
		protected var borderShape:Graphic;	
		protected var wShape:Graphic;
		
		private var _counter:Number = 0;
		public function get counter():Number { return _counter; }
		
		private var _x:Number;
		private var _y:Number;
		
		protected var _mShape:Graphic;
		public function get mShape():Graphic { return _mShape; }
		
		/**
		 * Constructor
		 */
		public function MaskContainer() 
		{
			super();
			
			graphicArray = new List();
			disableNativeTransform = true;
			nestedTransform = true;
			gestureEvents = true;
			//gestureList = { "n-double_tap":true, "n-drag":true, "n-rotate":true, "n-scale":true };
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
		 * @default 0x000000;
		 */
		public function get maskBorderColor():uint { return _maskBorderColor; }
		public function set maskBorderColor(value:uint):void {
			_maskBorderColor = value;
		}
		
		//MaskBorderThickness
		private var _maskBorderStroke:Number = 0;
		/**
		 * The thickness of the border in pixels.
		 * @default 0;
		 */
		public function get maskBorderStroke():Number { return _maskBorderStroke; }
		public function set maskBorderStroke(value:Number):void {
			_maskBorderStroke = value;
		}
		
		//MaskBorderAlpha
		private var _maskBorderAlpha:Number = 0;
		/**
		 * Alpha for the border of the mask if desired. Must be set between 0 and 1 to be visible.
		 * @default 0;
		 */
		public function get maskBorderAlpha():Number { return _maskBorderAlpha; }
		public function set maskBorderAlpha(value:Number):void {
			_maskBorderAlpha = value;
		}
		
		private var _maskX:Number = 0;
		/**
		 * Set the mask's starting X position.
		 */
		public function get maskX():Number { return _maskX; }
		public function set maskX(value:Number):void {
			_maskX = value;
		}
		
		private var _maskY:Number = 0;
		/**
		 * Set the mask's starting Y position.
		 */
		public function get maskY():Number { return _maskY; }
		public function set maskY(value:Number):void {
			_maskY = value;
		}
		
		private var _dragAngle:Number = 0;
		public function get dragAngle():Number { return _dragAngle; }
		public function set dragAngle(value:Number):void {
			_dragAngle = value;
		}
		
		private var _maskRotation:Number = 0;
		/**
		 * Set the starting rotation of the mask.
		 */
		public function get maskRotation():Number { return _maskRotation; }
		public function set maskRotation(value:Number):void {
			_maskRotation = value;
		}
		
		/**
		 * CML call back Initialisation
		 */
		override public function displayComplete():void {
			//super.displayComplete();
			
			//graphicArray.array = childList.getValueArray();
			
			for (var i:Number = 0; i < numChildren; i++) {
				if (getChildAt(i) is TouchContainer) {
					_touchScreen = getChildAt(i) as TouchContainer;
					removeChildAt(i);
					i--;
				} else {
					graphicArray.append(getChildAt(i));
				}
			}
			
			createMasks();
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			displayComplete();
		}
		
		private function createMasks():void {
			overallMask = new Graphic();
			
			//_touchScreen = new TouchContainer();
			//_touchScreen.gestureEvents = true;
			//_touchScreen.gestureList = { "n-drag":true, "n-rotate":true, "2-finger-scale":true, "n-double_tap":true, "3-finger-tilt":true };
			if (_touchScreen){
				addChild(_touchScreen);
				_touchScreen.gestureReleaseInertia = true;
			}
			
			switch(_maskShape) {
				case "rectangle":
					if(!_mShape){
						_mShape = new Graphic();
						_mShape.graphics.beginFill(0xffffff, 0);
						_mShape.graphics.drawRect((_maskBorderStroke/2) - (_maskWidth / 2), _maskBorderStroke/2 - (_maskHeight / 2), _maskWidth, _maskHeight);
						_mShape.graphics.endFill();
					}
					
					if(!borderShape){
						borderShape = new Graphic();
						borderShape.graphics.beginFill(_maskBorderColor, 0);
						borderShape.graphics.lineStyle(_maskBorderStroke, _maskBorderColor, _maskBorderAlpha);
						borderShape.graphics.drawRect(-1 * (_maskWidth / 2), -1 * (_maskHeight / 2), _maskWidth + (maskBorderStroke), _maskHeight + (maskBorderStroke));
						borderShape.graphics.endFill();
					}
					
					break;
				case "circle":
					if(!_mShape){
						_mShape = new Graphic();
						_mShape.graphics.beginFill(0xffffff, 0);
						_mShape.graphics.drawCircle(-1 * (_maskWidth / 2), -1 * (_maskHeight / 2), _maskRadius);
						_mShape.graphics.endFill();
					}
					
					if (!borderShape) {
						borderShape = new Graphic();
						borderShape.graphics.beginFill(_maskBorderColor, _maskBorderAlpha);
						borderShape.graphics.lineStyle(_maskBorderStroke, _maskBorderColor, _maskBorderAlpha);
						borderShape.graphics.drawCircle(-1 * (_maskWidth / 2), -1 * (_maskHeight / 2), _maskRadius + (_maskBorderStroke * 2));
						borderShape.graphics.endFill();
					}
					break;
			}
			
			if (_touchScreen){
				_touchScreen.addChild(borderShape);
				_touchScreen.addChild(_mShape);
			} else { addChild(borderShape); addChild(_mShape); }
			
			graphicArray.selectIndex(_counter).visible = true;
			graphicArray.selectIndex(_counter).mask = mShape;
			this.width = graphicArray.selectIndex(_counter).width;
			this.height = graphicArray.selectIndex(_counter).height;
			
			if(_touchScreen){
				_touchScreen.x = _maskX;
				_touchScreen.y = _maskY;
				_touchScreen.rotation = _maskRotation;
			}
			
			overallMask.graphics.beginFill(0x000000, 0);
			overallMask.graphics.lineStyle(0, 0, 0);
			overallMask.graphics.drawRect(0, 0, this.width, this.height);
			overallMask.graphics.endFill();
			addChild(overallMask);
			this.mask = overallMask;
			
			if(_touchScreen){
				_touchScreen.addEventListener(GWGestureEvent.DOUBLE_TAP, cycleMasks);
				_touchScreen.addEventListener(GWGestureEvent.TILT, alphaHandler);
			}
			
			if (this.parent) {
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", LOADED));
			}
		}
		
		/**
		 * cycles through multiple images
		 * @param	e
		 */
		public function cycleMasks(e:GWGestureEvent = null):void {			
			//removeChild(graphicArray.array[counter]);
			var tempAlpha:Number = graphicArray.selectIndex(_counter).alpha;
			graphicArray.selectIndex(_counter).visible = false;
			_counter++;
			
			if (_counter >= graphicArray.length) {
				_counter = 0;
			}
			graphicArray.selectIndex(_counter).mask = mShape;
			
			graphicArray.selectIndex(_counter).visible = true;
			//graphicArray.selectIndex(_counter).alpha = tempAlpha;
			graphicArray.selectIndex(_counter).alpha = 1
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _counter));
		}
		
		public function alphaHandler(e:GWGestureEvent):void {
			
			var alpha:Number = graphicArray.selectIndex(_counter).alpha + e.value.tilt_dy;
			if (alpha < 0.3)
				alpha = 0.3;
			else if (alpha > 1)
				alpha = 1;
			
			alphaShift(alpha);
		}
		
		public function alphaShift(n:Number):void {
			graphicArray.selectIndex(_counter).alpha = n;
		}
		
		public function reset():void {
			var mTween:ITween = BetweenAS3.tween(_touchScreen, { x:_maskX, y:_maskY, rotation:_maskRotation, scale:1, alpha:1 }, null, 0.5);
			mTween.play();
			var oTween:ITween = BetweenAS3.tween(graphicArray.selectIndex(_counter), { alpha:1 }, null, 0.5);
			oTween.play();
		}
		
		/**
		 * Dispose method to nullify listeners
		 */
		override public function dispose():void {
			super.dispose();
			
			_touchScreen.removeEventListener(GWGestureEvent.DOUBLE_TAP, cycleMasks);
			_touchScreen.removeEventListener(GWGestureEvent.TILT, alphaHandler);
			
			graphicArray = null;
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			hitShape = null;
			_mShape = null;
			borderShape = null;
			wShape = null;
			_touchScreen = null;
		}
	}

}