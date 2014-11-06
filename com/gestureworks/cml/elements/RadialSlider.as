package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.*;
	
	/**
	 * The RadialSlider element creates a circular progress bar that reponds touch and mouse input.
	 *  
	 * @author Ideum
	 * @see ProgressBar
	 */
	
	public class RadialSlider extends TouchContainer 
	{
		private var debug:Boolean = false;				
		private var knobOffset:Number = 0;
		private var stepknobPositions:Array;
		private var stepknobAngles:Array;
		
		public var touchKnob:TouchContainer;
		private var minPos:Number		
		private var maxPos:Number;
		
		/**
		 * Constructor
		 */
		public function RadialSlider() 
		{
			super();
			mouseChildren = true;
		}	
		
		private var _hit:*;
		/**
		 * Sets the slider's hit area
		 * @default null
		 */		
		public function get hit():* {return _hit;}
		public function set hit(value:*):void
		{
			if (value is DisplayObject)
				_hit = value;
			else {
				_hit = searchChildren(value);
				_hit = CMLObjectList.instance.getId(value);
			}
		}
				
		private var _rail:*;
		/**
		 * Sets the slider's rail element
		 * @default null
		 */		
		public function get rail():* {return _rail;}
		public function set rail(value:*):void
		{
			if (value is DisplayObject)
				_rail = value;
			else {
				_rail = searchChildren(value);
				_rail = CMLObjectList.instance.getId(value);
			}
			
			if (_rail) {
				width = rail.width;
				height = rail.height;
			}
		}					

		private var _knob:*;
		/**
		 * Sets the slider's knob element
		 * @default null
		 */		
		public function get knob():* {return _knob;}
		public function set knob(value:*):void
		{
			if (value is DisplayObject)
				_knob = value;
			else {
				_knob = searchChildren(value);	
				_knob = CMLObjectList.instance.getId(value);
			}
		}
		
		private var _railColor:uint = 0x000000;
		/**
		 * Color of default rail
		 */
		public function get railColor():uint { return _railColor; }
		public function set railColor(c:uint):void
		{
			_railColor = c;
		}
		
		private var _railAlpha:uint = 1;
		/**
		 * Alpha of default rail
		 */
		public function get railAlpha():Number { return _railAlpha; }
		public function set railAlpha(a:Number):void {
			_railAlpha = a;
		}
		
		private var _knobColor:uint = 0xDDDDDD;
		/**
		 * Color of default knob
		 */
		public function get knobColor():uint { return _knobColor; }
		public function set knobColor(c:uint):void {
			_knobColor = c;
		}
		
		private var _knobRadius:Number;
		/**
		 * Radius of default knob
		 */
		public function get knobRadius():Number { return _knobRadius; }
		public function set knobRadius(r:Number):void {
			_knobRadius = r;
		}

		private var _discrete:Boolean = false;
		/**
		 * Sets the slider's mode
		 * @default false
		 */		
		public function get discrete():Boolean {return _discrete;}
		public function set discrete(value:Boolean):void
		{
			_discrete = value;
		}
		
		private var _steps:int = 9;
		/**
		 * Sets the number of discrete steps used when discrete is true
		 * @default 9
		 */		
		public function get steps():int {return _steps;}
		public function set steps(value:int):void
		{
			_steps = value;	
		}
		
		private var _min:Number = 0;
		/**
		 * Sets the min output value
		 * @default 0
		 */		
		public function get min():Number {return _min;}
		public function set min(value:Number):void
		{
			_min = value;
		}
		
		private var _max:Number = 100;
		/**
		 * Sets the max output value
		 * @default 100
		 */		
		public function get max():Number {return _max;}
		public function set max(value:Number):void
		{
			_max = value;	
		}				
		
		private var _progress:Number = 0;
		/**
		 * Sets the progress of the slider, in min to max range.
		 * Setting does not refresh display of progress.
		 */
		public function get progress():Number {return _progress;}
		public function set progress(value:Number):void
		{
			_progress = value;
		}
		
		private var _startAngle:Number = 0;
		/**
		 * Sets the angle, clockwise from x axis, to start the slider
		 */
		public function get startAngle():Number {return _startAngle;}
		public function set startAngle(value:Number):void
		{
			_startAngle = value;
			
			if (_rail && _rail is Graphic)
			{
				rail.startAngle = startAngle;
			}
		}
		
		private var _clockwise:Boolean = false;
		/**
		 * Sets if the slider should go clockwise
		 * @default false
		 */
		public function get clockwise():Boolean {return _clockwise;}
		public function set clockwise(value:Boolean):void
		{
			_clockwise = value;
			
			if (_rail && _rail is Graphic)
			{
				rail.clockwise = clockwise;
			}
		}
		
		private var _centerX:Number = 0.0;
		/**
		 * Sets the center X value to use for slider
		 */
		public function get centerX():Number {return _centerX;}
		public function set centerX(value:Number):void
		{
			_centerX = value;
		}
		
		private var _centerY:Number = 0.0;
		/**
		 * Sets the center Y value to use for slider
		 */
		public function get centerY():Number {return _centerX;}
		public function set centerY(value:Number):void
		{
			_centerY = value;
		}
		
		private var _radius:Number = 0.0;
		/**
		 * Sets the outer radius value for the slider
		 */
		public function get radius():Number {return _radius;}
		public function set radius(value:Number):void
		{
			_radius = value;
		}
		
		private var _innerRadius:Number = 0.0;
		/**
		 * Sets the inner radius value for the slider
		 */
		public function get innerRadius():Number {return _innerRadius;}
		public function set innerRadius(value:Number):void
		{
			_innerRadius = value;
		}
		
		
		// read only // 
			
		private var _value:Number = 0;
		private var oldPoint:Point;
		/**
		 * Stores the current value as mapped to the min and max values.
		 * Can be used as input value, set input=true
		 * @default 0
		 */		
		public function get value():Number { return _value; }
		
		// public methods//		
		public function createEvents():void {
			if (hit)
			{
				hit.addEventListener(GWTouchEvent.TOUCH_BEGIN, onDownHit);
			}
			
			if (touchKnob)
			{
				touchKnob.addEventListener(GWGestureEvent.DRAG, onDrag);
				if (gestureReleaseInertia)
				  touchKnob.addEventListener(GWGestureEvent.COMPLETE, onComplete);
				else{
					touchKnob.addEventListener(GWTouchEvent.TOUCH_END, onComplete);
					
					if (hit)
					{
						hit.addEventListener(GWTouchEvent.TOUCH_OUT, onComplete);
					}
				}
			}
		}
		
		/**
		 * Initializes the slider object
		 */
		override public function init():void
		{	
			setupUI();
			
			if (knob)
			{
				if (mouseEnabled) {
					
					touchKnob = new TouchContainer;
					touchKnob.mouseChildren = false;
					touchKnob.affineTransform = false;
					touchKnob.nativeTransform = false;	
					touchKnob.gestureEvents = true;
					touchKnob.gestureList = { "n-drag-inertia": true };
					touchKnob.gestureReleaseInertia = false;
					
					touchKnob.addChild(knob);
					addChild(touchKnob);					
				}
				
				var knobStartPosition:Point = findPoint(0.0);
				knob.x = knobStartPosition.x;
				knob.y = knobStartPosition.y;
				
				knobOffset = -knobRadius;
			}
			
			if (discrete && steps > 0)
			{
				stepknobPositions = [];
				stepknobAngles = [];
				var angle:Number = 0;
				var angleStep:Number = 360.0 / steps;
				
				for (var i:uint = 0; i < steps; ++i)
				{
					stepknobPositions[i] = findPoint(i * angleStep);
					stepknobAngles[i] = i * angleStep;
				}
			}
			
			createEvents();			
		}
		
		/**
		 * Generates default elements
		 */
		protected function setupUI():void
		{
			if (!radius)
				radius = 100;
				
			if (!rail)
			{
				var railGraphic:Graphic = new Graphic();
				railGraphic.shape = "circleSegment";
				railGraphic.radius = radius;
				railGraphic.innerRadius = innerRadius;
				railGraphic.startAngle = startAngle;
				railGraphic.lineStroke = 1;
				railGraphic.color = railColor;
				railGraphic.alpha = railAlpha;
				railGraphic.lineColor = 0x333333;
				railGraphic.clockwise = clockwise;
				addChild(railGraphic);
				rail = DisplayObject(railGraphic);
			}
			
			if (!knob && defaultKnob)
				knob = defaultKnob;
		}	
		
		/**
		 * Provides default knob graphic when one is not provided. External to allow subclasses to bypass knob requirement. 
		 */
		protected function get defaultKnob():DisplayObject {
			var knobGraphic:Graphic = new Graphic();
			knobGraphic.shape = "circle";
			
			if (!knobRadius) {
				knobRadius = hit.width / 2;
			}
			knobGraphic.radius = knobRadius;
			knobGraphic.lineStroke = 2;
			knobGraphic.color = knobColor;
			knobGraphic.lineColor = 0x666666;
			return  DisplayObject(knobGraphic);				
		}
		
		/**
		 * Sets the value of the slider. Can set mouseInput=false to disable touch/mouse interaction.
		 * @param	val Input value contrained to output min and max
		 */		
		public function input(val:Number):void
		{	
			progress = val;
			
			updateValues();
		}
		
		protected function onDownHit(event:*):void
		{	
			if (debug)
				trace("down hit");
				
			var x:Number = event.localX - centerX;
			var y:Number = event.localY - centerY;
			
			progress = findProgress(x, y);
			
			updateValues();
		}
		
		protected function onDrag(event:GWGestureEvent):void
		{
			if (debug)			
				trace("drag");
				
			var x:Number = event.value.localX - centerX;
			var y:Number = event.value.localY - centerY;
			
			progress = findProgress(x, y);
			
			updateValues();
		}

		private function onComplete(event:*):void
		{
			if (debug)
				trace("release");
			
			updateValues();
		}		
		
		private function updateValues():void
		{
			var progressAngleBase:Number = NumberUtils.map(progress, min, max, 0.0, 360.0);
			
			var progressAngle:Number = progressAngleBase;
			if (!clockwise)
			{
				progressAngle = 360.0 - progressAngle;
			}
			
			var angle:Number = startAngle + progressAngle;
			
			var pi:Number = Math.PI;
			angle = (angle / 180.0) * pi;
			
			var placementRadius:Number = innerRadius + ((radius - innerRadius) * 0.5);
			
			var knobPosition:Point = new Point();
			knobPosition.x = Math.cos(angle) * placementRadius + knobOffset + centerX;
			knobPosition.y = Math.sin(angle) * placementRadius + knobOffset + centerY;
			
			if (discrete && steps > 0)
			{
				var index:int = getSnapValue(knobPosition);
				if (index > 0 && index < stepknobPositions.length && index < stepknobAngles.length)
				{
					knobPosition = stepknobPositions[index];
					progressAngleBase = stepknobAngles[index];
					if (!clockwise)
					{
						progressAngleBase = 360.0 - progressAngleBase;
					}
				}
			}
			
			knob.x = knobPosition.x;
			knob.y = knobPosition.y;

			if (_rail && _rail is Graphic)
			{
				_rail.angleLength = progressAngleBase;
			}
			
			_value = progress;
			
			if (debug)
			{
				trace("id:", this.id);
				trace("value:", _value);		
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "value", _value, true));
		}
		
		
		private function findPoint(angleDegrees:Number):Point
		{
			var pi:Number = Math.PI;
			var angle:Number = ((startAngle + angleDegrees) / 180.0) * pi;
			var radius:Number = innerRadius + ((radius - innerRadius) * 0.5);
			
			return new Point(Math.cos(angle) * radius + centerX - knobRadius, 
							 Math.sin(angle) * radius + centerY - knobRadius);
		}
		
		private function findProgress(x:Number, y:Number):Number
		{	
			var angle:Number = Math.atan2(y, x);
			
			var pi:Number = Math.PI;
			angle = angle * (180.0 / Math.PI);
			
			angle -= startAngle;
			
			while (angle < 0.0) angle += 360.0;
			while (angle > 360.0) angle -= 360.0;
			
			if (!clockwise)
			{
				angle = 360.0 - angle;
			}
			
			return NumberUtils.map(angle, 0.0, 360.0, min, max);
		}
		
		private function getSnapValue(desiredPoint:Point):int
		{
			var nearestIndex:int = -1;
			var bestDistance:Number = Number.MAX_VALUE;
			
			var distance:Number = 0;
			var stepKnobPositionsLength:uint = stepknobPositions.length;
			
			for (var i:uint = 0; i < stepKnobPositionsLength; ++i)
			{
				distance = Point.distance(stepknobPositions[i], desiredPoint);
				
				if (distance < bestDistance)
				{
					nearestIndex = i;
					bestDistance = distance;
				}
			}
			
			return nearestIndex;
		}
		
		override public function clone():*{
			var v:Vector.<String> = new < String > ["touchKnob", "knob", "hit", "rail"];
			var clone:RadialSlider = CloneUtils.clone(this, parent, v);
			
			//CloneUtils.copyChildList(this, clone);
			
			if (clone.parent)
				clone.parent.addChild(clone);
			else
				this.parent.addChild(clone);
			
			for (var i:int = 0; i < clone.numChildren; i++) 
			{
				if (clone.getChildAt(i).name == touchKnob.name) {
					clone.touchKnob = clone.getChildAt(i) as TouchContainer;
					clone.knob = clone.touchKnob.getChildAt(0) as Graphic;
				}
				else if (clone.getChildAt(i).name == hit.name) {
					clone.hit = clone.getChildAt(i);
				}
				else if (clone.getChildAt(i).name == rail.name) {
					clone.rail = clone.getChildAt(i);
				}
			}
			
			clone.init();
			if (clone.mouseEnabled)
				clone.createEvents();
			
			return clone;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			touchKnob = null;
			rail = null;
			knob = null;
			stepknobAngles = null;
			stepknobPositions = null;
			oldPoint = null;
			if(_hit){
				_hit.removeEventListener(GWTouchEvent.TOUCH_OUT, onComplete);
				_hit.removeEventListener(GWTouchEvent.TOUCH_BEGIN, onDownHit);
				_hit = null;
			}
		}
		
	}

}