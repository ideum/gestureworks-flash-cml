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
		}
		
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
	}

}