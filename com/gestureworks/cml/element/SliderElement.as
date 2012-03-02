package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.*;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.cml.core.*;	
	import com.gestureworks.events.GWGestureEvent;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * SliderElement
	 * @author Charles Veasey
	 */
	
	public class SliderElement extends Container 
	{
		private var debug:Boolean = false;				
		private var elements:Dictionary;	
		private var knobOffset:Number = 0;
		private var stepPositions:Array;
		
		public static var SLIDER_UPDATE:String = "slider update";
		
		public function SliderElement() 
		{
			super();
			elements = new Dictionary(true);	
		}
		
		
		override public function displayComplete():void
		{
			elements["knob"] = new TouchSprite;
			elements["hit"] = childList.getKey(hit);
			
			if (GestureWorks.supportsTouch) 
			{
				//trace("supports touch");
				elements["hit"].addEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
			}	
			else
			{
				elements["hit"].addEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
				elements["knob"].addEventListener(MouseEvent.MOUSE_DOWN, onDownFgnd);
			}			
			
			if (orientation == "horizontal")
			{
				knobOffset = (childList.getKey(knob).width / -2) + elements["hit"].x;
				elements["knob"].x = knobOffset;
			}
			else if (orientation == "vertical")
			{
				knobOffset = (childList.getKey(knob).height / -2) + elements["hit"].y;
				elements["knob"].y = knobOffset;					
			}

			elements["knob"].mouseChildren = false;
			elements["knob"].disableAffineTransform = true;
			elements["knob"].disableNativeTransform = true;	
			elements["knob"].gestureEvents = true;
			elements["knob"].addEventListener(GWGestureEvent.DRAG, onDrag);
			elements["knob"].addEventListener(GWGestureEvent.RELEASE, onRelease);							
			elements["knob"].addChild(childList.getKey(knob));
			addChild(elements["knob"]);				
						
			
			if (mode == "discrete")
			{
				stepPositions = [];
				var i:int;
								
				if (orientation == "horizontal")
				{				
					for (i = 0; i < steps; i++) 
					{					
						stepPositions[i] = (childList.getKey(hit).width / (steps-1)) * i;					
					}
				}
				else if (orientation == "vertical")
				{
					for (i = 0; i < steps; i++) 
					{
						stepPositions[i] = (childList.getKey(hit).height / (steps-1)) * i;
						
					}
				}				
				
				elements["knob"].gestureList = { "n-drag-no-physics": true, "tap":true };				
			}
			else
			{
				elements["knob"].gestureList = { "n-drag": true, "tap":true };
			}
			
		}

		
		
		/**
		 * Resets the slider
		 */
		public function reset():void
		{
			if (orientation == "horizontal")			
				elements["knob"].x = knobOffset;
			else if (orientation == "vertical")
				elements["knob"].y = knobOffset;			
		}
		
		
		private var _currentPosition:Number = 0;
		/**
		 * Stores the current position in pixels
		 * @default 0
		 */		
		public function get currentPosition():Number {return _currentPosition;}

		
		private var _currentValue:Number = 0;
		/**
		 * Stores the current value as mapped to the min and max values
		 * @default 0
		 */		
		public function get currentValue():Number {return _currentValue;}
		
		
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
		
		
		private var _mode:String = "continuous";
		/**
		 * Sets the slider's mode, choose continuous or discrete
		 * @default continuous
		 */		
		public function get mode():String {return _mode;}
		public function set mode(value:String):void
		{
			_mode = value;
		}		

		
		private var _hit:String;
		/**
		 * Sets the slider's hit area through a child id
		 * @default null
		 */		
		public function get hit():String {return _hit;}
		public function set hit(value:String):void
		{
			_hit = value;	
		}
		
		
		private var _rail:String;
		/**
		 * Sets the slider's rail element through a child id
		 * @default null
		 */		
		public function get rail():String {return _rail;}
		public function set rail(value:String):void
		{
			_rail = value;	
		}			
		

		private var _knob:String;
		/**
		 * Sets the slider's knob element through a child id
		 * @default null
		 */		
		public function get knob():String {return _knob;}
		public function set knob(value:String):void
		{
			_knob = value;	
		}
					
		
		private var _steps:int = 3;
		/**
		 * Sets the number of steps when mode is set to discrete
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
		
		
		
		
		///////////////////////////////////////////////////////
		/// EVENT HANDLERS
		//////////////////////////////////////////////////////
		
		private function onDownHit(event:*):void
		{
			trace("ontdown")
			
			var num:Number;
			
			if (orientation == "horizontal")		
				num = event.localX;
			else if (orientation == "vertical")
				num = event.localY;
			
			if (mode == "continuous")	
			{
				if (orientation == "horizontal")				
					elements["knob"].x = num + knobOffset;
				else if (orientation == "vertical")
					elements["knob"].y = num + knobOffset;		
			}
		
			else if (mode == "discrete")
			{
				var index:int = getSnapValue(num, stepPositions);				
				
				if (orientation == "horizontal")		
					elements["knob"].x = stepPositions[index] + knobOffset;
				else if (orientation == "vertical")
					elements["knob"].y = stepPositions[index] + knobOffset;
			}
			
			updateValues();
		}			
		
		
		private function onDownFgnd(event:*):void
		{
			//trace("ontdown")
			elements["knob"].removeEventListener(GWGestureEvent.DRAG, onDrag);													
			elements["knob"].addEventListener(GWGestureEvent.DRAG, onDrag);
			
			elements["knob"].removeEventListener(GWGestureEvent.RELEASE, onRelease);				
			elements["knob"].addEventListener(GWGestureEvent.RELEASE, onRelease);						
		}
		
	
		private function onRelease(event:*):void
		{
			if (debug)
				trace("release");			
			
			
			if (mode == "discrete")	
			{
				var index:int;
				
				if (orientation == "horizontal")
				{
					index = getSnapValue(elements["knob"].x, stepPositions);
					elements["knob"].x = stepPositions[index] + knobOffset;
				}
				else if (orientation == "vertical")
				{
					index = getSnapValue(elements["knob"].y, stepPositions);
					elements["knob"].y = stepPositions[index] + knobOffset;
				}	
			}	
			
			updateValues();
		}
		
		
		private function onDrag(event:GWGestureEvent):void
		{
			if (debug)			
				trace("drag");
			
			
			var moveValue:Number = 0;	
				
			if (orientation == "horizontal")
			{	
				moveValue = elements["knob"].x + event.value.dx;
				moveValue += childList.getKey(knob).x;
				
				if (moveValue >= knobOffset)
				{
					if (moveValue <= (elements["hit"].width + knobOffset))
					{
						elements["knob"].x += event.value.dx;
					}
					else
					{
						elements["knob"].stopDrag();
						elements["knob"].x = elements["hit"].width + knobOffset;					
					}
				}	
				else
				{
					elements["knob"].stopDrag();											
					elements["knob"].x = knobOffset;
				}				
			}
			
			else if (orientation == "vertical")
			{
				moveValue = elements["knob"].y + event.value.dy;
				moveValue += childList.getKey(knob).y;
				
				if (moveValue >= (elements["hit"].y + knobOffset))
				{
					if (moveValue <= (elements["hit"].y + elements["hit"].height + knobOffset))
					{
						elements["knob"].y += event.value.dy;
					}
					else
					{
						elements["knob"].stopDrag();
						elements["knob"].y = elements["hit"].height + knobOffset;					
					}
				}	
				else
				{
					elements["knob"].stopDrag();											
					elements["knob"].y = knobOffset;
				}					
			}			
			
			updateValues();
		}
	
		
		
		///////////////////////////////////////////////////////
		/// HELPERS
		//////////////////////////////////////////////////////		
		
		private function map(v:Number, a:Number, b:Number, x:Number=0, y:Number=1):Number 
		{
			return (v == a) ? x : (v - a) * (y - x) / (b - a) + x;
		}
		
	
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
			{
				_currentPosition = elements["knob"].x - knobOffset;
				_currentValue = map(_currentPosition, 0, elements["hit"].width, min, max); 			
			}
			
			else if (orientation == "vertical")
			{
				_currentPosition = elements["knob"].y - knobOffset;
				_currentValue = map(_currentPosition, 0, elements["hit"].height, min, max); 			
			}			
			
			if (debug)
			{
				trace("id:", this.id);
				trace("currentPosition:", _currentPosition);
				trace("currentValue:", _currentValue)				
			}

			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "currentValue", _currentValue));			
		}
		
	}

}