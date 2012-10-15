package com.gestureworks.cml.events
{
	import flash.events.Event;
	
	/**
	 * The StateEvent is the primary message event for CML elements and compoenents.
	 * It passes the dispatcher's id, the property name that has been changed, and the new property value.
	 * 
	 * @author Ideum
	 * @see FileEvent
	 */
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
		 * Event initiator's property value
		 * @default null
		 */	
		private var _value:*;
		public function get value():* { return _value; }	
		
		
		/**
		 * Creates a StateEvent object and sets defaults
		 * @param type
		 * @param id
		 * @param property
		 * @param bubbles
		 * @param cancelelable
		 * @return none
		 */		
		public function StateEvent(type:String, id:String=null, property:String=null, value:*=null, bubbles:Boolean=false, cancelable:Boolean = false):void 
		{
			//calls the super class Event
			super(type, bubbles, cancelable);

			//sets custom values
			_id = id;
			_property = property;
			_value = value;
		}
		
		
		/**
		 * Overrides event's clone method
		 * @param none
		 * @returns StateEvent
		 */		
		override public function clone():Event
		{
			return new StateEvent(type, _id, _property, _value, bubbles, cancelable);
		}		
	
		
	}
}
