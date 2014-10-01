package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.utils.DisplayUtils;
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
	public class Media extends TouchContainer implements IStream
	{			
		//supported media types
		private var _image:Image; 
		private var _video:Video;
		private var _audio:TouchContainer;
		
		//current media
		private var _current:TouchContainer; 
		
		//media source file
		private var _src:String; 
		
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
					
		//when dimensions are undefined, the <code>Media</code> wrapper inherits dimensions from current media element
		//when dimensions are defined, the media element dimensions are resized to the <code>Media</code> wrapper's
		private var sizeToContent:Boolean = true; 
		
		//initialized state
		private var initialized:Boolean;
		
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
			image.resample = true; 
			video = new Video();
			
			//access supported types from FileManager
			imageType = FileManager.imageType;
			videoType = FileManager.videoType;
			audioType = FileManager.audioType;		
		}

		/**
		 * @inheritDoc
		 */
		override public function init():void {	
			if (!initialized) {
				sizeToContent = !width && !height;
				initialized = true; 
				processSrc(src);
			}
			DisplayUtils.removeAllChildrenByType(this, [Image, Video]);			
			DisplayUtils.addChildren(this, [image, video]);			
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
				current.width = width;
				current.height = height;
				
				if (current == image) {
					image.resize();
				}
			}
		}
		
		/**
		 * Reference to current media element
		 */
		public function get current():TouchContainer { return _current; }
		
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
		 * Media file path
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
		 * Update current media with new media at provided source path
		 * @param	value
		 */
		private function processSrc(value:String):void {
			
			if (!initialized) {
				return; 
			}
			
			//clear previous
			if (_current) {				
				_current.visible = false; 
				_current = null;				
				image.close();
				video.close();
			}
			
			//abort process
			if (!value || !value.length) {
				return; 
			}
			
			//evaluate media type
			if (value.search(imageType) > -1) {
				_current = image; 	
				image.addEventListener(StateEvent.CHANGE, mediaLoaded);
				image.src = value; 
			}
			else if (value.search(videoType) > -1) {				
				_current = video; 				
				video.addEventListener(StateEvent.CHANGE, mediaLoaded);
				video.src = value; 				
			}
			else if (value.search(audioType) > -1) {
				
			}
			else {
				throw new Error("Unsupported media type: " + value);
			}
			
			//set stream flag
			_streamMedia = _current is IStream;								
			syncStreamSettings();	
		}
		
		/**
		 * Post load updates
		 * @param	e
		 */
		private function mediaLoaded(e:StateEvent):void {
			if (e.property == "isLoaded") {
				_current.removeEventListener(StateEvent.CHANGE, mediaLoaded);
				
				//sync current media and wrapper dimensions
				sizeMedia();	
				
				//execute media update callback
				if (mediaUpdate != null) {
					mediaUpdate.call();
				}
				
				//enable visibility of current media element
				_current.visible = true; 				
			}
		}
		
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
		override public function clone():* {

			cloneExclusions.push("mediaUpdate");
			var clone:Media = super.clone();
			clone.image = image.clone();
			clone.video = video.clone();
			clone.src = null;
			clone.src = src;
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