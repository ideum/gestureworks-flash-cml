package com.gestureworks.cml.element 
{
	import com.adobe.webapis.flickr.Photo;
	import com.gestureworks.cml.components.CollectionViewer;
	import com.gestureworks.cml.components.FlickrViewer;
	import com.gestureworks.cml.components.ImageViewer;
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.core.tweens.*;
	import org.libspark.betweenas3.easing.*;
	import org.libspark.betweenas3.tweens.*;
	import org.tuio.*;
	
	public class Dock extends Drawer
	{		
		public var previews:Array = [];		
		public var loadCnt:int = 0;
		public var searchTerms:Array = [];
		public var returnFields:Array = [];
		protected var _searchFieldsArray:Array;
		public var searchFields:String;
				
		public var result:Object;	
		public var resultCnt:int = 0;
		
		public var isLoading:Boolean = false;
		public var loadText:Text;	
		
		public var clones:Array = [];
		public var cloneMap:ChildList = new ChildList(false);
		public var placeHolders:Array = [];
		private var _placeHolderIndex:int = 0;	
		private var dropLocation:Graphic;
		
		public var dockText:Array = [];
		public var dials:Array = [];		
		public var cmlIni:Boolean = false;

		public var connection:NetConnection;		
		public var gateway:String;
		public var responder:Responder;
		public var maxLoad:int = 2;
	
		public var amountToShow:int = -1;
		public var autoShuffle:int = -1;
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
		public function get previousArrow():* { return _previousArrow; }
		public function set previousArrow(value:String):void {
			_previousArrow = searchChildren(value);
			if (contains(_previousArrow))
				removeChild(_previousArrow);
		}
		
		private var serverTimer:Timer;
		
		private var _serverTimeOut:Number = 30;
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
		 * CML init
		 */
		override public function displayComplete():void 
		{
			init();
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
			
			
			album = searchChildren(MenuAlbum);  //TODO: for testing purposes; need to provide more reliable access to album		
			//trace(album, dockText, dials);
			
			if (!flickrQuery) {
				flickrQuery = searchChildren(FlickrQuery);
			}
			
			addEventListener(StateEvent.CHANGE, selection);
			addEventListener(StateEvent.CHANGE, dragSelection);
			addEventListener(StateEvent.CHANGE, dropSelection);
			CMLParser.instance.addEventListener(CMLParser.COMPLETE, cmlInit);
			
			for (var j:int = 0; j < dials.length; j++) {
				dials[j].addEventListener(StateEvent.CHANGE, onDialChange);
				searchTerms[j] = "";
			}
			
						
			searchTermFiltering();
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
		
		public function connect():void
		{
			connection = new NetConnection;
			connection.connect(gateway);				
			responder = new Responder(onResult, onFault);	
		}
		
		
		// get search terms from dial and submit query
		protected function onDialChange(e:StateEvent):void 
		{
			for each (var obj:* in clones) {
				if ("dispose" in obj && obj.visible == false) {
					cloneMap.removeKey(obj.image.src);
					obj.removeEventListener(StateEvent.CHANGE, onCloneTimeout);
					obj.dispose();
				}
			}
			clones = [];
			album.clear();
			
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
				//trace("Flickr test:", Object(flickrQuery).hasOwnProperty(_searchFieldsArray[index]), _searchFieldsArray[index]);
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
			//by the target (scond condition is for filtering)
			
			if(cmlIni && e.target.id == e.id) {
				if (flickrQuery)
					queryFlickr();
				else
					 query();
			}
		}	
		
		
		
		// submit query
		private function query(e:KeyboardEvent=null):void
		{
			if (isLoading)
				return;
			
			isLoading = true;
			
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
			    connection.call("./ObjectSearchTest.search_choose_return", responder, searchTerms, returnFields, "medium");				
				//connection.call("./AMFTest.search_choose_return", responder, "crystal", null, null, returnFields);
				//connection.call("./AMFTest.search_and_return", responder, searchString, null, null);
				//connection.call("./AMFTest.getalldata", responder, entry.text);
				//connection.call("./SetTest.set_search", responder, entry.text);
			//}			
			
			
			album.clear();
			
			previews = [];
			clones = [];
			
			dockText[1].text = "searching collection...";
			dockText[0].visible = true;
			dockText[1].visible = true;
			var resultTxt:Text = searchChildren("#result_text");
			resultTxt.text = "";				
		}
		
		private function queryFlickr():void {
			flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
			flickrQuery.flickrSearch();
		}
		
		private function onQueryLoad(e:StateEvent):void {
			
			if (serverTimeOut && !serverTimer)
			{
				serverTimer = new Timer(serverTimeOut * 1000);
				serverTimer.addEventListener(TimerEvent.TIMER, serverTimeExpired);
			}
			if(serverTimer)
				serverTimer.start();
			
			flickrQuery.removeEventListener(StateEvent.CHANGE, onQueryLoad);
			
			album.clear();
			
			previews = [];
			clones = [];
			loadCnt = 0;
			
			dockText[1].text = "searching collection...";
			dockText[0].visible = true;
			dockText[1].visible = true;
			var resultTxt:Text = searchChildren("#result_text");
			resultTxt.text = "";
			
			resultCnt = flickrQuery.resultPhotos.length;
			
			if (!resultCnt) {
				isLoading = false;
				dockText[1].text = "No objects found. Please search again.";
			}
			
			loadClone();
		}
		
		private function onResult(res:Object):void
		{			
			result = res;
			resultCnt = 0;		
			loadCnt = 0;		
			
			for (var n:* in result) {
				resultCnt++;	
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

		
		private function onFault(fault:Object):void
		{
			trace(fault.description);
		}		
		

		private function loadClone():void
		{
			var num:int=0;
			
			num = maxLoad + loadCnt;
			
			if (num >= resultCnt)
				num = resultCnt;
				
			for (var i:int = loadCnt; i < num; i++) {	
				if (result) {
					for (var m:int = 0; m < templates.length; m++) 
					{
						if (templates[m] is ImageViewer){
							for (var j:* in result[i]) {
								searchExp(templates[m], result[i]);
							}
						}
					}
				}
				else if (flickrQuery && !result) {
					for (var k:int = 0; k < templates.length; k++) {
						if (templates[k] is FlickrViewer) {
							searchExp(templates[k], flickrQuery.resultPhotos[i]);
						}
					}
				}
				createClone(clones[i]);			
			}					
		}
		
		
		// creates image viewer clone
		protected function createClone(clone:*):void
		{
			// Check the templates for the one that's been populated, then update the source.
			var src:String = "";
			var i:int = 0;
			for (i = 0; i < templates.length; i++) {
				if (templates[i].image.src)
					src = templates[i].image.src;
			}
			
			if (cloneMap.hasKey(src)) {
				clones.push(cloneMap.getKey(src));
				
				if (loadCnt >= resultCnt)
					loadEnd();
				else 
					onCloneLoad();
			}
			else {
				for (var j:int = 0; j < templates.length; j++) {
					if (templates[j].image.src)
						clone = templates[j].clone();
				}
				clone.image.close();
				clones.push(clone);
				clone.addEventListener(StateEvent.CHANGE, onCloneLoad);			
				clone.image.open(src);				
				cloneMap.append(src, clone);
			}
		}		

		
		// image load data
		protected function onCloneLoad(event:StateEvent=null):void 
		{
			if (event) {
				event.target.removeEventListener(StateEvent.CHANGE, onCloneLoad);			
				event.target.addEventListener(StateEvent.CHANGE, onCloneTimeout);
			}					
			
			if ( (!event) || event.property == "isLoaded") {
				
				if (event && event.target is FlickrViewer)
					searchExp(event.target, event.target.image);
				else if (event && event.target)
					event.target.init();					
					
				dockText[1].text = "loading " + (String)(loadCnt + 1) + " of " + resultCnt;
				
				loadCnt++;
				
				if (loadCnt >= resultCnt) {
					loadEnd();
				}
				
				else if ( (loadCnt % maxLoad) == 0 ) {
					loadClone();
				}			
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
			
			var resultTxt:Text = searchChildren("#result_text");
			resultTxt.text = resultCnt + " Results";	
			if (flickrQuery && flickrQuery.pages > 1) {
				resultTxt.text += " (Page " + flickrQuery.pageNumber + " of " + flickrQuery.pages + ")";
			}
		
			album.clear();
			
			if (flickrQuery && flickrQuery.pages > 1) {
				if (flickrQuery.pageNumber > 1) {
					if (_previousArrow) 
						album.addChild(_previousArrow);
						//album.setChildIndex(_previousArrow, 0);
					// else...auto-generate one?
				}
			}
			
			for each(var clone:* in clones)
				album.addChild(getPreview(clone));
			
			if (flickrQuery && flickrQuery.pages > 1) {
				// Add a next arrow.
				if (flickrQuery.pageNumber < flickrQuery.pages) {
					if (_nextArrow) album.addChild(_nextArrow);
					// else...auto-generate one?
				}
			}
			
			album.margin = 15;
			album.init();
			
			for (var k:int = 0; k < clones.length; k++) {
				if (clones[k].visible)
					album.select(previews[k]);
			}	
			
		}
		
		
		private function getPreview(obj:*):TouchContainer
		{
			var prv:TouchContainer = new TouchContainer();
			
			if (flickrQuery)
				var flickr:Flickr = obj.image.clone();
			else if (!flickrQuery)
				var img:Image = obj.image.clone();				
				
			if (img){
				img.width = 0;
				img.height = 140;
				img.resample = true;
				img.scale = 1;
				img.resize();
			} else if (flickr) {
				flickr.width = 0;
				flickr.height = 140;
				flickr.resample = true;
				flickr.scale = 1;
				flickr.resize();
			}
						
			var title:Text;
			if (obj.back || obj.backs.length == 1) {
				title = obj.back.childList.getKey("title").clone();
			}
			else if (obj.backs && obj.backs.length > 1) {
				title = obj.searchChildren("title").clone();
			}
			if (img)
				title.width = img.width;
			else if (flickr)
				title.width = flickr.width;
			
			title.textAlign = "center";
			title.fontSize = 10;
			
			if(img) {
				title.y = img.height;			
				title.x = img.x;
				
				fadein(img, 1);
				
				prv.addChild(img);
				prv.addChild(title);
				prv.width = img.width;
				prv.height = img.height + 30;
				previews.push(prv);
			}
			
			else if (flickr) {
				title.y = flickr.height;			
				title.x = flickr.x;
				
				fadein(flickr, 1);
				
				prv.addChild(flickr);
				prv.addChild(title);
				prv.width = flickr.width;
				prv.height = flickr.height + 30;
				previews.push(prv);
			}
			
			return prv;
		}
		

		private function selection(e:StateEvent):void
		{
			if (e.property == "selectedItem")
			{	
				if (clones[previews.indexOf(e.value)])
					selectItem(clones[previews.indexOf(e.value)]);
				else if (e.value.contains(_nextArrow)) {
					if (flickrQuery) {
						for each (var obj:* in clones) {
							if ("dispose" in obj && obj.visible == false) {
								obj.removeEventListener(StateEvent.CHANGE, onCloneTimeout);
								obj.dispose();
							}
						}
						clones = [];
						album.clear();
						flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
						flickrQuery.nextPage();
					} // else if something else...
				} else if (e.value.contains(_previousArrow)) {
					if (flickrQuery) {
						for each (var obj:* in clones) {
							if ("dispose" in obj && obj.visible == false) {
								obj.dispose();
							}
						}
						clones = [];
						album.clear();
						flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
						flickrQuery.previousPage();
					} // else if something else...This should probably be replaced with a method search instead of hard coding.
				}
			}
		}
		
		private function selectItem(obj:*):void
		{
			var location:Graphic = placeHolders[placeHolderIndex];				
			
			// if object is already on the stage
			if (obj.visible) {
				obj.onUp();					
				obj.glowPulse();
				return;				
			}
			else
				obj.visible = true;
			
			obj.addEventListener(StateEvent.CHANGE, onCloneChange);
			
			
			if (autoShuffle) {
				if (GestureWorks.activeTUIO)
					obj.addEventListener(TuioTouchEvent.TOUCH_DOWN, moveB);
				else if (GestureWorks.supportsTouch)
					obj.addEventListener(TouchEvent.TOUCH_BEGIN, moveB);
				else 
					obj.addEventListener(MouseEvent.MOUSE_DOWN, moveB);	
			}
			
			obj.scale = .6;				
			if (position == "top") {
				obj.rotation = 180;
				obj.x = location.x + obj.width*obj.scale;
				obj.y = location.y + location.height;
				collectionViewer.tagObject(true, obj);
			}
			else {		
				obj.rotation = 0;
				obj.x = location.x;
				obj.y = location.y;				
				collectionViewer.tagObject(false, obj);
			}
			
			/*
			var deg:Number = NumberUtils.randomNumber( -2.5, 2.5);	 
			var point:Point = new Point(obj.x + (obj.width) / 2, obj.y + (obj.height) / 2);				
			var m:Matrix=obj.transform.matrix;
			m.tx -= point.x;
			m.ty -= point.y;
			m.rotate (deg*(Math.PI/180));
			m.tx += point.x;
			m.ty += point.y;
			obj.transform.matrix=m;
			*/
			
			obj.reset();
			moveBelowDock(obj);
			fadein(obj);				
			obj.visible = true;				
			
			placeHolderIndex++;						
		}
		
		private function dragSelection(e:StateEvent):void
		{
			if (e.property == "draggedItem")
			{
				for each(var placeHolder:* in placeHolders)
				{					
					if (CollisionDetection.isColliding(DisplayObject(e.value), DisplayObject(placeHolder), this))
					{
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
			if (e.property == "droppedItem" && dropLocation)
			{
				selectItem(clones[previews.indexOf(e.value)]);
				searchChildren("#menu1").select(e.value);
			}
		}
				
		private function moveB(e:*):void 
		{
			moveBelowDock(e.currentTarget as DisplayObject);
		}
		
		public function moveBelowDock(obj:DisplayObject):void 
		{
			//TODO: Fix rigid structure
			if (position=="bottom")
				parent.setChildIndex(obj, parent.getChildIndex(this) - 1);
			else
				parent.setChildIndex(obj, parent.getChildIndex(this) - 2);			
		}
		

		
		private function onCloneChange(e:StateEvent):void
		{					
			if (e.property == "visible") {				
				if (!e.value) {
					e.target.removeEventListener(StateEvent.CHANGE, onCloneChange);
					//e.target.visible = false;
					var index:int = clones.indexOf(e.target);				
					if (index >= 0) {
						var obj:* = previews[index];
						album.unSelect(obj);
						collectionViewer.untagObject(e.target);
					}
					else {
						index = cloneMap.search(e.value);
						if (index >= 0)
							cloneMap.removeIndex(index);
					}
				}
			}				
		}
		
	
		
		private function searchExp(obj:*, target:*):void {					
			if (!("propertyStates" in obj)) return;

			// Pass in the template, and the object to compare.
			
			// Iterate through the properties of the object to find {values}
			for (var s:String in obj.propertyStates[0]) {
				if ((String(obj.propertyStates[0][s])).indexOf("{") != -1) {
					
					// Create substring, check for substring "in" comparison object.
					var str:String = String(obj.propertyStates[0][s]).substring(1, String(obj.propertyStates[0][s]).length -1);
					
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
		
		private function onCloneTimeout(e:StateEvent):void {
			if (e.value == "timeout" || e.value == "quit"){
				if (clones.indexOf(e.target) > -1) return;
				else {
					e.target.removeEventListener(StateEvent.CHANGE, onCloneTimeout);
					e.target.dispose();
				}
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
			var tween:ITween = BetweenAS3.tween(obj, { alpha:1 }, { alpha:0 }, duration);
			tween.play();
		}
		

		private function fadeout(obj:DisplayObject, duration:Number=.25):void
		{
			var tween:ITween = BetweenAS3.tween(obj, { alpha:1 }, { alpha:0 }, duration);
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
			if (!searchTermFilters || !flickrQuery) return;
		
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
					trace("DIAL 2: "+dial2Text + "\n\n\n\nDIAL 3: " + dial3Text);	
											
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
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();	
			previews = null;
			searchTerms = null;
			returnFields = null;
			_searchFieldsArray = null;
			result = null;
			loadText = null;
			clones = null;
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
			
			removeEventListener(StateEvent.CHANGE, selection);
			removeEventListener(StateEvent.CHANGE, dragSelection);
			removeEventListener(StateEvent.CHANGE, dropSelection);
			
			if (flickrQuery)
			{
				flickrQuery.removeEventListener(StateEvent.CHANGE, onQueryLoad);
				flickrQuery = null;
		}
	}
	}

}