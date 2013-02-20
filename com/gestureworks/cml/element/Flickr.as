package  com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.BitmapFactory;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.Security;
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.events.*;
	import flash.display.PixelSnapping;
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
	 * @author josh
	 * @see YouTube
	 */
	public class Flickr extends BitmapFactory
	{
		private var displayPic:Bitmap = null;
		private var loader:Loader;
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
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded;}
		
		private var _description:String = "";
		public function get description():String { return _description; }
		
		/**
		 * CML display callback Initialisation
		 */
		override public function displayComplete():void {
			super.displayComplete();
			
			service = new FlickrService(_API_KEY);
			service.addEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
			service.addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			service.photos.getInfo(_src);
		}
		
		
		/**
		 * Initialisation method
		 */
		public function init():void
		{
			displayComplete();
		}
		
		private function errorEvent(e:IOErrorEvent):void {
			trace("Error in loading file:", e);
		}
		
		private function loadImage(e:FlickrResultEvent):void {
			
			if (e.success) {
				_description = e.data.photo.description;
				var picLink:String = "http://farm1.staticflickr.com/" + e.data.photo.server + "/" + e.data.photo.id + "_" + 
					e.data.photo.secret + ".jpg";
			
				open(picLink);
			}
			else { trace("Image " + _src + " failed to load. Please check your image ID and make sure it is accurate.");}
			
		}
		
		/**
		 * Dispose method to nullify the children and remove listener
		 */
		override public function dispose():void {
			super.dispose();
			
			service.removeEventListener(FlickrResultEvent.PHOTOS_GET_INFO, loadImage);
			service.removeEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			service = null;
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
		}
	}

}