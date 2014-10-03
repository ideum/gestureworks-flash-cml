package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.IAudio;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.utils.AudioFactory;
	import com.gestureworks.cml.utils.MP3FactoryNew;
	import com.gestureworks.cml.utils.Waveform;
	import com.gestureworks.cml.utils.WAVFactory;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	/**
	 * The Audio element loads and plays audio files and provides access to audio data. 
	 * <p>It support the following file types: .mp3 and .wav</p>
	 * @author Ideum
	 */
	public class Audio extends TouchContainer implements IStream, IAudio
	{		
		private var _src:String; 
		private var mp3:MP3FactoryNew;	
		private var wav:WAVFactory;
		private var audio:AudioFactory;
		
		private var _autoplay:Boolean;
		private var _loop:Boolean;
		private var _volume:Number = 1;
		private var _pan:Number = 0.0;
		
		private var waveForm:Waveform;
		private var bytes:ByteArray;
		private var displayTimer:Timer;
		
		//init function has been called
		private var initialized:Boolean;	
		
		/**
		 * Waveform visualization
		 * @default false
		 */
		public var waveform:Boolean;		
		
		/**
		 * Color of the waveform
		 * @default 0xFFFFFF
		 */
		public var waveColor:uint = 0xFFFFFF;
		
		/**
		 * Displays background graphic
		 * @default false
		 */
		public var background:Boolean;
		
		/**
		 * The background's alpha transparency
		 * @default 1
		 */
		public var backgroundAlpha:Number = 1;
		
		/**
		 * The background's color
		 * @default 0x333333
		 */
		public var backgroundColor:uint = 0x333333;
		
		/**
		 * Constructor
		 */
		public function Audio() {
			mouseChildren = true; 			
			mp3 = new MP3FactoryNew();
			wav = new WAVFactory();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			super.init();
			initialized = true; 
			setDisplay();
			processSrc(src);
		}
		
		/**
		 * Audio file path
		 */
		public function get src():String { return _src; }
		public function set src(value:String):void {
			if (value == _src) {
				return; 
			}			
			_src = value; 
			processSrc(_src);
		}
		
		/**
		 * Evaluate audio type and activate correct audio factory
		 * @param	value
		 */
		private function processSrc(value:String):void {
			if (!initialized) {
				return; 
			}
			
			//clear previous
			if (audio) {
				audio = null;
				mp3.close();
			}
			
			//abort process
			if (!value || !value.length) {
				return; 
			}
			
			//audio type evaluation
			var extension:String = value.split(".")[1].toLowerCase();
			switch(extension) {
				case "mp3":
					audio = mp3;
					break;
				case "wav":
					audio = wav; 
					break;
				default:
					throw Error("Unspported audio file: " + value);
			}			
			
			//sync settings and set src
			if(audio){
				syncStreamSettings();
				audio.statusCallback = onStatus;
				audio.src = value; 
			}
		}
		
		/**
		 * Apply media stream settings to current audio
		 */
		private function syncStreamSettings():void {
			autoplay = autoplay;
			loop = loop;
			volume = volume;
			pan = pan; 
		}
		
		/**
		 * @inheritDoc
		 */
		public function play():void {
			if(audio){
				audio.play();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function pause():void {
			if(audio){
				audio.pause();
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		public function resume():void {
			if(audio){
				audio.resume();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop():void {
			if(audio){
				audio.stop();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function seek(pos:Number):void {
			if(audio){
				audio.seek(pos);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void {
			_autoplay = value; 
			if(audio){
				audio.autoplay = value; 
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void {
			_loop = value; 
			if(audio){
				audio.loop = value; 
			}						
		}
		
		/**
		 * @inheritDoc
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			if(audio){
				audio.volume = value; 
			}									
		}
		
		/**
		 * @inheritDoc
		 */
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void {
			_pan = value; 
			if(audio){
				audio.pan = value; 
			}									
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isPlaying():Boolean { return audio ? audio.isPlaying : false; }		
		
		/**
		 * @inheritDoc
		 */
		public function get isPaused():Boolean { return audio ? audio.isPaused : false; }				
		
		/**
		 * @inheritDoc
		 */
		public function get isComplete():Boolean { return audio ? audio.isComplete : false; }
		
		/**
		 * @inheritDoc
		 */
		public function get position():Number { return audio ? audio.position : 0; }				
		
		/**
		 * @inheritDoc
		 */
		public function get duration():Number { return audio ? audio.duration : 0; }
		
		/**
		 * @inheritDoc
		 */
		public function get percentLoaded():Number { return audio ? audio.percentLoaded : 0; }
				
		/**
		 * @inheritDoc
		 */
		public function get metadata():* { return audio ? audio.metadata : null; }

		/**
		 * @inheritDoc
		 */		
		public function get title():String { return audio ? audio.title : null; }
		
		/**
		 * @inheritDoc
		 */		
		public function get artist():String { return audio ? audio.artist : null; }
		
		/**
		 * @inheritDoc
		 */		
		public function get album():String { return audio ? audio.album : null; }
		
		/**
		 * @inheritDoc
		 */		
		public function get date():String { return audio ? audio.date : null; }
		
		/**
		 * @inheritDoc
		 */		
		public function get publisher():String { return audio ? audio.publisher : null; }
		
		/**
		 * @inheritDoc
		 */		
		public function get comment():String { return audio ? audio.comment : null; }	
		
		/**
		 * @inheritDoc
		 */
		public function visualize(value:Waveform):void {
			if (value && audio) {
				audio.visualize(waveForm);
			}
		}
		
		/**
		 * Dispatch current status
		 */
		private function onStatus():void {
			var status:String = "isPlaying";
			var value:Boolean = isPlaying;
			
			if (isComplete) {
				status = "isComplete";
				value = isComplete;
			}
			else if (isPaused) {
				status = "isPaused";
				value = isPaused;
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, id, status, value));
			
			//update display timer based on play status
			if (displayTimer) {
				isPlaying ? displayTimer.start() : displayTimer.stop();
			}			
		}
		
		/**
		 * Setup audio visualization based on display settings
		 */
		private function setDisplay():void {
			
			//background graphic
			if (background) {
				graphics.beginFill(backgroundColor, backgroundAlpha);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
			}
			else {
				graphics.clear();
			}
			
			//waveform
			if (waveform) {
				waveForm = new Waveform();
				waveForm.waveColor = waveColor;
				waveForm.waveWidth = width;
				waveForm.waveHeight = height;				
				addChild(waveForm);
				bytes = new ByteArray();
			}
			else {
				waveForm = null;
			}
			
			displayTimer = new Timer(10);
			displayTimer.addEventListener(TimerEvent.TIMER, updateDisplay);
		}
		
		/**
		 * Update audio display
		 * @param	e
		 */
		private function updateDisplay(e:TimerEvent):void {
			visualize(waveForm);
		}
	}
}