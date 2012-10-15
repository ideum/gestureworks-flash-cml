package com.gestureworks.cml.interfaces
{
	/**
	 * Implements CSS compatibility.
	 * @author Ideum
	 */
	public interface ICSS
	{
		/**
		 * Returns the css class name.
		 */
		function get class_():String;
		
		/**
		 * Sets the css class name.
		 */
		function set class_(value:String):void;			
	}
}