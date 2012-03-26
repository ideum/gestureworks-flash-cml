package com.gestureworks.cml.interfaces
{
	/**
	 * IIterator
	 * Implements iterator and classes that can be iterated
	 * @author Charles Veasey
	 */
	
	public interface IIterator 
	{
		/**
		 * Moves the iterator to the first item in the collection.
		 */
		//function reset():void;
		
		/**
		 * Returns true if the iteration has more elements.
		 * @return
		 */
		function hasNext():Boolean;
		
		/**
		 * Returns the next element in the iteration.
		 * @return
		 */
		function next():*;
		
		
		/**
		 * Moves the iterator to the first item in the collection.
		 */
		///function start():void
		///function reset():void
	
		/**
		 * Grants access to the current item being referenced by the iterator.
		 * This provides a quick way to read or write the current data.
		 */
		//function get data():*
		
		/**
		 * @private
		 */
		//function set data(obj:*):void		
	}
}