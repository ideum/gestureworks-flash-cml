package com.gestureworks.cml.interfaces 
{
	/**
	 * IPlayable
	 * Implement play control buttons and classes that can play
	 * @author Charles Veasey
	 */
	
	public interface IPlay 
	{
		function play():void;
		function pause():void;		
		function resume():void;
		function stop():void;
		function seek():void;
	}
}