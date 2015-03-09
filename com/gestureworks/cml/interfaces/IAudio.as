package com.gestureworks.cml.interfaces
{
	import com.gestureworks.cml.base.media.Waveform
	/**
	 * Implements audio specific functions
	 * @author Ideum
	 */
	
	public interface IAudio
	{
		/**
		 * Audio metadata object
		 */
		function get metadata():*;
		
		/**
		 * Metadata title
		 */
		function get title():String;
		
		/**
		 * Metadata artist
		 */
		function get artist():String;
		
		/**
		 * Metadata album
		 */
		function get album():String; 
		
		/**
		 * Metadata date
		 */
		function get date():String; 
		
		/**
		 * Metadata publisher
		 */
		function get publisher():String;
		
		/**
		 * Metadata comment
		 */
		function get comment():String; 
		
		/**
		 * Draw audio waveform
		 * @param	value Waveform instance
		 */
		function visualize(value:Waveform):void;
	}
}