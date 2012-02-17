package com.gestureworks.cml.interfaces 
{
	/**
	 * IList
	 * Implement on classes that use list
	 * @author Charles Veasey
	 */
	
	public interface IList
	{
		function get currentIndex():int;
		function set currentIndex(value:int):void;
		
		function get currentValue():*;
	
		function get length():int;
		
		function getIndex(index:int):*;
		
		function selectIndex(index:int):*;
		
		function search(value:*):int;
		
		function append(value:*):void;
		
		function prepend(value:*):void;

		function insert(index:int, value:*):void;
		
		function remove(index:int):void;
	}
}