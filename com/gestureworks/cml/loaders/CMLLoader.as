package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * The CMLLoader class loads and stores a global reference to an external CML file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.core.CMLParser
	 */
	public class CMLLoader extends EventDispatcher
	{
		private var urlLoader:URLLoader;
		
		/**
		 * Holds class instances of the multiton
		 */
		static private var instances:Dictionary = new Dictionary;
		
		/**
		 * Returns an instance of the CMLLoader class
		 * @param	key
		 * @return
		 */
		public static function getInstance(key:*):CMLLoader
		{
			if (instances[key] == null)
				CMLLoader.instances[key] = new CMLLoader(new SingletonEnforcer());
			return CMLLoader.instances[key];
		}
		
		/**
		 * The INIT string is dispatch when file load is complete
		 */
		static public const INIT:String = "init";
		
		/**
		 * Contains the loaded CML (XML) file data
		 */
		public var data:XML = new XML;

		private var _isLoaded:Boolean;		
		/**
		 * Returns a boolean determining whether the file has been loaded
		 */
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		/**
		 * Constructor
		 * @param	enforcer
		 */
		public function CMLLoader(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		/**
		 * Loads the CML filepath
		 * @param	url
		 */
		public function loadCML(url:String):void
		{			
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onCMLDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		/**
		 * CML load complete handler
		 * @param	e
		 */
		private function onCMLDataLoaded(e:Event):void
		{
			data = XML(urlLoader.data);			
			_isLoaded = true;
			dispatchEvent(new Event(CMLLoader.INIT, true, true));
		}
	}
}

class SingletonEnforcer{}