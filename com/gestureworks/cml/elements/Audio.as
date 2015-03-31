package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.base.media.AudioFactory;
	import com.gestureworks.cml.base.media.MediaBase;
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.base.media.MP3Factory;
	import com.gestureworks.cml.base.media.Waveform;
	import com.gestureworks.cml.interfaces.IAudio;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.TimeUtils;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;

	/**
	 * The Audio element loads and plays audio files and provides access to audio data. Note .wav support is
	 * exlusive to AIR runtime. 
	 * <p>It support the following file types: .mp3 and .wav</p>
	 * @author Ideum
	 */
	public class Audio extends MediaBase implements IStream, IAudio
	{		
		private var mp3:MP3Factory;	
		private var wav:AudioFactory;
		private var audio:AudioFactory;
		
		private var _autoplay:Boolean;
		private var _loop:Boolean;
		private var _volume:Number = 1;
		private var _mute:Boolean;
		private var _pan:Number = 0.0;
		private var _position:Number = 0;
		private var unmuteVolume:Number = 1; 
		private var _backgroundSrc:String;		
		
		private var waveForm:Waveform;
		private var displayTimer:Timer;
		
		private var isAIR:Boolean; 
		
		/**
		 * Waveform visualization
		 * @default true
		 */
		public var waveform:Boolean = true;		
		
		/**
		 * Color of the waveform
		 * @default 0xFFFFFF
		 */
		public var waveColor:uint = 0xFFFFFF;
		
		/**
		 * Displays background graphic
		 * @default true
		 */
		public var background:Boolean = true;
		
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
		 * Inserts a background image in place of the basic graphic generated through the @see #background flag
		 */
		public var backgroundImage:Bitmap;
		
		/**
		 * Constructor
		 */
		public function Audio() {			
			mp3 = new MP3Factory();
			isAIR = Capabilities.playerType == "Desktop";
			if (isAIR) {
				try{
					var sourceClass:Class = getDefinitionByName("com.gestureworks.cml.base.media.WAVFactory") as Class;
					wav = new sourceClass;
				}
				catch (e:Error) {}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			setDisplay(); //super init invoked after display				
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set dimensionsTo(value:Object):void {
			super.dimensionsTo = value;
			setDisplay();
		}
		
		/**
		 * Evaluate audio type and activate correct audio factory
		 * @param	value
		 */
		override protected function processSrc(value:String):void {
			if (!initialized) {
				return; 
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
					if (isAIR) {
						if (!wav) {
							throw Error("The following import statement is required to load AIR-exclusive classes: import com.gestureworks.cml.core.CMLAir; CMLAir;");
						}
						else{
							audio = wav; 
						}
					}
					else {
						throw Error(".wav support requires AIR");
					}
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
			seek(_position);
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
			_position = pos; 
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
		public function get isSeeking():Boolean { return audio ? audio.isSeeking : false; }
		
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
		public function get progress():Number { return audio ? audio.position / audio.duration : 0; }
		
		/**
		 * @inheritDoc
		 */
		public function get elapsedTime():String { return audio ? TimeUtils.msToMinSec(audio.position) : "00:00"; }

		/**
		 * @inheritDoc
		 */
		public function get totalTime():String { return audio ? TimeUtils.msToMinSec(audio.duration) : "00:00"; }		
		
		/**
		 * @inheritDoc
		 */
		override public function get isLoaded():Boolean { return audio ? audio.isLoaded : false; }
		
		/**
		 * @inheritDoc
		 */
		override public function get percentLoaded():Number { return audio ? audio.percentLoaded : 0; }			
				
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
		 * @inheritDoc
		 */
		override protected function onStatus(status:String, value:*):void {
			if (status == MediaStatus.LOADED && value) {
				updateThumbnail();
			}			
			super.onStatus(status, value);
			//update display timer based on play status
			if (displayTimer) {
				isPlaying ? displayTimer.start() : displayTimer.stop();
			}									
		}
				
		/**
		 * Sepcifies an external image file to use as the background display; resulting Bitmap is assigned to @see #backgroundImage 
		 */	
		public function get backgroundSrc():String { return _backgroundSrc; }
		public function set backgroundSrc(value:String):void {
			
			if (value == _backgroundSrc) {
				return; 
			}
			
			_backgroundSrc = value; 
			
			//preloaded
			if (FileManager.media.getContent(_backgroundSrc)) {
				backgroundImage = FileManager.media.getLoader(_backgroundSrc).rawContent; 
			} 
			//load file
			else {
				var img:ImageLoader = new ImageLoader(_backgroundSrc);
				img.addEventListener(LoaderEvent.COMPLETE, function(e:LoaderEvent):void {
					backgroundImage = e.target.rawContent;
					setDisplay();
				});
				img.load();
			}				
		}
		
		/**
		 * Setup audio visualization based on display settings
		 */
		private function setDisplay():void {
			
			//default dimensions
			if (!width && !height) {
				width = 500;
				height = 250; 
			}
			
			//postpone for background image load
			if (backgroundSrc && !backgroundImage) {
				return; 
			}
						
			//dimension resolution
			if (backgroundImage) {				
				
				//background dimensions to audio
				backgroundImage = DisplayUtils.resampledBitmap(backgroundImage, width, height);
				
				//add background
				backgroundImage.alpha = backgroundAlpha;
				addChild(backgroundImage);
			}	
			//background graphic
			else if (background) {
				graphics.clear();
				graphics.beginFill(backgroundColor, backgroundAlpha);
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
			}
			else {
				graphics.clear();
			}
			
			//clear waveform
			if (waveForm) {
				removeChild(waveForm);
				waveForm = null;
			}
			
			//waveform
			if (waveform) {
				waveForm = new Waveform();
				waveForm.waveColor = waveColor;
				waveForm.waveWidth = width;
				waveForm.waveHeight = height;	
				addChild(waveForm);
			}
			else {
				waveForm = null;
			}
			
			//initialize display timer
			if(waveform || playbackProgress){
				displayTimer = new Timer(5);
				displayTimer.addEventListener(TimerEvent.TIMER, update);
			}
			else if (displayTimer) {
				displayTimer.stop();
				displayTimer.removeEventListener(TimerEvent.TIMER, update);								
				displayTimer = null;
			}
			
			//initialize audio
			super.init();
		}		
		
		/**
		 * Update audio display and/or publish progess
		 * @param	e
		 */
		private function update(e:TimerEvent):void {
			onStatus(MediaStatus.PLAYBACK_PROGRESS, progress);
			visualize(waveForm);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			if (!initialized) {
				return; 
			}
			
			super.close();				
			audio = null;
			mp3.close();
			if (wav) {
				wav.close();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {
			
			//pre clone state
			removeChild(waveForm);			
			var tmp:Boolean = resetDimensions;
			resetDimensions = false; 
			
			//clone
			var c:Audio = super.clone();
			
			//restore state
			addChild(waveForm);
			resetDimensions = tmp; 
			
			return c;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();						
			mp3.dispose();
			mp3 = null;
			wav.dispose();
			wav = null;
			audio = null;
			waveForm = null;
			if (displayTimer) {
				displayTimer.stop();
				displayTimer = null;
			}
		}
	}
}