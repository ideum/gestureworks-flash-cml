////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File: MP3Factory.as
//  Authors: Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.utils 
{	
	import com.gestureworks.cml.core.CMLObject;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.managers.FileManager;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	import com.greensock.loading.MP3Loader;
	import com.greensock.events.LoaderEvent;
	
	/** 
	 * The MP3Factory is the base class for all MP3s.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Charles
	 * @see com.gestureworks.cml.elements.MP3
	 * @see com.gestureworks.cml.elements.WAV
	 */	
	public class MP3Factory extends CMLObject
	{
		//audio	
		public var soundData:Sound;
		private var soundLoader:MP3Loader;
		public var channel:SoundChannel;
		protected var soundTrans:SoundTransform;
		protected var Position:uint;		
		
		
		/**
		 * Constructor
		 */
		public function MP3Factory()
		{
			super();
			soundData = new Sound();
			channel = new SoundChannel();
			soundTrans = new SoundTransform();			
		}			
		
		/**
		 * @deprecated use preload instead.
		 */
		[Deprecated(replacement = "preload")]
		public function get autoLoad():Boolean { return _preload; }
		public function set autoLoad(value:Boolean):void 
		{ 
			_preload = value; 
		}
		
		private var _preload:Boolean = true;
		/**
		 * Indicates whether the mp3 file is loaded when the src property is set
		 */	
		public function get preload():Boolean { return _preload; }
		public function set preload(value:Boolean):void {
			_preload = value;
		}
		
		private var _autoplay:Boolean = false;
		/**
		 * Indicates whether the mp3 file plays upon load
		 */	
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}

		private var _loop:Boolean = false;
		/**
		 * Mp3 loop play
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { 
			_loop = value; 
		}		
		
		private var _src:String;
			/**
		 * Sets the mp3 file path
		 */	
		public function get src():String{ return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;					
			_src = value;
			//if (autoLoad) load();
		}		
		
		private var _volume:Number = 1;
		/**
		 * Sets the volume
		 */	
		public function get volume():Number {return _volume;}		
		public function set volume(value:Number):void
		{
			if (value < 0.0) _volume = 0.0; 
			else if (value > 1.0) _volume = 1.0;
			else _volume = value;
		}
		
		private var _pan:Number = 0;
		/**
		 * Sets the pan
		 */	
		public function get pan():Number {return _pan;}				
		public function set pan(value:Number):void
		{
			if (value < -1.0) _pan = -1.0; 
			else if (value > 1.0) _pan = 1.0;
			else _pan = value;
		}
		
		/**
		 * Total duration
		 */		
		private var _duration:Number=0;
		public function get duration():Number { return _duration; }
		
		/**
		 * Percent of file loaded 
		 */		
		private var _percentLoaded:Number=0;
		public function get percentLoaded():Number { return _percentLoaded; }
		
		/**
		 * Playhead position in ms
		 */		
		private var _position:Number = 0;
		/**
		 * Playhead position in ms
		 */	
		public function get position():Number { return _position; }		
		
		private var _isPlaying:Boolean = false;
		/**
		 * Sets video playing status
		 */
		public function get isPlaying():Boolean { return _isPlaying; }
		
		override public function init():void
		{
			//if (preload)
				load();
				
			if (preload && FileManager.media.getContent(_src)) {
				soundLoaded();
			}
		}
		
		/**
		 * Disposal method
		 */				
		override public function dispose():void
		{
			super.dispose();
			channel = null;
			_isPlaying = false;
			
			if (channel) 
			{
				channel.stop();
				if (_isPlaying)
					channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				channel = null;
			}
			if (soundTrans) soundTrans = null;
			if (soundData) soundData = null;
			//if (parent) parent.removeChild(this);
		}
		
		/// PUBLIC METHODS ///
		
		
		/**
		 * Sets the src property and loads the mp3
		 * @param file
		 */		
		public function open(file:String):void
		{
			src = file;
			load();
		}

		/**
		 * Closes mp3 
		 */	
		public function close():void 
		{
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			//timer.stop();
		}		
		
		/**
		 * Plays the mp3 from the beginning
		 */		
		public function play():void
		{
			if (!_isPlaying) 
			{	
				channel = soundData.play(0, 0, soundTrans);
				channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
				_isPlaying = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
			}
		}
		
		/**
		 * Resumes mp3 playback from paused position
		 */			
		public function resume():void
		{
			if (!_isPlaying) 
			{				
				channel = soundData.play(Position, 0, soundTrans);
				channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
				_isPlaying = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
			}
		}
		
		/**
		 * Pauses mp3
		 */			
		public function pause():void
		{
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			Position = channel.position;
			_isPlaying = false;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
		}
		
		/**
		 * Pauses mp3 and returns to the beginning
		 */			
		public function stop():void
		{
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			Position = 0
			_isPlaying = false;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
		}
		
		/**
		 * Sets the mp3 playhead position in milliseconds
		 * @param position Number in ms
		 */
		public function seek(pos:Number):void
		{
			pause();
			Position = (pos / 100) * soundData.length;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "Position" , Position));
		}
	
		/// PRIVATE METHODS ///	
		protected function load():void
		{
			//audio
			soundLoader = new MP3Loader(_src);
		
			soundLoader.addEventListener(LoaderEvent.COMPLETE, soundLoaded);
			//soundData.addEventListener(Event.COMPLETE, soundLoaded);
			
			soundLoader.load();
		}
		
		protected function soundLoaded(event:Event=null):void 
		{    
			
			
			//audio
			volume = _volume;
			pan = 0.0;
			//soundData.load(new URLRequest(_src));	
			//soundLoader.load(new URLRequest(_src));
			soundTrans.volume = _volume;
			soundTrans.pan = _pan;
			_isPlaying = false;
			Position = 0;
			//soundData.removeEventListener(Event.COMPLETE, soundLoaded);
			//if (preload && autoplay) play();
			
			if (soundLoader)
			{
				soundLoader.removeEventListener(LoaderEvent.COMPLETE, soundLoaded);
				soundData = soundLoader.content;
				soundLoader.pauseSound();
				//fileData = img.loader;
				//img.removeEventListener(IMGLoader.COMPLETE, loadComplete);
				//img.removeEventListener(StateEvent.CHANGE, onPercentLoad);
			}
			else
			{
				var soundSrc:String;
				
				if (src)
					soundSrc = src;
				else
					soundSrc = state[0]["src"];
					
				if (!FileManager.media.getContent(soundSrc))
					return;
					
				soundData = (FileManager.media.getContent(soundSrc)) as Sound;			
			}
			
			if (autoplay) 
				play()
			
		}
		
		protected function soundComplete(event:Event):void
		{
			pause();
			Position = 0;
			if (_loop) play();
			else _isPlaying = false;
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "Complete" , "complete"));
		}
	}
}