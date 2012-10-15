package com.gestureworks.cml.interfaces
{
	/**
	 * Implements an iterator.
	 * @author Ideum
	 */
	public interface IIterator 
	{	
		/**
		 * Returns true if the iteration can return one more than the current index
		 * @return
		 */
		function hasNext():Boolean;
		
		/**
		 * Returns the next value in the iteration.
		 * @return
		 */
		function next():*;	
	}
}