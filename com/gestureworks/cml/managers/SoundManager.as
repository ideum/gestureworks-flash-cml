package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.element.Sound;
	import com.gestureworks.cml.utils.LinkedMap;
	import flash.utils.Dictionary;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	/**
	 * The sound manager only handles Sound elements attached to CML display objects for the purposes of accessibility. It does not handle regular MP3
	 * or WAV elements.
	 * 
	 * @author josh
	 */
	public class SoundManager 
	{
		private static var targetToSound:Dictionary = new Dictionary();
		private static var soundToTarget:Dictionary = new Dictionary();
		private static var soundMap:LinkedMap = new LinkedMap();
		
		public static function attachSound(target:Object, sound:Sound):void {
			
			var arr:Array = [];
			
			if (soundMap.hasKey(target)) {
				arr = soundMap.getKey(target);
				arr.push(sound);
				//Array(soundMap.getKey(target)).push(sound);
				trace("Fffff.", arr);
			}
			else {
				arr.push(sound);
				soundMap.append(target, arr);
			}
			trace("Target assembled:", soundMap.getKey(target));
			//soundMap.append(sound, target);
			//targetToSound[target] = sound;
			//soundToTarget[sound] = target;
			sound.target = target;
			
			sound.init();
			
			createEvents(sound);
		}
		
		private static function createEvents(sound:Sound):void {
			
			sound.target.addEventListener(GWGestureEvent.DRAG, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.ROTATE, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.TILT, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.SCALE, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.MANIPULATE, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.HOLD, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.TAP, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.DOUBLE_TAP, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.TRIPLE_TAP, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.FLICK, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.PIVOT, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.SWIPE, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.SCROLL, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.STROKE, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.STROKE_LETTER, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.STROKE_GREEK, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.STROKE_SYMBOL, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.STROKE_SHAPE, onSoundEvent);
			sound.target.addEventListener(GWGestureEvent.STROKE_NUMBER, onSoundEvent);
			
			for (var i:int = 0; i < sound.triggerArray.length; i++) {
				switch(sound.triggerArray[i]) {
					case "down":
						sound.target.addEventListener(GWTouchEvent.TOUCH_BEGIN, onSoundTouchEvent);
						break;
					case "up":
						sound.target.addEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
						break;
					case "out":
						sound.target.addEventListener(GWTouchEvent.TOUCH_OUT, onSoundTouchEvent);
						break;
				}
			}
			
			if (!sound.target.hasEventListener(GWTouchEvent.TOUCH_END))
				sound.target.addEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
		}
		
		private static function onSoundTouchEvent(e:GWTouchEvent):void {
			
			var arr:Array = soundMap.getKey(e.target);
			if (arr.length > 2) {
				Sound(arr[0]).play();
				return;
			}
			
			for (var i:int = 0; i < arr.length; i++) {
				var sound:Sound = arr[i];
				
				for (var j:int = 0; j < sound.triggerArray.length; j++){
					if (sound.triggerArray[j] == "down" && e.type == GWTouchEvent.TOUCH_BEGIN || 
						sound.triggerArray[j] == "up" && e.type == GWTouchEvent.TOUCH_END || 
						sound.triggerArray[j] == "out" && e.type == GWTouchEvent.TOUCH_OUT) {
						sound.play();
					}
					else if (e.type == GWTouchEvent.TOUCH_END) {
						sound.stop();
					}
				}
			}
		}
		
		private static function onSoundEvent(e:GWGestureEvent):void {
			//trace("e.type:", e.type);
			var arr:Array = soundMap.getKey(e.target);
			if (arr.length > 2) {
				Sound(arr[0]).play();
				return;
			}
			
			for (var i:int = 0; i < arr.length; i++) {
				var sound:Sound = arr[i];
				
				for (var j:int = 0; j < sound.triggerArray.length; j++){
					if (sound.triggerArray[j] == e.value.id) {
						sound.play();
					}
				}
			}
		}
		
		public static function deleteSound(obj:Object):void {
			var arr:Array = soundMap.getKey(obj);
			
			for (var i:int = 0; i < arr.length; i++) {
				deleteEvents(arr[i]);
				Sound(arr[i]).dispose();
				arr[i] = null;
			}
			
			soundMap.removeKey(obj);
		}
		
		private static function deleteEvents(sound:Sound):void {
			
			sound.target.removeEventListener(GWGestureEvent.DRAG, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.ROTATE, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.TILT, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.SCALE, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.MANIPULATE, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.HOLD, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.TAP, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.DOUBLE_TAP, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.TRIPLE_TAP, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.FLICK, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.PIVOT, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.SWIPE, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.SCROLL, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.STROKE, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.STROKE_LETTER, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.STROKE_GREEK, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.STROKE_SYMBOL, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.STROKE_SHAPE, onSoundEvent);
			sound.target.removeEventListener(GWGestureEvent.STROKE_NUMBER, onSoundEvent);
			
			for (var i:int = 0; i < sound.triggerArray.length; i++) {
				switch(sound.triggerArray[i]) {
					case "down":
						sound.target.removeEventListener(GWTouchEvent.TOUCH_BEGIN, onSoundTouchEvent);
						break;
					case "up":
						sound.target.removeEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
						break;
					case "out":
						sound.target.removeEventListener(GWTouchEvent.TOUCH_OUT, onSoundTouchEvent);
						break;
				}
			}
			
			if (sound.target.hasEventListener(GWTouchEvent.TOUCH_END))
				sound.target.removeEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
		}
	}

}