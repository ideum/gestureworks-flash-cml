package com.gestureworks.cml.interfaces
{
	/**
	 * ICSS
	 * Implement classes that are hooked into the css display engine
	 * @author Charles Veasey
	 */
	
	public interface ICSS
	{
		function get class_():String;
		function set class_(value:String):void;			
	}
}