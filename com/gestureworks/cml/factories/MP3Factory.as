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

package com.gestureworks.cml.factories 
{	
	import com.gestureworks.cml.factories.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * This is the base class for the MP3Element
	 */		
	public class MP3Factory extends ElementFactory
	{
		//audio	
		private var sound:Sound;
		private var channel:SoundChannel;
		private var soundTrans:SoundTransform;
		private var playing:Boolean;		
		private var cue:uint;		
		
		
		//graphic
		private var sp:Sprite;
		private var g:Graphics;
		private var bytes:ByteArray;
		private var _waveColor:int=0xFFFFFF;
		
		
				
		//update timer
		private var _timerFormated:String="00:00";
		public static var TIME:String = "Time";
		public var timer:Timer;
		
		
		public function MP3Factory()
		{
			super();
		}
		
		
		
		/**
		 * Sets the width
		 */		
		private var _width:Number=500
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		/**
		 * Sets the height
		 */		
		private var _height:Number=300;
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}			
		
		
		
		
		/**
		 * Indicates whether the mp3 file is loaded when the src property is set
		 */		
		private var _autoLoad:Boolean=true;
		public function get autoLoad():Boolean { return _autoLoad; }
		public function set autoLoad(value:Boolean):void 
		{ 
			_autoLoad = value; 
		}
		
		/**
		 * Indicates whether the mp3 file plays upon load
		 */		
		private var _autoplay:Boolean=false;
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}

		/**
		 * Mp3 loop play
		 */				
		private var _loop:Boolean=false;
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }		
		
		/**
		 * Sets the mp3 file path
		 */			
		private var _src:String;
		public function get src():String{ return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;					
			_src = value;
			if (autoLoad) load();
		}		
		
		/**
		 * Sets the volume
		 */			
		private var _volume:Number = 1;
		public function get volume():Number {return _volume;}		
		public function set volume(value:Number):void
		{
			if (value < 0.0) _volume = 0.0; 
			else if (value > 1.0) _volume = 1.0;
			else _volume = value;
		}
		
		
		/**
		 * Sets the pan
		 */			
		private var _pan:Number = 0;
		public function get pan():Number {return _pan;}				
		public function set pan(value:Number):void
		{
			if (value < -1.0) _pan = -1.0; 
			else if (value > 1.0) _pan = 1.0;
			else _pan = value;
		}		
		
		
		/**
		 * Visualization display type
		 */			
		private var _display:String = "waveform";
		public function get display():String {return _display;}				
		public function set display(value:String):void
		{
			_display = value;
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
		private var _position:Number=0;
		public function get position():Number { return _position; }		
		

		
		
		
		
		
		
		
		/**
		 * Disposal method
		 */				
		override public function dispose():void
		{
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, updateDisplay);
				timer = null;
			}
			if (channel) 
			{
				channel.stop();
				if (playing)
					channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				channel = null;
			}
			if (soundTrans) soundTrans = null;
			if (id3) {
				sound.removeEventListener(Event.ID3, id3Handler);
				id3 = null;
			}
			if (sound) sound = null;
			if (bytes) bytes = null;
			if (sp) sp = null;
			if (parent) parent.removeChild(this);
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
			timer.stop();
		}		
		
		/**
		 * Plays the mp3 from the beginning
		 */		
		public function play():void
		{
			if (!playing) 
			{	
				timer.start();
				channel = sound.play(0, 0, soundTrans);
				channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
				playing = true;
			}
		}
		
		/**
		 * Resumes mp3 playback from paused position
		 */			
		public function resume():void
		{
			if (!playing) 
			{				
			timer.start();
			channel = sound.play(cue, 0, soundTrans);
			channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			playing = true;
			}
		}
		
		/**
		 * Pauses mp3
		 */			
		public function pause():void
		{
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			timer.stop();
			cue = channel.position;
			playing = false
		}
		
		/**
		 * Pauses mp3 and returns to the beginning
		 */			
		public function stop():void
		{
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			timer.stop();
			cue = 0
			playing = false
		}
		
		/**
		 * Sets the mp3 playhead position
		 * @param offset
		 */
		public function seek(offset:Number):void
		{

		}

		
	
		/// PRIVATE METHODS ///	
		private function load():void
		{
			//audio
			sound = new Sound();
			channel = new SoundChannel();
			soundTrans = new SoundTransform();
			sound.addEventListener(Event.COMPLETE, soundLoaded);
			

			 _waveColor = 0xFFFFFF;
			 
			if (display == "waveform") 
			{
				sp = new Sprite();
				bytes = new ByteArray();
			}
			
			//ID3 metadata
			if (!_useId3) _useId3 = 'yes';
			if (_useId3 == 'yes')
				sound.addEventListener(Event.ID3, id3Handler);
			
			//update timer
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			
			//audio
			volume = 1.0;
			pan = 0.0;
			loop = true
			sound.load(new URLRequest(_src));			
			soundTrans.volume = _volume;
			soundTrans.pan = _pan;
			playing = false;
			cue = 0;
			

			//graphic
			if (display == "waveform") 
			{
				bgGraphic = new Sprite;
				bgGraphic.graphics.beginFill(0x333333, .5);
				bgGraphic.graphics.drawRect(0, 0, _width, _height);
				bgGraphic.graphics.endFill();
				addChild(bgGraphic);
				
				g = sp.graphics;
				addChild(sp);
			}
			
			if (autoplay) play();
							
		}		
		
	
		
		private var bgGraphic:Sprite;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		//graphics
		public function set waveColor(value:int):void
		{
			_waveColor = value;
		}
		
		public function get waveColor():int
		{
			return _waveColor;
		}	
		
		
		
		
		
		
		
		
		//ID3 metadata
		private var id3:ID3Info;
		private var _useId3:String;
		private var _id3Title:String;
		private var _id3Author:String;
		private var _id3Album:String;
		private var _id3Year:String;
		private var _id3Copyright:String;
		private var _id3Comment:String;
		
		public function set useId3(value:String):void
		{
			_useId3 = value;
		}
		
		public function get useId3():String
		{
			return _useId3;
		}
		
		public function get id3Title():String
		{
			return _id3Title;
		}
		
		public function get id3Author():String
		{
			return _id3Author;
		}
		
		public function get id3Album():String
		{
			return _id3Album;
		}
		
		public function get id3Year():String
		{
			return _id3Year;
		}
		
		public function get id3Copyright():String
		{
			return _id3Copyright
		}
		
		public function get id3Comment():String
		{
			return _id3Comment;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		//update timer
		public function get time():String
		{
			return _timerFormated;
		}
	
		

		
		private function soundLoaded(event:Event):void 
		{    
			sound.removeEventListener(Event.COMPLETE, soundLoaded);
			super.layoutUI();
		}
		
		private function soundComplete(event:Event):void
		{
			pause();
			cue = 0;
			if (_loop == 'on') play();
		}
		
		//graphic
		private function draw():void 
		{
			var origin:Number = height * .5;
			sound.extract(bytes, 2048, (channel.position*44.1));
			bytes.position = 0;
			
			g.clear();
			g.lineStyle(0, waveColor);
			g.beginFill(waveColor, 0.5);
			g.moveTo(0, origin);
			
			var i:int = 0;
			var cnt:int = 0;
			while(bytes.bytesAvailable > 0)
			{
				var average:Number = bytes.readFloat() + bytes.readFloat() * .5;
				if (cnt % 8 == 0) {
					g.lineTo(i*(width/255), average * height  * _volume * 2 + origin);
					g.lineTo(i*(width/255), origin);
					i++
				}	
				cnt++;
			}
			
			bytes.position = 0;
			g.endFill();		
		}	
		
		//id3 metadata method
		private function id3Handler(event:Event):void 
		{
			id3 = sound.id3;
			if (id3.songName) _id3Title = id3.songName;
			if (id3.artist) _id3Author = id3.artist;
			if (id3.album) _id3Album = id3.album;
			if (id3.year) _id3Year = id3.year;
			if (id3.TCOP) _id3Copyright = id3.TCOP;		
			if (id3.comment) _id3Comment = id3.comment;		
		}
		
		//timer methods
		private function updateDisplay(event:TimerEvent):void
		{
			var string:String=formatTime(channel.position);
			sendUpdate(string);
			
			if (display == "waveform") 		
				draw();
		}
		
		private function sendUpdate(string:String):void
		{
			_timerFormated = string;
			//dispatchEvent(new Event(Mp3Loader.TIME, true, true));
		}
		
		private function formatTime(t:int):String
		{
			var s:int=Math.round(t/1000);
			var m:int=0;
			if (s>0)
			{
				while (s > 59)
				{
					m++;
					s-=60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			}
			else return "00:00";
		}	
	}
}