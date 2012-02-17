package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * CML, Multiton Class
	 * Loads and stores a global reference to a CML file
	 * @authors Charles Veasey
	 */
	
	public class CML extends EventDispatcher
	{
		static public const INIT:String = "init";		
		static private var instances:Dictionary = new Dictionary;
		
		private var urlLoader:URLLoader;
		public var data:XML = new XML;

		private var _isLoaded:Boolean;		
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		public function CML(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		public function loadCML(url:String):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onCMLDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		public function onCMLDataLoaded(e:Event):void
		{
			data = XML(urlLoader.data);			
			_isLoaded = true;
			dispatchEvent(new Event(CML.INIT, true, true));
		}
		
		public static function getInstance(key:*):CML
		{
			if (instances[key] == null)
				CML.instances[key] = new CML(new SingletonEnforcer());
			return CML.instances[key];
		}
	
	}
}

class SingletonEnforcer{}
