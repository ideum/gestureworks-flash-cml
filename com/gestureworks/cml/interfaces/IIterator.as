package com.gestureworks.cml.interfaces
{
	/**
	 * IIterator
	 * Implement iterator and classes that can be iterated
	 * @author Charles Veasey
	 */
	
	public interface IIterator 
	{
		function reset():void;
		function hasNext():Boolean;			
		function next():*;
	}
}