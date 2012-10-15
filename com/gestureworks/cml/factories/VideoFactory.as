package com.gestureworks.cml.factories
{	
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import com.gestureworks.cml.events.StateEvent;

	/** 
	 * The VideoFactory is the base class for all Videos.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.factories.Text
	 * @see com.gestureworks.cml.factories.TLF
	 * @see com.gestureworks.cml.factories.ElementFactory
	 */	 
	public class VideoFactory extends ElementFactory
	{
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		private var video:Video;
		private var customClient:Object;
		private var timer:Timer;
		private var sizeLoaded:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function VideoFactory() {}

		private var _debug:Boolean = false;
		/**
		 * Prints status message to console
		 */	
		public function get debug():Boolean { return _debug; }
		public function set debug(value:Boolean):void 
		{ 
			_debug = value; 
		}		
		
		private var _width:Number = 0;
		/**
		 * Sets the video width
		 */	
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			if (video) video.width = value;
		}
		
		private var _height:Number = 0;
		/**
		 * Sets the video height
		 */		
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
			if (video) video.height = value;
		}		
		
		private var _autoLoad:Boolean = true;
		/**
		 * Indicates whether the video file is loaded when the src property is set
		 */
		public function get autoLoad():Boolean { return _autoLoad; }
		public function set autoLoad(value:Boolean):void 
		{ 
			_autoLoad = value; 
		}
		
		private var _autoplay:Boolean = false;
		/**
		 * Indicates whether the video file plays upon load
		 */	
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}
		
		private var _loop:Boolean = false;
		/**
		 * Video loop play
		 */	
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }		
		
		private var _src:String;
		/**
		 * Sets the video file path
		 */		
		public function get src():String{ return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;					
			_src = value;
			if (autoLoad) load();
		}		
		
		private var _deblocking:int;
		/**
		 * Indicates the type of filter applied to decoded video as part of post-processing. 
		 */		
		public function get deblocking():int { return _deblocking; }
		public function set deblocking(value:int):void 
		{ 
			_deblocking = value; 
			if (video) video.deblocking = value 
		}
	
		private var _smoothing:Boolean;
		/**
		 * Specifies whether the video should be smoothed (interpolated) when it is scaled. 
		 */	
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(value:Boolean):void 
		{ 
			_smoothing = value; 
			if (video) video.smoothing = value;
		}
		
		private var _duration:Number = 0;
		/**
		 * Total video duration
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
		
		
		
		/// PUBLIC METHODS ///
		
		
		/**
		 * Sets the src property and loads the video
		 * @param file
		 */		
		public function open(file:String):void
		{
			src = file;
			load();
		}

		/**
		 * Closes video 
		 */	
		public function close():void 
		{
			if (netConnection) 
			{
				netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				netConnection.close()
				netConnection = null;
			}
			if (netStream) 
			{
				netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				netStream.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				netStream.close();

				if (netStream.hasOwnProperty("dispose"))
					netStream['dispose'](); // only works in fp 11+	
				
				netStream = null;
			}

			if (customClient)
				customClient = null;
			
			if (video)
			{
				if (contains(video))
					removeChild(video);
				video.clear();
				video = null;
			}
			
			if (timer)
			{
				timer.removeEventListener(TimerEvent.TIMER, onPosition);
				timer.removeEventListener(TimerEvent.TIMER, onProgress);					
				timer.stop();
				timer = null;
			}
			
			src = "";
			
			sizeLoaded = false;
		}		
		
		/**
		 * Plays the video from the beginning
		 */		
		public function play():void
		{
			netStream.seek(0);				
			netStream.resume();
			timer.reset();
			timer.start();
			_position = 0;
		}
		
		/**
		 * Resumes video playback from paused position
		 */			
		public function resume():void
		{
			netStream.resume();
			timer.start();
		}
		
		/**
		 * Pauses video
		 */			
		public function pause():void
		{
			netStream.pause();
			timer.stop();
		}
		
		/**
		 * Pauses video and returns to the beginning
		 */			
		public function stop():void
		{
			netStream.pause();
			netStream.seek(0);
			timer.stop();	
			timer.reset();
			_position = 0;
		}
		
		/**
		 * Sets the video playhead position
		 * @param offset
		 */
		public function seek(offset:Number):void
		{
			netStream.seek(offset);
			
			if (position < 0)
				position == 0;
			
			_position += offset;
		}

	
		/// PRIVATE METHODS ///	
		private function load():void
		{
			netConnection = new NetConnection;
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			netConnection.connect(null);
		}		
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code) 
			{
				case "NetConnection.Connect.Success":
					connectNetStream();
					break;
				case "NetStream.Play.StreamNotFound":
					if (debug) trace("Unable to locate video: " + src);
					break;
				case "NetStream.Play.Stop":
					end();
					break;
			}	
			
			if (debug)
				trace(event.info.code);
		}
		
		private function connectNetStream():void
		{
			timer = new Timer(1);
			timer.addEventListener(TimerEvent.TIMER, onProgress);
			timer.start();
			
			netStream = new NetStream(netConnection);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			customClient = new Object;			
			customClient.onMetaData = onMetaData;		
			netStream.client = customClient;

			video = new Video;
			video.attachNetStream(netStream);
			
			//the meta data callback seems unrealiable, so give the option to specify video diemensions here as well
			if (width > 0)
				video.width = _width;
			if (height > 0)
				video.height = _height;
				
			addChild(video);			
			
			netStream.play(src);
			netStream.pause();
			netStream.seek(0);
			if (autoplay) play();			
		}
		
		private function onMetaData(meta:Object):void
		{
			if (meta.duration != null && _duration > 0)
			{
				_duration = meta.duration;
				
				if (debug)
				{
					trace("video file: " + src);					
					trace("video duration: " + meta.duration);
				}	
			}
			

			if (meta.width != null && meta.height != null && !sizeLoaded)
			{
				
				if (width > 0)
					video.width = width;
				else
					video.width = meta.width;
				
				if (height > 0)
					video.height = height;
				else
					video.height = meta.height;
											
				if (debug)
				{
					trace("video width: " + meta.width);
					trace("video height: " + meta.height);				
				}
				
				sizeLoaded = true;
				
				// file and all metadata loaded
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("security error: " + event.text);
		}
		
		private function onAsyncError(event:AsyncErrorEvent):void
		{
			trace("async error: " + event.text);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("io error: " + event.text);
		}		
		
		private function onProgress(event:TimerEvent):void
		{
			_percentLoaded = Math.round(netStream.bytesLoaded/netStream.bytesTotal * 100);
			
			if (percentLoaded >= 100)
			{	
				timer.stop();
				timer.reset();
				timer.removeEventListener(TimerEvent.TIMER, onProgress);
				timer.addEventListener(TimerEvent.TIMER, onPosition);				
			}
			else
			{
				if (debug)
					trace(src + " percent loaded: " + percentLoaded);
			}	
		}
		
		private function onPosition(event:TimerEvent):void
		{
			_position++;
			
			if (debug)
				trace(_position);
		}
		
		private function end():void
		{
			if (loop) play();
			else stop();
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", "end", true, true));
		}	
		
		/**
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			close();
		}
			
	}
}