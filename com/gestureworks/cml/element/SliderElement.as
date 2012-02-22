package com.gestureworks.cml.element 
{
	import away3d.audio.drivers.AbstractSound3DDriver;
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
			elements["foreground"] = new TouchSprite;
			
			elements["hit"] = childList.getKey(hit);
			
			if (GestureWorks.supportsTouch) 
			{
				elements["hit"].addEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
				elements["foreground"].addEventListener(TouchEvent.TOUCH_BEGIN, onDownFgnd);
			}	
			else
			{
				elements["hit"].addEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
				elements["foreground"].addEventListener(MouseEvent.MOUSE_DOWN, onDownFgnd);
			}			
			
			if (orientation == "horizontal")
			{
				foregroundOffset = childList.getKey(foreground).width / -2;
				elements["foreground"].x = foregroundOffset;
			}
			else if (orientation == "vertical")
			{
				foregroundOffset = childList.getKey(foreground).height / -2;
				elements["foreground"].y = foregroundOffset;					
			}
			
			elements["foreground"].disableAffineTransform = true;
			elements["foreground"].disableNativeTransform = true;	
			elements["foreground"].gestureEvents = true;
			elements["foreground"].addEventListener(GWGestureEvent.DRAG, onDrag);				
			elements["foreground"].addChild(childList.getKey(foreground));
			addChild(elements["foreground"]);				
						
			
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
				
				elements["foreground"].gestureList = { "n-drag-no-physics": true };				
			}
			else
			{
				elements["foreground"].gestureList = { "n-drag": true };
			}
			
		}

			
		
		/**
		 * Resets the slider
		 */
		public function reset():void
		{
			if (orientation == "horizontal")			
				elements["foreground"].x = foregroundOffset;
			else if (orientation == "vertical")
				elements["foreground"].y = foregroundOffset;			
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
			elements["foreground"].removeEventListener(GWGestureEvent.DRAG, onDrag);																
			elements["foreground"].addEventListener(GWGestureEvent.DRAG, onDrag);
			
			elements["foreground"].removeEventListener(GWGestureEvent.RELEASE, onRelease);				
			elements["foreground"].addEventListener(GWGestureEvent.RELEASE, onRelease);	
			
			var num:Number;
			
			if (orientation == "horizontal")		
				num = event.localX;
			else if (orientation == "vertical")
				num = event.localY;
			
			if (mode == "continuous")	
			{
				if (orientation == "horizontal")				
					elements["foreground"].x = num + foregroundOffset;
				else if (orientation == "vertical")
					elements["foreground"].y = num + foregroundOffset;		
			}
		
			else if (mode == "discrete")
			{
				var index:int = getSnapValue(num, stepPositions);				
				
				if (orientation == "horizontal")		
					elements["foreground"].x = stepPositions[index] + foregroundOffset;
				else if (orientation == "vertical")
					elements["foreground"].y = stepPositions[index] + foregroundOffset;
			}
			
			updateValues();
		}			
		
		
		private function onDownFgnd(event:*):void
		{
			elements["foreground"].removeEventListener(GWGestureEvent.DRAG, onDrag);													
			elements["foreground"].addEventListener(GWGestureEvent.DRAG, onDrag);
			
			elements["foreground"].removeEventListener(GWGestureEvent.RELEASE, onRelease);				
			elements["foreground"].addEventListener(GWGestureEvent.RELEASE, onRelease);						
		}
		
	
		private function onRelease(event:*):void
		{
			if (debug)
				trace("release");			
			
			elements["foreground"].removeEventListener(GWGestureEvent.RELEASE, onRelease);														
			
			if (mode == "discrete")	
			{
				elements["foreground"].removeEventListener(GWGestureEvent.DRAG, onDrag);
			
				var index:int;
				
				if (orientation == "horizontal")
				{
					index = getSnapValue(elements["foreground"].x, stepPositions);
					elements["foreground"].x = stepPositions[index] + foregroundOffset;
				}
				else if (orientation == "vertical")
				{
					index = getSnapValue(elements["foreground"].y, stepPositions);
					elements["foreground"].y = stepPositions[index] + foregroundOffset;
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
				moveValue = elements["foreground"].x + event.value.dx;
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
			}
			
			else if (orientation == "vertical")
			{
				moveValue = elements["foreground"].y + event.value.dy;
				moveValue += childList.getKey(foreground).y;
				
				if (moveValue >= (elements["hit"].y + foregroundOffset))
				{
					if (moveValue <= (elements["hit"].y + elements["hit"].height + foregroundOffset))
					{
						elements["foreground"].y += event.value.dy;
					}
					else
					{
						elements["foreground"].stopDrag();
						elements["foreground"].y = elements["hit"].height + foregroundOffset;					
					}
				}	
				else
				{
					elements["foreground"].stopDrag();											
					elements["foreground"].y = foregroundOffset;
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
				_currentPosition = elements["foreground"].x - foregroundOffset;
				_currentValue = map(_currentPosition, 0, elements["hit"].width, min, max); 			
			}
			
			else if (orientation == "vertical")
			{
				_currentPosition = elements["foreground"].y - foregroundOffset;
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