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
	 * The Slider element creates s horizontal or vertical slider that reponds touch and mouse input. It also allows for the input 
	 * value to be fed through a function call, allowing the slider to updated by another process. The slider can be orientated 
	 * horizontally or vertically. It can act as a continuous slider or one that snaps to x-number of discrete steps.
	 *  
	 * @author Ideum
	 * @see ScrollBar
	 */
	
	public class Slider extends TouchContainer 
	{
		private var debug:Boolean = false;				
		private var knobOffset:Number = 0;
		private var stepknobPositions:Array;
		public var touchKnob:TouchContainer;
		private var minPos:Number		
		private var maxPos:Number;
		
		/**
		 * Constructor
		 */
		public function Slider() 
		{
			super();
			mouseChildren = true;
		}	
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			if (rail) rail.width = value;
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (rail) rail.height = value;
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
			}
		}
		
		private var _railLineColor:uint = 0x333333;
		/**
		 * Color of default rail line
		 */
		public function get railLineColor():uint { return _railLineColor; }
		public function set railLineColor(c:uint):void {
			_railLineColor = c;
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
		
		/**
		 * Convenience orientation flag
		 * @return true if horizontal, false otherwise
		 */
		public function isHorizontal():Boolean
		{
			return orientation == "horizontal";
		}
		
		private var _orientation:String = "horizontal";
		/**
		 * Sets the orientation of the slider, choose horizontal or vertical
		 * @default horizontal
		 */		
		public function get orientation():String {return _orientation;}
		public function set orientation(value:String):void
		{
			_orientation = value;	
		}
		
		
		private var _discrete:Boolean = false;
		/**
		 * Sets the slider's mode
		 * @default true
		 */		
		public function get discrete():Boolean {return _discrete;}
		public function set discrete(value:Boolean):void
		{
			_discrete = value;
		}		

		
		private var _steps:int = 3;
		/**
		 * Sets the number of discrete steps used when discrete is true
		 * @default 3
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
		
		
		/**
		 * Turns gestureReleaseInertia off and on
		 * @default false
		 */		
		override public function get releaseInertia():Boolean {return super.releaseInertia;}
		override public function set releaseInertia(value:Boolean):void
		{
			super.releaseInertia = value;
			if (touchKnob)
				touchKnob.releaseInertia = value;
		}		
		
			
		
		
		// read only // 
		
		private var _knobPosition:Number = 0;
		/**
		 * Stores the current knobPosition in pixels
		 * @default 0
		 */		
		public function get knobPosition():Number {return _knobPosition;}
			
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
			hit.addEventListener(GWTouchEvent.TOUCH_BEGIN, onDownHit);
			
			if (touchKnob)
			{
				touchKnob.addEventListener(GWGestureEvent.DRAG, onDrag);
				if (gestureReleaseInertia)
				  touchKnob.addEventListener(GWGestureEvent.COMPLETE, onComplete);
				else{
					touchKnob.addEventListener(GWTouchEvent.TOUCH_END, onComplete);
					hit.addEventListener(GWTouchEvent.TOUCH_OUT, onComplete);
				}
			}
		}
		
		/**
		 * Resets the knob position
		 */
		public function reset():void
		{
			if (isHorizontal())			
				touchKnob.x = knobOffset;
			else 
				touchKnob.y = knobOffset;			
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
					touchKnob.gestureReleaseInertia = gestureReleaseInertia;
					
					touchKnob.addChild(knob);
					addChild(touchKnob);					
				}
				
				
				if (isHorizontal())
				{
					knobOffset = knob.width / 2;
					minPos = rail.x - knobOffset;				
					maxPos = rail.x + rail.width - knobOffset;
					knob.x = minPos;
					knob.y = rail.height / 2 - knob.height / 2;
				}
				else 
				{
					knobOffset = knob.height/2;
					minPos = rail.y - knobOffset;
					maxPos = rail.y + rail.height - knobOffset;	
					knob.y = minPos;					
					knob.x = rail.width / 2 - knob.width / 2;
				}
			}
								
			if (discrete)
			{				
				stepknobPositions = [];
				var i:int;
								
				if (isHorizontal())
				{				
					for (i = 0; i < steps; i++) 
					{					
						stepknobPositions[i] = (rail.width / (steps - 1)) * i;	
					}
				}
				else
				{
					for (i = 0; i < steps; i++) 
					{
						stepknobPositions[i] = (rail.height / (steps-1)) * i;
					}
				}				
			}
			
			createEvents();			
		}
		
		/**
		 * Generates default elements
		 */
		protected function setupUI():void
		{
			if (!width)
				width = isHorizontal() ? 500: 20;
			if (!height)
				height = isHorizontal() ? 20: 500;
				
			if (!rail)
			{
				var railGraphic:Graphic = new Graphic();
				railGraphic.shape = "rectangle";
				railGraphic.width = isHorizontal() ? width: height;
				railGraphic.height = isHorizontal() ? height: width;
				railGraphic.lineStroke = 1;
				railGraphic.color = railColor;
				railGraphic.alpha = railAlpha;
				railGraphic.lineColor = railLineColor;
				addChild(railGraphic);
				rail = DisplayObject(railGraphic);
			}
			
			if (!hit)
			{
				var hitGraphic:Graphic = railGraphic.clone();
				hitGraphic.alpha = 0;
				addChild(hitGraphic);
				hit = DisplayObject(hitGraphic);
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
			knobGraphic.radius = knobRadius ? knobRadius : isHorizontal() ? hit.height / 2 : hit.width / 2;
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
			if (orientation == "horizontal") {
				_knobPosition = NumberUtils.map(val, min, max, 0, rail.width, false, true, true); 						
				_knobPosition -= knobOffset;				
				knob.x = _knobPosition;			
			}	
			else if (orientation == "vertical") {
				_knobPosition = NumberUtils.map(val, min, max, 0, rail.height, false, true, true); 						
				_knobPosition -= knobOffset;				
				knob.y = _knobPosition;	
			}	
		}
		
		
		// private event handlers //
		
		protected function onDownHit(event:*):void
		{			
			var num:Number;
			
			if (orientation == "horizontal")		
				num = event.localX;
			else if (orientation == "vertical")
				num = event.localY;
			
			if (!discrete)	
			{
				if (orientation == "horizontal")				
					knob.x = num + rail.x - knobOffset;
				else if (orientation == "vertical")
					knob.y = num + rail.y - knobOffset;		
			}
			else
			{
				var index:int = getSnapValue(num, stepknobPositions);				
				
				if (orientation == "horizontal")		
					knob.x = stepknobPositions[index] - knobOffset;
				else if (orientation == "vertical")
					knob.y = stepknobPositions[index] - knobOffset;
			}
						
			updateValues();
		}	
	
		
		protected function onDrag(event:GWGestureEvent):void
		{
			if (debug)			
				trace("drag");			
				
			var newValue:Number = 0;
			var point:Point = new Point(knob.x, knob.y);
			
			if (!oldPoint) {
				oldPoint = new Point(event.value.localX, event.value.localY);
			}
			else if (oldPoint) {
				point.x += event.value.localX - point.x;
				point.y += event.value.localY - point.y;
				oldPoint.y = event.value.localY;
				oldPoint.x = event.value.localX;
			}
			
			if (orientation == "horizontal" && point.x-knob.height/2 < minPos)	
				knob.x = minPos;
			else if (orientation == "vertical" && point.y-knob.height/2 < minPos)	
				knob.y = minPos;
			else if (orientation == "horizontal" && point.x-knob.height/2 > maxPos)	
				knob.x = maxPos;
			else if (orientation == "vertical" && point.y-knob.height/2 > maxPos)	
				knob.y = maxPos;
			else {
				if (orientation == "horizontal")	
					knob.x = point.x - knob.width/2;
				else if (orientation == "vertical")	
					knob.y = point.y - knob.height/2;
			}
			
			updateValues();
		}
	
		
		private function onComplete(event:*):void
		{
			if (debug)
				trace("release");			
			
			
			if (discrete)	
			{
				var index:int;
				
				if (orientation == "horizontal")
				{
					index = getSnapValue(knob.x+knobOffset, stepknobPositions);
					knob.x = stepknobPositions[index] - knobOffset;
				}
				else if (orientation == "vertical")
				{
					index = getSnapValue(knob.y+knobOffset, stepknobPositions);
					knob.y = stepknobPositions[index] - knobOffset;
				}	
			}	
			
			updateValues();
		}		
		
		
		// private methods // 	

	
		private function getSnapValue(desiredNumber:Number, array:Array):int 
		{
			var nearestIndex:Number = -1;
			var bestDistanceFoundYet:Number = Number.MAX_VALUE;
			var d:int = 0;
			
			for (var i:int = 0; i < array.length; i++) 
			{				
				if (array[i] == desiredNumber) 
					return i;
				else 
				{
					d = Math.abs(desiredNumber - array[i]);
					if (d < bestDistanceFoundYet) 
					{
						nearestIndex = i;
						bestDistanceFoundYet = d;
					}
				}
			}
			
			return nearestIndex;
		}
		
		
		private function updateValues():void
		{
			if (orientation == "horizontal") {
				_knobPosition = knob.x - minPos;
				_value = NumberUtils.map(_knobPosition, 0, rail.width, min, max, false, true, true); 											
			}
			else if (orientation == "vertical") {
				_knobPosition = knob.y - minPos;
				_value = NumberUtils.map(_knobPosition, 0, rail.height, min, max, false, true, true); 											
			}
			
			if (debug)
			{
				trace("id:", this.id);
				trace("knobPosition:", _knobPosition);
				trace("value:", _value)				
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _value, true));			
		}
		
		override public function clone():*{
			var v:Vector.<String> = new < String > ["touchKnob", "knob", "hit", "rail"];
			var clone:Slider = CloneUtils.clone(this, parent, v);
			
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
			stepknobPositions = null;
			touchKnob = null;
			hit = null;
			rail = null;
			knob = null;
			oldPoint = null;
		}
		
		public function updateLayout():void {
			if (orientation == "horizontal") {
				if (rail) {
					this.width = rail.width;
					this.height = rail.height;
				}
			}
		}
		
	}

}