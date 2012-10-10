package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * XmlLoader
	 * Loads and stores a global reference to an XML file
	 * @author Charles Veasey
	 */
	
	public class XMLLoader extends EventDispatcher
	{
		/**
		 * stores initial state
		 */
		static public const INIT:String = "init";		
		static private var instances:Dictionary = new Dictionary;
		
		private var urlLoader:URLLoader;
		
		/**
		 * data the xml file manages
		 */
		public var data:XML = new XML;

		private var _isLoaded:Boolean;		
		/**
		 * returns the loaded value
		 */
		public function get isLoaded():Boolean { return _isLoaded; }		
		
		/**
		 * constructor will allow single instance for this XMLLoader class
		 * @param	enforcer
		 */	 
		public function XMLLoader(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		/**
		 * loads the xml file
		 * @param	url
		 */
		public function loadXML(url:String):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onXMLDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		/**
		 * dispatches an event on loaded file
		 * @param	e
		 */
		public function onXMLDataLoaded(e:Event):void
		{
			data = XML(urlLoader.data);
			_isLoaded = true;
			dispatchEvent(new Event(XML_.INIT, true, true));
		}
		
		/**
		 * returns the XML loader key value
		 * @param	key
		 * @return
		 */
		public static function getInstance(key:*):XMLLoader
		{
			if (instances[key] == null)
				XMLLoader.instances[key] = new XMLLoader(new SingletonEnforcer());
			return XMLLoader.instances[key];
		}
	}
}

/**
 * class can only be access by the XMLLoader class only. 
 */
class SingletonEnforcer{}