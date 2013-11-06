package com.gestureworks.cml.elements 
{
	import flash.display.DisplayObject;
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * The LiveVideo element captures and displays live video input from a user’s camera and also captures audio from a microphone.
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	    var livevideo:LiveVideo = new LiveVideo;
		livevideo.camera = new Camera();
		livevideo.mic = new Microphone();
		addChild(livevideo);
	    livevideo.init();
	
	 *
	 * </codeblock>
	 * @author Uma and shaun
	 */
	
	public class LiveVideo extends TouchContainer
	{
	
	/**
	 * LiveVideoElement Constructor.
	 */	
		public function LiveVideo() 
		{
			video = new flash.media.Video();
			mouseChildren = true;
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
		public var video:flash.media.Video;
		
		/**
		* defines camera element.
		*/
		public var _camera:VideoCamera;
		/**
		* defines the mic object.
		*/
		public var _microphone:com.gestureworks.cml.elements.Microphone;
		
		public var cam:flash.media.Camera;
		
		public var mic:flash.media.Microphone;
	
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
			
			if (value is VideoCamera)
				_camera = value;
			else 
				_camera = searchChildren(value);
		}
		
		/**
		* sets the microphone element.
		*/
		public function get microphone():*
		{
			return _microphone;
		}
		public function set microphone(value:*):void
		{
			if (!value) return;
			
			if (value is com.gestureworks.cml.elements.Microphone)
				_microphone = value;
			else 
				_microphone = searchChildren(value);
		}
		
		/**
		* Initializes the configuration and display of live video and audio.
		*/
		override public function init():void
		{ 
			load();
			
		  //Get the default camera for the system	
		   cam = camera ? camera.getCamera() : null;
		  
		  if (cam == null)
			trace("unable to locate camera");
		  else
		   {
		   cam.addEventListener(StatusEvent.STATUS, statusHandler);
		   //attaches camera to video.
           video.attachCamera(cam);
		   }
   
		   //Get the default microphone for the system	
		  
		   mic = microphone ? microphone.getMicrophone() : null;
		   
		   if (mic == null)
		   {
			trace("unable to locate mic");   
		   }
		   else
		   {
			   mic.setLoopBack(true);
			   mic.setUseEchoSuppression(true);
			   netstream.attachAudio(mic);
			   mic.addEventListener(ActivityEvent.ACTIVITY, testMic);
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
			//video = new flash.media.Video();
			addChild(video);
			
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
	 * @inheritDoc
	 */	
	override public function dispose():void
	{
		netConnection = null;
		netstream = null;
		_camera = null;
		_microphone = null;
		video = null;
		
		if(cam){
			cam.removeEventListener(StatusEvent.STATUS, statusHandler);
			cam = null;
		}
		if(mic){
			mic.removeEventListener(ActivityEvent.ACTIVITY , testMic);
			mic = null;
		}
	}
}
}