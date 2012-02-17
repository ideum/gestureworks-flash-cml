package com.gestureworks.cml.interfaces 
{
	/**
	 * Implements classes that are layout objects
	 * @author Charles Veasey
	 */
	public interface ILayout extends IObject
	{
		function layout(container:IContainer):void;
	}
	
}