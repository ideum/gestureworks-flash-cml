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
		static public const INIT:String = "init";		
		static private var instances:Dictionary = new Dictionary;
		
		private var urlLoader:URLLoader;
		public var data:XML = new XML;

		private var _isLoaded:Boolean;		
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		public function CMLLoader(enforcer:SingletonEnforcer)
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
			dispatchEvent(new Event(CMLLoader.INIT, true, true));
		}
		
		public static function getInstance(key:*):CMLLoader
		{
			if (instances[key] == null)
				CMLLoader.instances[key] = new CMLLoader(new SingletonEnforcer());
			return CMLLoader.instances[key];
		}
	
	}
}

class SingletonEnforcer{}
