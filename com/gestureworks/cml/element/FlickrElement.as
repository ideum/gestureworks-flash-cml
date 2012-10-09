package  com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.events.*;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	/**
	 * FlickrElement provides access to images stored on Flickr through the Flickr API. To access the image, one must have the image's ID from the flickr server, and a Flickr API Key.
	 * Flickr API keys start out at free and have some subscription plans depending on the amount of use they receive. They are available at: http://www.flickr/com/service/api
	 * 
	 * FlickrElement has the following parameters: apikey, src
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var flickrImg:FlickrElement = new FlickrElement();
		flickrImg.apikey = "ENTER YOUR FLICKR API KEY";
		flickrImg.src = "5703998760";
		addChild(flickrImg);
		
		//Call init() once you're ready to display the class.
		flickrImg.init();
	 *
	 * </codeblock>
	 * @author josh
	 */
	public class FlickrElement extends ElementFactory
	{
		private var displayPic:Bitmap = null;
		private var loader:Loader;
		private var service:FlickrService;
		
		/**
		 * constructor
		 */
		public function FlickrElement() 
		{
			super();
			
			Security.loadPolicyFile("http://farm1.static.flickr.com/crossdomain.xml");
			Security.loadPolicyFile("http://farm2.static.flickr.com/crossdomain.xml");
			Security.loadPolicyFile("http://farm3.static.flickr.com/crossdomain.xml");
			Security.loadPolicyFile("http://farm4.static.flickr.com/crossdomain.xml");
			Security.loadPolicyFile("http://farm5.static.flickr.com/crossdomain.xml");
		}
		
		private var _API_KEY:String;
		/**
		 * The user's API key, necessary for making queries to the API,
		 * but not necessary for single images.
		 */
		public function get apikey():String { return _API_KEY; }
		public function set apikey(value:String):void {
			_API_KEY = value;
		}
		
		
		private var _imageId:String;
		/**
		 * A string for the image id.
		 */
		public function get src():String { return _imageId; }
		public function set src(value:String):void {
			_imageId = value;
		}
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded;}
		
		
		/**
		 * CML display callback initialisation
		 */
		override public function displayComplete():void {
			super.displayComplete();
			
			service = new FlickrService(_API_KEY);
			service.addEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
			service.photos.getInfo(_imageId);
		}
		
		
		/**
		 * initialisation method
		 */
		public function init():void
		{
			displayComplete();
		}
		
		
		private function loadImage(e:FlickrResultEvent):void {
			//trace(e.data.photo.server);
			//trace(e.data.photo.id);
			if(e.success){
				var picLink:String = "http://farm1.staticflickr.com/" + e.data.photo.server + "/" + e.data.photo.id + "_" + 
					e.data.photo.secret + ".jpg";
			
				var imageRequest:URLRequest = new URLRequest(picLink);
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, displayImage);
				loader.load(imageRequest);
			}
			else { trace("Image " + _imageId + " failed to load. Please check your image ID and make sure it is accurate.");}
		}
		
		private function displayImage(e:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, displayImage);
			
			displayPic = e.currentTarget.content;
			
			if (displayPic.width > width && width > 0) {
				displayPic.height = (displayPic.height / 100) * ((width / displayPic.width) * 100);
				displayPic.width = width;
			}
			if (displayPic.height > height && height > 0) {
				displayPic.width = (displayPic.width / 100) * ((height / displayPic.height) * 100);
				displayPic.height = height;
			}
			
			addChild(displayPic);
			_loaded = "loaded";
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _loaded));
		}
		
		/**
		 * sets the width and height of frame
		 */
		public function updateFrame():void {
			width = displayPic.width;
			height = displayPic.height;
		}
		
		/**
		 * dispose method to nullify the children and remove listener
		 */
		override public function dispose():void {
			super.dispose();
			
			service.removeEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
			service = null;
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			loader.unload();
			loader = null;
			
			displayPic = null;
		}
	}

}