package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.text.StyleSheet;
	
	/**
	 * CSS, Multiton Class
	 * Loads and stores a global reference to a CSS Stylesheet 
	 * @authors Charles Veasey
	 */
	
	public class CSS extends EventDispatcher
	{
		static public const INIT:String = "init";		
		static private var instances:Dictionary = new Dictionary;
		
		private var urlLoader:URLLoader;
		public var data:StyleSheet = new StyleSheet;

		private var _isLoaded:Boolean;		
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		public function CSS(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		public function loadStyle(url:String):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onCSSDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		public function onCSSDataLoaded(e:Event):void
		{
			data.parseCSS(urlLoader.data);
			_isLoaded = true;
			dispatchEvent(new Event(CSS.INIT, true, true));
		}
		
		public static function getInstance(key:*):CSS
		{
			if (instances[key] == null)
				CSS.instances[key] = new CSS(new SingletonEnforcer());
			return CSS.instances[key];
		}
	
	}
}

class SingletonEnforcer{}