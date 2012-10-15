package com.gestureworks.cml.interfaces 
{
	/**
	 * Implement media control methods
	 * @author Ideum
	 */
	
	public interface IPlay 
	{
		/**
		 * Plays the media from the beginning.
		 */
		function play():void;
		
		/**
		 * Pauses the media.
		 */
		function pause():void;	
		
		/**
		 * Resumes the media from paused position.
		 */
		function resume():void;
		
		/**
		 * Stops the media.
		 */
		function stop():void;
		
		/**
		 * Seeks media to pos in milliseconds.
		 * @param	pos
		 */
		function seek(pos:Number):void;
	}
}