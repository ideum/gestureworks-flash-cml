package  com.gestureworks.cml.elements
{
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.events.*;
	import com.gestureworks.cml.events.StateEvent;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.Security;
	/**
	 * The Flick element provides access to images stored on Flickr through the Flickr API. To access the image, one must have the image's ID from the flickr server, and a Flickr API Key.
	 * Flickr API keys start out at free and have some subscription plans depending on the amount of use they receive. They are available at: http://www.flickr/com/service/api
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var flickrImg:Flickr = new Flickr();
		flickrImg.apikey = "ENTER YOUR FLICKR API KEY";
		flickrImg.src = "5703998760";
		addChild(flickrImg);
		
		//Call init() once you're ready to display the class.
		flickrImg.init();
	 *
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see YouTube
	 */
	public class Flickr extends Image
	{
		private var service:FlickrService;
		
		/**
		 * Constructor
		 */
		public function Flickr() 
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
		
		
		private var _src:String;
		/**
		 * A string for the image id.
		 */
		override public function get src():String { return _src; }
		override public function set src(value:String):void {
			_src = value;
		}
		
		private var _url:String;
		/**
		 * A string for the image url.
		 */
		public function get url():String { return _url; }
		public function set url(value:String):void {
			_url = value;
		}		
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded;}
		
		
		
		private var _description:String = "";
		public function get description():String { return _description; }
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			if (isLoaded)
				return;
			if (src && src.length > 1) {
				service = new FlickrService(_API_KEY);
				service.addEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
				service.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
				service.photos.getInfo(_src);
			}
		}
		
		private function errorEvent(e:IOErrorEvent):void {
			trace("Error in loading file:", e);
		}
		

		private function loadImage(e:FlickrResultEvent):void {			

			e.target.removeEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			
			if (e.success) {
				_description = e.data.photo.description;
				url = "http://farm1.staticflickr.com/" + e.data.photo.server + "/" + e.data.photo.id + "_" + 
					e.data.photo.secret + ".jpg";
	
				if (!isLoaded)	
					open(url);

			}
			else { trace("Image " + _src + " failed to load. Please check your image ID and make sure it is accurate.");}
		}
		
		/*
		 * Opens an external image file
		 * @param	file
		 */
		override public function open(file:String=null):void
		{
			if (file) url = file;
			img = new ImageLoader(url);
			img.load(); 
			img.addEventListener(LoaderEvent.COMPLETE, loadComplete);
			img.addEventListener(StateEvent.CHANGE, onPercentLoad);
		}			
					
		
		/*
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			
			service.removeEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
			service.removeEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			service = null;
		}
	}

}