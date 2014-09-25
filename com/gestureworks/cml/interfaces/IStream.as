package com.gestureworks.cml.interfaces
{
	/**
	 * Implements streaming media control methods
	 * @author Ideum
	 */
	
	public interface IStream
	{
		/**
		 * Plays the media from the beginning
		 */
		function play():void;
		
		/**
		 * Pauses the media
		 */
		function pause():void;	
		
		/**
		 * Resumes the media from paused position
		 */
		function resume():void;
		
		/**
		 * Stops the media
		 */
		function stop():void;
		
		/**
		 * Seeks media playhead position in milliseconds
		 * @param	pos offset
		 */
		function seek(pos:Number):void;
		
		/**
		 * Plays media on load
		 */
		function get autoplay():Boolean;
		function set autoplay(value:Boolean):void; 		
		
		/**
		 * Auto-plays the media on end
		 */
		function get loop():Boolean;
		function set loop(value:Boolean):void;
		
		/**
		 * Audio volume
		 */
		function get volume():Number;
		function set volume(value:Number):void;
		
		/**
		 * Audio pan
		 */
		function get pan():Number;
		function set pan(value:Number):void;		
		
		/**
		 * Returns media play status
		 */
		function get isPlaying():Boolean;
	}
}