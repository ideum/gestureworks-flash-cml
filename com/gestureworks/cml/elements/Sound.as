package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.MP3Factory;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.utils.Dictionary;
	/**
	 * 
	 * @author Ideum
	 */
	public class Sound extends MP3Factory
	{
		
		private var loaded:Boolean = false;
		//private var dispatch:String = "down";
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
			if (_triggerArray.length < 1)
				_triggerArray.push(_trigger);
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
		
		private var _stopOnRelease:Boolean = false;
		/**
		 * This is a special property to set the sound file to stop on release. Looping will automatically cause a sound file to stop on release,
		 * this variable will allow specification for long sound files to stop when the user releases. Don't set this to 'true' for sounds that are
		 * supposed to play on "up".
		 */
		public function get stopOnRelease():Boolean { return _stopOnRelease; }
		public function set stopOnRelease(value:Boolean):void {
			_stopOnRelease = value;
		}
		
		private var _eventlessNotification:Boolean = false;
		/**
		 * This is a property for setting if the sound has no specific gesture or event attached to it, so it will be processed into the SoundManager's
		 * dictionary but will not interfere with other events.
		 */
		public function get eventlessNotification():Boolean { return _eventlessNotification; }
		public function set eventlessNotification(value:Boolean):void {
			_eventlessNotification = value;
		}
		
		private var _importance:int = 0;
		/**
		 * This property determines the sound's play heirarchy in reference to other sounds. If the sound's heirarchy is lower than a sound that's currently 
		 * playing, it will not play. If the sound's heirarchy is the same as a sound that is currently playing, they will play at the same time, and if it is 
		 * higher, than the other sound will be stopped for this sound to play. Setting importance to a negative number will exclude the sound from the comparison
		 * so it will always play without interrupting any other sounds. So -1 should be used for a background sound that always plays.
		 * @default 0
		 */
		public function get importance():int { return _importance; }
		public function set importance(value:int):void {
			_importance = value;
		}
		
		override public function init():void {
			super.init();
		}
		
		override protected function soundLoaded(e:Event=null):void {
			loaded = true;
			super.soundLoaded(e);
		}
		
		override public function play():void {
			if (loaded && !isPlaying)
				super.play();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			target = null;
			_triggerArray = null;
		}
	}

}