package com.gestureworks.cml.loaders 
{
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.factories.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	/**
	 * The MP3Loader class loads an external MP3 file.
	 * 
	 * 
	 */
	public class MP3Loader extends LoaderFactory
	{		
		/**
		 * Constructor
		 */
		public function MP3Loader() { super(); }		

		/**
		 * The COMPLETE string is dispatched when the file has loaded.
		 */
		static public const COMPLETE:String = "COMPLETE";	
		
		override protected function onComplete(e:Event):void
		{
			super.onComplete(e);	
			dispatchEvent(new Event(MP3Loader.COMPLETE, false, false));			
			dispatchEvent(new Event(Event.COMPLETE, false, false)); //deprecate			
		}

	}
}