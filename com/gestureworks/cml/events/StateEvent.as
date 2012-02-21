package com.gestureworks.cml.events
{
	import flash.events.Event;
	
	public class StateEvent extends Event 
	{	
		/**
		 * Event constant
		 * @default CHANGE
		 */	
		public static const CHANGE:String = "CHANGE";
		
		
		/**
		 * Event initiator's id
		 * @default null
		 */	
		private var _id:String;
		public function get id():String { return _id; }		

		
		/**
		 * Event initiator's property
		 * @default null
		 */	
		private var _property:String;
		public function get property():String { return _property; }	
		
		
			
		/**
		 * Creates a StateEvent object and sets defaults
		 * @param type
		 * @param id
		 * @param property
		 * @param bubbles
		 * @param cancelelable
		 * @return none
		 */		
		public function StateEvent(type:String, id:String=null, property:String=null, bubbles:Boolean=false, cancelable:Boolean = false):void 
		{
			//calls the super class Event
			super(type, bubbles, cancelable);

			//sets custom values
			_id = id;
			_property = property;
		}
		
		
		/**
		 * Overrides event's clone method
		 * @param none
		 * @returns StateEvent
		 */		
		override public function clone():Event
		{
			return new StateEvent(type, _id, _property, bubbles, cancelable);
		}		
	
		
	}
}
