package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	import flash.utils.*;
	 
	/** 
	 * The MediaElement class is a wrapper for media elements including the ImageElement, VideoElement, and the MP3Element.
	 * It auto-selects the correct media element based on the input file extension. It suppports the following file extensions: 
	 * png, gif, jpg, mpeg-4, mp4, m4v, 3gpp, mov, flv, f4v, and mp3.
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 * @includeExample MediaElementExample.as -noswf
	 *
	 * @see ElementFactory
	 * @see ObjectFactory
	 */	 
	public class MediaElement extends ElementFactory
	{
		private var imageTypes:RegExp;
		private var videoTypes:RegExp;
		private var mp3Types:RegExp;
		private var dictionary:Dictionary;
		private var current:String;
		
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
		 * Media width
		 */				
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}		
		
	
		private var _height:Number=0;
		/**
		 * Media height
		 */			
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}		
		
	
		private var _autoPlay:Boolean=false;
		/**
		 * Indicates whether the file plays upon load
		 */			
		public function get autoPlay():Boolean { return _autoPlay; }
		public function set autoPlay(value:Boolean):void 
		{	
			_autoPlay = value;
		}
		
			
		private var _loop:Boolean;
		/**
		 * Media loop play
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
		 * Media file source
		 */			
		public function get src():String {return _src;}
		public function set src(value:String):void
		{
			if (_src != value)
			{
				_src = value;
				open(_src);				
			}
		}		

				
		/**
		 * Open File
		 * @Param file path
		 */		
		public function open(file:String=src):void 
		{	
			if (file.search(imageTypes) >= 0)
 			{
				dictionary[file] = new ImageElement;
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
			
			if (dictionary[file].hasOwnProperty("width"))
				dictionary[file].width = width;
			if (dictionary[file].hasOwnProperty("height"))
				dictionary[file].height = height;
			if (dictionary[file].hasOwnProperty("loop"))
				dictionary[file].loop = loop;
			if (dictionary[file].hasOwnProperty("autoPlay"))
				dictionary[file].autoPlay = autoPlay;
			if (dictionary[file].hasOwnProperty("src"))
				dictionary[file].src = file;						
			
			addChild(dictionary[file]);			
			current=file;			
		}
		
		
		private function onComplete(event:Event):void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/**
		 * Closes file
		 */	
		public function close():void 
		{
			if (dictionary[current])
			{
				if (dictionary[current].hasOwnProperty("close"))				
					dictionary[current].close();
				if (this.contains(dictionary[current]))
					removeChild(dictionary[current]);
				dictionary[current] = null;
				delete dictionary[current];
			}
		}
		
		/**
		 * Plays from the beginning
		 */		
		public function play():void
		{
			if (dictionary[current].hasOwnProperty("play"))
				dictionary[current].play();			
		}
		
		/**
		 * Resumes playback from paused position
		 */			
		public function resume():void
		{
			if (dictionary[current].hasOwnProperty("resume"))
				dictionary[current].resume();
		}
		
		/**
		 * Pauses 
		 */			
		public function pause():void
		{
			if (dictionary[current].hasOwnProperty("pause"))
				dictionary[current].pause();
		}
		
		/**
		 * Pauses and returns to the beginning
		 */			
		public function stop():void
		{
			if (dictionary[current].hasOwnProperty("stop"))
				dictionary[current].stop();
		}
		
		
		/**
		 * Sets the playhead position
		 * @param offset
		 */
		public function seek(offset:Number):void
		{
			if (dictionary[current].hasOwnProperty("seek"))
				dictionary[current].seek(offset);
		}
		
	}
}