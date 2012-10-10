package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.utils.LinkedMap;
	
	/**
	 * IContainer
	 * Implement classes that are display container
	 * @author Charles Veasey
	 */
	public interface IContainer extends IElement
	{
		function get childList():LinkedMap;
		function get layout():*;
	}
	
}