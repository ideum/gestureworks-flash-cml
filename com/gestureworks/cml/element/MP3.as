package com.gestureworks.cml.element 
{	
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.Waveform;
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
		mp3Element.preload = true;
		mp3Element.autoplay = true;
		addChild(mp3Element);		
		mp3Element.init();
	 *
	 * </codeblock>
	 */		
	public class MP3 extends MP3Factory
	{
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
		
		/*override public function set preload(value:Boolean):void {
			if (value)
			super.preload = value;
			//load();
		}*/
		
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
		 * Disposal method
		 */				
		override public function dispose():void
		{
			super.dispose();
			
			while (numChildren > 0) {
				removeChildAt(0);
			}
			
			if (bgGraphic)
				bgGraphic = null;
						
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, updateDisplay);
				timer = null;
			}
			
			if (_id3) {
				sound.removeEventListener(Event.ID3, id3Handler);
				_id3 = null;
			}
			if (bytes) bytes = null;
		}
		
		/**
		 * CML initialization callback
		 */		
		override public function displayComplete():void
		{
			//if (preload)
				//load();
				init();
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			super.init();
			//load();
		}

		/**
		 * Closes mp3 
		 */	
		override public function close():void 
		{
			super.close();
			timer.stop();
		}		
		
		/**
		 * Plays from the beginning
		 */		
		override public function play():void
		{
			super.play();
			
			if (isPlaying) 
			{	
				timer.start();
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
			}
		
		}
				
		/**
		 * Resumes playback from paused position
		 */			
		override public function resume():void
		{
			super.resume();
			
			if (isPlaying) 
			{				
				timer.start();
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
			}
		}
		
		/**
		 * Pauses playback
		 */			
		override public function pause():void
		{
			super.pause();
			
			timer.stop();
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
		}
		
		/**
		 * Pauses playback and returns to the beginning
		 */			
		override public function stop():void
		{
			super.stop();
			
			timer.stop();
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", isPlaying));
		}
		
		override public function seek(pos:Number):void
		{
			super.seek(pos);
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "Position" , Position));
		}
		
		// private methods //
		
		override protected function load():void
		{	
			loading = true;;
			
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
			
			//ID3 metadata
			//sound.addEventListener(Event.ID3, id3Handler);
			
			//update timer
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, updateDisplay);
			
			super.load();
			
			//ID3 metadata
			sound.addEventListener(Event.ID3, id3Handler);
		}		
		
	
		//update timer
		public function get time():String
		{
			return _timerFormated;
		}
	
		
		private function soundLoaded(event:Event):void 
		{    
			sound.removeEventListener(Event.COMPLETE, soundLoaded);
		}
		
		override protected function soundComplete(event:Event):void
		{
			timer.stop();
			super.soundComplete(event);
		}
		
		//graphic
		private function draw():void 
		{
			var origin:Number = height * .5;
			sound.extract(bytes, 2048, (channel.position*44.1));
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
			
			var timePos:Number = channel.position / 1000;
			timePos = timePos / (sound.length / 1000);
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