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
		 * @default false
		 */
		function get autoplay():Boolean;
		function set autoplay(value:Boolean):void; 		
		
		/**
		 * Auto-plays the media on end
		 * @default false
		 */
		function get loop():Boolean;
		function set loop(value:Boolean):void;
		
		/**
		 * Audio volume
		 * @default 1
		 */
		function get volume():Number;
		function set volume(value:Number):void;
		
		/**
		 * Audio pan
		 * @default 0
		 */
		function get pan():Number;
		function set pan(value:Number):void;	
		
		/**
		 * Returns media play status
		 * @default false
		 */
		function get isPlaying():Boolean;
		
		/**
		 * Returns media paused status
		 * @default false
		 */
		function get isPaused():Boolean; 
		
		/**
		 * Returns media complete status
		 * @default false
		 */
		function get isComplete():Boolean;
		
		/**
		 * Current playback position in ms
		 * @default 0
		 */
		function get position():Number; 
		
		/**
		 * Total length of media in ms
		 * @default 0
		 */
		function get duration():Number;
		
		/**
		 * Percentage of bytes loaded
		 */
		function get percentLoaded():Number;
	}
}