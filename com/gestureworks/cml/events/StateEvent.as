package com.gestureworks.cml.events
{
	import com.gestureworks.cml.elements.TouchContainer;
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
		 * Event initiator
		 */
		private var _target:*;
		override public function get target():Object { return _target; }
		
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
		 * @param target
		 * @param property
		 * @param bubbles
		 * @param cancelelable
		 * @return none
		 */		
		public function StateEvent(type:String, target:*=null, property:String=null, value:*=null, bubbles:Boolean=false, cancelable:Boolean = false):void 
		{
			//calls the super class Event
			super(type, bubbles, cancelable);

			//sets custom values
			_target = target;
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
			return new StateEvent(type, _target, _property, _value, bubbles, cancelable);
		}		
	
		
	}
}
