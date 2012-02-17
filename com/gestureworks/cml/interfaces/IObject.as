package com.gestureworks.cml.interfaces 
{
	/**
	 * IObject
	 * Implements classes that are CML objects
	 * @author Charles Veasey
	 */
	
	public interface IObject extends ICML
	{
		function get id():String;	
		function set id(value:String):void;		
		function dispose():void;				
		function postparseCML(cml:XMLList):void;		
		function updateProperties(state:Number = 0):void;
	}
	
}