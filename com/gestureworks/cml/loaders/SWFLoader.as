package com.gestureworks.cml.loaders
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.*;
	
	/**
	 * The SWFLoader class loads and stores a global reference to an exteranl SWF file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.element.SWF
	 */
	public class SWFLoader extends EventDispatcher
	{ 
		/**
		 * Constructor
		 */
		public function SWFLoader() {}		
		
		/**
		 * The FILE_LOADED string is dispatch when file load is complete
		 */
		public static const FILE_LOADED:String = "FILE_LOADED";				
		
		/**
		 * Hold information of loaded swf file
		 */
		public var loader:Loader;
		
		private var _isLoaded:Boolean = false;
		/**
		 * Returns loaded to true or false
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
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			var loaderContext:LoaderContext = new LoaderContext(false);
			loaderContext.allowCodeImport = true;
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;
			loader.load(new URLRequest(url), loaderContext);			
		}		

		/**
		 * SWF load complete hander
		 * @param	event
		 */		
		private function loaderCompleteHandler(event:Event):void
		{			
			_isLoaded = true;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);			
			dispatchEvent(new Event(SWFLoader.FILE_LOADED, true, true));			
		}		
	}
}

