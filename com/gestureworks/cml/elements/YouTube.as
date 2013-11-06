package  com.gestureworks.cml.elements
{
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.Security;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	/**
	 * The YouTube element retrieves and streams a Youtube video using the Youtube API. The source of the file will be the Youtube video's ID.
	 * The video must be set to allow embedding and accessible without a user sign in.
	 * 
	 * <p>The Video ID is the 10-digit ID associated with the video link. For example, a direct URL to the video used in this example is:
	 * http://www.youtube.com/watch?v=h0MZX-D8xzA. Notice the "h0MZX-D8xzA" is the video's id. A video must be set to allow embedding from its owner
	 * to be used by the YouTube API. If you receive "Error 100" or "Error 101", or "150", the video either no longer exists, or its embedding has 
	 * been disabled.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var ytElement:YouTubeElement = new YouTubeElement();
		ytElement.src = "h0MZX-D8xzA";
		ytElement.autoplay = true;
		ytElement.chrome = true;
		addChild(ytElement);
		ytElement.init();
	 *
	 * </codeblock>
	 * @author Ideum
	 */
	public class YouTube extends TouchContainer
	{
		private const YTDOMAIN:String = "http://www.youtube.com";
		private const YTAPI:String = "http://www.youtube.com/apiplayer?version=3";
		
		private var player:Object;
		private var loader:Loader;
		
		private var _loaded:Boolean = false;
		private var timer:Timer;
		
		public function get loaded():Boolean { return _loaded; }
		
		/**
		 * Constructor
		 */
		public function YouTube() 
		{
			super();
			mouseChildren = true;
			Security.allowDomain(YTDOMAIN);
		}
		
		private var _VIDEO_ID:String;
		/**
		 * Sets the video ID to be loaded. Must be present or the element will crash.
		 */
		public function get src():String { return _VIDEO_ID; }
		public function set src(value:String):void {
			_VIDEO_ID = value;
		}
		
		private var _width:Number = 480;
		/**
		 * Sets the video width.
		 * @default 480
		 */
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
		}
		
		private var _height:Number = 360;
		/**
		 * Sets the video height.
		 * @default 360
		 */
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
		}
		
		private var _chrome:Boolean = false;
		/**
		 * Sets whether or not to use the chromed (player with buttons) or not.
		 * @default false
		 */
		public function get chrome():Boolean { return _chrome; }
		public function set chrome(value:Boolean):void { 
			_chrome = value;
		}
		
		private var _autoplay:Boolean = false;
		/**
		 * Sets whether or not the video plays immediately. Note: the player does not
		 * start loading the FLV it requests until a call to play the video, or seek to
		 * the video is called.
		 * @default false;
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}
		
		private var _isPlaying:Boolean = false;
		public function get isPlaying():Boolean { return _isPlaying; }
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			loadVideo();
		}
		
		/**
		 * Start playing from the beginning.
		 */
		public function play():void {
			timer.stop();
			timer.reset();
			player.seekTo(0, true);
			if (!_isPlaying){
				resume();
			}
		}
		
		/**
		 * Resume from last spot.
		 */
		public function resume():void {
			player.playVideo();
			_isPlaying = true;
			timer.start();
		}
		
		/**
		 * pauses the video
		 */
		public function pause():void {
			player.pauseVideo();
			_isPlaying = false;
			timer.stop();
		}
		
		/**
		 * stops the video
		 */
		public function stop():void {
			player.pauseVideo();
			player.seekTo(0, true);
			_isPlaying = false;
			timer.stop();
			timer.reset();
		}
		
		/**
		 * seek 
		 * @param	value
		 */
		public function seek(value:Number, seekAhead:Boolean):void {
			var goTo:Number = Math.floor((value / 100) * player.getDuration());
			player.seekTo(value, seekAhead);
		}
		
		/**
		 * closes the video
		 */
		public function close():void {
			player.stopVideo();
			player.visible = false;
		}
		
		private function loadVideo():void {
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
			if(!_chrome){
				loader.load(new URLRequest(YTAPI));
			}
			else if (_chrome) {
				loader.load(new URLRequest("http://www.youtube.com/v/" + _VIDEO_ID + "?version=3"));
			}
		}
		
		private function onLoaderInit(e:Event):void {
			addChild(loader);
			loader.content.addEventListener("onReady", onPlayerReady);
			loader.content.addEventListener("onError", onPlayerError);
		}
		
		private function onPlayerReady(e:Event):void {
			loader.content.removeEventListener("onReady", onPlayerReady);
			
			player = loader.content;
			player.setSize(_width, _height);
			if (_autoplay){
				player.loadVideoById(_VIDEO_ID);
				_isPlaying = true;
			}
			else if (!_autoplay) {
				player.cueVideoById(_VIDEO_ID);
			}
			_loaded = true;
			
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		private function onPlayerError(e:Event):void {
			trace("Player error: ", Object(e).data);
		}
		
		private function onTimer(e:TimerEvent):void {
			var position:Number = player.getCurrentTime() / player.getDuration();
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "position", position));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			player = null;
			
			if(loader){
				loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoaderInit);
				loader.content.removeEventListener("onReady", onPlayerReady);
				loader.content.removeEventListener("onError", onPlayerError);
				loader.unload();
				loader = null;
			}
		
			if(timer){
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer = null;
			}
		}
	}

}