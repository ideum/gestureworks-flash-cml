package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.interfaces.IIterator
	
	/**
	 * Implements a 2-way iterator on Lists.
	 * @author Ideum
	 */
	public interface IListIterator extends IIterator
	{
		/**
		 * Returns true if the collection has items 
		 * which have a lower index than the current index
		 * @return
		 */
		function hasPrev():Boolean;
		
		/**
		 * Returns the previous item in the collection
		 * @return
		 */
		function prev():*;
	}
}