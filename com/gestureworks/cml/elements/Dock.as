package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.components.*;
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import com.greensock.TweenLite;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * Designed for the database version of the <code>CollectionViewer</code>, the <code>Dock</code> is a retractable control station intended to guide users through 
	 * database query construction by vertically spinning a set of dials populated with predefined search terms. Each dial change submits a new query, as a combination 
	 * of aligned dial terms, and can produce visual result set representations in its menu album. The album can be horizontally scrolled and images can be loaded to 
	 * stage by either tapping a result or dragging a result to the stage. 
	 */
	public class Dock extends Drawer
	{		
		private var TOTAL_RESULTS:int = 0;
		
		public var loadCnt:int = 0;
		public var searchTerms:Array = [];
		private var _returnFields:Array = [];		
		protected var _searchFieldsArray:Array;
		public var searchFields:String;
				
		public var result:*;	
		public var resultCnt:int = 0;
		
		public var isLoading:Boolean = false;
		public var loadText:Text;	
		
		public var maxClones:int = 30;		

		private var srcMap:Dictionary;
		private var cloneMap:LinkedMap;
		
		public var placeHolders:Array = [];
		private var _placeHolderIndex:int = 0;	
		private var dropLocation:Graphic;
		
		public var dockText:Array = [];
		public var dials:Array = [];		
		public var cmlIni:Boolean = false;

		public var connection:NetConnection;		
		public var gateway:String;
		public var responder:Responder;
		public var maxLoad:int = 1;
	
		public var amountToShow:int = -1;
		//public var autoShuffle:int = -1;
		public var templates:Array = [];		

		public var album:MenuAlbum;
		public var collectionViewer:CollectionViewer;

		private var flickrQuery:FlickrQuery;

		//search term filtering attributes
		private var _searchTermFilters:Boolean = false;
		private var combinations:int = 0;
		private var dial2Filters:Object = new Object();
		private var dial3Filters:Object = new Object();
		private var progress:Text;
		private var filteringInProcess:Boolean = false;		

		public var pos:String;

		// Pagination
		private var resultsDict:Array;
		private var currentPage:int;
		private var pageCount:int;
		
		/**
		 * Constructor
		 */
		public function Dock() 
		{
			super();
		
		}
		
		private var _nextArrow:*;
		/**
		 * An optional way to set a custom graphic for multiple pages of results. Setting this will remove it from the childList to be placed inside the menu album.
		 */
		public function get nextArrow():* { return _nextArrow; }
		public function set nextArrow(value:String):void {
			_nextArrow = searchChildren(value);
			if (contains(_nextArrow))
				removeChild(_nextArrow);
		}
		
		private var _previousArrow:*;
		/**
		 * An optional way to set a custom graphic for multiple pages of results. Setting this will remove it from the childList to be placed inside the menu album.
		 */		
		public function get previousArrow():* { return _previousArrow; }
		public function set previousArrow(value:String):void {
			_previousArrow = searchChildren(value);
			if (contains(_previousArrow))
				removeChild(_previousArrow);
		}
		
		private var serverTimer:Timer;
		
		private var _serverTimeOut:Number = 30;
		/**
		 * The amout of time allotted for server connection or query results
		 */
		public function get serverTimeOut():Number { return _serverTimeOut; }
		public function set serverTimeOut(t:Number):void
		{
			_serverTimeOut = t;
		}
		
		private function serverTimeExpired(e:TimerEvent):void
		{
			dockText[1].text = "Server Time Expired: Make a new selection.";
			dockText[1].visible = true;
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void
		{
			super.init();
			
			collectionViewer = DisplayUtils.getParentType(CollectionViewer,this);
			_searchFieldsArray = searchFields.split(",");
			
			dockText = searchChildren(".dock-text", Array);

			var c:Container = childList.getCSSClass("dials", 0);
			dials = c.searchChildren(Dial, Array)
						
			album = c.searchChildren(MenuAlbum);  //TODO: for testing purposes; need to provide more reliable access to album		
			
			if (!flickrQuery) {
				flickrQuery = searchChildren(FlickrQuery);
				
				if (flickrQuery) {
					flickrQuery.init();
				
					if (_resultsPerPage > 0)
						flickrQuery.resultsPerPage = _resultsPerPage;
					else // This is to avoid conflict with CollectiveAccess pagination. 
						_resultsPerPage = flickrQuery.resultsPerPage;
					
					if (flickrQuery.photosetid != "") {
						
						flickrQuery.addEventListener(StateEvent.CHANGE, flickrSetup);
						flickrQuery.flickrSetInfo();
					}
				}
			}
			
			addEventListener(StateEvent.CHANGE, selection);
			addEventListener(StateEvent.CHANGE, dragSelection);
			addEventListener(StateEvent.CHANGE, dropSelection);

			CMLParser.addEventListener(CMLParser.COMPLETE, cmlInit);
			
			for (var j:int = 0; j < dials.length; j++) {
				dials[j].addEventListener(StateEvent.CHANGE, onDialChange);
				searchTerms[j] = "";
			}
			
			searchTermFiltering();
			
			srcMap = new Dictionary;		
			cloneMap = new LinkedMap(false);

			//preloadClones(maxClones);
		}
		
		private function flickrSetup(e:StateEvent):void 
		{
			flickrQuery.removeEventListener(StateEvent.CHANGE, flickrSetup);
			TOTAL_RESULTS = flickrQuery.total;
			dockText[1].text = "Use the dials to make a selection. Tap on the thumbnails to load them onto the table.\n" + TOTAL_RESULTS + " items in Collection."
			// TO-DO: retrieve info description of FlickrGroup;
			//var container:Container = searchChildren(
			var aCon:Container = searchChildren("#album-container");
			if (aCon)
				var bCon:Container = aCon.searchChildren("#info-pane");
			if (bCon){
				var infoText:* = bCon.searchChildren("#info-text");
				
				if (!infoText) return;
				infoText.htmlText = flickrQuery.setDescription;
				
				if (infoText.parent is ScrollPane)
					ScrollPane(infoText.parent).updateLayout(infoText.parent.width, infoText.parent.height);					
			}
			return;
		}
			
		/**
		 * 
		 */
		public function get returnFields():* {return _returnFields; }
		public function set returnFields(f:*):void{
			if(f is XML)
				f = f.toString().split(",");
			if(f is Array)
				_returnFields = f;
		}
		
		private var _resultsPerPage:int = 0;
		/**
		 * Sets the results for pagination. If left unset, CollectiveAccess will return any and all results for a search. FlickrQuery will default to whatever
		 * amount it has set (default for FlickrQuery: 12), otherwise the resultsPerPage property is definitive whether FlickrQuery or CollectiveAccess is used.
		 */
		public function get resultsPerPage():int { return _resultsPerPage; }
		public function set resultsPerPage(value:int):void {
			_resultsPerPage = value;
		}

		private var previews:Array = [];
		private var locked:Array = [];
		
		// srcMap // 
		
		private function addSrc(src:String, clone:Component):void
		{	
			if (srcMap[clone])  //remove previous references
			{
				var prevSrc:String = srcMap[clone];
				var preview:TouchContainer = srcMap[prevSrc]["preview"];
				delete srcMap[clone];
				delete srcMap[preview];
				delete srcMap[prevSrc];
			}
			
			srcMap[src] = new Dictionary();
			srcMap[src]["clone"] = clone;			
			srcMap[clone] = src;
		}
	
		private function addPreview(clone:Component, preview:TouchContainer):void
		{	
			var src:String = srcMap[clone];	
			var oldPrev:TouchContainer = srcMap[src]["preview"];
			if (oldPrev)
				delete srcMap[oldPrev];
			
			srcMap[src]["preview"] = preview;			
			srcMap[preview] = src;			
			
			if (previews.indexOf(preview) == -1)
			{
				previews.push(preview);
				locked.push(cloneMap.getKeyArray().indexOf(clone));
			}
		}
		
		private function removeSrc(src:String):void
		{
			var k:*;
			if (!srcMap[src]) return;
			delete srcMap[src]["clone"];
			delete srcMap[src]["preview"];
			
			for (k in srcMap[src]) {
				delete srcMap[src][k];
			}
			
			delete srcMap[src];
		}
	
		private function removeByKey(key:String):void
		{
			if (!srcMap[key]) return;
			if (!srcMap[key]["preview"]) return;
			
			var index:int = previews.search(srcMap[key]["preview"]);
			
			if (index == -1)
				return;
				
			var original:Array = previews.slice(); 
			var temp:Array = original.splice(index, 1); 
			temp.shift();
			original = original.concat(temp); 
			previews = original;			
		}
		
		
		// preload // 
		private var loadIndex:int = 0;
		
		
		/**
		 * Preloads the maxClones value of template clones
		 */
		public function preloadClones():void
		{			
			if (loadIndex == maxClones) return;
			
			var clone:Component;
			clone = templates[0].clone();
			cloneMap.append(clone, preloadExp( clone, new LinkedMap() ));
			loadIndex++;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "preloaded", loadIndex));
		}
		
		private function preloadExp(obj:*, lm:LinkedMap):LinkedMap 
		{	
			if (!("state" in obj)) 
				return lm;
			
			// Iterate through the properties of the object to find {values}
			for (var s:String in obj.state[0]) {
				if ((String(obj.state[0][s])).indexOf("{") != -1) {
					
					// Create substring
					var str:String = String(obj.state[0][s]).substring(1, String(obj.state[0][s]).length -1);
					obj.state[0][s] = str;
					if (s == "src") 
						lm.prepend(obj, s);
					else
						lm.append(obj, s);
				}
			}
			
			if (obj is DisplayObjectContainer) {
				for (var i:int = 0; i < obj.numChildren; i++) {
					lm = preloadExp(obj.getChildAt(i), lm);		
				}
			}
			return lm;
		}
		
		
		private function resolveExp(res:*):void
		{			
			var obj:Object = cloneMap.value.key;
			var prop:String = cloneMap.value.value;
			var exp:* = obj["state"][0][prop];
			var src:String = res[exp];
			
			if ("updateLayout" in obj)
				obj["updateLayout"]();
			
			if (srcMap[src]) {	
				addPreview(srcMap[src]["clone"], getPreview(srcMap[src]["clone"]));
				onCloneLoad();
			}
			else {
				nextClone(res);
			}
				
		}
		
		private function incrementCloneMap():void
		{
			if (cloneMap.hasNext())
				cloneMap.next();
			else
				cloneMap.reset();
		}
		
		private function availableClone():void
		{
			unlockedClone();
			var unavailable:int = locked.length;
			var clone:Component = cloneMap.key;
						
			while (clone.visible)
			{
				incrementCloneMap();
				if (unavailable == maxClones)
					break;
				if (locked.indexOf(cloneMap.index) != -1)
					continue;
				clone = cloneMap.key;
				unavailable++;
			}			
		}
		
		private function unlockedClone():void
		{
			while (locked.indexOf(cloneMap.index) != -1)
				incrementCloneMap();
		}
		
		private function nextClone(res:*):void
		{
			availableClone();
			var clone:Component = cloneMap.key;
			var obj:Object;
			var prop:String;
			var exp:*;
			var src:String;
			
			if (clone.visible)
				onCloneChange(null, clone);
			
			var keys:Array = cloneMap.value.getKeyArray();
			var values:Array = cloneMap.value.getValueArray();
			
			for (var i:int = 0; i < keys.length; i++)
			{
				obj = keys[i];
				prop = values[i];
				exp = String(obj["state"][0][prop]).replace(/[\s\r\n{}]*/gim,"");
				
				StateUtils.loadState(obj, 0, true);
				
				if (exp in res)
				{
					try {
						obj[prop] = null;						
					}
					catch (e:Error) {
						obj[prop] = "";
					}
					
					if (res[exp]) {
						obj[prop] = res[exp];
						if (prop == "src") {
							src = obj[prop];
							processSrc(src, obj);
						}
					}
				}
			}
		}
		
		private function processSrc(src:String, obj:Object):void
		{
			var clone:* = cloneMap.key;
			
			addSrc(src, clone); 							
			obj.close();
			clone.addEventListener(StateEvent.CHANGE, onCloneLoad);

			if (obj is Flickr) {				
				clone.listenLoadComplete();
				obj.init();	
			}
			else {
				obj.addEventListener(StateEvent.CHANGE, function loaded(e:StateEvent):void {
					obj.removeEventListener(StateEvent.CHANGE, loaded);
					clone.dispatchEvent(new StateEvent(StateEvent.CHANGE, clone.id, "isLoaded", true));
				});
				obj.open();		
			}
		}
		
		
		
		// used as flag for dial listeners to skip default selections
		private function cmlInit(e:Event):void
		{
			CMLParser.instance.removeEventListener(CMLParser.COMPLETE, cmlInit);
			cmlIni = !filteringInProcess;
		}
		
		protected function get placeHolderIndex():int { return _placeHolderIndex; }
		protected function set placeHolderIndex(i:int):void
		{
			placeHolders[_placeHolderIndex].lineColor = 0xbbbbbb;		
			_placeHolderIndex = i;			
			_placeHolderIndex = _placeHolderIndex == placeHolders.length  ? 0 : _placeHolderIndex;						
			placeHolders[_placeHolderIndex].lineColor = 0x000000;			
		}				
		
		/**
		 * Connect to a database
		 */
		public function connect():void
		{
			if (gateway == "flickr") 
				return;
			connection = new NetConnection;
			connection.connect(gateway);				
			//responder = new Responder(onResult, onFault);
			
			// Get the total results of the Collective Access collection. firstResult() will set up the appropriate responder.
			responder = new Responder(firstResult, onFault);
			//connection.call("./ObjectSearchTest.search_choose_return", responder);
			connection.call("./ObjectSearchTest.search_choose_return", responder, "", returnFields, "large");
		}
		
		/**
		 * Submit query based on aligned dial search terms
		 * @param	e  dial change state event
		 */
		protected function onDialChange(e:StateEvent):void 
		{
			cancelLoading();
			
			var index:int = dials.indexOf(e.target);
			
			if (!flickrQuery){
				if (index == 0)
					searchTerms[index] = _searchFieldsArray[index] + ": \"" + e.value + "\""; 
				
				else if (index == 1)
					searchTerms[index] = _searchFieldsArray[index] + ": \"" + e.value + "\""; 
				
				else if (index == 2)
					searchTerms[index] = _searchFieldsArray[index] + ": \"" + e.value + "\""; 

			}
			// If this were Flickr...
			// FlickrQuery -- generate search?
			// Pass in searchFields array items, get out search setup?
			// 
			// service.photos.search( user_id, tag_string, tag_mode, 
			
			else if (flickrQuery) {
				flickrQuery.tags = "";
				flickrQuery.text = "";
				for (var i:int = 0; i < 3; i++) {
					if (_searchFieldsArray[i] == "text" ) {
						// Do something with text.
						if (dials[i] != "" || dials[i] != null && i < 2)
							flickrQuery[_searchFieldsArray[i]] += dials[i].currentString + ", ";
					}
					if (_searchFieldsArray[i] == "tags") {
						if (dials[i] != "" || dials[i] != null) {
							if (i < 2)
								flickrQuery[_searchFieldsArray[i]] += dials[i].currentString + ", ";
							else if (i == 2)
								flickrQuery[_searchFieldsArray[i]] += dials[i].currentString;
						}							
					}
				}
				
				// Set up event listener and run a search here.
			}
			
			//verify the cml has been initialized and the event was triggered
			//by the target (second condition is for filtering)
			
			if (cmlIni && e.target.id == e.id) {
				
				checkServerTimer();
				if (flickrQuery)
					queryFlickr();
				else
					 query();
			}
		}	
		
		
	
		
		
		// submit query
		private function query(e:KeyboardEvent=null):void
		{
			isLoading = true;
			album.clear();
			
			//var searchString:String = "ca_objects.work_description:This is a yellow flower man";
			//var searchString:String = "ca_object_labels.name:Yellow Flower";
			//var searchString:String = "ca_objects.work_description:This is a AND ca_object_labels.name:Yellow";
			//var searchString:String = "ca_objects.work_description:This is a";
			//var searchFields:Array = ["work_description:This is a", "copyrightdate:August"];
			//var searchFields:Array = [];		
			
			// ::returns image sizes::
			// original
			// mediumlarge
			// medium
			// small
			// etc -- see collective access
		
			//if (!e || e.keyCode == 13) {
			connection.call("./ObjectSearchTest.search_choose_return", responder, searchTerms, returnFields, "large");				
				//connection.call("./AMFTest.search_choose_return", responder, "crystal", null, null, returnFields);
				//connection.call("./AMFTest.search_and_return", responder, searchString, null, null);
				//connection.call("./AMFTest.getalldata", responder, entry.text);
				//connection.call("./SetTest.set_search", responder, entry.text);
			//}			
			
			
			dockText[1].text = "searching collection...";
			dockText[0].visible = true;
			dockText[1].visible = true;
			
			var aCon:* = searchChildren("#album-container");
			var resultTxt:Text = aCon.searchChildren("#result_text");
			resultTxt.text = "";				
		}
		
		private function queryFlickr():void {
			flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
			flickrQuery.flickrSearch();
		}
		
		private function checkServerTimer():void
		{
			if (serverTimeOut && !serverTimer)
			{
				serverTimer = new Timer(serverTimeOut * 1000);
				serverTimer.addEventListener(TimerEvent.TIMER, serverTimeExpired);
			}
			if(serverTimer)
				serverTimer.start();
		}
		
		private function onQueryLoad(e:StateEvent):void {
			isLoading = true;
			flickrQuery.removeEventListener(StateEvent.CHANGE, onQueryLoad);
			
			album.clear();
			previews = [];
			locked = [];
			
			loadCnt = 0;
			result = flickrQuery.resultPhotos;
			
			dockText[1].text = "searching collection...";
			dockText[0].visible = true;
			dockText[1].visible = true;
			
			var c:Container = childList.getCSSClass("dials", 0);
			var resultTxt:Text = c.searchChildren("#result_text");
			resultTxt.text = "";
			
			resultCnt = flickrQuery.resultPhotos.length;
			
			if (!resultCnt) {
				isLoading = false;
				dockText[1].text = "No objects found. Please search again.";
			}
				
			loadClone();
		}
		
		private function firstResult(res:Object):void {
			TOTAL_RESULTS = 0;
			result = res;
			for (var n:* in result) {
				TOTAL_RESULTS++;
			}
			
			dockText[1].text = "Use the dials to make a selection. Tap on the thumbnails to load them onto the table.\n" + TOTAL_RESULTS + " items in Collection."
			responder = new Responder(onResult, onFault);
		}
		
		private function onResult(res:Object):void
		{
			album.clear();
			previews = [];
			locked = [];			
			result = res;
			resultCnt = 0;		
			loadCnt = 0;
			currentPage = 0;
			
			resultsDict = [];
			
			for (var n:* in result) {
				resultCnt++;	
			}
			
			// If resultCnt is higher than the results per page...
			// create an array for each "page" returned. Associate
			// those arrays with a dictionary of indices or some such
			// thing.
			
			if (_resultsPerPage > 0) {
				pageCount = Math.ceil(resultCnt / resultsPerPage);
				
				if (pageCount > 1 && !flickrQuery) {
					resultsDict = [];
					
					for (var i:int = 0; i < pageCount; i++) {
						resultsDict.push(processPages(i));	
					}
					
					currentPage = 0;
					result = resultsDict[currentPage];
				}
			}
			
			if (!resultCnt) {
				isLoading = false;
				dockText[1].text = "No objects found. Please search again.";
			}
			
			if (amountToShow > resultCnt)
				amountToShow = resultCnt;			
			
			//printResult(result);
			
			loadClone();			
		}

		private function processPages(page:int):Array {
			var pageContent:Array = new Array();
			for (var i:int = page * resultsPerPage; i < _resultsPerPage + (page * _resultsPerPage); i++) {
				pageContent.push(result[i]);
			}
			return pageContent;
		}
		
		private function onFault(fault:Object):void
		{
			dockText[1].text = fault.description;
			dockText[1].visible = true;
		}		
		
		

		
		private function loadClone():void
		{
			var num:int=0;
			
			num = maxLoad + loadCnt;
			
			if (num >= resultCnt)
				num = resultCnt;
			
			for (var i:int = loadCnt; i < num; i++) {
				resolveExp(result[i]);
			}
		}
		
	
		
		// image load data
		protected function onCloneLoad(event:StateEvent = null):void 
		{		
			if (!event || event.property == "isLoaded") {				
				if (event){
					event.target.removeEventListener(StateEvent.CHANGE, onCloneLoad);					
					addPreview(Component(event.target), getPreview(event.target));
					
					if (event.target is FlickrViewer) {	// this hack b/c Flickr API is broken	
						var c:* = event.target.childList.getKey("back2");
						c.searchChildren(".info_description").htmlText = event.target.image.description;
						c.init();
					}
					else 
						event.target.init();											
				}
				
				dockText[1].text = "loading " + (String)(loadCnt + 1) + " of " + resultCnt;			
				loadCnt++;
				
				if (loadCnt >= resultCnt || loadCnt >= _resultsPerPage)
					loadEnd();
				else if ( (loadCnt % maxLoad) == 0 )
					loadClone();
			}						
		}						
		
		
		private function loadEnd():void 
		{
			displayResults();
			loadCnt = 0;
			isLoading = false;			
		}
		
		
		protected function displayResults():void
		{
			if (serverTimer)
				serverTimer.reset();
				
			for (var i:int = 0; i < dockText.length; i++) {
				dockText[i].visible = false;
			}
			
			var c:Container = childList.getCSSClass("dials", 0);
			var resultTxt:Text = c.searchChildren("#result_text");
			if (TOTAL_RESULTS != 0) {
				resultTxt.text = resultCnt + " Results, " + TOTAL_RESULTS + " in Collection";	
			}
			else {
				resultTxt.text = resultCnt + " Results";
			}
			if (flickrQuery && flickrQuery.pages > 1) {
				resultTxt.text += " (Page " + flickrQuery.pageNumber + " of " + flickrQuery.pages + ")";
			}
			else if (resultsDict && resultsDict.length > 1) {
				resultTxt.text += " (Page " + (currentPage + 1) + " of " + pageCount + ")";
			}
			
			if (flickrQuery && flickrQuery.pages > 1) {
				if (flickrQuery.pageNumber > 1) {
					if (_previousArrow) {
						if(!album.contains(_previousArrow))
							album.addChild(_previousArrow);
						album.backButton = _previousArrow;
					}
					// else...auto-generate one?
				}
			}
			else if (resultsDict && resultsDict.length > 1 && currentPage > 0) {
				if (_previousArrow) {
					if(!album.contains(_previousArrow))
						album.addChild(_previousArrow);
					album.backButton = _previousArrow;
				}
			}
			
			
			var src:String;
			var j:int;
			var preview:*
			
			for each (preview in previews) {
				album.addChild(preview);
			}
	
			if (flickrQuery && flickrQuery.pages > 1) {
				// Add a next arrow.
				if (flickrQuery.pageNumber < flickrQuery.pages) {
					if (_nextArrow) {
						if (!album.contains(_nextArrow))
							album.addChild(_nextArrow);
						album.forwardButton = _nextArrow;
					}
					// else...auto-generate one?
				}
			}
			else if (resultsDict && resultsDict.length > 1 && currentPage < resultsDict.length - 1) {
				if (_nextArrow) {
					if (!album.contains(_nextArrow))
						album.addChild(_nextArrow);
					album.forwardButton = _nextArrow;
				}
			}
			
			album.margin = 15;
			album.init();
			
			for each (preview in previews) {
				src = srcMap[preview];
				if (src && srcMap[src]["clone"].visible)	
					album.select(preview);	
			}			
		}
		
		
		private function getPreview(obj:*):TouchContainer
		{
			var prv:TouchContainer = new TouchContainer();
			var img:* = obj.image.clone();
				
			img.width = 0;
			img.height = 140;
			img.resample = true;
			img.resize();
						
			var title:Text;
			if (obj.back || obj.backs.length == 1) {
				title = obj.back.childList.getKey("title").clone();
			}
			else if (obj.backs && obj.backs.length > 1) {
				title = obj.searchChildren("title").clone();
				TouchContainer(title.parent).childList.removeByValue(title); //remove from childList of source parent
			}
			
			title.width = img.width;			
			title.textAlign = "center";
			title.fontSize = 10;			
			title.y = img.height;			
			title.x = img.x;
			
			fadein(img, 1);
			
			prv.addChild(img);
			prv.addChild(title);
			prv.width = img.width;
			prv.height = img.height + 30;			
			
			return prv;
		}
		

		private function selection(e:StateEvent):void
		{
			var preview:*;			
			var clone:*;			
			var src:String;
			
			if (e.property == "selectedItem") {	
				
				preview = e.value;
				src = srcMap[preview];
				
				if (srcMap[src]) {
					selectItem(srcMap[src]["clone"]);					
				}
				else if (e.value.contains(_nextArrow)) {
					if (flickrQuery) {
						flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
						flickrQuery.nextPage();
					} // else if something else...
					else {
						nextDBpage();
					}
				} else if (e.value.contains(_previousArrow)) {
					if (flickrQuery) {
						flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
						flickrQuery.previousPage();
					} // else if something else...This should probably be replaced with a method search instead of hard coding.
					else {
						previousDBpage();
					}
				}
			}
			else if (e.property == "toggle" && e.value == "info") {
				var aCon:* = searchChildren("#album-container");
				var bCon:Container = aCon.searchChildren("#info-pane");
				if (bCon)
					bCon.visible = !bCon.visible;
			}
		}
		
		private function selectItem(obj:*):void
		{					
			// if object is already on the stage
			if (obj.visible) {
				obj.onUp();					
				//obj.glowPulse();
				moveBelowDock(obj);				
				return;				
			}
										
			var location:Graphic = placeHolders[placeHolderIndex];								
			obj.addEventListener(StateEvent.CHANGE, onCloneChange);
			
			
			if (autoShuffle) 
				obj.addEventListener(GWTouchEvent.TOUCH_BEGIN, moveB);
			
			//if ("scale" in obj["state"][0])
			//	obj.scale = obj["state"][0]["scale"];
			//else
				obj.scale = .6;
					
			if (position == "top") {
				//if ("rotation" in obj["state"][0])
				//	obj.rotation = obj["state"][0]["rotation"];
				//else
					obj.rotation = 180;
				
				obj.x = location.x + obj.width*obj.scale;
				obj.y = location.y + location.height;
				collectionViewer.tagObject(true, obj);
			}
			else {		
				//if ("rotation" in obj["state"][0])
				//	obj.rotation = obj["state"][0]["rotation"];
				//else
					obj.rotation = 0;
				obj.x = location.x;
				obj.y = location.y;				
				collectionViewer.tagObject(false, obj);
			}
			
			
			obj.reset();
			moveBelowDock(obj);
			fadein(obj);				
			obj.visible = true;				
			
			placeHolderIndex++;						
		}
		
		private function nextDBpage():void {
			currentPage++;
			
			album.clear();
			previews = [];
			locked = [];			
			result = resultsDict[currentPage];
			//resultCnt = 0;		
			loadCnt = 0;	
			
			loadClone();	
		}
		
		private function previousDBpage():void {
			currentPage--;
			
			album.clear();
			previews = [];
			locked = [];			
			result = resultsDict[currentPage];
			//resultCnt = 0;		
			loadCnt = 0;	
			
			loadClone();
		}
		
		private function searchExp(obj:*, target:*):void {					
			if (!("state" in obj)) return;

			// Pass in the template, and the object to compare.
			
			// Iterate through the properties of the object to find {values}
			for (var s:String in obj.state[0]) {
				if ((String(obj.state[0][s])).indexOf("{") != -1) {
					
					// Create substring, check for substring "in" comparison object.
					var str:String = String(obj.state[0][s]).substring(1, String(obj.state[0][s]).length -1);
					
					if (str in target && target[str] != null) {
						// Assign object's values to template clone if found.
						obj[s] = target[str];
					}
				}
			}
			
			if (obj is DisplayObjectContainer) {
				for (var i:int = 0; i < obj.numChildren; i++) {
					searchExp(obj.getChildAt(i), target);		
				}
			}
		}		
		
		private function dragSelection(e:StateEvent):void
		{
			if (e.property == "draggedItem") {
				for each(var placeHolder:* in placeHolders) {					
					if (CollisionDetection.isColliding(DisplayObject(e.value), DisplayObject(placeHolder), this)) {
						placeHolderIndex= placeHolders.indexOf(placeHolder);
						dropLocation = placeHolder;
						return;
					}
				}
				dropLocation = null;
			}
		}
				
		private function dropSelection(e:StateEvent):void
		{
			if (e.property == "droppedItem" && dropLocation) {
				var src:String = srcMap[e.value];
				selectItem(srcMap[src]["clone"]);
				var aCon:* = searchChildren("#album-container");
				aCon.searchChildren("#menu1").select(e.value);
			}
		}
				
		private function moveB(e:*):void 
		{
			moveBelowDock(e.currentTarget as DisplayObject);
		}
		
		/**
		 * Moves the specified display object beneath the dock in the display list
		 * @param	obj
		 */
		public function moveBelowDock(obj:DisplayObject):void 
		{
			//TODO: Fix rigid structure
			if (position=="bottom")
				parent.setChildIndex(obj, (parent.getChildIndex(this)-1));
			else
				parent.setChildIndex(obj, (parent.getChildIndex(this)-2));			
		}
		
		
		private function onCloneChange(e:StateEvent, target:*=null):void
		{					
			if (!e || e.property == "visible") {				
				if (e && !e.value) {
					target = e.target; 
				}
				if (target)				
				{				
					var clone:* = target;
					clone.removeEventListener(StateEvent.CHANGE, onCloneChange);
					if (srcMap[clone]) {
						var src:String = srcMap[clone];	
						collectionViewer.untagObject(clone);
						if (srcMap[src]["preview"])
							album.unSelect(srcMap[src]["preview"]);
						else 
							removeSrc(src);
					}
					target.visible = false;	
				}
			}				
		}
		
		private function cancelLoading():void
		{
			if (isLoading && flickrQuery)
			{
				for each(var clone:Component in cloneMap.getKeyArray())
					clone.removeEventListener(StateEvent.CHANGE, onCloneLoad);
				isLoading = false;
			}
		}

		// traces result object
		private function printResult(result:Object):void
		{
			i = 0;
			
			for (var i:* in result) {
				trace("---result---", i);
				for (var j:* in result[i]) {
					trace(j, result[i][j]);
				}
				i++;
			}
		}
		
		
		
		// util methods
		
		private function moveToTop(obj:*):void
		{
			if (obj.parent && obj.parent != this )
				moveToTop(obj.parent);
			else
				addChild(obj);
		}
		
		private function hideAll():void
		{			
			for (var i:int = 0; i < numChildren; i++)
			{
				if(getChildAt(i) is TouchContainer)
					getChildAt(i).visible = false;
			}
		}
			
		private function fadein(obj:DisplayObject, duration:Number=.25):void
		{
			var tween:TweenLite = TweenLite.fromTo(obj, duration, { alpha:0 }, { alpha:1 } );
			tween.play();
		}
		

		private function fadeout(obj:DisplayObject, duration:Number=.25):void
		{
			var tween:TweenLite = TweenLite.fromTo(obj, duration, { alpha:1 }, { alpha:0 } );
			tween.play();			
		}	
		
		/**
		 * Automates the generation of filtered search term lists and applies them to the dials. 
		 * This will require additional load time relative to the number of search terms. 
		 */
		public function get searchTermFilters():Boolean { return _searchTermFilters; }
		public function set searchTermFilters(f:Boolean):void
		{
			_searchTermFilters = f;
		}
		
		//NOTE: 
		//
		/**
		 * Mechanism to preprocess defined queries and automate the generation of filtered lists for flickrQueries.
		 * TODO: Exapand to work with collective access queries and flickr text searches
		 */
		private function searchTermFiltering():void
		{
			if (!searchTermFilters || !flickrQuery) 
				return;
		
			//verify lists are unfiltered
			for each(var dial:Dial in dials)
			{
				if (dial.text.indexOf(":") > -1)
				{
					throw new Error("Colon(:) characters are reserved for search term filtering and cannot exist in an unfiltered list. If attempting to auto-generate" +
					" the filters through the \"searchTermFilters\" flag, remove filter syntax from the text of the dials. Otherwise disable the flag.");
					return;
				}
			}
			
			filteringInProcess = true;
			
			TOTAL_RESULTS = 0;
			
			//create temporary load screen
			var top:Boolean = position == "top";
			var filterScreen:Graphic = new Graphic();
			filterScreen.shape = "rectangle";
			filterScreen.width = stage.stageWidth;
			filterScreen.height = stage.stageHeight/2;
			filterScreen.y = top ? 0 : filterScreen.height;
			filterScreen.color = 0x000000;
			filterScreen.lineStroke = 0;
			
			//progress update
			progress = new Text();
			progress.color = 0xFFFFFF;
			progress.fontSize = 40;					
			progress.autoSize = "right";
			progress.x = filterScreen.width / 2;
			progress.y = filterScreen.height / 2;
			if (top)
				DisplayUtils.rotateAroundCenter(progress, 180);
			filterScreen.addChild(progress);
			
			//add load screen at initialization and remove after filter process
			collectionViewer.addChild(filterScreen);
			addEventListener(StateEvent.CHANGE, function(e:StateEvent):void {
				if (e.property == "filters_complete")
				{
					filteringInProcess = false;
					cmlIni = true;
					collectionViewer.removeChild(filterScreen);
				}
			});						
			
			//access search terms from the dock's dials and generate a query for each combination
			var d1SearchTerms:Array = dials[0].text.split(",");
			var d2SearchTerms:Array = dials[1].text.split(",");
			var d3SearchTerms:Array = dials[2].text.split(",");
			
			var queries:Array = [];
			
			for each(var i:String in d1SearchTerms)
			{
				for each(var j:String in d2SearchTerms)
				{
					for each(var k:String in d3SearchTerms)
					{
						var query:FlickrQuery = new FlickrQuery();
						query.apikey = "5487a9cd58bb07a37700558d6362972f";
						query.tagMode = "all"; 
						query.userid = "25053835@N03";
						query.init();
						query.tags = (i + ", " + j + ", " + k);
						query.addEventListener(StateEvent.CHANGE, resultCount);
						queries.push(query);
					}
				}
			}			
						
			//initate query queue
			queries[0].flickrSearch();
			addEventListener(StateEvent.CHANGE, function(e:StateEvent):void {
				if (e.property == "query_complete")
				{
					progress.text = "Loading: applying "+e.value+" of "+queries.length+" search term filters";
					if(e.value < queries.length)
						queries[e.value].flickrSearch();
					else
						dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "filters_generated"));
				}
			});
			
			//translate the valid maps into the dial's filter syntax and apply the filters to
			//the filtered dials
			addEventListener(StateEvent.CHANGE, function(e:StateEvent):void {
				if (e.property == "filters_generated")
				{
					var dial2Text:String;
					for (var d2Key:String in dial2Filters)
					{
						if (!dial2Text)
							dial2Text = d2Key + ",";
						else
							dial2Text = d2Key + ",\n\t" + dial2Text;
						for each(var d2Val:String in dial2Filters[d2Key])
							dial2Text = d2Val + ":" + dial2Text;
					}
					
					var dial3Text:String;
					for (var d3Key:String in dial3Filters)
					{
						if (!dial3Text)
							dial3Text = d3Key + ",";
						else
							dial3Text = d3Key + ",\n\t" + dial3Text;
						
						for each(var d3Val:String in dial3Filters[d3Key])
							dial3Text = d3Val + ":" + dial3Text;
					}
					
					dial2Text = dial2Text.substr(0, dial2Text.length-1);
					dial3Text = dial3Text.substr(0, dial3Text.length-1);
											
					dials[1].text = dial2Text;
					dials[1].filterDial = dials[0];
					dials[1].init();
					
					dials[2].text = dial3Text;
					dials[2].filterDial = dials[1];
					dials[2].init();
					
					dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "filters_complete"));
				}
			});
		}
			
		/**
		 * Evaluates valid(combinations with non-empty result sets) search terms and generates filter mappings.
		 * @param	e
		 */
		private function resultCount(e:StateEvent):void {
			if (e.value == "flickrResult")
			{
				var query:FlickrQuery = FlickrQuery(e.target);
				query.removeEventListener(StateEvent.CHANGE, resultCount);			
				resultCnt = query.resultPhotos.length;
				var tags:Array = query.tags.split(",");
				
				if (resultCnt)
				{				
					TOTAL_RESULTS += query.total;
					if (!dial2Filters[tags[1]])
						dial2Filters[tags[1]] = new Array();			
					if (dial2Filters[tags[1]].indexOf(tags[0]) < 0)
						dial2Filters[tags[1]].push(tags[0]);										
						
					if (!dial3Filters[tags[2]])
						dial3Filters[tags[2]] = new Array();			
					if (dial3Filters[tags[2]].indexOf(tags[0]+"|"+tags[1]) < 0)
						dial3Filters[tags[2]].push(tags[0]+"|"+tags[1]);							
				}
				
				combinations++;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "query_complete", combinations));
			}
		}		
					
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();	
			searchTerms = null;
			_returnFields = null;
			_searchFieldsArray = null;
			result = null;
			loadText = null;
			cloneMap = null;
			placeHolders = null;
			dropLocation = null;
			dockText = null;
			dials = null;
			connection = null;
			responder = null;
			templates = null;
			album = null;
			collectionViewer = null;
			dial2Filters = null;
			dial3Filters = null;
			progress = null;
			nextArrow = null;
			previousArrow = null;			
			srcMap = null;
			dial2Filters = null;
			dial3Filters = null;
			resultsDict = null;
			previews = null;
			locked = null;
			
			if (serverTimer) { 
				serverTimer.removeEventListener(TimerEvent.TIMER, serverTimeExpired);
				serverTimer.stop();
				serverTimer = null;
			}
			
			if (flickrQuery) {
				flickrQuery.removeEventListener(StateEvent.CHANGE, onQueryLoad);
				flickrQuery.removeEventListener(StateEvent.CHANGE, flickrSetup);
				flickrQuery = null;
			}
		}
	}

}