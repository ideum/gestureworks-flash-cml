package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.element.MP3;
	import com.gestureworks.cml.element.Sound;
	import com.gestureworks.cml.managers.SoundManager;
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
		
		/**
		 * Writes cml to object sound.
		 * @param	obj
		 * @param	cml
		 */
		public static function parseCML(target:Object, cml:XMLList):void
		{
			if (!("sound" in target)) 
				return;
		
			var name:String;
			var val:*;
			var i:int;			
			
			for each (var node:XML in cml.*) {
				if (node.name() == "Sound") {
					
					var sound:Sound = new Sound();
					for each (val in node.@*) {
						name = val.name();
						if (val == "true") val = true;
						if (val == "false") val = false;	
						//obj.state[obj.state.length - 1][name]  = val;
						sound[name] = val;
						sound.autoplay = false;
					}
					
					//sound.init();
					
					// Add sound and parent to manager.
					SoundManager.attachSound(target, sound);
				}	
			}
		}
		
	}

}