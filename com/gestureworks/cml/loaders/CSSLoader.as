package com.gestureworks.cml.loaders
{
	import com.gestureworks.cml.events.FileEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.utils.Dictionary;
	
	/**
	 * The CSSManager class loads and stores a global reference to an external CSS file.
	 * 
	 * @author Charles
	 * @see com.gestureworks.managers.CSSManager
	 */
	public class CSSLoader extends EventDispatcher
	{
		private var urlLoader:URLLoader;
				
		/**
		 * Holds class instances of the multiton.
		 */		
		static private var instances:Dictionary = new Dictionary;
		
		/**
		 * Returns an instance of the CMLLoader class
		 * @param	key
		 * @return
		 */
		public static function getInstance(key:*):CSSLoader
		{
			if (instances[key] == null)
				CSSLoader.instances[key] = new CSSLoader(new SingletonEnforcer());
			return CSSLoader.instances[key];
		}		

		private var _isLoaded:Boolean;		
		/**
		 * Returns a boolean determining whether the file has been loaded
		 */
		public function get isLoaded():Boolean { return _isLoaded; }
		
		/**
		 * Contains the loaded CSS data
		 */
		public var data:StyleSheet = new StyleSheet;
		
		/**
		 * Constructor
		 * @param	enforcer
		 */
		public function CSSLoader(enforcer:SingletonEnforcer)
		{
			_isLoaded = false;
		}	
		
		/**
		 * Loads the CSS style sheet file
		 * @param	url
		 */
		public function loadStyle(url:String):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader;
			urlLoader.addEventListener(Event.COMPLETE, onCSSDataLoaded);
			urlLoader.load(urlRequest);
		}
		
		/**
		 * CSS load complete handler
		 * @param	e
		 */
		private function onCSSDataLoaded(e:Event):void
		{
			data.parseCSS(urlLoader.data);
			_isLoaded = true;
			dispatchEvent(new FileEvent(FileEvent.CSS_LOADED));
		}
	}
}

class SingletonEnforcer{}