package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * Loads and stores a global reference to a CML file
	 * Multiton Class
	 * @authors Charles Veasey
	 */
	
	public class CMLLoader extends EventDispatcher
	{
		/**
		 * stores the init 
		 */
		static public const INIT:String = "init";		
		static private var instances:Dictionary = new Dictionary;
		
		private var urlLoader:URLLoader;
		/**
		 * holds the data
		 */
		public var data:XML = new XML;

		private var _isLoaded:Boolean;		
		/**
		 * returns the isloaded value
		 */
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		/**
		 * constructor - this will allow single instance for this CMLLoader class
		 * @param	enforcer
		 */
		public function CMLLoader(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		/**
		 * loads the cml file
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
		 * dispatches an event
		 * @param	e
		 */
		public function onCMLDataLoaded(e:Event):void
		{
			data = XML(urlLoader.data);			
			_isLoaded = true;
			dispatchEvent(new Event(CMLLoader.INIT, true, true));
		}
		
		/**
		 * returns the CMLLoader key
		 * @param	key
		 * @return
		 */
		public static function getInstance(key:*):CMLLoader
		{
			if (instances[key] == null)
				CMLLoader.instances[key] = new CMLLoader(new SingletonEnforcer());
			return CMLLoader.instances[key];
		}
	
	}
}

/**
 * class can only be access by the CMLLoader class only. 
 */
class SingletonEnforcer{}
