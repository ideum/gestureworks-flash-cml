package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * XML_, Multiton Class
	 * Loads and stores a global reference to an XML file
	 * @author Charles Veasey
	 */
	
	public class XML_ extends EventDispatcher
	{
		static public const INIT:String = "init";		
		static private var instances:Dictionary = new Dictionary;
		
		private var urlLoader:URLLoader;
		public var data:XML = new XML;

		private var _isLoaded:Boolean;		
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		public function XML_(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		public function loadXML(url:String):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onXMLDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		public function onXMLDataLoaded(e:Event):void
		{
			data = XML(urlLoader.data);
			_isLoaded = true;
			dispatchEvent(new Event(XML_.INIT, true, true));
		}
		
		public static function getInstance(key:*):XML_
		{
			if (instances[key] == null)
				XML_.instances[key] = new XML_(new SingletonEnforcer());
			return XML_.instances[key];
		}
	}
}

class SingletonEnforcer{}