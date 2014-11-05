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
		 * Sets volume to 0 when true, and returns volume to setting prior to muting when false
		 * @default false
		 */		
		function get mute():Boolean;
		function set mute(value:Boolean):void;
		
		/**
		 * Audio pan {L=-1, R=1}
		 * @default 0
		 */
		function get pan():Number;
		function set pan(value:Number):void;	
		
		/**
		 * Media play status
		 * @default false
		 */
		function get isPlaying():Boolean;
		
		/**
		 * Media seeking status
		 * @default false
		 */
		function get isSeeking():Boolean; 		
		
		/**
		 * Media paused status
		 * @default false
		 */
		function get isPaused():Boolean; 
		
		/**
		 * Media complete status
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
		 * Position relative to duration
		 * @default 0
		 */
		function get progress():Number;
		
		/**
		 * Formatted string of the position (min:sec)
		 * @default "00:00"
		 */
		function get elapsedTime():String;
		
		/**
		 * Formatted string of the duration (min:sec)
		 * @default "00:00"
		 */
		function get totalTime():String;
	}
}