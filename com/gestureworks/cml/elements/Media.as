package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.base.media.MediaBase;
	import com.gestureworks.cml.base.media.MediaStatus;
	import flash.events.*;
	import flash.utils.*;
	 
	/** 
	 * The Media class is a wrapper for image, video, and audio elements. It auto-selects the correct media element based on the input
	 * file extension. It suppports the following file extensions: png, gif, jpg, mpeg-4, mp4, m4v, 3gpp, mov, flv, f4v, mp3, and wav.
	 * 
	 * @author Ideum
	 * @see Image
	 * @see Video
	 * @see MP3
	 * @see WAV
	 */	 
	public class Media extends MediaBase implements IStream
	{			
		//supported media types
		private var _image:Image; 
		private var _video:Video;
		private var _audio:Audio;
		
		//current media
		private var _current:MediaBase; 
		
		//supported media types
		private var imageType:RegExp;
		private var videoType:RegExp;
		private var audioType:RegExp;
		
		//current media implments IStream
		private var _streamMedia:Boolean;
		
		//stream operations
		private var _autoplay:Boolean;
		private var _loop:Boolean;
		private var _volume:Number;
		private var _pan:Number;
		private var _mute:Boolean;								
					
		//when dimensions are undefined, the <code>Media</code> wrapper inherits dimensions from current media element
		//when dimensions are defined, the media element dimensions are resized to the <code>Media</code> wrapper's
		private var sizeToContent:Boolean = true; 		
		
		/**
		 * Callback excuted when media has been updated
		 */
		public var mediaUpdate:Function;
		
		/**
		 * Constructor
		 */
		public function Media(){
			super();
			
			image = new Image();
			video = new Video();			
			audio = new Audio();
			
			//access supported types from FileManager
			imageType = FileManager.imageType;
			videoType = FileManager.videoType;
			audioType = FileManager.audioType;		
		}

		/**
		 * @inheritDoc
		 */
		override public function init():void {	
			
			//only allow internally constructed media objects
			DisplayUtils.removeAllChildrenByType(this, [Image, Video, Audio]);			
			DisplayUtils.addChildren(this, [image, video, audio]);	
						
			sizeToContent = !width && !height;
				
			//initialized media
			if (!initialized) {
				image.init();
				video.init();
				audio.init();
			}
			
			syncThumbSettings();
			super.init();		
		}
		
		/**
		 * Sync current media element and wrapper dimensions
		 */
		private function sizeMedia():void {
			if (!current) {
				return; 
			}

			//inherit dimensions from current media element
			if (sizeToContent) {
				width = current.width;
				height = current.height;
			}
			//apply dimensions to current media element
			else{				
				if (current == image) {
					image.resize(width, height);
				}
				else if (current == video) {
					video.resize(width, height);
				}
				else{
					audio.dimensionsTo = this; 			
				}
			}
		}
		
		/**
		 * Reference to current media element
		 */
		public function get current():MediaBase { return _current; }
		
		/**
		 * Image element
		 */
		public function get image():* { return _image; }
		public function set image(value:*):void {
			if (value is XML) {
				value = getElementById(value);
			}
			if (value is Image) {
				_image = value;
				_image.visible = false; 
			}
		}		
		
		/**
		 * Video element
		 */
		public function get video():* { return _video; }
		public function set video(value:*):void {
			if (value is XML) {
				value = getElementById(value);
			}
			if (value is Video) {
				_video = value; 
				_video.visible = false; 				
			}
		}	
		
		/**
		 * Audio element
		 */
		public function get audio():* { return _audio; }
		public function set audio(value:*):void {
			if (value is XML) {
				value = getElementById(value);
			}
			if (value is Audio) {
				_audio = value;
				_audio.visible = false; 
			}
		}
			
		/**
		 * Update current media with new media at provided source path
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
			
			//unsubscribe to previous media events
			if (_current) {
				_current.removeEventListener(StateEvent.CHANGE, mediaStatus);				
			}
			
			//evaluate media type
			if (value.search(imageType) > -1) {
				_current = image; 					
				image.addEventListener(StateEvent.CHANGE, mediaStatus);
				image.src = value; 
			}
			else if (value.search(videoType) > -1) {				
				_current = video; 											
				video.addEventListener(StateEvent.CHANGE, mediaStatus);
				video.src = value; 				
			}
			else if (value.search(audioType) > -1) {
				_current = audio;
				audio.addEventListener(StateEvent.CHANGE, mediaStatus);
				audio.src = value; 
			}
			else {
				throw new Error("Unsupported media type: " + value);
			}	
			
			//set stream flag
			_streamMedia = _current is IStream;								
			syncStreamSettings();	
		}
		
		/**
		 * Relay media status
		 * @param	e
		 */
		private function mediaStatus(e:StateEvent):void {			
			if (e.property == MediaStatus.LOADED && e.value) {
				
				//sync current media and wrapper dimensions
				sizeMedia();	
				
				//execute media update callback
				if (mediaUpdate != null) {
					mediaUpdate.call();
				}
				
				//enable visibility of current media element
				_current.visible = true; 
				
				loadComplete();
			}
			else if (e.property == MediaStatus.THUMB_LOADED) {
				if (thumbSrc || thumbnail || !e.value) {
					return; 
				}
				thumbnail = current.thumbnail; 
				onStatus(e.property, e.value);
			}
			else{
				onStatus(e.property, e.value);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function generateThumb():void {} //defer to curent media function
		
		/**
		 * Flag indicating the current media supports stream operations
		 */
		public function get streamMedia():Boolean { return _streamMedia; }
		
		/**
		 * Apply media stream settings to stream media types
		 */
		private function syncStreamSettings():void {
			var sMedia:Array = DisplayUtils.getAllChildrenByType(this, IStream);
			for each(var m:IStream in sMedia) {
				m.autoplay = autoplay;
				m.loop = loop;
				m.volume = isNaN(volume) ? 1: volume;
				m.pan = isNaN(pan) ? 0 : pan;
			}
		}
		
		/**
		 * Propagate thumb settings to child media elements
		 */
		private function syncThumbSettings():void {
			image.preview = video.preview = audio.preview = preview;
			image.thumbWidth = video.thumbWidth = audio.thumbWidth = thumbWidth;
			image.thumbHeight = video.thumbHeight = audio.thumbHeight = thumbHeight;
		}
		
		/**
		 * @inheritDoc
		 */
		public function play():void {
			if (streamMedia) {
				IStream(current).play();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function pause():void {
			if (streamMedia) {
				IStream(current).pause();
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function resume():void {
			if (streamMedia) {
				IStream(current).resume();
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop():void {
			if (streamMedia) {
				IStream(current).stop();
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function seek(pos:Number):void {
			if (streamMedia) {
				IStream(current).seek(pos);
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void {
			_autoplay = value;
			if (streamMedia) {
				IStream(current).autoplay = _autoplay;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void {
			_loop = value; 
			if (streamMedia) {
				IStream(current).loop = _loop;
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value; 
			if (streamMedia) {
				IStream(current).volume = _volume;
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mute():Boolean { return _mute; }
		public function set mute(value:Boolean):void {
			_mute = value;
			if (streamMedia) {
				IStream(current).mute = _mute; 
			}
		}			
		
		/**
		 * @inheritDoc
		 */
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void {
			_pan = value; 
			if (streamMedia) {
				IStream(current).pan = _pan;
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isPlaying():Boolean { return streamMedia ? IStream(current).isPlaying : false; }	
		
		/**
		 * @inheritDoc
		 */
		public function get isSeeking():Boolean { return streamMedia ? IStream(current).isSeeking : false; }
		
		/**
		 * @inheritDoc
		 */
		public function get isPaused():Boolean { return streamMedia ? IStream(current).isPaused : false; }			
		
		/**
		 * @inheritDoc
		 */
		public function get isComplete():Boolean { return streamMedia ? IStream(current).isComplete : false; }
		
		/**
		 * @inheritDoc
		 */
		public function get position():Number { return streamMedia ? IStream(current).position : 0; }
		
		/**
		 * @inheritDoc
		 */
		public function get duration():Number { return streamMedia ? IStream(current).duration : 0; }
		
		/**
		 * @inheritDoc
		 */
		public function get progress():Number { return streamMedia ? IStream(current).progress : 0; }
		
		/**
		 * @inheritDoc
		 */
		public function get elapsedTime():String { return streamMedia ? IStream(current).elapsedTime : "00:00"; }
		
		/**
		 * @inheritDoc
		 */
		public function get totalTime():String { return streamMedia ? IStream(current).totalTime : "00:00"; }
		
		/**
		 * @inheritDoc
		 */
		override public function get isLoaded():Boolean { return current ? current.isLoaded : false; }		
		
		/**
		 * @inheritDoc
		 */
		override public function get percentLoaded():Number { return current ? current.percentLoaded : 0; }
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			if (!initialized) {
				return; 
			}
			
			super.close();
			sizeToContent = !width && !height;			
			if (_current) {				
				_current.visible = false; 
				_current = null;				
				image.close();
				video.close();
				audio.close();
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {

			cloneExclusions.push("mediaUpdate");
			var clone:Media = super.clone();
			clone.image = image.clone();
			clone.video = video.clone();
			clone.audio = audio.clone();
			clone.src = null;
			clone.src = src;
			clone.width = sizeToContent ? 0 : clone.width;
			clone.height = sizeToContent ? 0 : clone.height;
			clone.init();
			
			src = null;
			src = clone.src; 
			init();
			
			return clone;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {			
			super.dispose();			
			_image = null;
			_video = null;
			_audio = null;			
			_current = null;
			imageType = null;
			videoType = null;
			audioType = null;			
		}
	}
}