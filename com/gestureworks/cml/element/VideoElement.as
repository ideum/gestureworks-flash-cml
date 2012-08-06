package com.gestureworks.cml.element
{	
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;

	public class VideoElement extends ElementFactory
	{
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		private var video:Video;
		private var videoObject:Object;
		private var customClient:Object;
		private var timer:Timer;
		private var sizeLoaded:Boolean = false;
		
		public function VideoElement() {}

		/**
		 * Prints status message to console
		 */				
		private var _debug:Boolean=false;
		public function get debug():Boolean { return _debug; }
		public function set debug(value:Boolean):void 
		{ 
			_debug = value; 
		}		
		
		/**
		 * Sets the video width
		 */		
		private var _width:Number=0;
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			if (video) video.width = value;
		}
		
		/**
		 * Sets the video height
		 */		
		private var _height:Number=0;
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
			if (video) video.height = value;
		}		
		
		/**
		 * Indicates whether the video file is loaded when the src property is set
		 */		
		private var _autoLoad:Boolean=true;
		public function get autoLoad():Boolean { return _autoLoad; }
		public function set autoLoad(value:Boolean):void 
		{ 
			_autoLoad = value; 
		}
		
		/**
		 * Indicates whether the video file plays upon load
		 */		
		private var _autoplay:Boolean=false;
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}

		/**
		 * Video loop play
		 */				
		private var _loop:Boolean=false;
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }		
		
		/**
		 * Sets the video file path
		 */			
		private var _src:String;
		public function get src():String{ return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;					
			_src = value;
			if (autoLoad) load();
		}		
		
		/**
		 * Indicates the type of filter applied to decoded video as part of post-processing. 
		 */		
		private var _deblocking:int;
		public function get deblocking():int { return _deblocking; }
		public function set deblocking(value:int):void 
		{ 
			_deblocking = value; 
			if (video) video.deblocking = value 
		}
		
		/**
		 * Specifies whether the video should be smoothed (interpolated) when it is scaled. 
		 */		
		private var _smoothing:Boolean;
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(value:Boolean):void 
		{ 
			_smoothing = value; 
			if (video) video.smoothing = value;
		}
		
		
		/**
		 * Total video duration
		 */		
		private var _duration:Number=0;
		public function get duration():Number { return _duration; }
		
		/**
		 * Percent of file loaded 
		 */		
		private var _percentLoaded:Number=0;
		public function get percentLoaded():Number { return _percentLoaded; }
		
		/**
		 * Playhead position in ms
		 */		
		private var _position:Number=0;
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
				video.clear();
				video = null;
			}
			
			if (timer)
			{
				timer.removeEventListener(TimerEvent.TIMER, onPosition);					
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
					if (debug) print("Unable to locate video: " + src);
					break;
				case "NetStream.Buffer.Full":
					timer.removeEventListener(TimerEvent.TIMER, onProgress);
					break;	
				case "NetStream.Play.Stop":
					
					end();
					break;
			}	
			
			if (debug)
				print(event.info.code);
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
					print("video file: " + src);					
					print("video duration: " + meta.duration);
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
					print("video width: " + meta.width);
					print("video height: " + meta.height);				
				}
				
				sizeLoaded = true;
				
				// file and all metadata loaded
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			print("security error: " + event.text);
		}
		
		private function onAsyncError(event:AsyncErrorEvent):void
		{
			print("async error: " + event.text);
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			print("io error: " + event.text);
		}		
		
		private function onProgress(event:TimerEvent):void
		{
			_percentLoaded = Math.round(netStream.bytesLoaded/netStream.bytesTotal * 100);
			
			if (percentLoaded >= 100)
			{	
				timer.stop();
				timer.reset();
				timer.removeEventListener(TimerEvent.TIMER, onProgress);
			}
			else
			{
				if (debug)
					print(src + " percent loaded: " + percentLoaded);
			}	
		}
		
		private function onPosition(event:TimerEvent):void
		{			
			_position++;
			
			if (debug)
				print(_position);
		}
		
		private function end():void
		{
			if (loop) play();
			else stop();
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", "end", true, true));
		}		
			
	}
}