package  com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.net.URLRequest;
	
	/**
	 * The YoutubeElement is an object that retrieves and streams a Youtube video using the Youtube API. The source of the file will be the Youtube video's ID.
	 * The video must be set to allow embedding and accessible without a user sign in.
	 * 
	 * The Video ID is the 10-digit ID associated with the video link. For example, a direct URL to the video used in this example is:
	 * http://www.youtube.com/watch?v=h0MZX-D8xzA. Notice the "h0MZX-D8xzA" is the video's id. A video must be set to allow embedding from its owner
	 * to be used by the YouTube API. If you receive "Error 100" or "Error 101", or "150", the video either no longer exists, or its embedding has 
	 * been disabled.
	 * 
	 * YoutubeElement has the following parameters: src, chrome, autoplay
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
	 * @author josh
	 */
	public class YouTubeElement extends ElementFactory
	{
		private const YTDOMAIN:String = "http://www.youtube.com";
		private const YTAPI:String = "http://www.youtube.com/apiplayer?version=3";
		
		private var player:Object;
		private var loader:Loader;
		private var playing:Boolean = false;
		
		private var _loaded:Boolean = false;
		public function get loaded():Boolean { return _loaded; }
		
		public function YouTubeElement() 
		{
			super();
			
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
		 * @default: 480;
		 */
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
		}
		
		private var _height:Number = 360;
		/**
		 * Sets the video height.
		 * @default: 360;
		 */
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
		}
		
		private var _chrome:Boolean = false;
		/**
		 * Sets whether or not to use the chromed (player with buttons) or not.
		 * @default: false
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
		 * @default: false;
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
		}
		
		override public function displayComplete():void {
			super.displayComplete();
			
			loadVideo();
		
		}
		
		public function init():void
		{
			displayComplete();
		}
		
		//Start playing from the beginning.
		public function play():void {
			player.seekTo(0, true);
			if (!playing){
				resume();
			}
		}
		
		//Resume from last spot.
		public function resume():void {
			player.playVideo();
			playing = true;
		}
		
		//Pause
		public function pause():void {
			player.pauseVideo();
			playing = false;
		}
		
		//Stop
		public function stop():void {
			player.pauseVideo();
			player.seekTo(0, true);
			playing = false;
		}
		
		//Seek
		public function seek(value:Number):void {
			player.seekTo(value, true);
		}
		
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
				playing = true;
			}
			else if (!_autoplay) {
				player.cueVideoById(_VIDEO_ID);
			}
			_loaded = true;
		}
		
		private function onPlayerError(e:Event):void {
			trace("Player error: ", Object(e).data);
		}
		
		override public function dispose():void {
			super.dispose();
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			player.destroy();
			player = null;
			
			loader.content.removeEventListener("onError", onPlayerError);
			loader.unload();
			loader = null;
			
			_loaded = false;
		}
	}

}