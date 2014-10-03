////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File: AudioFactory.as
//  Authors: Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.utils 
{	
	import com.gestureworks.cml.interfaces.IAudio;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.managers.FileManager;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	/** 
	 * The AudioFactory is the base class for all audio factories. 
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 */	
	public class AudioFactory implements IStream, IAudio
	{
		protected var _soundData:Sound;
		protected var _channel:SoundChannel;
		protected var _soundTransform:SoundTransform;
		protected var _src:String;	
		
		protected var _autoplay:Boolean;
		protected var _loop:Boolean;	
		protected var _volume:Number = 1;	
		protected var _pan:Number = 0;
		protected var _duration:Number = 0;		
		
		protected var _percentLoaded:Number = 0;	
		protected var _position:Number = 0;	
		protected var _isPlaying:Boolean;	
		protected var _isPaused:Boolean;
		protected var _isComplete:Boolean;
		
		protected var _metadata:*;
		protected var _title:String;
		protected var _artist:String;
		protected var _album:String;
		protected var _date:String;
		protected var _publisher:String;
		protected var _comment:String;
		
		public var statusCallback:Function;
		
		/**
		 * Constructor
		 */
		public function AudioFactory(){
			super();
			_soundData = new Sound();
			_channel = new SoundChannel();
			_soundTransform = new SoundTransform();	
		}
		
		/**
		 * Sound manager instance
		 */
		public function get soundData():Sound { return _soundData; }
		
		/**
		 * SoundChannel instance
		 */
		public function get channel():SoundChannel { return _channel; }
		
		/**
		 * SoundTransform instance
		 */
		public function get soundTransform():SoundTransform { return _soundTransform; }
		
		/**
		 * Execute status callback
		 */
		protected function publishStatus():void {
			if (statusCallback != null) {
				statusCallback.call();
			}
		}
		
		/**
		 * Sets the audio file path
		 */	
		public function get src():String{ return _src;}
		public function set src(value:String):void{
			if (src == value) {
				return; 
			}
			
			_src = value;			
			if (FileManager.media.getContent(_src)) {
				soundLoaded();
			}
			else {
				load();
			}
		}		
	
		/**
		 * Load audio file
		 */
		protected function load():void { }
		
		/**
		 * Track load progress
		 * @param	event
		 */
		protected function loadProgress(event:Event=null):void {}			
		
		/**
		 * Audio file load complete
		 * @param	event
		 */
		protected function soundLoaded(event:Event=null):void {    
			_soundTransform.volume = volume;
			_soundTransform.pan = pan;
		}
		
		/**
		 * Audio stream complete
		 * @param	event
		 */
		protected function soundComplete(event:Event = null):void {
			_isComplete = true; 			
			stop();								
		}	
		
		/**
		 * Closes audio file
		 */	
		public function close():void {
			stop();
			_channel.stop();					
		}			
		
		/**
		 * @inheritDoc
		 */		
		public function play():void { 
			_isPlaying = true; 
			_isPaused = false; 
			_isComplete = false; 
			publishStatus();
		}
		
		/**
		 * @inheritDoc
		 */			
		public function resume():void {
			_isPlaying = true;  
			_isPaused = false; 
			publishStatus();			
		}
		
		/**
		 * @inheritDoc
		 */			
		public function pause():void {
			_isPlaying = false; 
			_isPaused = true; 
			publishStatus();			
		}
		
		/**
		 * @inheritDoc
		 */			
		public function stop():void {
			_isPlaying = false; 
			_isPaused = false; 
			_position = 0;
			publishStatus();			
		}
		
		/**
		 * @inheritDoc
		 */
		public function seek(pos:Number):void{}		
		
		/**
		 * @inheritDoc
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void {	
			_autoplay = value;
		}

		/**
		 * @inheritDoc
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { 
			_loop = value; 
		}		
		
		/**
		 * @inheritDoc
		 */
		public function get volume():Number {return _volume;}		
		public function set volume(value:Number):void{
			_volume = value < 0 ? 0 : value > 1 ? 1 : value; 
		}
		
		/**
		 * @inheritDoc
		 */	
		public function get pan():Number {return _pan;}				
		public function set pan(value:Number):void{
			_pan = value < -1 ? -1 : value > 1 ? 1 : value; 
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isPlaying():Boolean { return _isPlaying; }	
		
		/**
		 * @inheritDoc
		 */
		public function get isPaused():Boolean { return _isPaused; }
		
		/**
		 * @inheritDoc
		 */
		public function get isComplete():Boolean { return _isComplete; }
		
		/**
		 * @inheritDoc
		 */		
		public function get duration():Number { return _duration; }
		
		/**
		 * @inheritDoc
		 */		
		public function get percentLoaded():Number { return _percentLoaded; }
				
		/**
		 * @inheritDoc
		 */	
		public function get position():Number { return _position; }		
		
		/**
		 * @inheritDoc
		 */
		public function get metadata():* { return _metadata; }

		/**
		 * @inheritDoc
		 */		
		public function get title():String { return _title; }
		
		/**
		 * @inheritDoc
		 */		
		public function get artist():String { return _artist; }
		
		/**
		 * @inheritDoc
		 */		
		public function get album():String { return _album; }
		
		/**
		 * @inheritDoc
		 */		
		public function get date():String { return _date; }
		
		/**
		 * @inheritDoc
		 */		
		public function get publisher():String { return _publisher; }
		
		/**
		 * @inheritDoc
		 */		
		public function get comment():String { return _comment; }
		
		/**
		 * Draw audio visualization
		 * @param	value Waveform object
		 */
		public function visualize(value:Waveform):void {}
		
		/**
		 * Disposal function
		 */				
		public function dispose():void{}		
	}
}