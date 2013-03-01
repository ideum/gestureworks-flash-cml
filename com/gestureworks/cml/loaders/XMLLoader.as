package com.gestureworks.cml.loaders
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * The XMLLoader class loads and stores a global reference to an external XML file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.core.CMLLoader
	 */
	public class XMLLoader extends EventDispatcher
	{				
		private var urlLoader:URLLoader;
		private var urlRequest:URLRequest;
		
		/**
		 * Holds class instances of the multiton
		 */
		static private var instances:Dictionary = new Dictionary;
		
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
		
		/**
		 * The INIT string is dispatch when file load is complete
		 */
		static public const INIT:String = "init";		
		
		/**
		 * Contains the loaded xml file data
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
		public function XMLLoader(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		/**
		 * Loads the XML filepath
		 * @param	url
		 */
		public function loadXML(url:String):void
		{
			urlRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onXMLDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		/**
		 * XML load complete handler
		 * @param	e
		 */
		public function onXMLDataLoaded(e:Event):void
		{
			try {
				data = XML(urlLoader.data);	
			}
			catch (er:Error) {
				throw new Error(er.message + " File Path: " + urlRequest.url);
			}
			_isLoaded = true;
			dispatchEvent(new Event(XMLLoader.INIT, true, true));
		}
				
	}
}

class SingletonEnforcer{}