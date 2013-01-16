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
	/**
	 * The FlickQuery is designed to be used with the dock to set a query in CML that may be used in conjunction with searchFields and the dials to provide a way to search
	 * via groups, users, and tags.
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
	public class FlickrQuery extends ElementFactory
	{
		private var displayPic:Bitmap = null;
		private var loader:Loader;
		private var service:FlickrService;
		public var resultPhotos:Array;
		
		/**
		 * Constructor
		 */
		public function FlickrQuery() 
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
		
		private var _user_id:String = "";
		public function get userid():String { return _user_id; }
		public function set userid(value:String):void {
			_user_id = value;
		}
		
		private var _group_id:String = "";
		public function get groupid():String { return _group_id; }
		public function set groupid(value:String):void {
			_group_id = value;
		}
		
		private var _tags:String = "";
		/**
		 * A comma separated list of tags to search for.
		 */
		public function get tags():String { return _tags; }
		public function set tags(value:String):void {
			_tags = value;
		}
		
		private var _text:String = "";
		/**
		 * An optional string to search for, this will search titles, descriptions, and tags.
		 */
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
		}
		
		private var _tag_mode:String = "all";
		/**
		 * Either "any" for an OR combination of tags, or "all" for an AND combination.
		 * @default "all"
		 */
		public function get tagMode():String { return _tag_mode; }
		public function set tagMode(value:String):void {
			_tag_mode = value;
		}
		
		private var _is_commons:Boolean = false;
		/**
		 * Return images that are part of the Flickr commons project.
		 */
		public function get isCommons():Boolean { return _is_commons; }
		public function set isCommons(value:Boolean):void {
			_is_commons = value;
		}
		
		// TO DO: Add in Latitude, Longitude, and geo-search radius as options?
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded;}
		
		
		/**
		 * CML display callback Initialisation
		 */
		override public function displayComplete():void {
			super.displayComplete();
			
			service = new FlickrService(_API_KEY);
			service.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, onSearchComplete);
			//service.photos.search(_user_id, _tags, _tag_mode, _text, null, null, null, null, -1, "", 100, 100, "date-posted-desc", _group_id);
		}
		
		
		/**
		 * Initialisation method
		 */
		public function init():void
		{
			displayComplete();
		}
		
		public function flickrSearch():void {
			service.photos.search(_user_id, _tags, _tag_mode, _text, null, null, null, null, -1, "", 100, 100, "date-posted-desc");
		}
		
		private function onSearchComplete(e:FlickrResultEvent):void {
			trace("Search complete");
			
			var xPos:Number = 0;
			var yPos:Number = 0;
			var rot:Number = 0;
			
			if (e.success) {
				trace("Data: ", e.data, e.data.photos.page);
				/*if (e.data.photos.photos.length > 0) {
					for (var i:Number = 0; i < 10; i++) {
						var img:Flickr = new Flickr();
						img.src = e.data.photos.photos[i].id;
						img.apikey = _API_KEY;
						stage.addChild(img);
						
						img.init();
						
						img.x = xPos;
						xPos += 300;
						img.rotation = rot;
						rot += 9;
						if (xPos > stage.stageWidth){
							xPos = 0;
							yPos += 400;
						}
					}
				}*/
				
				resultPhotos = e.data.photos.photos;
				trace("ResultPhotos info:", resultPhotos.length);
			}
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", "flickrResult"));
		}
		
		
		/**
		 * Dispose method to nullify the children and remove listener
		 */
		override public function dispose():void {
			super.dispose();
			
			service.removeEventListener(FlickrResultEvent.PHOTOS_SEARCH, onSearchComplete);
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