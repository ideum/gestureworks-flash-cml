package com.gestureworks.cml.interfaces 
{
	import com.gestureworks.cml.interfaces.IIterator
	
	/**
	 * IListIterator
	 * Implement 2-way iterator on list classes
	 * @author Charles Veasey
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