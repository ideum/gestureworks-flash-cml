package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.utils.LinkedMap;
	
	/**
	 * Implements CML display containers.
	 * @author Ideum
	 */
	public interface IContainer extends IElement
	{
		/**
		 * Returns the CML childlist.
		 */
		function get childList():LinkedMap;
		
		/**
		 * Returns the layout.
		 */
		function get layout():*;
	}
	
}