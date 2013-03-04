package com.gestureworks.cml.events
{
	import flash.events.Event;
	
	/**
	 * The FileEvent is dispatched during file loading operations.
	 * 
	 * @author Ideum
	 * @see StateEvent
	 */
	public class FileEvent extends Event 
	{	
		/**
		 * Event constant
		 * @default CML_LOADED
		 */	
		public static const CML_LOADED:String = "CML_LOADED";
		

		/**
		 * Event constant
		 * @default CSS_LOADED
		 */	
		public static const CSS_LOADED:String = "CSS_LOADED";		
		
		
		/**
		 * Event constant
		 * @default FILES_LOADED
		 */	
		public static const FILES_LOADED:String = "FILES_LOADED";
		
		
		/**
		 * Event constant
		 * @default FILES_LOADED
		 */	
		public static const FILE_LOADED:String = "FILE_LOADED";
		
		
		/**
		 * Event initiator's file path name
		 * @default null
		 */	
		private var _path:String;
		public function get path():String { return _path; }				
		
		/**
		 * Event initiator's file path name
		 * @default null
		 */	
		private var _data:*;
		public function get data():* { return _data; }	
		
		/**
		 * Creates a FileEvent object and sets defaults
		 * @param type
		 * @param path
		 * @param property
		 * @param bubbles
		 * @param cancelelable
		 * @return none
		 */		
		public function FileEvent(type:String, path:String=null, data:*=null, bubbles:Boolean=false, cancelable:Boolean = false):void 
		{
			//calls the super class Event
			super(type, bubbles, cancelable);

			//sets custom values
			_path = path;
			_data = data;
		}
		
		
		/**
		 * Overrides event's clone method
		 * @param none
		 * @returns FileEvent
		 */		
		override public function clone():Event
		{
			return new FileEvent(type, _path, _data, bubbles, cancelable);
		}		
	
		
	}
}
