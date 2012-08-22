package com.gestureworks.cml.interfaces 
{
	import flash.display.DisplayObjectContainer;
	/**
	 * Implements classes that are layout objects
	 * @author Charles Veasey
	 */
	public interface ILayout extends IObject
	{
		function layout(container:DisplayObjectContainer):void;
	}
	
}