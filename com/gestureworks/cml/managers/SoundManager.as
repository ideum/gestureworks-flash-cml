package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.element.Sound;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.LinkedMap;
	import flash.utils.Dictionary;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.events.EventDispatcher;
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
		
		private static var releaseSounds:Array = [];
		
		private static var soundPlaying:Boolean = false;
		static public var dispatch:EventDispatcher = new EventDispatcher();
		
		public static function attachSound(target:Object, sound:Sound):void {
			
			var arr:Array = [];
			
			if (soundMap.hasKey(target)) {
				arr = soundMap.getKey(target);
				arr.push(sound);
				//Array(soundMap.getKey(target)).push(sound);
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
		
		/**
		 * Allows access to externally play a sound. The default sound is the first sound that was added by CML, but the user
		 * may supply a soundIndex to target a specific sound.
		 * @param	target
		 * @param	soundIndex
		 */
		public static function play(target:Object, soundIndex:int = 0):void {
			//if (soundPlaying) return;
			
			if (soundMap.hasKey(target)) {
				var arr:Array = soundMap.getKey(target);
				Sound(arr[soundIndex]).play();
				soundPlaying = true;
			}
			
		}
		
		/**
		 * Allows access to externally stop all sounds that are playing, or stop a target sound
		 * @param	target
		 * @param	soundIndex
		 */
		public static function stop(target:Object, soundIndex:int = 0, stopAll:Boolean = false) {
			if (soundMap.hasKey(target)) {
				var arr:Array = soundMap.getKey(target);
				if (!stopAll) {
					soundPlaying = false;
					Sound(arr[soundIndex]).stop();
					dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
				}
				else {
					for (var i:int = 0; i < arr.length; i++) {
						soundPlaying = false;
						Sound(arr[i]).stop();
						dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
					}
				}
			}
		}
		
		private static function createEvents(sound:Sound):void {
			
			sound.addEventListener(StateEvent.CHANGE, onComplete);
			
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
			
			if (!sound.target.hasEventListener(GWTouchEvent.TOUCH_END)) {
				releaseSounds.push(sound);
				sound.target.addEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
			}
		}
		
		private static function onSoundTouchEvent(e:GWTouchEvent):void {
			var arr:Array;
			
			if (e.target is TouchContainer) {
				var tc:TouchContainer = e.target as TouchContainer;
				for (var l:int = 0; l < tc.numChildren; l++) 
				{
					if (tc.getChildAt(l).hitTestPoint(e.stageX, e.stageY)) {
						if (soundMap.hasKey(tc.getChildAt(l))) {
							arr = soundMap.getKey(tc.getChildAt(l));
						}
					}					
				}
			}
			
			if (arr == null)
				arr = soundMap.getKey(e.target);
			//trace("e.target:", e.target);
			
			if (arr == null){
				arr = findParent(e.target);
				if (!arr)
					return;
			}
			
			triggerSound(arr, e);
		}	
		
		private static function triggerSound(soundMapArray:Array, e:GWTouchEvent):void {
			
			if (soundMapArray.length > 2) {
				Sound(soundMapArray[0]).play();
				soundPlaying = true;
				return;
			}
			
			for (var i:int = 0; i < soundMapArray.length; i++) {
				var sound:Sound = soundMapArray[i];
				
				for (var j:int = 0; j < sound.triggerArray.length; j++){
					if (sound.triggerArray[j] == "down" && e.type == GWTouchEvent.TOUCH_BEGIN || 
						sound.triggerArray[j] == "up" && e.type == GWTouchEvent.TOUCH_END || 
						sound.triggerArray[j] == "out" && e.type == GWTouchEvent.TOUCH_OUT) {
						sound.play();
						soundPlaying = true;
					}
					else if (e.type == GWTouchEvent.TOUCH_END && sound.loop) {
						soundPlaying = false;
						sound.stop();
						dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
					}
					else if (e.type == GWTouchEvent.TOUCH_END && sound.stopOnRelease) {
						soundPlaying = false;
						sound.stop();
						dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
					}
					else if (e.type == GWTouchEvent.TOUCH_END) {
						for (var k:int = 0; k < releaseSounds.length; k++) 
						{
							Sound(releaseSounds[k]).stop();
							dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
						}
					}
				}
			}
		}
		
		private static function findParent(obj:*):Array {
			var arr:Array;
			if (obj.parent) {
				arr = soundMap.getKey(obj.parent);
				if (arr) {
					return arr;
				}
				else {
					arr = findParent(obj.parent);
					return arr;
				}
			}
			else {
				return null;
			}
		}
		
		private static function onSoundEvent(e:GWGestureEvent):void {
			//trace("e.type:", e.type);
			
			var arr:Array
			
			if (e.target is TouchContainer) {
				var tc:TouchContainer = e.target as TouchContainer;
				for (var l:int = 0; l < tc.numChildren; l++) 
				{
					if (tc.getChildAt(l).hitTestPoint(e.value.stageX, e.value.stageY)) {
						if (soundMap.hasKey(tc.getChildAt(l))) {
							arr = soundMap.getKey(tc.getChildAt(l));
						}
					}					
				}
			}
			
			if (arr == null) {
				arr = soundMap.getKey(e.target);
			}
			
			if (arr.length > 2) {
				Sound(arr[0]).play();
				soundPlaying = true;
				return;
			}
			
			for (var i:int = 0; i < arr.length; i++) {
				var sound:Sound = arr[i];
				
				for (var j:int = 0; j < sound.triggerArray.length; j++){
					if (sound.triggerArray[j] == e.value.id) {
						sound.play();
						soundPlaying = true;
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
		
		private static function onComplete(e:StateEvent):void {
			if (e.value == "complete") {
				if (!e.target.loop)
					soundPlaying = false;
				//dispatch = new EventDispatcher();
				dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "complete"));
			}
		}
	}

}