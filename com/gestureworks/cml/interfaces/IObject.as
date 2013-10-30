package com.gestureworks.cml.interfaces 
{
	/**
	 * Implements CML Objects.
	 * @author Ideum
	 */
	public interface IObject extends ICML
	{
		/**
		 * Returns the object's id.
		 */
		function get id():String;
		
		/**
		 * Sets the object's id.
		 */
		function set id(value:String):void;	
		
		/**
		 * Dispose method.
		 */
		function dispose():void;	
		
		/**
		 * Abstract method allows settings of a postparse CML routine.
		 * @param	cml
		 */
		function postparseCML(cml:XMLList):void;
		
		/**
		 * 
		 * @param	state
		 */
		function updateProperties(state:* = 0):void;
	}
	
}