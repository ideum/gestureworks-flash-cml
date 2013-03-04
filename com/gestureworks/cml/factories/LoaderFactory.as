package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	/**
	 * The loader base class.
	 * 
	 * @author Charles
	 */
	public class LoaderFactory extends EventDispatcher
	{
		protected var urlRequest:URLRequest;
		
		
		/**
		 * Constructor
		 */
		public function LoaderFactory() {}
		
		
		protected var _loader:*;
		/**
		 * Contains the loader
		 */		
		public function get loader():* {return _loader;}
		
		
		protected var _data:*;
		/**
		 * Contains the loader
		 */		
		public function get data():* {return _loader;}
		
		
		protected var _isLoaded:Boolean = false;
		/**
		 * Returns true if the file is loaded
		 */
		public function get isLoaded():Boolean {return _isLoaded;}	
		
		
		protected var _percentLoaded:Number;
		/**
		 * Returns the percentage loaded value
		 */
		public function get percentLoaded():Number {return _percentLoaded;}	
		
		
		protected var _src:String = "";		
		/**
		 * Sets the file source path
		 */
		public function get src():String {return _src;}
		public function set src(value:String):void 
		{
			_src = value;
		}

		
		// public methods
		
		
		/**
		 * Loads an external bitmap file
		 * @param	url
		 */
		public function load(url:String):void
		{
			_src = url;
			urlRequest = new URLRequest(url);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);						
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.load(urlRequest);
		}		
		
		
		/**
		 * Unloads and stops current loading process
		 */		
		public function unloadAndStop():void 
		{
			_loader.unloadAndStop();
		}		
		
		
		// private methods

		
		protected function onComplete(e:Event):void
		{
			_isLoaded = true;
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);							
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);	
		}
				
		
		protected function onProgress(e:ProgressEvent):void
		{
			_percentLoaded = e.bytesLoaded / e.bytesTotal;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, null, "percentLoaded", percentLoaded));
		}	

		
		protected function onError(e:IOErrorEvent):void 
		{
			throw new Error(e.text);
		}		
		
	}
}