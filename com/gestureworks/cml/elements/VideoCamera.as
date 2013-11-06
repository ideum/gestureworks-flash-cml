package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.CMLObject;
	import flash.events.EventDispatcher;
	import flash.media.Camera;

	/**
	 * Dispatched when a camera reports its status.
	 * @eventType	flash.events.StatusEvent.STATUS
	 */
	[Event(name="status", type="flash.events.StatusEvent")] 

	/**
	 * Dispatched when a camera begins or ends a session.
	 * @eventType	flash.events.ActivityEvent.ACTIVITY
	 */
	[Event(name="activity", type="flash.events.ActivityEvent")] 

	/**
	 * The Camera element captures video from the client system's camera. 
	 * Use the Video class to monitor the video locally.  
	 * Use the NetConnection and NetStream classes to transmit the video to Flash Media Server.
	 * Flash Media Server can send the video stream to other servers and broadcast it to other clients running Flash Player.
	 * 
	 *   <p class="- topic/p ">A Camera instance captures video in landscape aspect ratio. On devices that can change the screen orientation,
	 * such as mobile phones, a Video object attached to the camera will only show upright video in a landscape-aspect orientation. 
	 * Thus, mobile apps should use a landscape orientation when displaying video and should not auto-rotate.</p><p class="- topic/p ">As of AIR 2.6, autofocus is enabled automatically on mobile devices with an autofocus camera. If the camera does not support continuous autofocus,
	 * and many mobile device cameras do not, then the camera is focused when the Camera object is attached to a video stream and whenever 
	 * the <codeph class="+ topic/ph pr-d/codeph ">setMode()</codeph> method is called. On desktop computers, autofocus behavior is dependent on the camera driver and settings.</p><p class="- topic/p ">In an AIR application on Android and iOS, the camera does not capture video while an AIR app is not the active, foreground application.
	 * In addition, streaming connections can be lost when the application is in the background. On iOS, the camera video cannot be
	 * displayed when an application uses the GPU rendering mode. The camera video can still be streamed to a server.</p><p class="- topic/p "><b class="+ topic/ph hi-d/b ">Mobile Browser Support:</b> This class is not supported in mobile browsers.</p><p class="- topic/p "><i class="+ topic/ph hi-d/i ">AIR profile support:</i> This feature is supported 
	 * on desktop operating systems, but it is not supported on all mobile devices. It is not
	 * supported on AIR for TV devices. See 
	 * <xref href="http://help.adobe.com/en_US/air/build/WS144092a96ffef7cc16ddeea2126bb46b82f-8000.html" class="- topic/xref ">
	 * AIR Profile Support</xref> for more information regarding API support across multiple profiles.</p><p class="- topic/p ">You can test 
	 * for support at run time using the <codeph class="+ topic/ph pr-d/codeph ">Camera.isSupported</codeph> property. 
	 * Note that for AIR for TV devices, <codeph class="+ topic/ph pr-d/codeph ">Camera.isSupported</codeph> is <codeph class="+ topic/ph pr-d/codeph ">true</codeph> but
	 * <codeph class="+ topic/ph pr-d/codeph ">Camera.getCamera()</codeph> always returns <codeph class="+ topic/ph pr-d/codeph ">null</codeph>.</p><p class="- topic/p ">
	 * For information about capturing audio, see the Microphone class.
	 * </p><p class="- topic/p "><b class="+ topic/ph hi-d/b ">Important: </b>Flash Player displays a Privacy dialog box that lets the user choose whether 
	 * to allow or deny access to the camera. Make sure your application window size is at least 215 x 138 pixels; 
	 * this is the minimum size required to display the dialog box.
	 * </p><p class="- topic/p ">To create or reference a Camera object, use the <codeph class="+ topic/ph pr-d/codeph ">getCamera()</codeph> method.</p>
	 * 
	 *   EXAMPLE:
	 * 
	 *   The following example shows the image from a camera after acknowledging the
	 * security warning.  The Stage is set such that it cannot be scaled and is aligned to the
	 * top-left of the player window.  The <codeph class="+ topic/ph pr-d/codeph ">activity</codeph> event is dispatched at the
	 * start and end (if any) of the session and is captured by the <codeph class="+ topic/ph pr-d/codeph ">activityHandler()</codeph>
	 * method, which prints out information about the event.
	 * 
	 *   <p class="- topic/p "><b class="+ topic/ph hi-d/b ">Note:</b> A camera must be attached to your computer for this example
	 * to work correctly.</p><codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
	 *   package {
	 * import flash.display.Sprite;
	 * import flash.display.StageAlign;
	 * import flash.display.StageScaleMode;
	 * import flash.events.*;
	 * import flash.media.Camera;
	 * import flash.media.Video;
	 * 
	 *   public class CameraExample extends Sprite {
	 * private var video:Video;
	 * 
	 *   public function CameraExample() {
	 * stage.scaleMode = StageScaleMode.NO_SCALE;
	 * stage.align = StageAlign.TOP_LEFT;
	 * 
	 *   var camera:Camera = Camera.getCamera();
	 * 
	 *   if (camera != null) {
	 * camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
	 * video = new Video(camera.width * 2, camera.height * 2);
	 * video.attachCamera(camera);
	 * addChild(video);
	 * } else {
	 *   trace("You need a camera.");
	 * }
	 * }
	 * 
	 *   private function activityHandler(event:ActivityEvent):void {
	 *    trace("activityHandler: " + event);
	 * }
	 * }
	 * }
	 * </codeblock>
	 * @author Ideum
	 */
	public final class VideoCamera extends CMLObject
	{
		private var cam:flash.media.Camera;
		
		/**
		 * Constructor
		 */
		public function VideoCamera()
		{
			cam = new flash.media.Camera;
		}
		
		/**
		 * The amount of motion the camera is detecting. Values range from 0 (no motion is being detected) to 
		 * 100 (a large amount of motion is being detected). The value of this property can help you determine if you need to pass a setting 
		 * to the setMotionLevel() method.
		 * If the camera is available but is not yet being used because the
		 * Video.attachCamera() method has not been called, this property
		 * is set to -1.If you are streaming only uncompressed local video, this property is set only if you have assigned a function to the  event 
		 * handler. Otherwise, it is undefined.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get activityLevel () : Number
		{
			return cam.activityLevel;
		}

		/**
		 * The maximum amount of bandwidth the current outgoing video feed can use, in bytes. 
		 * A value of 0 means the feed can use as much bandwidth as needed to maintain the desired frame quality.
		 * To set this property, use the setQuality() method.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get bandwidth () : int
		{
			return cam.bandwidth;
		}

		/**
		 * The rate at which the camera is capturing data, in frames per second. 
		 * This property cannot be set; however, you can use the setMode() method
		 * to set a related property—fps—which specifies the maximum
		 * frame rate at which you would like the camera to capture data.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get currentFPS () : Number
		{
			return cam.currentFPS;
		}

		/**
		 * The maximum rate at which the camera can capture data, in frames per second. 
		 * The maximum rate possible depends on the capabilities of the camera; this frame rate may not be achieved.
		 * To set a desired value for this property, use the setMode() method.To determine the rate at which the camera is currently capturing data, use the currentFPS property.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get fps () : Number
		{
			return cam.fps;
		}

		/**
		 * The current capture height, in pixels. To set a value for this property, 
		 * use the setMode() method.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get height () : int
		{
			return cam.height;
		}

		/**
		 * A zero-based integer that specifies the index of the camera, as reflected in
		 * the array returned by the names property.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get index () : int
		{
			return cam.index;
		}
	

		/**
		 * The isSupported property is set to true if the 
		 * Camera class is supported on the current platform, otherwise it is
		 * set to false.
		 * @langversion	3.0
		 * @playerversion	Flash 10.1
		 * @playerversion	AIR 2
		 */
		public static function get isSupported () : Boolean
		{
			return Camera.isSupported;
		}

		/**
		 * The number of video frames transmitted in full (called keyframes) 
		 * instead of being interpolated by the video compression algorithm. 
		 * The default value is 15, which means that every 15th frame is a keyframe.
		 * A value of 1 means that every frame is a keyframe. The allowed values are
		 * 1 through 48.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get keyFrameInterval () : int
		{
			return cam.keyFrameInterval;
		}

		/**
		 * Indicates whether a local view of what the camera is capturing is compressed
		 * and decompressed (true), as it would be for live transmission using
		 * Flash Media Server, or uncompressed (false). The default value is
		 * false.
		 * 
		 *   Although a compressed stream is useful for testing, such as when previewing
		 * video quality settings, it has a significant processing cost. The local view
		 * is compressed, edited for transmission as it would be over a live connection,
		 * and then decompressed for local viewing.
		 * To set this value, use Camera.setLoopback(). To set the amount of 
		 * compression used when this property is true, use Camera.setQuality().
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get loopback () : Boolean
		{
			return cam.loopback;
		}

		/**
		 * The amount of motion required to invoke the activity event. Acceptable values range from 0 to 100. 
		 * The default value is 50.
		 * Video can be displayed regardless of the value of the motionLevel property. For more information, see 
		 * setMotionLevel().
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get motionLevel () : int
		{
			return cam.motionLevel;
		}

		/**
		 * The number of milliseconds between the time the camera stops detecting motion and the time the activity event is invoked. The 
		 * default value is 2000 (2 seconds). 
		 * To set this value, use setMotionLevel().
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get motionTimeout () : int
		{
			return cam.motionTimeout;
		}

		/**
		 * A Boolean value indicating whether the user has denied access to the camera
		 * (true) or allowed access (false) in the Flash Player Privacy dialog box.
		 * 
		 *   When this value changes, the statusevent is dispatched.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get muted () : Boolean
		{
			return cam.muted;
		}

		/**
		 * The name of the current camera, as returned by the camera hardware.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get name () : String
		{
			return cam.name;
		}

		/**
		 * An array of strings indicating the names of all available cameras
		 * without displaying the Flash Player Privacy dialog box. This array behaves in the
		 * same way as any other ActionScript array, implicitly providing the zero-based
		 * index of each camera and the number of cameras on the system (by means of 
		 * names.length). For more information, see the names Array class entry.
		 * 
		 *   Calling the names property requires an extensive examination of the hardware.
		 * In most cases, you can just use the default camera.On Android, only one camera is supported, even if the device has more than one camera devices. The
		 * name of the camera is always, "Default."
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public static function get names () : Array
		{
			return Camera.names;
		}

		/**
		 * The required level of picture quality, as determined by the amount of compression being applied to each video
		 * frame. Acceptable quality values range from 1 (lowest quality, maximum compression) to 100 (highest quality, no compression). The 
		 * default value is 0, which means that picture quality can vary as needed to avoid exceeding available bandwidth.
		 * 
		 *   To set this property, use the setQuality() method.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get quality () : int
		{
			return cam.quality;
		}

		/**
		 * The current capture width, in pixels. To set a desired value for this property, 
		 * use the setMode() method.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get width () : int
		{
			return cam.width;
		}

		//static function _scanHardware () : void
		//{
			//Camera._scanHardware;
		//}
        
		

		/**
		 * Returns a reference to a Camera object for capturing video. To begin capturing
		 * the video, you must attach the Camera object to a Video object (see Video.attachCamera()
		 * ). To transmit video to Flash Media Server, call NetStream.attachCamera()
		 * to attach the Camera object to a NetStream object.
		 * 
		 *   Multiple calls to the getCamera() method reference the same camera driver.
		 * Thus, if your code contains code like firstCam:Camera = getCamera() 
		 * and secondCam:Camera = getCamera(),
		 * both firstCam and secondCam reference the same camera,
		 * which is the user's default camera.On iOS devices with a both a front- and a rear-facing camera, you can only capture
		 * video from one camera at a time. On Android devices, you can only access the rear-facing camera.In general, you shouldn't pass a value for the name parameter; simply use
		 * getCamera() to return a reference to the default camera. By means of the Camera
		 * settings panel (discussed later in this section), the user can specify the default camera
		 * to use. You can't use ActionScript to set a user's Allow or Deny permission setting
		 * for access to the camera, but you can display the Adobe Flash Player Settings camera 
		 * setting dialog box where the user can set the camera permission. When a SWF file using 
		 * the attachCamera() method tries to 
		 * attach the camera returned by the getCamera() method to a Video or 
		 * NetStream object, Flash Player displays a dialog box that lets the user choose  
		 * to allow or deny access to the camera. (Make sure your application window size is at least 
		 * 215 x 138 pixels; this is the minimum size Flash Player requires to display the dialog box.) 
		 * When the user responds to the camera setting dialog box, Flash Player returns an 
		 * information object in the status event that indicates the user's response: 
		 * Camera.muted indicates 
		 * the user denied access to a camera; Camera.Unmuted indicates the user allowed access 
		 * to a camera. To determine whether the user has denied or allowed access to the camera without 
		 * handling the status event, use the muted property.In Flash Player, the user can specify permanent privacy settings for a particular domain by right-clicking
		 * (Windows and Linux) or Control-clicking (Macintosh) while a SWF file is playing, selecting Settings, 
		 * opening the Privacy dialog, and selecting Remember. If the user selects Remember, Flash Player no longer 
		 * asks the user whether to allow or deny SWF files from this domain access to your camera.Note: The attachCamera() method will not invoke the dialog box
		 * to Allow or Deny access to the camera if the user has denied access by selecting Remember 
		 * in the Flash Player Settings dialog box. In this case, you can prompt the user to change the
		 * Allow or Deny setting by displaying the Flash Player Privacy panel for the user 
		 * using Security.showSettings(SecurityPanel.PRIVACY).If getCamera() returns null, either the camera is in use by another
		 * application, or there are no cameras installed on the system. To determine whether any cameras
		 * are installed, use the names.length property. To display the Flash Player Camera Settings panel,
		 * which lets the user choose the camera to be referenced by getCamera(), use 
		 * Security.showSettings(SecurityPanel.CAMERA). Scanning the hardware for cameras takes time. When the runtime finds at least one camera, 
		 * the hardware is not scanned again for the lifetime of the player instance. However, if
		 * the runtime doesn't find any cameras, it will scan each time getCamera is called.
		 * This is helpful if the camera is present but is disabled; if your SWF file provides a
		 * Try Again button that calls getCamera, Flash Player can find the camera without the
		 * user having to restart the SWF file.
		 * @param	name	Specifies which camera to get, as determined from the array
		 *   returned by the names property. For most applications, get the default camera 
		 *   by omitting this parameter. To specify a value for this parameter, use the string representation
		 *   of the zero-based index position within the Camera.names array. For example, to specify the third
		 *   camera in the array, use Camera.getCamera("2").
		 * @return	If the name parameter is not specified, this method returns a reference
		 *   to the default camera or, if it is in use by another application, to the first
		 *   available camera. (If there is more than one camera installed, the user may specify
		 *   the default camera in the Flash Player Camera Settings panel.) If no cameras are available
		 *   or installed, the method returns null.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public  function getCamera (name:String = null) : flash.media.Camera
		{
			return flash.media.Camera.getCamera(name);
		}

		public function setCursor (value:Boolean) : void
		{
			cam.setCursor(value);
		}

		/**
		 * Specifies which video frames are transmitted in full (called keyframes)
		 * instead of being interpolated by the video compression algorithm. This method
		 * is applicable only if you are transmitting video using Flash Media Server.
		 * 
		 *   The Flash Video compression algorithm compresses video by transmitting
		 * only what has changed since the last frame of the video; these portions are 
		 * considered to be interpolated frames. Frames of a video can be interpolated according
		 * to the contents of the previous frame. A keyframe, however, is a video frame that
		 * is complete; it is not interpolated from prior frames.To determine how to set a value for the keyFrameInterval parameter,
		 * consider both bandwidth use and video playback accessibility. For example, 
		 * specifying a higher value for keyFrameInterval (sending keyframes less frequently)
		 * reduces bandwidth use. 
		 * However, this may increase the amount of time required to position the playhead
		 * at a particular point in the video; more prior video frames may have to be interpolated
		 * before the video can resume.Conversely, specifying a lower value for keyFrameInterval 
		 * (sending keyframes more frequently) increases bandwidth use because entire video frames
		 * are transmitted more often, but may decrease the amount of time required to seek a 
		 * particular video frame within a recorded video.
		 * @param	keyFrameInterval	A value that specifies which video frames are transmitted in full
		 *   (as keyframes) instead of being interpolated by the video compression algorithm. 
		 *   A value of 1 means that every frame is a keyframe, a value of 3 means that every third frame
		 *   is a keyframe, and so on. Acceptable values are 1 through 48.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function setKeyFrameInterval (keyFrameInterval:int) : void
		{
			cam.setKeyFrameInterval(keyFrameInterval);
		}

		/**
		 * Specifies whether to use a compressed video stream for a local view of the camera.
		 * This method is applicable only if you are transmitting video using Flash Media Server;
		 * setting compress to true lets you see more precisely how the video
		 * will appear to users when they view it in real time.
		 * 
		 *   Although a compressed stream is useful for testing purposes, such as previewing video
		 * quality settings, it has a significant processing cost, because the local view is not 
		 * simply compressed; it is compressed, edited for transmission as it would be over a live
		 * connection, and then decompressed for local viewing.To set the amount of compression used when you set compress to true,
		 * use Camera.setQuality().
		 * @param	compress	Specifies whether to use a compressed video stream (true) 
		 *   or an uncompressed stream (false) for a local view of what the camera
		 *   is receiving.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function setLoopback (compress:Boolean = false) : void
		{
			cam.setLoopback(compress);
		}

		/**
		 * Sets the camera capture mode to the native mode that best meets the specified requirements.
		 * If the camera does not have a native mode that matches all the parameters you pass, 
		 * Flash Player selects a capture mode that most closely synthesizes the requested mode. 
		 * This manipulation may involve cropping the image and dropping frames.
		 * 
		 *   By default, Flash Player drops frames as needed to maintain image size. To minimize the number
		 * of dropped frames, even if this means reducing the size of the image, pass false
		 * for the favorArea parameter.When choosing a native mode, Flash Player tries to maintain the requested aspect ratio
		 * whenever possible. For example, if you issue the command myCam.setMode(400, 400, 30),
		 * and the maximum width and height values available on the camera are 320 and 288, Flash Player sets
		 * both the width and height at 288; by setting these properties to the same value, Flash Player 
		 * maintains the 1:1 aspect ratio you requested.To determine the values assigned to these properties after Flash Player selects the mode
		 * that most closely matches your requested values, use the width, height,
		 * and fps properties.
		 * If you are using Flash Media Server, you can also capture single frames or create time-lapse
		 * photography. For more information, see NetStream.attachCamera().
		 * @param	width	The requested capture width, in pixels. The default value is 160.
		 * @param	height	The requested capture height, in pixels. The default value is 120.
		 * @param	fps	The requested rate at which the camera should capture data, in frames per second.
		 *   The default value is 15.
		 * @param	favorArea	Specifies whether to manipulate the width, height, and frame rate if 
		 *   the camera does not have a native mode that meets the specified requirements. 
		 *   The default value is true, which means that maintaining capture size
		 *   is favored; using this parameter selects the mode that most closely matches 
		 *   width and height values, even if doing so adversely affects 
		 *   performance by reducing the frame rate. To maximize frame rate at the expense 
		 *   of camera height and width, pass false for the favorArea parameter.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function setMode (width:int, height:int, fps:Number, favorArea:Boolean = true) : void
		{
			cam.setMode(width, height, fps, favorArea);
		}

		/**
		 * Specifies how much motion is required to dispatch the activity event. 
		 * Optionally sets the number of milliseconds that must elapse without activity before 
		 * Flash Player considers motion to have stopped and dispatches the event. 
		 * Note: Video can be displayed regardless of the value of the
		 * motionLevel parameter. This parameter determines only when and under
		 * what circumstances the event is dispatched—not whether video is actually being 
		 * captured or displayed.
		 * To prevent the camera from detecting motion at all, pass a value of 100 for the
		 * motionLevel parameter; the activity event is never dispatched. 
		 * (You would probably use this value only for testing purposes—for example, to 
		 * temporarily disable any handlers that would normally be triggered when the event is dispatched.)
		 * 
		 *   To determine the amount of motion the camera is currently detecting, use the
		 * activityLevel property. 
		 * Motion sensitivity values correspond directly to activity values.
		 * Complete lack of motion is an activity value of 0. Constant motion is an activity value of 100.
		 * Your activity value is less than your motion sensitivity value when you're not moving; 
		 * when you are moving, activity values frequently exceed your motion sensitivity value.
		 * 
		 *   This method is similar in purpose to the Microphone.setSilenceLevel() method; 
		 * both methods are used to specify when the activity event
		 * should be dispatched. However, these methods have a significantly different impact
		 * on publishing streams:
		 * Microphone.setSilenceLevel() is designed to optimize bandwidth. 
		 * When an audio stream is considered silent, no audio data is sent. Instead, a single message
		 * is sent, indicating that silence has started. Camera.setMotionLevel() is designed to detect motion and does not affect
		 * bandwidth usage. Even if a video stream does not detect motion, video is still sent.
		 * @param	motionLevel	Specifies the amount of motion required to dispatch the
		 *   activity event. Acceptable values range from 0 to 100. The default value is 50.
		 * @param	timeout	Specifies how many milliseconds must elapse without activity 
		 *   before Flash Player considers activity to have stopped and dispatches the activity event.
		 *   The default value is 2000 milliseconds (2 seconds).
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function setMotionLevel (motionLevel:int, timeout:int = 2000) : void
		{
			cam.setMotionLevel(motionLevel, timeout);
		}

		/**
		 * Sets the maximum amount of bandwidth per second or the required picture quality
		 * of the current outgoing video feed. This method is generally applicable only if
		 * you are transmitting video using Flash Media Server.
		 * 
		 *   Use this method to specify which element of the outgoing video feed is more
		 * important to your application—bandwidth use or picture quality.To indicate that bandwidth use takes precedence, pass a value for bandwidth
		 * and 0 for quality. Flash Player transmits video at the highest quality
		 * possible within the specified bandwidth. If necessary, Flash Player reduces picture
		 * quality to avoid exceeding the specified bandwidth. In general, as motion increases,
		 * quality decreases.To indicate that quality takes precedence, pass 0 for bandwidth 
		 * and a numeric value for quality. Flash Player uses as much bandwidth
		 * as required to maintain the specified quality. If necessary, Flash Player reduces the frame
		 * rate to maintain picture quality. In general, as motion increases, bandwidth use also
		 * increases.To specify that both bandwidth and quality are equally important, pass numeric 
		 * values for both parameters. Flash Player transmits video that achieves the specified quality
		 * and that doesn't exceed the specified bandwidth. If necessary, Flash Player reduces the 
		 * frame rate to maintain picture quality without exceeding the specified bandwidth.
		 * @param	bandwidth	Specifies the maximum amount of bandwidth that the current outgoing video
		 *   feed can use, in bytes per second. To specify that Flash Player video can use as much bandwidth
		 *   as needed to maintain the value of quality, pass 0 for 
		 *   bandwidth. The default value is 16384.
		 * @param	quality	An integer that specifies the required level of picture quality,
		 *   as determined by the amount of compression being applied to each video frame. 
		 *   Acceptable values range from 1 (lowest quality, maximum compression) to 100 (highest 
		 *   quality, no compression). To specify that picture quality can vary as needed to avoid 
		 *   exceeding bandwidth, pass 0 for quality.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function setQuality (bandwidth:int, quality:int) : void
		{
			cam.setQuality(bandwidth, quality);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			cam = null;
		}
	}
}
