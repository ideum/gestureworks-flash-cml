package com.gestureworks.cml.interfaces 
{
	/**
	 * Implements CML compatibility.
	 * @author Ideum
	 */
	public interface ICML 
	{		
		/**
		 * Internal CML parse method. This can be overridden to create custom parse routines.
		 * @param	cml
		 * @return  The XMLList to return back to the CML parser for further processing.
		 */	
		function parseCML(cml:XMLList):XMLList;	
	}
	
}