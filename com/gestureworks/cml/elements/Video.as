package com.gestureworks.cml.elements
{	
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.DisplayUtils;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * The Video element loads a video and plays it, and provides access to play, pause, stop, and seek methods.
	 * 
	 * <p>It support the following file types are: .mp4, .FLV, .MPEG-4, .m4v, .3GPP, .MOV, .F4V</p>
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var video:VideoElement = new VideoElement();
		video.src = "myVideo.mp4";
		video.autoplay = true;
		video.init();
		addChild(video);		
		video.play();
	 *
	 * </codeblock>
	 */

	public class Video extends TouchContainer
	{
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		private var video:flash.media.Video;
		private var videoObject:Object;
		private var customClient:Object;
		private var positionTimer:Timer;
		private var progressTimer:Timer;
		private var sizeLoaded:Boolean = false;
		private var playButton:Button;
		private var unmuteVolume:Number = 1;
		private var _resample:Boolean;
		/**
		 * Constructor
		 */
		public function Video()
		{
		  positionTimer = new Timer(20);
		  mouseChildren = true;
		}
		
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
			if (playButton) playButton.x = width / 2 - playButton.width / 2;				
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
			if (playButton) playButton.y = height / 2 - playButton.height / 2;
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
		public function get src():String { return _src; }
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
		
		/**
		 * Elapsed net stream time
		 */
		public function get elapsedTime():Number { return netStream.time; }
		
		private var _percentLoaded:Number = 0;
		/**
		 * Percent of file loaded 
		 */	
		public function get percentLoaded():Number { return _percentLoaded; }
			
		private var _position:Number = 0;
		/**
		 * Playhead position in ms
		 */	
		override public function get position():* { return _position; }
		
		private var _progressBar:ProgressBar;
		/**
		 * Links a progress bar to the video process
		 */
		public function get progressBar():* {return _progressBar;}
		public function set progressBar(pb:*):void {
			if (!pb) return;
			
			if (!(pb is ProgressBar))
				pb = childList.getKey(pb.toString());
			if (pb is ProgressBar)
			{
				_progressBar = pb;
				_progressBar.source = this;				
				mouseChildren = true;
				
				if (!_progressBar.width)
					_progressBar.width = width;
				if (!_progressBar.height)
					_progressBar.height = height*.06;
				if (!_progressBar.y)
					_progressBar.y = height;
				
				addChildAt(_progressBar, numChildren - 1);
			}
		}
		
		private var _isLoaded:Boolean = false;
		/**
		 * Returns video loaded status
		 */
		public function get isLoaded():Boolean { return _isLoaded;}
		
		private var _isPlaying:Boolean = false;
		/**
		 * Returns video playing status
		 */	
		public function get isPlaying():Boolean { return _isPlaying; }
		
		private var _isPaused:Boolean = false;
		/**
		 * Returns video paused status
		 */
		public function get isPaused():Boolean { return _isPaused; }
		
		private var _playButtonState:String = "down";
		/**
		 * Specifies the button state to execute the play operation
		 * @default down
		 */
		public function get playButtonState():String { return _playButtonState; }
		public function set playButtonState(s:String):void
		{
			_playButtonState = s;
		}
				
		private var _volume:Number = 1;
		/**
		 * Sets the audio volume
		 * @default 1
		 */
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			var soundTransform:SoundTransform = netStream.soundTransform;
			soundTransform.volume = _volume;
			netStream.soundTransform = soundTransform;	
		}
		
		private var _pan:Number = 0.0;
		/**
		 * Sets the audio pan (L=-1.0; R=1.0)
		 * @default 0.0
		 */
		public function get pan():Number { return _pan; }
		public function set pan(value:Number):void {
			if (Math.abs(value) <= 1) {
				_pan = value;
				var soundTransform:SoundTransform = netStream.soundTransform;
				soundTransform.pan = _pan;
				netStream.soundTransform = soundTransform;
			} else {
				trace("You must set pan limits within 1.0 to -1.0");
			}
		}
		
		private var _mute:Boolean;
		/**
		 * Turns the volume all the way down when true and returns it to volume prior to muting when false
		 * @default false
		 */
		public function get mute():Boolean { return _mute; }
		public function set mute(value:Boolean):void {
			_mute = value;
			if (_mute)
				unmuteVolume = volume;
			volume = _mute ? 0 : unmuteVolume;								
		}		
		
		public function get resample():Boolean {
			return _resample;
		}
		
		public function set resample(value:Boolean):void {
			_resample = value;
		}
   		
		/**
		 * Flag central alignment of the play button
		 */
		public var centerPlayButton:Boolean = true;
	
		override public function init():void 
		{
			super.init();
			
			playButton = searchChildren(Button);
			if (playButton) {				
				mouseChildren = true;								
				if(centerPlayButton){				
					var tempRot:Number = playButton.rotation;				
					playButton.rotation = 0;
					playButton.x = width / 2 - playButton.width / 2;
					playButton.y = height / 2 - playButton.height / 2;				
					DisplayUtils.rotateAroundCenter(playButton, tempRot);
				}
			}
			
			progressBar = searchChildren(ProgressBar);
		}
		
		/// PUBLIC METHODS ///
		
		public function resize():void {
			if (video.videoWidth != 0 && video.videoHeight != 0) {
				fitContent(video.videoWidth, video.videoHeight);
			} else {
				fitContent(_width, _height);
			}
		}
		
		public function fitContent(aspectWidth:Number, aspectHeight:Number):void {
			if (_resample) {
				if ((width != 0 && height != 0) && (aspectWidth != 0 && aspectHeight != 0)) {
					var relLength:Number = 0;
					if (aspectHeight > aspectWidth) {
						relLength = aspectWidth / aspectHeight;
						video.height = _height;
						video.width = _height * relLength;
					} else {
						relLength = aspectHeight / aspectWidth;
						video.width = _width;
						video.height = _width * relLength;
					}
					video.x = (_width - video.width) / 2;
					video.y = (_height - video.height) / 2;
				} else {
					trace('not enough info to fit content...');
				}
			} else {
				video.width = _width;
				video.height = _height;
			}
		}
		
		/**
		 * Sets the src property and loads the video
		 * @param file
		 */		
		public function open(file:String=null):void
		{			
			src = file ? file: src;
			if(src)
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
			_isLoaded = false; 
		}		
		
		/**
		 * Plays the video from the beginning
		 */		
		public function play(e:StateEvent=null):void
		{			
			if (e && e.value != playButtonState) return;
			netStream.seek(0);				
			netStream.play(src);
			positionTimer.reset();
			positionTimer.start();
			_position = 0;
			positionTimer.removeEventListener(TimerEvent.TIMER, onPosition);
			positionTimer.addEventListener(TimerEvent.TIMER, onPosition);	
		}
		
		/**
		 * Resumes video playback from paused position
		 */			
		public function resume(e:StateEvent=null):void
		{
			if (e && e.value != playButtonState) return;
			netStream.resume();
			positionTimer.start();
	   	}
		
		/**
		 * Pauses video
		 */			
		public function pause(e:StateEvent=null):void
		{
			if (e && e.value != playButtonState) return;
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
			var goTo:Number = Math.floor((offset / 100) * duration);
			
			_position = goTo;
			netStream.seek(goTo);
			/*netStream.seek(offset);
			
			if (position < 0)
				position == 0;
			_position += offset;*/
		
		}

		/// PRIVATE METHODS ///	
		private function load():void
		{
			if (isLoaded) return;
			if (netConnection) {
				netConnection.close();
				//netConnection.removeEventListener((NetStatusEvent.NET_STATUS, onNetStatus);
				//netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
			else
				netConnection = new NetConnection;
			
			if (!netConnection.hasEventListener(NetStatusEvent.NET_STATUS))
				netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			if (!netConnection.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
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
				case "NetStream.Buffer.Full":
					 if (progressTimer){
						progressTimer.removeEventListener(TimerEvent.TIMER, onProgress);
						progressTimer.stop();
					 }
					 break;	
				case "NetStream.Play.Start":
					 _isPlaying = true;
					 _isPaused = false;
					 updatePlayButton();
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					 break;	
				case "NetStream.Play.Stop":
					 end();
				     _isPlaying = false;
					 _isPaused = false;
					 updatePlayButton();
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "ended", true));
					 break;
				case "NetStream.Pause.Notify":
					 _isPlaying = false;
					 _isPaused = true;
					 updatePlayButton();
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					 break;
				case "NetStream.Unpause.Notify":
					_isPlaying = true;
					_isPaused = false;
					updatePlayButton();
					dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isPlaying", _isPlaying ));
					break;
				case "NetStream.Seek.Notify":
					 dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", position));
					 break;
			}	
				if (debug)
					trace(event.info.code);
		}
		
		private function connectNetStream():void
		{
			progressTimer = new Timer(1000);
			if (!positionTimer)
				positionTimer = new Timer(20);
			
			netStream = new NetStream(netConnection);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			netStream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			customClient = new Object;			
			customClient.onMetaData = onMetaData;		
			netStream.client = customClient;

			video = new flash.media.Video;
			video.attachNetStream(netStream);
			
			//the meta data callback seems unrealiable, so give the option to specify video diemensions here as well
			if (width > 0)
				video.width = _width;
			else if (!width)
				width = video.width;
			
			if (height > 0)
				video.height = _height;
			else if (!height)
				height = video.height;
			
			resize();
				
			addChild(video);						
			play();
			_isLoaded = true;
		}
		
		protected function onMetaData(meta:Object):void
		{
			if (meta.duration != null )
			{
				_duration = meta.duration;
				
				if (debug) {
					trace("video file: " + src);					
					trace("video duration: " + duration);
				}	
			}
			
		
			if (meta.width != null && meta.height != null && !sizeLoaded)
			{
				/*if (width > 0)
					video.width = width;
				else
					video.width = meta.width;
				
				if (height > 0)
					video.height = height;
				else
					video.height = meta.height;*/
					
				fitContent(meta.width, meta.height);
											
				if (debug) {
					trace("video width: " + meta.width);
					trace("video height: " + meta.height);				
				}
				
				sizeLoaded = true;
				
				// file and all metadata loaded
				if (!autoplay) stop();
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
				progressTimer.stop();
				progressTimer.reset();
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgress);
			}
			else
			{
				if (debug)
					trace(src + " percent loaded: " + percentLoaded);
			}	
		}
		
		protected function onPosition(event:TimerEvent):void
		{			
			if (!netStream) return;
			_position = netStream.time / _duration;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", position));	
		}
		
		protected function end():void
		{
			if (loop) play();
			else stop();
			
			// Dispatch event for playlist here.
		}	
		
		/**
		 * Toggles between play and pause states
		 */
		private function updatePlayButton():void
		{
			if (!playButton) return;
			
			if (isPlaying){
				playButton.alpha = 0;
				playButton.removeEventListener(StateEvent.CHANGE, resume);
				playButton.removeEventListener(StateEvent.CHANGE, play);				
				playButton.addEventListener(StateEvent.CHANGE, pause);				
			}
			else{
				playButton.alpha = 1;
				
				//move to top
				if (getChildIndex(playButton) != numChildren - 1)
					addChild(playButton);
				if (isPaused)
					playButton.addEventListener(StateEvent.CHANGE, resume);
				else
					playButton.addEventListener(StateEvent.CHANGE, play);
				playButton.removeEventListener(StateEvent.CHANGE, pause);					
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
			videoObject = null;
			customClient = null;			
			playButton = null;
			_progressBar = null;
			super.dispose();
		}

	}
}