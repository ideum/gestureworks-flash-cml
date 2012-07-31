//TODO: Incorporate StateEvents including: play, pause, stop, time 

package com.gestureworks.cml.element 
{	
	import com.gestureworks.cml.factories.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * 
	 */		
	public class MP3Element extends ElementFactory
	{
		// audio	
		private var sound:Sound;
		private var channel:SoundChannel;
		private var soundTrans:SoundTransform;
		private var playing:Boolean;		
		private var cue:uint;		
		private var loading:Boolean = false;
		
		// graphic
		private var sp:Sprite;
		private var g:Graphics;
		private var bgGraphic:Sprite;

		private var bytes:ByteArray;
		
		// update timer
		private var _timerFormated:String = "00:00";
		public static var TIME:String = "Time";
		public var timer:Timer;

		
		public function MP3Element()
		{
			super();
		}
		
		
		private var _backgroundColor:uint = 0x333333;
		/**
		 * Sets the background color
		 * @default 0x333333
		 */			
		public function get backgroundColor():uint {return _backgroundColor;}
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		
		private var _backgroundAlpha:Number = 1.0;
		/**
		 * Sets the background alpha
		 * @default 1.0
		 */			
		public function get backgroundAlpha():Number{ return _backgroundAlpha;}
		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
		}		
		
		
		private var _waveColor:uint = 0xFFFFFF;	
		/**
		 * Sets the color of the waveform
		 * @default 0xFFFFFF
		 */			
		public function get waveColor():uint{ return _waveColor;}
		public function set waveColor(value:uint):void
		{
			_waveColor = value;
		}
		
		
		private var _width:Number = 500;
		/**
		 * Sets the width in pixels
		 * @default 500
		 */			
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
	
		private var _height:Number = 300;
		/**
		 * Sets the height in pixels
		 * @default 300
		 */			
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}					
		
		
		[Deprecated(replacement="preload")] 
		private var _autoLoad:Boolean=true;
		public function get autoLoad():Boolean { return _preload; }
		public function set autoLoad(value:Boolean):void 
		{ 
			_preload = value;
		}
	
	
		private var _preload:Boolean = true;
		/**
		 * Indicates whether the mp3 file is preloaded by the cml parser
		 * @default true
		 */			
		public function get preload():Boolean { return _preload; }
		public function set preload(value:Boolean):void 
		{ 
			_preload = value;
		}
		
		
		private var _autoplay:Boolean = false;
		/**
		 * Indicates whether the mp3 file plays upon load
		 * @default true
		 */			
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}

			
		private var _loop:Boolean = false;
		/**
		 * Specifies wether the mp3 file will to loop to the beginning and continue playing upon completion
		 * @default false
		 */			
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }		
		
		
		private var _src:String;
		/**
		 * Sets the mp3 file path
		 * @default
		 */			
		public function get src():String{ return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;					
			_src = value;
		}		
		
	
		private var _volume:Number = 1;
		/**
		 * Sets the volume 
		 * @default 1
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
		 * Sets the audio pannning ( -1 = left, 0 = center, 1 = right )
		 * @default 0
		 */				
		public function get pan():Number {return _pan;}				
		public function set pan(value:Number):void
		{
			if (value < -1.0) _pan = -1.0; 
			else if (value > 1.0) _pan = 1.0;
			else _pan = value;
		}		
				
		
		private var _display:String = "waveform";
		/**
		 * Visualization display type, choose waveform or none
		 * @default waveform
		 */			
		public function get display():String {return _display;}				
		public function set display(value:String):void
		{
			_display = value;
		}	
		
		
		// read only // 
	
		private var _duration:Number = 0;
		/**
		 * Total duration
		 */			
		public function get duration():Number { return _duration; }
		
	
		private var _percentLoaded:Number = 0;
		/**
		 * Percent of file loaded 
		 */			
		public function get percentLoaded():Number { return _percentLoaded; }
		
	
		private var _position:Number = 0;
		/**
		 * Playhead position in ms
		 */			
		public function get position():Number { return _position; }
		
		
		private var _id3:ID3Info;
		/**
		 * ID3 info object
		 */
		public function get id3():ID3Info { return _id3; }
		
		
		private var _id3Title:String;
		/**
		 * ID3 title
		 */
		public function get id3Title():String{return _id3Title;}
		
		
		private var _id3Author:String;
		/**
		 * ID3 author
		 */
		public function get id3Author():String{return _id3Author;}
		
		
		private var _id3Album:String;
		/**
		 * ID3 album
		 */
		public function get id3Album():String{return _id3Album;}
		
		
		private var _id3Year:String;
		/**
		 * ID3 Year
		 */
		public function get id3Year():String{return _id3Year;}
		
		
		private var _id3Copyright:String;
		/**
		 * ID3 Copyright
		 */		
		public function get id3Copyright():String{return _id3Copyright}
		
		
		private var _id3Comment:String;
		/**
		 * ID3 Comment
		 */
		public function get id3Comment():String{return _id3Comment;}		

		
		// public methods // 
		
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
			if (_id3) {
				sound.removeEventListener(Event.ID3, id3Handler);
				_id3 = null;
			}
			if (sound) sound = null;
			if (bytes) bytes = null;
			if (sp) sp = null;
			if (parent) parent.removeChild(this);
		}
		
		/**
		 * CML initialization callback
		 */		
		override public function displayComplete():void
		{
			if (preload)
				load();
		}
		
		/**
		 * Sets the src property from the argument and loads the mp3 file
		 * @param file Full path and file name of mp3 file
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
		 * Plays from the beginning
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
		 * Resumes playback from paused position
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
		 * Pauses playback
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
		 * Pauses playback and returns to the beginning
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
		 * Sets the mp3 playhead position in milliseconds
		 * @param position Number in ms
		 */
		public function seek(position:Number):void
		{
			stop();
			cue = position;
			play();
		}
	
		
		// private methods //
		
		private function load():void
		{
			loading = true;;
			
			sound = new Sound();
			channel = new SoundChannel();
			soundTrans = new SoundTransform();
			sound.addEventListener(Event.COMPLETE, soundLoaded);
			
			if (display == "waveform") 
			{
				sp = new Sprite();
				bytes = new ByteArray();
			}
			
			//ID3 metadata
			sound.addEventListener(Event.ID3, id3Handler);
			
			//update timer
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			//audio
			sound.load(new URLRequest(_src));			
			soundTrans.volume = _volume;
			soundTrans.pan = _pan;
			playing = false;
			cue = 0;

			//graphic
			if (display == "waveform") 
			{
				bgGraphic = new Sprite;
				bgGraphic.graphics.beginFill(backgroundColor, backgroundAlpha);
				bgGraphic.graphics.drawRect(0, 0, _width, _height);
				bgGraphic.graphics.endFill();
				addChild(bgGraphic);
				
				g = sp.graphics;
				addChild(sp);
			}
			
			if (autoplay) play();
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
			var origin:Number = _height * .5;
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
					g.lineTo(i*(_width/255), average * _height  * _volume * 0.75 + origin);
					g.lineTo(i*(_width/255), origin);
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
			_id3 = sound.id3;
			if (_id3.songName) _id3Title = id3.songName;
			if (_id3.artist) _id3Author = id3.artist;
			if (_id3.album) _id3Album = id3.album;
			if (_id3.year) _id3Year = id3.year;
			if (_id3.TCOP) _id3Copyright = id3.TCOP;		
			if (_id3.comment) _id3Comment = id3.comment;		
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