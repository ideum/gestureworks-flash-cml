package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.core.CMLObject;
	import com.gestureworks.cml.utils.ChildList;
	
	/**
	 * Implements CML display containers.
	 * @author Ideum
	 */
	public interface IContainer extends IObject
	{
		/**
		 * Searches the childList and adds each child to the display list.
		 */
		function addAllChildren():void;		
	
	}
	
}