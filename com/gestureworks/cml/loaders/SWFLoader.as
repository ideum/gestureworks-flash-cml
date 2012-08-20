package com.gestureworks.cml.loaders
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;	
	
	/**
	 * SwfLoader
	 * Loads a SWF file
	 * @authors Charles Veasey
	 */	
	
	public class SWFLoader extends EventDispatcher
	{ 
		public function SWFLoader() {}		
		
		public static const FILE_LOADED:String = "FILE_LOADED";				
		
		public var loader:Loader;
		
		private var _loaded:Boolean = false;
		public function get loaded():Boolean { return _loaded; }	
		
		private var _src:String = "";		
		public function get src():String {return _src;}
		public function set src(value:String):void 
		{
			if (src == "")
			_src = value;
			
			if (!loaded)
				load(src);
		}

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
		
		private function loaderCompleteHandler(event:Event):void
		{			
			_loaded = true;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);			
			dispatchEvent(new Event(SWFLoader.FILE_LOADED, true, true));			
		}		
	}
}

