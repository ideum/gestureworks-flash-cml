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
		function get className():String;
		
		/**
		 * Sets the css class name.
		 */
		function set className(value:String):void;			
	}
}