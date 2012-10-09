package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import org.tuio.*;
	
	/**
	 * Slider can be used through touch and mouse input devices. It also allows for the input value to be fed through a function call, allowing the slider to updated by another process.
	 * The slider can be orientated horizontally or vertically. It can act as a continuous slider or one that snaps to x-number of discrete steps.
	 * 
	 * It has following parametrs:hit, rail, knob, orientation, discrete, steps, min, max and gestureReleaseInertia.
	 * 
	 * @author Ideum (Charles Veasey)
	 */
	
	public class Slider extends Container 
	{
		private var debug:Boolean = false;				
		private var knobOffset:Number = 0;
		private var stepknobPositions:Array;
		private var touchKnob:TouchSprite;
		private var minPos:Number		
		private var maxPos:Number;
		
		/**
		 * constructor
		 */
		public function Slider() 
		{
			super();
			touchKnob = new TouchSprite;
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
			else
				_hit = searchChildren(value);
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
			else
				_rail = searchChildren(value);	
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
			else
				_knob = searchChildren(value);				
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
		
		
		private var _gestureReleaseInertia:Boolean = false;
		/**
		 * Turns gestureReleaseInertia off and on
		 * @default false
		 */		
		public function get gestureReleaseInertia():Boolean {return _gestureReleaseInertia;}
		public function set gestureReleaseInertia(value:Boolean):void
		{
			_gestureReleaseInertia = value;
			if (touchKnob)
				touchKnob.gestureReleaseInertia = value;
		}		
		
			
		
		
		// read only // 
		
		private var _knobPosition:Number = 0;
		/**
		 * Stores the current knobPosition in pixels
		 * @default 0
		 */		
		public function get knobPosition():Number {return _knobPosition;}

			
		private var _value:Number = 0;
		/**
		 * Stores the current value as mapped to the min and max values.
		 * Can be used as input value, set input=true
		 * @default 0
		 */		
		public function get value():Number { return _value; }
		
		
		// public methods//
		
		/**
		 * CML initialization callback
		 */
		override public function displayComplete():void
		{
			if (!rail)
				throw new Error("rail must be set");
			if (!hit)
				throw new Error("hit must be set");
			if (!knob)
				throw new Error("knob must be set");	
			
				
			if (mouseEnabled) {

				if (GestureWorks.activeTUIO)
					hit.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDownHit);
				else if (GestureWorks.supportsTouch)
					hit.addEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
				else
					hit.addEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
			
				touchKnob = new TouchSprite;
				touchKnob.mouseChildren = false;
				touchKnob.disableAffineTransform = true;
				touchKnob.disableNativeTransform = true;	
				touchKnob.gestureEvents = true;
				touchKnob.gestureList = { "n-drag-inertia": true };
				touchKnob.gestureReleaseInertia = gestureReleaseInertia;
				touchKnob.addEventListener(GWGestureEvent.DRAG, onDrag);
				if (gestureReleaseInertia)
				  touchKnob.addEventListener(GWGestureEvent.COMPLETE, onComplete);
				else
					touchKnob.addEventListener(TouchEvent.TOUCH_END, onComplete);
				touchKnob.addChild(knob);
				addChild(touchKnob);					
			}
			
			
			if (orientation == "horizontal")
			{
				knobOffset = knob.width / 2;
				minPos = rail.x - knobOffset;				
				maxPos = rail.x + rail.width - knobOffset;
				knob.x = minPos;				
			}
			else if (orientation == "vertical")
			{
				knobOffset = knob.height/2;
				minPos = rail.y - knobOffset;
				maxPos = rail.y + rail.height - knobOffset;	
				knob.y = minPos;					
			}
			
						
			if (discrete)
			{				
				stepknobPositions = [];
				var i:int;
								
				if (orientation == "horizontal")
				{				
					for (i = 0; i < steps; i++) 
					{					
						stepknobPositions[i] = (rail.width / (steps - 1)) * i;	
					}
				}
				else if (orientation == "vertical")
				{
					for (i = 0; i < steps; i++) 
					{
						stepknobPositions[i] = (rail.height / (steps-1)) * i;
					}
				}				
			}
		}
		
		
		/**
		 * Resets the knob position
		 */
		public function reset():void
		{
			if (orientation == "horizontal")			
				touchKnob.x = knobOffset;
			else if (orientation == "vertical")
				touchKnob.y = knobOffset;			
		}
		
		/**
		 * Initializes the slider object
		 */
		public function init():void
		{
			displayComplete();			
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
		
		private function onDownHit(event:*):void
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
	
		
		private function onDrag(event:GWGestureEvent):void
		{
			if (debug)			
				trace("drag");			
				
			var newValue:Number = 0;	
				
			if (orientation == "horizontal")
				newValue = knob.x + event.value.drag_dx;
			else if (orientation == "vertical")
				newValue = knob.y + event.value.drag_dy;
			
			if (newValue < minPos) {
				if (orientation == "horizontal")	
					knob.x = minPos;
				else if (orientation == "vertical")	
					knob.y = minPos;
			}	
			else if (newValue > maxPos) {
				if (orientation == "horizontal")	
					knob.x = maxPos;
				else if (orientation == "vertical")	
					knob.y = maxPos;
			}	
			else {
				if (orientation == "horizontal")	
					knob.x = newValue;
				else if (orientation == "vertical")	
					knob.y = newValue;
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
			if (orientation == "horizontal")
				_knobPosition = knob.x - minPos;
			else if (orientation == "vertical")
				_knobPosition = knob.y - minPos;
				
			_value = NumberUtils.map(_knobPosition, 0, rail.width, min, max, false, true, true); 							
			
			if (debug)
			{
				trace("id:", this.id);
				trace("knobPosition:", _knobPosition);
				trace("value:", _value)				
			}

			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _value));			
		}
		
		/**
		 * dispose method to nullify attributes and remove listeners
		 */
		override public function dispose():void
		{
			super.dispose();
			stepknobPositions = null;
			touchKnob = null;
			hit = null;
			rail = null;
			knob = null;
			touchKnob.removeEventListener(GWGestureEvent.COMPLETE, onComplete);
			touchKnob.removeEventListener(TouchEvent.TOUCH_END, onComplete);
			hit.removeEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
			hit.removeEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
			hit.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDownHit);
		}
		
	}

}