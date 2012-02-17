package com.gestureworks.cml.interfaces 
{
	/**
	 * ICML
	 * Implements classes that able to be parsed by cml parser
	 * @author Charles Veasey
	 */
	
	public interface ICML 
	{		
		function parseCML(cml:XMLList):XMLList;
	}
	
}