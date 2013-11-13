package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.utils.ChildList;
	/**
	 * Implements CML Objects.
	 * @author Ideum
	 */
	public interface IObject extends ICML
	{
		/**
		 * Returns the index created by the CML parser.
		 */
		function get cmlIndex():int;
		
		/**
		 * Sets the index created by the CML parser.
		 * @param value
		 */
		function set cmlIndex(value:int):void;
		
		/**
		 * Returns the object's id.
		 */
		function get id():String;
		
		/**
		 * Sets the object's id.
		 * @param value
		 */
		function set id(value:String):void;	
		
		/**
		 * Returns the object's childList.
		 */
		function get childList():ChildList;		
		
		/**
		 * Sets the object's childList.
		 * @param value
		 */		
		function set childList(value:ChildList):void;		
		
		/**
		 * Abstract method allows the setting of a postparse CML routine.
		 * @param	cml
		 */
		function postparseCML(cml:XMLList):void;
		
		/**
		 * Updates properties from state.
		 * @param	state
		 */
		function updateProperties(state:* = 0):void;
		
		/**
		 * Initialization method.
		 */		
		function init():void;		
		
		/**
		 * Dispose method.
		 */
		function dispose():void;		
	}
	
}