package com.gestureworks.cml.loaders 
{
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	/**
	 * The IMGLoader class loads and stores a global reference to an external bitmap image file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.element.Image
	 */
	public class IMGLoader extends EventDispatcher
	{
		/**
		 * Constructor
		 */
		public function IMGLoader() {}
		
		/**
		 * Contains the loaded bitmap data
		 */
		public var loader:Loader
		
		private var _isLoaded:Boolean = false;
		/**
		 * Returns the loaded value
		 */
		public function get isLoaded():Boolean { return _isLoaded; }	
		
		private var _src:String = "";		
		/**
		 * Sets the file source path
		 */
		public function get src():String {return _src;}
		public function set src(value:String):void 
		{
			if (src == "")
			_src = value;
			
			if (!_isLoaded)
				load(src);
		}

		/**
		 * Loads an external bitmap file
		 * @param	url
		 */
		public function load(url:String):void
		{
			if (src == "")
				_src = url;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);			
			loader.load(new URLRequest(url));
		}		
		
		/**
		 * Bitmap load complete handler
		 * @param	event
		 */
		private function onComplete(event:Event):void
		{
			trace(event);
			_isLoaded = true;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);	
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);	
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);				
			dispatchEvent(new Event(Event.COMPLETE, false, false));			
		}
		
		private function onError(event:IOErrorEvent):void
		{
			trace(event);		
		}		

		private function onProgress(event:ProgressEvent):void
		{
			
			trace(event);		
		}	
		
		
	}
}