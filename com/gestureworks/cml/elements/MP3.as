package com.gestureworks.cml.elements 
{	
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * The MP3 element loads an .MP3 file and plays it, with the options to pause, stop, seek, and resume play. The Mp3 element will automatically load any id3 data
	 * if it is present. The MP3 element also provides the option of a displaying graphical waveform by setting the display property to "waveform", otherwise 
	 * "none". The waveform's color can also be set.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	    var mp3Element:MP3 = new MP3();
		mp3Element.src = "RuthCalledShot_vbr.mp3";
		mp3Element.display = "waveform";
		mp3Element.backgroundAlpha = 0.5;
		mp3Element.backgroundColor = 0x333333;
		mp3Element.waveColor = 0x558855;
		mp3Element.volume = 1.0;
		mp3Element.pan = 0;
		mp3Element.loop = true;
		mp3Element.autoplay = true;
		addChild(mp3Element);		
		mp3Element.init();
	 *
	 * </codeblock>
	 */		
	public class MP3 extends TouchContainer
	{
		private var _mp3:MP3Factory = new MP3Factory();
		/**
		 * Exposes read-only access for the mp3 factory element.
		 */
		public function get mp3():MP3Factory { return _mp3; }
		
		// audio	
		//private var sound:Sound;
		//private var channel:SoundChannel;
		//private var soundTrans:SoundTransform;
		//private var Position:uint;		
		private var loading:Boolean = false;
		private var waveForm:Waveform;
		
		// graphics
		private var bgGraphic:Sprite;

		private var bytes:ByteArray;
		
		// update timer
		private var _timerFormated:String = "00:00";
		public static var TIME:String = "Time";
		public var timer:Timer;

		/**
		 * Constructor
		 */
		public function MP3()
		{
			super();
			mouseChildren = true;
			width = 400
			height = 200;
		}
		
		private var _src:String;
		/**
		 * Sets the source of the mp3.
		 */
		public function get src():String { return _src; }
		public function set src(value:String):void {
			_src = value;
			_mp3.src = _src;
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
		
		private var _display:String = "waveform";
		/**
		 * Visualization display type, can be set to "waveform", "none", or an image URL.
		 * @default waveform
		 */			
		public function get display():String {return _display;}				
		public function set display(value:String):void
		{
			_display = value;
		}	
		
		public function get isPlaying():Boolean { return _mp3.isPlaying; }
		
		
		private var _autoplay:Boolean = false;
		/**
		 * Indicates whether the mp3 file plays upon load
		 */	
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
			_mp3.autoplay = _autoplay;
		}

		private var _loop:Boolean = false;
		/**
		 * Mp3 loop play
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void 
		{ 
			_loop = value;
			_mp3.loop = _loop; 
		}
		
		private var _volume:Number = 1;
		/**
		 * Sets the volume
		 */	
		public function get volume():Number {return _volume;}		
		public function set volume(value:Number):void
		{
			_volume = value;
			_mp3.volume = _volume;
		}
		
		private var _pan:Number = 0;
		/**
		 * Sets the pan
		 */	
		public function get pan():Number {return _pan;}				
		public function set pan(value:Number):void
		{
			_pan = value;
			_mp3.pan = _pan;
		}
		
//} endregion
		

//{ region ID3 properties
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
		public function get id3Comment():String { return _id3Comment; }	
		 
//} endregion
		
		// public methods // 
		
		/**
		 * @inheritDoc
		 */				
		override public function dispose():void
		{
			super.dispose();			
			bgGraphic = null;						
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, updateDisplay);
				timer = null;
			}			
			if (_mp3) {
				_mp3.addEventListener(Event.ID3, id3Handler);
				_mp3.addEventListener(StateEvent.CHANGE, playbackHandler);				
				_mp3 = null;
			}
			_id3 = null;
			bytes = null;
			waveForm = null;
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{			
			super.init();
			load();
		}

		/**
		 * Closes mp3 
		 */	
		public function open(file:String=null):void 
		{
			if (file) 
				src = file;
			if (src)
				_mp3.open(src);
		}			
		
		/**
		 * Closes mp3 
		 */	
		public function close():void 
		{
			_mp3.close();
			timer.stop();
		}		
		
		/**
		 * Plays from the beginning
		 */		
		public function play():void
		{
			_mp3.play();
			
			//if (isPlaying) 
			//{	
				//timer.start();
				//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
			//}
		
		}
				
		/**
		 * Resumes playback from paused position
		 */			
		public function resume():void
		{
			_mp3.resume();
			
			//if (isPlaying) 
			//{				
				//timer.start();
				//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
			//}
		}
		
		/**
		 * Pauses playback
		 */			
		public function pause():void
		{
			_mp3.pause();
			
			//timer.stop();
			//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
		}
		
		/**
		 * Pauses playback and returns to the beginning
		 */			
		public function stop():void
		{
			_mp3.stop();
			
			//timer.stop();
			//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
		}
		
		public function seek(pos:Number):void
		{
			_mp3.seek(pos);
			//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "Position" , Position));
		}
		
		// private methods //
		
		protected function load():void
		{	
			loading = true;
			
			if (display == "waveform") 
			{
				bgGraphic = new Sprite;
				bgGraphic.graphics.beginFill(backgroundColor, backgroundAlpha);
				bgGraphic.graphics.drawRect(0, 0, width, height);
				bgGraphic.graphics.endFill();
				addChild(bgGraphic);
				
				waveForm = new Waveform();
				waveForm.waveColor = _waveColor;
				waveForm.waveWidth = width;
				waveForm.waveHeight = height;
				addChild(waveForm);
				bytes = new ByteArray();
			}
			else if (display && display != "none") {
				var image:Image = new Image();
				image.src = display;
				if(width){
					image.width = this.width;
				}
				if (height){
					image.height = this.height
				}
				image.addEventListener(Event.COMPLETE, imageComplete);
				image.open(image.src);
				
				function imageComplete(e:Event):void {
					image.removeEventListener(Event.COMPLETE, imageComplete);
					addChild(image);
					if (!width) {
						width = image.width;
					}
					if (!height) {
						height = image.height;
					}
				}
			}
			
			//update timer
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			//ID3 metadata
			_mp3.addEventListener(Event.ID3, id3Handler);
			
			_mp3.addEventListener(StateEvent.CHANGE, playbackHandler);
			
			_mp3.init();
		}		
		
		private function playbackHandler(e:StateEvent):void {
			switch(e.property) {
				case "isPlaying":
					if (isPlaying)
						timer.start();
					else
						timer.stop();
					break;
					
				case "Position":
					// Do something about position?
					break;
			}
		}
	
		//update timer
		public function get time():String
		{
			return _timerFormated;
		}
		
		private function soundComplete(event:Event):void
		{
			timer.stop();
			//super.soundComplete(event);
		}
		
		//graphic
		private function draw():void 
		{
			var origin:Number = height * .5;
			_mp3.soundData.extract(bytes, 2048, (_mp3.channel.position*44.1));
			bytes.position = 0;
			
			var i:int = 0;
			var cnt:int = 0;
			while(bytes.bytesAvailable > 0)
			{
				var average:Number = bytes.readFloat() + bytes.readFloat() * .5;
				
				if (cnt % 8 == 0) {
					waveForm.averageGain[cnt] = average;
					waveForm.draw();
				}	
				cnt++;
			}
			
			bytes.position = 0;
		}	
		
		//id3 metadata method
		private function id3Handler(event:Event):void 
		{
			_id3 = _mp3.soundData.id3;
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
			var string:String=formatTime(_mp3.channel.position);
			sendUpdate(string);
			
			var timePos:Number = _mp3.channel.position / 1000;
			timePos = timePos / (_mp3.soundData.length / 1000);
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", timePos));
			
			if (display == "waveform") 		
				draw();
		}
		
		private function sendUpdate(string:String):void
		{
			_timerFormated = string;
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