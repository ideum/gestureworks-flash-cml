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

package com.gestureworks.cml.base.media 
{	
	import com.gestureworks.cml.interfaces.IAudio;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.base.media.Waveform;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
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
		private var _mute:Boolean;				
		protected var _pan:Number = 0;
		protected var _duration:Number = 0;	
		protected var _progress:Number = 0;
		protected var _elapsedTime:String = "00:00";
		protected var _totalTime:String = "00:00";
		
		protected var _percentLoaded:Number = 0;	
		protected var _position:Number = 0;	
		protected var _isPlaying:Boolean;	
		protected var _isSeeking:Boolean;
		protected var _isPaused:Boolean;
		protected var _isComplete:Boolean;
		protected var _isLoaded:Boolean;
		
		protected var _metadata:*;
		protected var _title:String;
		protected var _artist:String;
		protected var _album:String;
		protected var _date:String;
		protected var _publisher:String;
		protected var _comment:String;
		
		private var unmuteVolume:Number = 1;		
		
		/**
		 * Callback function fired on status change
		 */
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
		 * @param status  current status
		 * @param value  value of current status
		 */
		protected function publishStatus(status:String, value:Boolean):void {
			if (statusCallback != null) {
				statusCallback.call(null, status, value);
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
			
			close();
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
			_isLoaded = true; 
			publishStatus(MediaStatus.LOADED, isLoaded);
		}
		
		/**
		 * Audio stream complete
		 * @param	event
		 */
		protected function soundComplete(event:Event = null):void {
			_isComplete = true; 
			publishStatus(MediaStatus.PLAYBACK_COMPLETE, isComplete);
			stop();								
		}	
		
		/**
		 * Closes audio file
		 */	
		public function close():void {
			stop();
			_src = null;
			_channel.stop();	
			_isLoaded = false;
			_isPlaying = false; 
			_isSeeking = false; 
			_isPaused = false; 
			_isComplete = false; 
		}			
		
		/**
		 * @inheritDoc
		 */		
		public function play():void { 
			_isPlaying = true; 
			_isPaused = false; 
			_isComplete = false; 
			publishStatus(MediaStatus.PLAYING, isPlaying);
		}
		
		/**
		 * @inheritDoc
		 */			
		public function resume():void {
			_isPlaying = true;  
			_isPaused = false; 
			publishStatus(MediaStatus.PLAYING, isPlaying);			
		}
		
		/**
		 * @inheritDoc
		 */			
		public function pause():void {
			_isPlaying = false; 
			_isPaused = true; 
			publishStatus(MediaStatus.PAUSED, isPaused);			
		}
		
		/**
		 * @inheritDoc
		 */			
		public function stop():void {
			_isPlaying = false; 
			_isPaused = false; 
			_position = 0;
			publishStatus(MediaStatus.PLAYING, isPlaying);			
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
		public function get mute():Boolean { return _mute; }
		public function set mute(value:Boolean):void {
			_mute = value;
			if (_mute){
				unmuteVolume = volume;
			}
			volume = _mute ? 0 : unmuteVolume;								
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
		public function get isSeeking():Boolean { return _isSeeking; }
		
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
		public function get isLoaded():Boolean { return _isLoaded; }
		
		/**
		 * @inheritDoc
		 */	
		public function get position():Number { return _position; }			
		
		/**
		 * @inheritDoc
		 */		
		public function get duration():Number { return _duration; }
		
		/**
		 * @inheritDoc
		 */
		public function get progress():Number { return _progress; }
		
		/**
		 * @inheritDoc
		 */
		public function get elapsedTime():String { return _elapsedTime; }
		
		/**
		 * @inheritDoc
		 */
		public function get totalTime():String { return _totalTime; }
		
		/**
		 * @inheritDoc
		 */		
		public function get percentLoaded():Number { return _percentLoaded; }	
		
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
		 * @inheritDoc
		 */
		public function visualize(value:Waveform):void {}
		
		/**
		 * Clone function
		 * @return copy of object
		 */
		public function clone():AudioFactory {
			return CloneUtils.clone(this);
		}
		
		/**
		 * Disposal function
		 */				
		public function dispose():void {
			_soundData = null;
			_channel= null;
			_soundTransform = null;		
			_metadata = null;			
		}		
	}
}