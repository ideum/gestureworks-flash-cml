package com.gestureworks.cml.element 
{
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * The LiveVideoElement captures and displays live video input from a user’s camera and also captures audio from microphone.
	 * It has the following parameters: width, height. 
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	    var livevideo:LiveVideoElement = new LiveVideoElement;
		livevideo.camera = new CameraElement();
		livevideo.mic = new MicrophoneElement();
		addChild(livevideo);
	    livevideo.init();
	
	 *
	 * </codeblock>
	 * @author Uma and shaun
	 */
	
	public class LiveVideoElement extends Container
	{
	
	/**
	 * LiveVideoElement Constructor.
	 */	
		public function LiveVideoElement() 
		{
			video = new Video();
			addChild(video);
			load();
		}
		
		/**
		 * Defines net connection object.
		 */
		public var netConnection:NetConnection;
		
		/**
		* Defines netstream object.
		*/
		public var netstream:NetStream;
		
		/**
		* defines the video element
		*/
		public var video:Video;
		
		/**
		* defines camera element.
		*/
		public var _camera:CameraElement;
		
		/**
		* defines the mic object.
		*/
		public var _mic:MicrophoneElement;
		
		/**
		* defines the cam object.
		*/
		public var cam:Camera;
	
    	/**
		* sets the camera element.
		*/
		public function get camera():*
		{
			return _camera;
		}
		public function set camera(value:*):void
		{
			if (!value) return;
			
			if (value is CameraElement)
				_camera = value;
			else 
				_camera = searchChildren(value);
		}
		
		/**
		* sets the microphone element.
		*/
		public function get mic():*
		{
			return _mic;
		}
		public function set mic(value:*):void
		{
			if (!value) return;
			
			if (value is MicrophoneElement)
				_mic = value;
			else 
				_mic = searchChildren(value);
		}
		
		private var micro:Microphone;
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}
		
		/**
		* Initializes the configuration and display of live video and audio.
		*/
		public function init():void
		{ 
		  //Get the default camera for the system	
		  cam = camera.getCamera();
		  
		  if (camera == null)
			trace("unable to locate camera");
		  else
		   {
		   trace("Found camera: " + cam.name);
		   cam.addEventListener(StatusEvent.STATUS, statusHandler);
		   //attaches camera to video.
           video.attachCamera(cam);
		   //netstream.attachCamera(cam);
		   }

		   if (mic)
		   {
		   micro = mic.getMicrophone();
		   micro.setLoopBack(true);
		   micro.setUseEchoSuppression(true);
		   netstream.attachAudio(micro);
		  //video.attachNetStream(netstream);
		   micro.addEventListener(ActivityEvent.ACTIVITY , testMic);
		  }
		}
		
		/**
		 * sets the height of the video
		 */
		override public function set height(value:Number):void 
		{
		 video.height = value;
		 super.height = value;
		}
	
		/**
		 * setd the width of the video
		 */
		override public function set width(value:Number):void 
		{
		 video.width = value;
		 super.width = value;
		}
	
		/**
		 * Establishes net connection.Use NetStream class to send streams of data over the connection.
		 */ 
		private function load():void
		{
		 netConnection = new NetConnection;
		 netConnection.connect(null);
		 netstream = new NetStream(netConnection);
		}	
		
		/**
		 * A Microphone object dispatches an ActivityEvent object whenever microphone reports that it has become active.
		 * @param	event
		 */
		public function testMic(event:ActivityEvent):void
		{
		 trace("mic");
		}
		
		/**
		 * stops livevideo.
		 */
		public function stop():void
		{
		 trace("livevideostop");
		}
		
		/**
		 * An object dispatches a StatusEvent object when a device, such as a camera reports its status. 
		 * @param	event
		 */
		private function statusHandler(event:StatusEvent):void
		{
			
		if (cam.muted)
		trace("Unable to connect to active camera.");
		
		else
		{
		// update width and height to the size of the video, if not already specified
		 if (!width)
		 video.width = cam.width;
		 else
		  video.width = width;
		  
		 if (!height)
		 video.height = cam.height;
		 else
		 video.height = height;
		}
		cam.removeEventListener(StatusEvent.STATUS, statusHandler);
		}

	/**
	 * dispose method to remove listener
	 */	
	override public function dispose():void
	{
		netConnection = null;
		netstream = null;
		mic = null;
		cam = null;
		camera = null;
		video = null;
		cam.removeEventListener(StatusEvent.STATUS, statusHandler);
		micro.removeEventListener(ActivityEvent.ACTIVITY , testMic);
	}
}
}