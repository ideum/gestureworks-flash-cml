package com.gestureworks.cml.elements
{	
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.base.media.MediaBase;
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.utils.TimeUtils;
	import com.greensock.TweenLite;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * The Video element loads a video and plays it, and provides access to play, pause, stop, and seek methods.
	 * <p>It support the following file types are: .mp4, .FLV, .MPEG-4, .m4v, .3GPP, .MOV, .F4V</p>
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *  var video:VideoElement = new VideoElement();
	 * 	video.src = "path/to/video.mp4";
	 *	video.autoplay = true;
	 *	video.init();
	 *	addChild(video);			 
	 * </codeblock>
	 */		
	 public class Video extends MediaBase implements IStream {
		   
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		private var video:flash.media.Video;
		private var customClient:Object;
		private var positionTimer:Timer;
		private var progressTimer:Timer;		
		private var unmuteVolume:Number = 1;			
		
		private var _debug:Boolean;	
		private var _autoplay:Boolean;		
		private var _duration:Number = 0;	
		private var _position:Number = 0;	
		private var _volume:Number = 1;		
		private var _pan:Number = 0.0;		
		private var _isPlaying:Boolean;	
		private var _isSeeking:Boolean;
		private var _isPaused:Boolean;		
		private var _isComplete:Boolean;
		private var _loop:Boolean;
		private var _mute:Boolean;	
		private var _aspectRatio:Number = 0;	
		private var _previewAtPosition:Number = 0;
		private var _previewAtProgress:Number = 0.5;		
		
		/**
		 * Prints status messages to console
		 */
		public var debug:Boolean;
				
		/**
		 * Constructor
		 */
		public function Video(){
		  positionTimer = new Timer(20);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			super.init();			
		}
		
		/**
		 * Playhead position (in seconds) to generate a snapshot at when the @see #preview flag is enabled; overwrites
		 * @see #previewAtProgress
		 * @default 0
		 */		
		public function get previewAtPosition():Number { return _previewAtPosition; }
		public function set previewAtPosition(value:Number):void {
			_previewAtPosition = value < 0 ? 0 : value > duration ? duration : value; 
		}
		
		/**
		 * Percentage of video duration to generate a snapshot at when the <code>preview</code> flag is enabled
		 * @default 0.5
		 */
		public function get previewAtProgress():Number { return _previewAtProgress; }
		public function set previewAtProgress(value:Number):void {
			_previewAtProgress = value < 0 ? 0 : value > 1 ? 1 : value;
		}
		
		/**
		 * Indicates the type of filter applied to the decoded video as part of post-processing. 
		 */
		public function get deblocking():int { return video ? video.deblocking : 0; }
		public function set deblocking(value:int):void { 
			if (video) {
				video.deblocking = value 
			}
		}
			
		/**
		 * Specifies whether the video should be smoothed (interpolated) when it is scaled. 
		 */	
		public function get smoothing():Boolean { return video ? video.smoothing : false; }
		public function set smoothing(value:Boolean):void { 
			if (video) {
				video.smoothing = value;
			}
		}
		
		/**
		 * Aspect ratio (width/height) 
		 */
		public function get aspectRatio():Number { return _aspectRatio; }		
		
		/**
		 * Initialize net connection
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
			
			netConnection = new NetConnection;			
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);			
			netConnection.connect(null);			
		}
		
		/**
		 * @inheritDoc
		 */		
		public function play():void{			
			netStream.seek(_position);				
			netStream.play(src);
			positionTimer.reset();
			positionTimer.start();
			positionTimer.removeEventListener(TimerEvent.TIMER, onPosition);
			positionTimer.addEventListener(TimerEvent.TIMER, onPosition);	
		}
		
		/**
		 * @inheritDoc
		 */			
		public function resume():void{
			netStream.resume();
			positionTimer.start();
	   	}
		
		/**
		 * @inheritDoc
		 */			
		public function pause():void{
			netStream.pause();
			positionTimer.stop();
		}
		
		/**
		 * @inheritDoc
		 */			
		public function stop():void{
			netStream.pause();
			netStream.seek(0);
			positionTimer.stop();	
			positionTimer.reset();
			_position = 0;
		}
		
		/**
		 * Seeks video playhead position in seconds
		 * @param	pos offset in seconds
		 */
		public function seek(pos:Number):void {
			if (!isSeeking && netStream) {
				_isSeeking = true; 
				netStream.seek(pos);	
				onStatus(MediaStatus.SEEKING, _isSeeking);
			}
		}
		
		/**
		 * @inheritDoc
		 */	
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void {	_autoplay = value;	}
					
		/**
		 * @inheritDoc
		 */	
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void { _loop = value; }		
		
		/**
		 * @inheritDoc
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			
			if(netStream){
				var soundTransform:SoundTransform = netStream.soundTransform;
				soundTransform.volume = _volume;
				netStream.soundTransform = soundTransform;	
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
			if (netStream) {				
				_pan = value > 1 ? 1 : value < -1 ? -1 : value; 
				var soundTransform:SoundTransform = netStream.soundTransform;
				soundTransform.pan = _pan;
				netStream.soundTransform = soundTransform;
			} 
		}	
		
		/**
		 * @inheritDoc
		 */	
		public function get isPlaying():Boolean { return _isPlaying; }
		
		/**
		 * @inheritDoc
		 */
		public function get isSeeking():Boolean { return _isSeeking; }
		
		/**
		 * @inheritDoc
		 */
		public function get isPaused():Boolean { return _isPaused; }
				
		/**
		 * @inheritDoc
		 */
		public function get isComplete():Boolean { return _isComplete; }		
				
		/**
		 * Video playback position in seconds
		 */	
		public function get position():Number { return netStream.time; }
		
		/**
		 * Total length of video in seconds
		 */	
		public function get duration():Number { return _duration; }
		
		/**
		 * @inheritDoc
		 */
		public function get progress():Number { return position / duration; }
		
		/**
		 * @inheritDoc
		 */
		public function get elapsedTime():String { return TimeUtils.secToMinSec(position); }
		
		/**
		 * @inheritDoc
		 */
		public function get totalTime():String { return TimeUtils.secToMinSec(duration); }	
		
		/**
		 * Initialize net stream and video object
		 */
		private function connectNetStream():void{
			
			if (!positionTimer)
				positionTimer = new Timer(10);
			
			progressTimer = new Timer(20);
			progressTimer.addEventListener(TimerEvent.TIMER, loading);			
			progressTimer.start();				
			
			netStream = new NetStream(netConnection);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			customClient = new Object;			
			customClient.onMetaData = onMetaData;	
			netStream.client = customClient;

			video = new flash.media.Video;
			video.attachNetStream(netStream);
					
			//start stream
			play();
		}
		
		/**
		 * Add loaded video to wrapper
		 * @param	w initial video width
		 * @param	h initial video height
		 */
		private function addVideo(w:Number, h:Number):void {
			if (!isLoaded) {									
				_isLoaded = true; 
								
				//apply wrapper dimension to video
				if(width || height){
					resize(width, height);
				}
				//apply video dimension to wrapper
				else {
					resize(w, h);
				}
				
				addChild(video);
				loadComplete();				
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateThumbnail():void {
			
			//thumbnail generation pre-processing
			if (preview) {
				stop();
				seek(previewAtPosition ? previewAtPosition : previewAtProgress * duration); 		
				TweenLite.delayedCall(duration * .005, capturePreview, [visible, position]); //delay to simulate seek complete (net status is inaccurate)	
				visible = false; 
			}
			else {
				
				super.updateThumbnail();
				
				//handle autoplay
				if (!autoplay) {
					stop();
				}									
			}			
		}
		
		/**
		 * Capture thumbnail at playhead position
		 * @param	vis  visibility setting prior to preview seek
		 * @param	pos  playhead position prior to preview seek
		 */
		private function capturePreview(vis:Boolean, pos:Number):void {			
			super.updateThumbnail();
			seek(pos);
			TweenLite.delayedCall(duration * .005, function():void { //delay to simulate seek complete (net status is inaccurate)				
				visible = vis; 			
				//handle autoplay
				if (autoplay) {
					resume();
				}
			});
		}
		
		/**
		 * Resize loaded video to the provided dimensions. Setting one of the dimensions to zero (or NaN), maintains the aspect ratio relative
		 * to the non-zero dimension. Setting both values to 0, sets dimension to the resolution of the loaded video file. 
		 * @param	w  resize width
		 * @param	h  resize height
		 */
		public function resize(w:Number = 0, h:Number = 0):void {
			if (isLoaded) {
								
				//calculate scale percentages
				var percentX:Number = 1;
				var percentY:Number = 1; 
				if (w && h) {
					percentX = w / video.videoWidth;
					percentY = h / video.videoHeight;
				}
				else if (w) {
					percentX = percentY = w / video.videoWidth;
				}
				else if (h) {
					percentY = percentX = h / video.videoHeight;
				}
				
				//update dimensions
				width = video.videoWidth * percentX;
				video.width = width;				
				height = video.videoHeight * percentY;
				video.height = height;
				
				//update aspect ratio
				_aspectRatio = width / height;
			}
		}		
		
		/**
		 * Process meta data
		 * @param	meta
		 */
		protected function onMetaData(meta:Object):void {			
			_duration = meta.duration ? meta.duration : 0; 			
			
			if (meta.width && meta.height){		
				addVideo(meta.width, meta.height);
			}		
		}
		
		/**
		 * NetConnection.call() attempts to connect to a server outside the caller's security sandbox
		 * @param	event 
		 */
		private function onSecurityError(event:SecurityErrorEvent):void { trace("security error: " + event.text); }
		
		/**
		 * An exception is thrown asynchronously — that is, from native asynchronous code
		 * @param	event
		 */
		private function onAsyncError(event:AsyncErrorEvent):void { trace("async error: " + event.text); }
		
		/**
		 * An input or output error occurs that causes a network operation to fail
		 * @param	event 
		 */
		private function onIOError(event:IOErrorEvent):void { trace("io error: " + event.text); }		
		
		/**
		 * @inheritDoc
		 */
		override protected function loading(event:Event = null):void{
			_percentLoaded = Math.round(netStream.bytesLoaded/netStream.bytesTotal * 100);
			
			if (percentLoaded >= 100){	
				progressTimer.stop();
				progressTimer.reset();
				progressTimer.removeEventListener(TimerEvent.TIMER, loading);
			}
			
			if (debug) { trace(src + " percent loaded: " + percentLoaded); }	
			
			super.loading(event);
		}
		
		/**
		 * Playback progress
		 * @param	event
		 */
		protected function onPosition(event:TimerEvent):void{			
			if (!netStream) {
				return;
			}							
			
			//update position
			onStatus(MediaStatus.PLAYBACK_PROGRESS, progress); 	
		}
		
		/**
		 * End of playback
		 */
		protected function onEnd():void {
			if (loop) {
				play();
			}
			else {
				stop();			
			}
		}			
		
		/**
		 * NetConnection object is reporting its status or error condition
		 * @param	event
		 */
		private function onNetStatus(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					 connectNetStream();
					 break;
				case "NetStream.Play.StreamNotFound":
					 if (debug) trace("Unable to locate video: " + src);
					 break;
				case "NetStream.Buffer.Full":
					 if (progressTimer){
						progressTimer.removeEventListener(TimerEvent.TIMER, loading);
						progressTimer.stop();
					 }
					 addVideo(video.videoHeight, video.videoWidth);
					 break;	
				case "NetStream.Play.Start":
					 _isPlaying = true;
					 _isPaused = false;
					 _isComplete = false; 
					 onStatus(MediaStatus.PLAYING, _isPlaying);
					 break;	
				case "NetStream.Play.Stop":
					 onEnd();
				     _isPlaying = false;
					 _isPaused = false;
					 _isComplete = true; 
					 onStatus(MediaStatus.PLAYBACK_COMPLETE, _isComplete);					 
					 break;
				case "NetStream.Pause.Notify":
					 _isPlaying = false;
					 _isPaused = true;
					 onStatus(MediaStatus.PAUSED, _isPaused);
					 break;
				case "NetStream.Unpause.Notify":
					_isPlaying = true;
					_isPaused = false;
					onStatus(MediaStatus.PLAYING, _isPlaying);
					break;
				case "NetStream.Seek.Notify":
					_isSeeking = false; 
					onStatus(MediaStatus.SEEKING, _isSeeking);	
					break;
			}	
			
			if (debug){
				trace(event.info.code);
			}
		}			

		/**
		 * @inheritDoc
		 */	
		override public function close():void {
			if (!initialized) {
				return; 
			}
			
			super.close();
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
				if (netStream.hasOwnProperty("dispose")) {
					netStream['dispose'](); // only works in fp 11+	
				}
				
				netStream = null;
			}
			
			if (customClient)
				customClient = null;
			
			if (video)
			{
				video.clear();
				removeChild(video);
				video = null;
			}
			
			if (positionTimer)
			{
				positionTimer.removeEventListener(TimerEvent.TIMER, onPosition);					
				positionTimer.stop();
				positionTimer = null;
			}					
		}								
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			if (positionTimer) {
				positionTimer.stop();
				positionTimer.removeEventListener(TimerEvent.TIMER, onPosition);
				positionTimer = null;
			}
			
			if (progressTimer) {
				progressTimer.stop();
				progressTimer = null;
			}
			
			if (video) {
				video.attachNetStream(null);
			}
			
			if (netConnection) {
				netConnection.close();
				netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				netConnection = null;
			}
			
			if (netStream) {
				netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				netStream.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				netStream.dispose();
				netStream = null;
			}
			
			
			video = null;
			customClient = null;			
			super.dispose();
		}

	}
}