package com.gestureworks.cml.loaders 
{
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.factories.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	/**
	 * The IMGLoader class loads an external bitmap file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.element.Image
	 */
	public class IMGLoader extends LoaderFactory
	{		
		/**
		 * Constructor
		 */
		public function IMGLoader() { super(); }		

		/**
		 * The COMPLETE string is dispatched when the file has loaded.
		 */
		static public const COMPLETE:String = "COMPLETE";	
		
		override protected function onComplete(e:Event):void
		{
			super.onComplete(e);	
			dispatchEvent(new Event(IMGLoader.COMPLETE, false, false));			
			dispatchEvent(new Event(Event.COMPLETE, false, false)); //deprecate			
		}

	}
}