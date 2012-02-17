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
		function hasPrev():Boolean;
		function prev():*;
	}
}