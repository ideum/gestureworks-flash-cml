package com.gestureworks.cml.interfaces
{
	/**
	 * IElement
	 * Implement classes that are display elements
	 * @authors Charles Veasey
	 */	
	
	public interface IElement extends IObject
	{
		 function get width():Number;
		 function set width(value:Number):void;
		 function get height():Number;
		 function set height(value:Number):void;		 
	}
	
	
}