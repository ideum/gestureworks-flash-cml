package com.gestureworks.cml.events
{
	import flash.events.Event;
	
	/**
	 * This class contains the types and other definitions of file event dispatched by the application.
	 * @author..
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
		 * Event initiator's file type
		 * @default null
		 */	
		private var _fileType:String;
		public function get fileType():String { return _fileType; }	
		
		
		/**
		 * Event initiator's file path name
		 * @default null
		 */	
		private var _filePath:String;
		public function get filePath():String { return _filePath; }				
		
		
		/**
		 * Creates a FileEvent object and sets defaults
		 * @param type
		 * @param id
		 * @param property
		 * @param bubbles
		 * @param cancelelable
		 * @return none
		 */		
		public function FileEvent(type:String, fileType:String=null, filePath:String=null, bubbles:Boolean=false, cancelable:Boolean = false):void 
		{
			//calls the super class Event
			super(type, bubbles, cancelable);

			//sets custom values
			_fileType = fileType;
			_filePath = filePath;
		}
		
		
		/**
		 * Overrides event's clone method
		 * @param none
		 * @returns FileEvent
		 */		
		override public function clone():Event
		{
			return new FileEvent(type, _fileType, _filePath, bubbles, cancelable);
		}		
	
		
	}
}
