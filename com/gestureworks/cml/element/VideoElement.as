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
		private var positionTimer:Timer;
		private var progressTimer:Timer;
		private var sizeLoaded:Boolean = false;
		
		public function VideoElement() {}

		private var _debug:Boolean=false;
		/**
		 * Prints status message to console
		 */	
		public function get debug():Boolean { return _debug; }
		public function set debug(value:Boolean):void 
		{ 
			_debug = value; 
		}		
		
		private var _width:Number=0;
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
		
		private var _isPlaying:Boolean = false;
		/**
		 * sets video playing status
		 */	
		public function get isPlaying():Boolean { return _isPlaying; }
   		
	
			
		
		
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
			
			if (positionTimer)
			{
				positionTimer.removeEventListener(TimerEvent.TIMER, onPosition);					
				positionTimer.stop();
				positionTimer = null;
			}
			
			src = "";
			
			sizeLoaded = false;
		}		
		
		/**
		 * Plays the video from the beginning
		 */		
		public function play():void
		{
			positionTimer = new Timer(1);
			netStream.seek(0);				
			netStream.resume();
			positionTimer.reset();
			positionTimer.start();
			_position = 0;
			positionTimer.removeEventListener(TimerEvent.TIMER, onPosition);
			positionTimer.addEventListener(TimerEvent.TIMER, onPosition);	
		}
		
		/**
		 * Resumes video playback from paused position
		 */			
		public function resume():void
		{
			netStream.resume();
			positionTimer.start();
		}
		
		/**
		 * Pauses video
		 */			
		public function pause():void
		{
			netStream.pause();
			positionTimer.stop();
		}
		
		/**
		 * Pauses video and returns to the beginning
		 */			
		public function stop():void
		{
			netStream.pause();
			netStream.seek(0);
			positionTimer.stop();	
			positionTimer.reset();
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
					 progressTimer.removeEventListener(TimerEvent.TIMER, onProgress);
					 progressTimer.stop();
					 break;	
				case "NetStream.Play.Start":
					 trace("video started");
					 _isPlaying = true;
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					 break;	
				case "NetStream.Play.Stop":

					 trace("video stopped");
					 end();
				     _isPlaying = false;
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					 break;
				case "NetStream.Pause.Notify":
                     trace("video paused");
					 _isPlaying = false;
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					 break;
				case "NetStream.Seek.Notify":
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", position));
					 break;

					
					end();
					break;

			}	
				if (debug)
				print(event.info.code);
		}
		
		private function connectNetStream():void
		{
			progressTimer = new Timer(1000);
		//	progressTimer.addEventListener(TimerEvent.TIMER, onProgress); 
		//	progressTimer.start(); not able to stop
			
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
				progressTimer.stop();
				progressTimer.reset();
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgress);
			}
			else
			{
				if (debug)
					print(src + " percent loaded: " + percentLoaded);
			}	
			trace("onProgress");
		}
		
		private function onPosition(event:TimerEvent):void
		{			
			_position++;
	
			if (debug)
				trace(_position); 
		
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", position));	

		}
	
		private function end():void
		{
			if (loop) play();
			else stop();
	
		}		
			
	}
}