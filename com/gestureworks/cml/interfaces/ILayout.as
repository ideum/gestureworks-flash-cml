package com.gestureworks.cml.interfaces 
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * Implements container layouts.
	 * @author Ideum
	 */
	public interface ILayout extends IObject
	{		
		/**
		 * Applies layout to the input container
		 * @param	container
		 */
		function layout(container:DisplayObjectContainer):void;
	}
	
}