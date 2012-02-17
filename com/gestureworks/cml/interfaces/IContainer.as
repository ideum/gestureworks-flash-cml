package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.utils.LinkedMap;
	
	/**
	 * ...
	 * @author Charles Veasey
	 */
	public interface IContainer extends IElement
	{
		function get childList():LinkedMap;
		function get layout():String;
	}
	
}