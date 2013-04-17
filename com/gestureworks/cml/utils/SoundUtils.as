package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.element.MP3;
	import flash.display.DisplayObjectContainer;
	import flash.events.TouchEvent;
	import flash.utils.Dictionary;
	/**
	 * SoundUtils is a class primarily designed to assist in managing mp3 sounds attached to touch objects.
	 * Objects and their desired sound sources are passed in, and those are added to a sound dictionary after the sound
	 * files are initialized, then played on touch down.
	 * @author josh
	 */
	public class SoundUtils 
	{
		
		private static var dictionary:Dictionary = new Dictionary();
		
		public function SoundUtils() 
		{
			
		}
		
		public static function attachSound(obj:Object, src:String):void {
			
			if (dictionary[obj]) {
				//deleteSound(obj);
				//obj.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				//MP3(dictionary[obj]).dispose();
				//dictionary[obj] = null;
			}
			
			var wav:MP3 = new MP3();
			wav.src = src;
			wav.autoplay = false;
			wav.loop = false;
			wav.display = "none";
			
			//obj.addChild(wav);
			
			wav.init();
			
			dictionary[obj] = wav;
			
			//if (!(obj.hasEventListener(TouchEvent.TOUCH_BEGIN)))
				obj.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
		}
		
		private static function onDown(e:TouchEvent):void {
			trace("On down in Sound Utils.", e.target, dictionary[e.target]);
			MP3(dictionary[e.target]).play();
		}
		
		public static function deleteSound(obj:Object):void {
			obj.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
			MP3(dictionary[obj]).dispose();
			dictionary[obj] = null;
			delete dictionary[obj];
		}
	}

}