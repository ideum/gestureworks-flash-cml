package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.MP3Factory;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.utils.Dictionary;
	/**
	 * 
	 * @author josh
	 */
	public class Sound extends MP3Factory
	{
		
		private var loaded:Boolean = false;
		private var dispatch:String = "down";
		private var _triggerArray:Array;
		
		public function Sound() 
		{
			super();
			preload = true;
			autoplay = false;
		}
		
		private var _trigger:String = "down";
		/**
		 * Sets the touch events that will play the sound.
		 * @default down
		 */
		public function get trigger():String { return _trigger; }
		public function set trigger(value:String):void {
			_trigger = value;
			
			_triggerArray = _trigger.split(",");
			/*var triggerIds:Array = new Array();
			// On Collision
			
			for (var i:int = 0; i < _triggerArray.length; i++) {
				var subArr:Array = String(_triggerArray[i]).split("-");
				_triggerArray[i] = subArr[subArr.length - 1];
				if (subArr.length > 1) {
					triggerIds[i] = subArr[0] + "-";
					for (var j:int = 1; j < subArr.length - 1; j++) {
						triggerIds[i] += subArr[j] + "-";
					}
					trace(triggerIds);
				}
			}*/
		}
		
		public function get triggerArray():Array { return _triggerArray; }
		
		
		private var _target:*;
		/**
		 * Sets the target object that will trigger the sound playing when touched by the triggering event. This can accept an ID or take a direct display object.
		 */
		public function get target():* { return _target; }
		public function set target(value:*):void {
			if (!value) 
				return;
			else 
				_target = value;
			
			
		}
		
		override public function init():void {
			super.init();
			
			//createEvents();
		}
		
		//private var 
		
		override protected function soundLoaded(e:Event=null):void {
			loaded = true;
			super.soundLoaded(e);
		}
		
		override public function play():void {
			if (loaded && !isPlaying)
				super.play();
		}
		
		override public function dispose():void {
			super.dispose();
			target = null;
		}
		
		private function createEvents():void {
			if (!target) return;
			if (!_triggerArray || _triggerArray.length < 1) return;
			
			//target.addEventListener(GWGestureEvent.START, onGestureStart);
			
			// Listen for collision somehow.
			
			for (var i:int = 0; i < _triggerArray.length; i++) {
				
				switch(_triggerArray[i]) {
					case "drag":
						target.addEventListener(GWGestureEvent.DRAG, onSoundEvent);
						break;
					case "rotate":
						target.addEventListener(GWGestureEvent.ROTATE, onSoundEvent);
						break;
					case "tilt":
						target.addEventListener(GWGestureEvent.TILT, onSoundEvent);
						break;
					case "scale":
						target.addEventListener(GWGestureEvent.SCALE, onSoundEvent);
						break;
					case "manipulate":
						target.addEventListener(GWGestureEvent.MANIPULATE, onSoundEvent);
						break;
					case "hold":
						target.addEventListener(GWGestureEvent.HOLD, onSoundEvent);
						break;
					case "tap":
						target.addEventListener(GWGestureEvent.TAP, onSoundEvent);
						break;
					case "double_tap":
						target.addEventListener(GWGestureEvent.DOUBLE_TAP, onSoundEvent);
						break;
					case "triple_tap":
						target.addEventListener(GWGestureEvent.TRIPLE_TAP, onSoundEvent);
						break;
					case "flick":
						target.addEventListener(GWGestureEvent.FLICK, onSoundEvent);
						break;
					case "pivot":
						target.addEventListener(GWGestureEvent.PIVOT, onSoundEvent);
						break;
					case "swipe":
						target.addEventListener(GWGestureEvent.SWIPE, onSoundEvent);
						break;
					case "scroll":
						target.addEventListener(GWGestureEvent.SCROLL, onSoundEvent);
						break;
					case "stroke":
						target.addEventListener(GWGestureEvent.STROKE, onSoundEvent);
						break;
					case "stroke_letter":
						target.addEventListener(GWGestureEvent.STROKE_LETTER, onSoundEvent);
						break;
					case "stroke_greek":
						target.addEventListener(GWGestureEvent.STROKE_GREEK, onSoundEvent);
						break;
					case "stroke_symbol":
						target.addEventListener(GWGestureEvent.STROKE_SYMBOL, onSoundEvent);
						break;
					case "stroke_shape":
						target.addEventListener(GWGestureEvent.STROKE_SHAPE, onSoundEvent);
						break;
					case "stroke_number":
						target.addEventListener(GWGestureEvent.STROKE_NUMBER, onSoundEvent);
						break;
					case "down":
						target.addEventListener(GWTouchEvent.TOUCH_BEGIN, onSoundTouchEvent);
						break;
					case "up":
						target.addEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
						break;
					case "out":
						target.addEventListener(GWTouchEvent.TOUCH_OUT, onSoundTouchEvent);
						break;
				}
				
			}
			
			if (!target.hasEventListener(GWTouchEvent.TOUCH_END))
				target.addEventListener(GWGestureEvent.COMPLETE, onTouchComplete);
		}
		
		private function onGestureStart(e:GWGestureEvent):void {
			trace("Touch starting");
		}
		
		private function onSoundEvent(e:GWGestureEvent):void {
			trace(e.type, e.value.id);
			play();
		}
		
		private function onSoundTouchEvent(e:GWTouchEvent):void {
			
		}
		
		private function onTouchComplete(e:GWGestureEvent):void {
			if (loop == true)
				super.stop();
		}
	}

}