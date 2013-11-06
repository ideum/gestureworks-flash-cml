package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.elements.Sound;
	import com.gestureworks.cml.elements.TouchContainer;
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
		public static var soundMap:LinkedMap = new LinkedMap();
		
		private static var releaseSounds:Array = [];
		
		private static var _isSoundPlaying:Boolean = false;
		public function get isSoundPlaying():Boolean { return _isSoundPlaying; }
		
		
		static public var dispatch:EventDispatcher = new EventDispatcher();
		
		private static var soundPlaying:Sound;
		//public static var soundIndex:Sound;
		private static var _soundsPlaying:Array = [];
		public static function get soundsPlaying():Array { return _soundsPlaying; }
		
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
				var sound:Sound = arr[soundIndex];
				
				//if (!important(sound)) 
					//return;
				
				sound.play();
				
				_isSoundPlaying = true;
				if (soundsPlaying.indexOf(sound) < 0)
					_soundsPlaying.push(sound);
			}
			
		}
		
		/**
		 * Allows access to externally stop all sounds that are playing, or stop a target sound
		 * @param	target
		 * @param	soundIndex
		 */
		public static function stop(target:Object, soundIndex:int = 0, stopAll:Boolean = false):void {
			if (soundMap.hasKey(target)) {
				var arr:Array = soundMap.getKey(target);
				if (!stopAll) {
					_isSoundPlaying = false;
					
					Sound(arr[soundIndex]).stop();
					removeFromArray(_soundsPlaying.indexOf(arr[soundIndex]));
					
					soundPlaying = null;
					dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
				}
				else {
					for (var i:int = 0; i < arr.length; i++) {
						_isSoundPlaying = false;
						Sound(arr[i]).stop();
						soundPlaying = null;
						removeFromArray(_soundsPlaying.indexOf(arr[i]));
						dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
					}
					//_soundsPlaying = [];
				}
			}
		}
		
		
		/**
		 * Stop all sounds that are playing
		 * @param	target
		 * @param	soundIndex
		 */
		public static function stopAll():void {
			for (var i:int = 0; i < soundsPlaying.length; i++) {
				Sound(soundsPlaying[i]).stop();
			}
			_soundsPlaying = [];
			dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
		}		
		
		private static function createEvents(sound:Sound):void {
			
			sound.addEventListener(StateEvent.CHANGE, onComplete);
			if (sound.eventlessNotification)
				return;
			
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
						if (sound.stopOnRelease)
							sound.target.addEventListener(GWTouchEvent.TOUCH_END, onSoundTouchEvent);
						break;
					case "out":
						sound.target.addEventListener(GWTouchEvent.TOUCH_OUT, onSoundTouchEvent);
						break;
				}
			}
			
			if (!sound.target.hasEventListener(GWTouchEvent.TOUCH_END) && sound.stopOnRelease) {
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
			
			if (arr == null){
				arr = findParent(e.target);
				if (!arr)
					return;
			}
			
			triggerSound(arr, e);
		}	
		
		private static function triggerSound(soundMapArray:Array, e:GWTouchEvent):void {
			
			var sound:Sound;
			if (soundMapArray.length < 2) {
				sound = soundMapArray[0];
				for (var m:int = 0; m < sound.triggerArray.length; m++) {
					if (sound.triggerArray[m] == e.type) {
						
						if (!important(sound)) return;
						
						sound.play();
						if (soundsPlaying.indexOf(sound) < 0)
							_soundsPlaying.push(sound);
						_isSoundPlaying = true;
					}
				}
				
				return;
			}
			
			for (var i:int = 0; i < soundMapArray.length; i++) {
				sound = soundMapArray[i];
				
				for (var j:int = 0; j < sound.triggerArray.length; j++) {
					
					// Checking trigger if sound needs to be played.
					if (sound.triggerArray[j] == "down" && e.type == GWTouchEvent.TOUCH_BEGIN || 
						sound.triggerArray[j] == "up" && e.type == GWTouchEvent.TOUCH_END || 
						sound.triggerArray[j] == "out" && e.type == GWTouchEvent.TOUCH_OUT) {
						
						// Checking if sound is important enough to override or play along with any other sounds playing.
						if (!important(sound)) 
							return;
						
						sound.play();
						if (soundsPlaying.indexOf(sound) < 0)
							_soundsPlaying.push(sound);
						_isSoundPlaying = true;
					}
					
					// Stopping sounds for touch up.
					else if (e.type == GWTouchEvent.TOUCH_END && sound.loop) {
						_isSoundPlaying = false;
						sound.stop();
						removeFromArray(_soundsPlaying.indexOf(sound));
						dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
					}
					else if (e.type == GWTouchEvent.TOUCH_END && sound.stopOnRelease) {
						_isSoundPlaying = false;
						sound.stop();
						removeFromArray(_soundsPlaying.indexOf(sound));
						dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, "SoundManager", "Complete", "stopped"));
					}
					else if (e.type == GWTouchEvent.TOUCH_END) {
						for (var k:int = 0; k < releaseSounds.length; k++) 
						{
							Sound(releaseSounds[k]).stop();
							removeFromArray(_soundsPlaying.indexOf(releaseSounds[k]));
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
			var arr:Array
			var sound:Sound;
			
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
			
			if (arr.length < 2) {
				sound = arr[0];
				for (var m:int = 0; m < sound.triggerArray.length; m++) {
					if (sound.triggerArray[m] == e.value.id) {
						if (!important(sound)) 
							return;
						sound.play();
						if (soundsPlaying.indexOf(sound) < 0)
							_soundsPlaying.push(sound);
						_isSoundPlaying = true;
					}
				}
				
				//isSoundPlaying = true;
				return;
			}
			
			for (var i:int = 0; i < arr.length; i++) {
				sound = arr[i];
				
				for (var j:int = 0; j < sound.triggerArray.length; j++) {
					if (sound.triggerArray[j] == e.value.id) {
						if (!important(sound)) 
							return;
							
						sound.play();
						if (soundsPlaying.indexOf(sound) < 0)
							_soundsPlaying.push(sound);
						_isSoundPlaying = true;
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
				
				if (_soundsPlaying.indexOf(arr[i]) > -1)
					removeFromArray(_soundsPlaying.indexOf(arr[i]));
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
		
		private static function important(sound:Sound):Boolean {
			if (soundsPlaying.length < 1) return true;
			
			if (sound.importance < 0) return true;
			
			var importantEnough:Boolean = true;
			
			for (var i:int = 0; i < soundsPlaying.length; i++) {
				if (Sound(soundsPlaying[i]).importance > sound.importance) {
					importantEnough = false;
					break;
				}
				
				// Stop the sound playing if it's less important.
				else if (Sound(soundsPlaying[i]).importance > -1 && Sound(soundsPlaying[i]).importance < sound.importance) {					
					Sound(soundsPlaying[i]).stop();
					removeFromArray(i);
					i--;
					importantEnough = true;
				}
			}
			
			return importantEnough;
		}
		
		private static function onComplete(e:StateEvent):void {
			if (e.value == "complete") {
				if (!e.target.loop)
					_isSoundPlaying = false;
				removeFromArray(_soundsPlaying.indexOf(e.target));
				dispatch.dispatchEvent(new StateEvent(StateEvent.CHANGE, Sound(e.target).src, "Complete", "complete"));
			}
		}
		
		private static function removeFromArray(index:int):void
		{
			var original:Array = _soundsPlaying.slice(); 
			var temp:Array = original.splice(index, 1); 
			temp.shift();
			original = original.concat(temp); 
			_soundsPlaying = original;
		}
	}

}