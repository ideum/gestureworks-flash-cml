package com.gestureworks.cml.interfaces
{
	/**
	 * Implements CML Elements.
	 * @author Ideum
	 */	
	public interface IElement extends IObject
	{
		/**
		 * Returns the width of the display object.
		 */
		function get width():Number;
		
		/**
		 * Sets the width of the display object.
		 */
		function set width(value:Number):void;
		
		/**
		 * Returns the height of the display object.
		 */
		function get height():Number;
		
		/**
		 * Sets the height of the display object.
		 */		
		function set height(value:Number):void;		 
	}
	
	
}