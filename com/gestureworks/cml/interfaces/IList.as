package com.gestureworks.cml.interfaces 
{
	/**
	 * Implements lists.
	 * @author Ideum
	 */
	public interface IList
	{
		/**
		 * Returns current list index.
		 */
		function get currentIndex():int;

		/**
		 * Sets current list index
		 */		
		function set currentIndex(value:int):void;
		
		/**
		 * Returns current list value.
		 */
		function get currentValue():*;
	
		/**
		 * Returns list length.
		 */
		function get length():int;
		
		/**
		 * Returns value by input index
		 * @param	index
		 * @return  value
		 */
		function getIndex(index:int):*;
		
		/**
		 * Returns value by input index.
		 * @param	index
		 * @return  value
		 */	
		function selectIndex(index:int):*;
		
		/**
		 * Returns index by input value.
		 * @param	value
		 * @return  index
		 */
		function search(value:*):int;
		
		/**
		 * Appends input value to list.
		 * @param  index
		 */
		function append(value:*):void;
		
		/**
		 * Prepends input value to list.
		 * @param	value
		 */
		function prepend(value:*):void;

		/**
		 * Inserts input value to list. The indices ajust accordingly.
		 * @param	index
		 * @param	value
		 */
		function insert(index:int, value:*):void;
		
		/**
		 * Removes value from list. The indices ajust accordingly.
		 * @param	index
		 */
		function remove(index:int):void;
	}
}