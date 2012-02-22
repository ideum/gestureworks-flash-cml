package com.gestureworks.cml.element 
{
	import away3d.audio.drivers.AbstractSound3DDriver;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * SliderElement
	 * @author Charles Veasey
	 */
	
	public class SliderElement extends Container 
	{
		private var debug:Boolean = true;				
		private var elements:Dictionary;	
		private var foregroundOffset:Number = 0;
		private var stepPositions:Array;
		
		public function SliderElement() 
		{
			super();
			elements = new Dictionary(true);	
		}
		
		
		override public function displayComplete():void
		{
			
			if (foreground)
			{
				elements["foreground"] = new TouchSprite;
			}
				
			
			if (hit)
			{				
				elements["hit"] = childList.getKey(hit);
				
				if (GestureWorks.supportsTouch) 
				{
					elements["hit"].addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					elements["hit"].addEventListener(TouchEvent.TOUCH_END, onEnd);
					elements["foreground"].addEventListener(TouchEvent.TOUCH_BEGIN, onDown);					
				}	
				
				else
				{
					elements["hit"].addEventListener(MouseEvent.MOUSE_DOWN, onDown);
					elements["hit"].addEventListener(MouseEvent.MOUSE_UP, onEnd);
					//elements["hit"].addEventListener(MouseEvent.MOUSE_OUT, onOut);					
					elements["foreground"].addEventListener(MouseEvent.MOUSE_DOWN, onDownFgnd);
				//	elements["foreground"].addEventListener(MouseEvent.MOUSE_OUT, onOut);										
				}
				
			}
			
			if (foreground)
			{
				foregroundOffset = childList.getKey(foreground).width / -2;
				elements["foreground"].x = foregroundOffset;
				addChild(elements["foreground"]);
			
				elements["foreground"].disableAffineTransform = true;
				elements["foreground"].disableNativeTransform = true;	
				elements["foreground"].gestureList = { "n-drag":true };
				elements["foreground"].gestureEvents = true;
				elements["foreground"].addEventListener(GWGestureEvent.DRAG, onDrag);				
				elements["foreground"].addChild(childList.getKey(foreground));
				
				
					//elements["foreground"].addEventListener(MouseEvent.MOUSE_UP, onEnd);
				
			}
			
			
			if (mode == "discrete" && steps > 0)
			{
				stepPositions = [];
				
				for (var i:int = 0; i < steps; i++) 
				{
					stepPositions[i] = (childList.getKey(background).width / (steps-1)) * i;
					
					trace(stepPositions[i]);
				}
			}
			
		}

		private function onDownFgnd(event:*):void
		{
			elements["foreground"].addEventListener(GWGestureEvent.DRAG, onDrag);				
		}
		
		
		private function onDown(event:*):void
		{
			
			elements["foreground"].addEventListener(GWGestureEvent.DRAG, onDrag);				
			
			var num:Number = event.localX;
			
			if (mode == "discrete")	
			{
				var index:int = getSnapValue(num, stepPositions);				
				elements["foreground"].x = stepPositions[index] + foregroundOffset;
			}
		
			else // default: continuous
			{
				elements["foreground"].x = event.localX + foregroundOffset;
			}
			
			_currentPosition = elements["foreground"].x - foregroundOffset;
			_currentValue = map(_currentPosition, 0, elements["hit"].width, min, max); 			
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "currentValue", _currentValue));
		}		
		
		
		private function onEnd(event:*):void
		{
			trace("end");
			
			elements["foreground"].removeEventListener(GWGestureEvent.DRAG, onDrag);				

			
			if (mode == "discrete")	
			{	
				var index:int = getSnapValue(elements["foreground"].x, stepPositions);
				
				trace(index);
				elements["foreground"].x = stepPositions[index] + foregroundOffset;
			}				
		}
		
		
		private var outFlag:Boolean = false;
		
		private function onOut(event:*):void
		{
			trace("out");
			
			outFlag = true;
		
			elements["foreground"].removeEventListener(GWGestureEvent.DRAG, onDrag);				
			
		}
		
		private function onDrag(event:GWGestureEvent):void
		{
			trace("drag");
			
			var moveValue:Number = elements["foreground"].x + event.value.dx;
			moveValue += childList.getKey(foreground).x;			

			if (moveValue >= (elements["hit"].x + foregroundOffset))
			{
				if (moveValue <= (elements["hit"].x + elements["hit"].width + foregroundOffset))
				{
					elements["foreground"].x += event.value.dx;
				}
				else
				{
					elements["foreground"].stopDrag();
					elements["foreground"].x = elements["hit"].width + foregroundOffset;					
				}
			}	
			else
			{
				elements["foreground"].stopDrag();											
				elements["foreground"].x = foregroundOffset;
			}
					
			
			_currentPosition = elements["foreground"].x - foregroundOffset;
			_currentValue = map(_currentPosition, 0, elements["hit"].width, min, max); 			
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "currentValue", _currentValue));
		}
		
		
		

		
		
		/**
		 * Resets the slider
		 */
		public function reset():void
		{
			elements["foreground"].x = foregroundOffset;			
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
		

		private var _background:String;
		/**
		 * Sets the slider's background element through a child id
		 * @default null
		 */		
		public function get background():String {return _background;}
		public function set background(value:String):void
		{
			_background = value;	
		}			
		
		

		private var _foreground:String;
		/**
		 * Sets the slider's foreground element through a child id
		 * @default null
		 */		
		public function get foreground():String {return _foreground;}
		public function set foreground(value:String):void
		{
			_foreground = value;	
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
		 * Sets the min output value when mode is set to continuous
		 * @default 0
		 */		
		public function get min():Number {return _min;}
		public function set min(value:Number):void
		{
			_steps = value;	
		}
		
		

		private var _max:Number = 100;
		/**
		 * Sets the max output value when mode is set to continuous
		 * @default 100
		 */		
		public function get max():Number {return _max;}
		public function set max(value:Number):void
		{
			_max = value;	
		}				
		
		
		
		private function map(v:Number, a:Number, b:Number, x:Number=0, y:Number=1):Number 
		{
			return (v == a) ? x : (v - a) * (y - x) / (b - a) + x;
		}
		
	
		private function getSnapValue(desiredNumber:Number, array:Array):int 
		{
			var nearestIndex:Number = -1;
			var bestDistanceFoundYet:Number = Number.MAX_VALUE;
			
			for (var i:int = 0; i < array.length; i++) 
			{				
				if (array[i] == desiredNumber) 
					return i;
				else 
				{
					var d:int = Math.abs(desiredNumber - array[i]);
					if (d < bestDistanceFoundYet) 
					{
						nearestIndex = i;
						bestDistanceFoundYet = d;
					}
				}
			}
			
			return nearestIndex;
		}
		
		
		
	}

}