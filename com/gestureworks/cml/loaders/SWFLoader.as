package com.gestureworks.cml.loaders
{
	import com.gestureworks.cml.factories.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	/**
	 * The SWFLoader class loads an external SWF file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.element.SWF
	 */
	public class SWFLoader extends LoaderFactory
	{ 		
		/**
		 * Constructor
		 */
		public function SWFLoader() { super(); }		
		
		/**
		 * The COMPLETE string is dispatched when the file has loaded.
		 */
		public static const COMPLETE:String = "COMPLETE";		
		
		/**
		 * Loads an external swf file
		 * @param	url
		 */
		override public function load(url:String):void
		{
			_src = url;
			urlRequest = new URLRequest(url);
							
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);						
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
						
			var loaderContext:LoaderContext = new LoaderContext(false);
			loaderContext.allowCodeImport = true;
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;
			
			_loader.load(urlRequest, loaderContext);
		}		
		
		override protected function onComplete(e:Event):void
		{
			super.onComplete(e);
			dispatchEvent(new Event(SWFLoader.COMPLETE, false, false));						
		}		
	}
}

