// phasing out the Element suffix for more uniform framework, less typing, and cleaner cml
// use frame instead
// -charles veasey, 7/29/11

package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	import flash.utils.*;
	 
	/** 
	 * The Media class is a wrapper for media elements including the ImageElement, VideoElement, and the MP3Element.
	 * It auto-selects the correct media element based on the input file extension. It suppports the following file extensions: 
	 * png, gif, jpg, mpeg-4, mp4, m4v, 3gpp, mov, flv, f4v, and mp3.
	 * 
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * @langversion 3.0
	 *
	 * @includeExample MediaElementExample.as -noswf
	 *
	 * @see com.gestureworks.cml.factories.ElementFactory
	 * @see com.gestureworks.cml.factories.ObjectFactory
	 */	 
	public class MediaElement extends ElementFactory
	{
		private var imageTypes:RegExp;
		private var videoTypes:RegExp;
		private var mp3Types:RegExp;
		private var dictionary:Dictionary;
		private var currentFile:String;
		
		public function MediaElement()
		{
			super();
			dictionary = new Dictionary(true);
			imageTypes = /^.*\.(png|gif|jpg)$/i;  
			videoTypes = /^.*\.(mpeg-4|mp4|m4v|3gpp|mov|flv|f4v)$/i;			
			mp3Types = /^.*\.(mp3)$/i;			
		}


		private var _width:Number=0;
		/**
		 * Sets media width
		 * @default 0
		 */				
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}		
		
	
		private var _height:Number=0;
		/**
		 * Sets media height
		 * @default 0
		 */			
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}		
		
	
		private var _autoplay:Boolean=false;
		/**
		 * Indicates whether the file plays upon load
		 * @default false
		 */			
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
			
			if (dictionary[currentFile])
			{
				dictionary[currentFile].autoplay = value;
				if (value && dictionary[currentFile].hasOwnProperty("play"))
					dictionary[currentFile].play();
			}
		}
		
			
		private var _loop:Boolean=false;
		/**
		 * Indicates whether the media will re-play when it has reached the end
		 * @default false
		 */			
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void 
		{ 
			_loop = value;
			if (dictionary[_src])
			{	
				if (dictionary[_src].hasOwnProperty("loop"))
					dictionary[_src].loop = loop;
			}
		}				
		
	
		private var _src:String;
		/**
		 * Sets the media file source
		 * @default null
		 */			
		public function get src():String {return _src;}
		public function set src(value:String):void
		{
			if (_src != value)
				_src = value;
		}		

		
		private var _current:*;
		/**
		 * Returns a reference to the current media object
		 * @default null
		 */			
		public function get current():String {return dictionary[currentFile];}

		
		private var _resample:Boolean = false;
		/**
		 * Specifies whether a loaded image is resampled to the provided width and/or height.
		 * In order for resampling to work, this must be set to true, and a width and/or height 
		 * must be set prior to calling open.
		 * @default false
		 */
		public function get resample():Boolean{return _resample;}
		public function set resample(value:Boolean):void
		{
			_resample = value;
		}		
			
		
		

		////////////////////////////////////////////////////////////////////////////////
		// Public Methods
		////////////////////////////////////////////////////////////////////////////////		
	
		
		/**
		 * Opens the file specified in the argument
		 * @Param file path
		 */		
		public function open(file:String):void 
		{
			if (file.search(imageTypes) >= 0)
 			{
				dictionary[file] = new ImageElement;
				dictionary[file].addEventListener(Event.COMPLETE, onComplete);				
			}	
			else if (file.search(videoTypes) >= 0)
			{	
				dictionary[file] = new VideoElement;
				dictionary[file].addEventListener(Event.COMPLETE, onComplete);				
			}
			else if (file.search(mp3Types) >= 0)
			{	
				dictionary[file] = new MP3Element;
				dictionary[file].addEventListener(Event.COMPLETE, onComplete);				
			}
			else
				throw new Error("Media type is not supported: " + file);
			
			if (dictionary[file].hasOwnProperty("width") && _width != 0)		dictionary[file].width = _width;
			if (dictionary[file].hasOwnProperty("height") && _height != 0)	dictionary[file].height = _height;
			if (dictionary[file].hasOwnProperty("loop"))					dictionary[file].loop = loop;
			if (dictionary[file].hasOwnProperty("autoplay"))				dictionary[file].autoplay = autoplay;
			if (dictionary[file].hasOwnProperty("open"))					dictionary[file].open(file);						
			
			addChild(dictionary[file]);			
			currentFile = file;	
		}
		
		
		private function onComplete(event:Event):void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/**
		 * Closes the currently open media file
		 */	
		public function close():void 
		{
			if (dictionary[currentFile])
			{
				if (dictionary[currentFile].hasOwnProperty("close"))				
					dictionary[currentFile].close();
				if (this.contains(dictionary[currentFile]))
					removeChild(dictionary[currentFile]);
				dictionary[currentFile] = null;
				delete dictionary[currentFile];
				currentFile = null;
			}
		}
		
		
		/**
		 * Plays the media file from the beginning
		 */		
		public function play():void
		{
			if (dictionary[currentFile].hasOwnProperty("play"))
				dictionary[currentFile].play();			
		}
		
		
		/**
		 * Resumes media playback from paused position
		 */			
		public function resume():void
		{
			if (dictionary[currentFile].hasOwnProperty("resume"))
				dictionary[currentFile].resume();
		}
		
		
		/**
		 * Pauses media playback
		 */			
		public function pause():void
		{
			if (dictionary[currentFile].hasOwnProperty("pause"))
				dictionary[currentFile].pause();
		}
		
		
		/**
		 * Pauses the media file and returns to the playhead to the beginning
		 */			
		public function stop():void
		{
			if (dictionary[currentFile].hasOwnProperty("stop"))
				dictionary[currentFile].stop();
		}
		
		
		/**
		 * Sets the media playhead position
		 * @param offset
		 */
		public function seek(offset:Number):void
		{
			if (dictionary[currentFile].hasOwnProperty("seek"))
				dictionary[currentFile].seek(offset);
		}
		
		
		/**
		 * This is called by the CML parser. Do not override this method.
		 */		
		override public function postparseCML(cml:XMLList):void 
		{
			if (this.propertyStates[0]["src"])
				open(this.propertyStates[0]["src"]);
		}		
		
	}
}