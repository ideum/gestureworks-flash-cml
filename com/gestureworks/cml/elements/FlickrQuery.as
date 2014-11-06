package  com.gestureworks.cml.elements
{
	import com.adobe.webapis.flickr.methodgroups.Photos;
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
	   
	 *
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see YouTube
	 */
	public class FlickrQuery extends TouchContainer
	{
		private var service:FlickrService;
		public var resultPhotos:Array;
		private var _data:*;
		public function get data():Object { return _data; }
		
		/**
		 * Constructor
		 */
		public function FlickrQuery() 
		{
			super();
			mouseChildren = true;
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
		/**
		 * Groupid is currently not supported by the Actionscript version of the Flickr API.
		 */
		public function get groupid():String { return _group_id; }
		public function set groupid(value:String):void {
			_group_id = value;
		}
		
		private var _photosetid:String = "";
		/**
		 * Photoset id is used to return every photo in a photoset. This does not run on search, it needs to be used with the flickrSet() method to retrieve results.
		 */
		public function get photosetid():String { return _photosetid; }
		public function set photosetid(value:String):void {
			_photosetid = value;
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
		
		private var _resultsPerPage:int = 12;
		/**
		 * Select the number of results to turn per page.
		 * @default 12
		 */
		public function get resultsPerPage():int { return _resultsPerPage; }
		public function set resultsPerPage(value:int):void {
			_resultsPerPage = value;
		}
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded;}
		
		private var _pages:Number = 0;
		/**
		 * Read-only property indicating number of page results returned.
		 */
		public function get pages():Number { return _pages; }
		
		private var _results:Number = 0;
		private var checkTags:Array;
		public var pageNumber:int = 1;
		/**
		 * Read-only property indicating total results per page returned.
		 */
		public function get results():Number { return _results; }
		
		private var _total:int = 0;
		/**
		 * Read-only property to get the total number of results available to a search (regardless of per page limitations)
		 */
		public function get total():int { return _total; }
		
		private var _setDescription:String = "";
		/**
		 * Read only property that returns the description of a set after set info is returned.
		 */
		public function get setDescription():String { return _setDescription; }
		
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			service = new FlickrService(_API_KEY);
			service.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, onSearchComplete);
		}
		
		public function flickrSearch():void {
			service.photos.search(_user_id, _tags, _tag_mode, _text, null, null, null, null, -1, "", _resultsPerPage, 1, "date-posted-desc");
		}
		
		public function flickrSet():void {
			service.addEventListener(FlickrResultEvent.PHOTOSETS_GET_PHOTOS, onSetComplete);
			service.photosets.getPhotos(_photosetid);
		}
		
		public function flickrSetInfo():void {
			
			service.addEventListener(FlickrResultEvent.PHOTOSETS_GET_INFO, onSetInfoComplete);
			service.photosets.getInfo(_photosetid);
		}
		
		private function onSearchComplete(e:FlickrResultEvent):void {			
			var pList:Photos = new Photos(service);
			
			_pages = e.data.photos.pages;
			_total = e.data.total;
			resultPhotos = e.data.photos.photos;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "value", "flickrResult"));
			
		}
		
		private function onSetComplete(e:FlickrResultEvent):void {
			service.removeEventListener(FlickrResultEvent.PHOTOSETS_GET_PHOTOS, onSetComplete);
			resultPhotos = e.data.photoset.photos;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "value", "flickrResult"));
		}
		
		private function onSetInfoComplete(e:FlickrResultEvent):void {
			service.removeEventListener(FlickrResultEvent.PHOTOSETS_GET_INFO, onSetInfoComplete);
			
			// TO DO: Add field or way to get set info.
			_total = e.data.photoSet.photoCount;
			_setDescription = e.data.photoSet.description;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "value", "flickrInfoResult"));
		}
		
		// Update photo page.
		public function nextPage():void {
			resultPhotos = [];
			
			pageNumber++;
			if (pageNumber > _pages)
				pageNumber = _pages;
			
			service.photos.search(_user_id, _tags, _tag_mode, _text, null, null, null, null, -1, "", _resultsPerPage, 2, "date-posted-desc");
			
			//resultPhotos = _data.photos.photos;
		}
		
		public function previousPage():void {
			resultPhotos = [];
			
			pageNumber--;
			if (pageNumber < 1)
				pageNumber = 1;
			
			service.photos.search(_user_id, _tags, _tag_mode, _text, null, null, null, null, -1, "", _resultsPerPage, pageNumber, "date-posted-desc");
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			resultPhotos = null;
			checkTags = null;
			service.removeEventListener(FlickrResultEvent.PHOTOS_SEARCH, onSearchComplete);
			service = null;			
			_data = null;
		}
	}

}