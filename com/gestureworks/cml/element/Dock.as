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
		public var searchTerms:Array = ["work_description:rug"];
		public var returnFields:Array = ["work_description", "copyrightdate"];
		protected var _searchFieldsArray:Array;
		public var searchFields:String;
				
		public var result:Object;	
		public var resultCnt:int = 0;
		
		public var isLoading:Boolean = false;
		public var loadText:Text;	
		
		public var clones:Array = [];
		public var cloneMap:LinkedMap = new LinkedMap(false);
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
		}
		
		// used as flag for dial listeners to skip default selections
		private function cmlInit(e:Event):void
		{
			CMLParser.instance.removeEventListener(CMLParser.COMPLETE, cmlInit);
			cmlIni = true;
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
				//album.belt.removeChild(obj);
				cloneMap.removeKey(obj.image.src);
				//if (obj["image"]) obj.image.close();
				if ("dispose" in obj && obj.visible == false) {
					obj.removeEventListener(StateEvent.CHANGE, onCloneTimeout);
					obj.dispose();
				}
			}
			cloneMap = new LinkedMap(false);
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
				
				trace("searchTerms", searchTerms);
			}
			// If this were Flickr...
			// FlickrQuery -- generate search?
			// Pass in searchFields array items, get out search setup?
			// 
			// service.photos.search( user_id, tag_string, tag_mode, 
			
			else if (flickrQuery) {
				flickrQuery.tags = "";
				flickrQuery.text = "";
				trace("Flickr test:", Object(flickrQuery).hasOwnProperty(_searchFieldsArray[index]), _searchFieldsArray[index]);
				for (var i:int = 0; i < 3; i++) 
				{
					trace("Setting field:", _searchFieldsArray[i]);
					if (_searchFieldsArray[i] == "text" ) {
						// Do something with text.
						if (dials[i] != "" || dials[i] != null && i < 2)
							flickrQuery[_searchFieldsArray[i]] += dials[i].currentString + ", ";
						trace("FlickrQuery text:", flickrQuery.text);
					}
					if (_searchFieldsArray[i] == "tags") {
						if (dials[i] != "" || dials[i] != null) {
							if (i < 2)
								flickrQuery[_searchFieldsArray[i]] += dials[i].currentString + ", ";
							else if (i == 2)
								flickrQuery[_searchFieldsArray[i]] += dials[i].currentString;
						}
							
						trace("FlickrQuery tags:", flickrQuery.tags);
					}
				}
				
				// Set up event listener and run a search here.
			}
			
			//verify the cml has been initialized and the event was triggered
			//by the target (scond condition is for filtering)
			if(cmlIni && e.target.id == e.id)
			{
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
			//flickrQuery.tags = "";
			//flickrQuery.text = "";
			
		}
		
		private function onQueryLoad(e:StateEvent):void {
			flickrQuery.removeEventListener(StateEvent.CHANGE, onQueryLoad);
			
			album.clear();
			
			previews = [];
			clones = [];
			
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
			
			printResult(result);
			
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
			//var src:String = templates[0].image.src;
			//var src:String = templates[1].image.src;
			
			// Check the templates for the one that's been populated, then update the source.
			var src:String = "";
			var i:int = 0;
			for (i = 0; i < templates.length; i++) 
			{
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
				//clone = templates[0].clone(); // TODO: remove hardcoded template item
				//clone = templates[1].clone();
				for (var j:int = 0; j < templates.length; j++) 
				{
					if (templates[j].image.src)
					clone = templates[j].clone();
				}
				//if (flickrQuery)
					//searchExp(clone, templates[1]);
				clone.image.close();
				clones.push(clone);
				clone.addEventListener(StateEvent.CHANGE, onCloneLoad);			
				clone.image.open(src);
				//clone.init();
				cloneMap.append(src, clone);
			}
		}		

		
		// image load data
		protected function onCloneLoad(event:StateEvent=null):void 
		{			
			if ( (!event) || event.property == "isLoaded") {
				
				if (event.target is FlickrViewer)
					searchExp(event.target, event.target.image);
				
				dockText[1].text = "loading " + (String)(loadCnt + 1) + " of " + resultCnt;
				if (event) {
					event.target.removeEventListener(StateEvent.CHANGE, onCloneLoad);			
					event.target.init();
					event.target.addEventListener(StateEvent.CHANGE, onCloneTimeout);
				}
				loadCnt++;
				
				if (loadCnt >= resultCnt) {
					loadEnd();
				}
				
				else if ( (loadCnt % maxLoad) == 0 ) {
					loadClone();
				}
				else {
					//trace((loadCnt % maxLoad))
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
				
			for (var i:int = 0; i < dockText.length; i++) {
				dockText[i].visible = false;
			}
			
			var resultTxt:Text = searchChildren("#result_text");
			resultTxt.text = resultCnt + " Results";	
			if (flickrQuery && flickrQuery.pages > 1) {
				resultTxt.text += " (Page " + flickrQuery.pageNumber + " of " + flickrQuery.pages + ")";
			}
		
			//var album:Album = ("menu1");  //TODO: for testing purposes; need to provide more reliable access to album
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
		}
		
		
		private function getPreview(obj:*):TouchContainer
		{
			var prv:TouchContainer = new TouchContainer();
			
			var flickr:Flickr;
			var img:Image;
			if (flickrQuery) {
				flickr = obj.image.clone();
				//flickr.displayComplete();
			}
			else if (!flickrQuery)
				img = obj.image.clone();
													
				
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
			//var title:Text = obj.back.childList.getKey("title").clone();
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
							//album.belt.removeChild(obj);
							cloneMap.removeKey(obj.image.src);
							//if (obj["image"]) obj.image.close();
							if ("dispose" in obj && obj.visible == false) {
								obj.removeEventListener(StateEvent.CHANGE, onCloneTimeout);
								obj.dispose();
							}
						}
						cloneMap = new LinkedMap(false);
						clones = [];
						album.clear();
						flickrQuery.addEventListener(StateEvent.CHANGE, onQueryLoad);
						flickrQuery.nextPage();
					} // else if something else...
				} else if (e.value.contains(_previousArrow)) {
					if (flickrQuery) {
						for each (var obj:* in clones) {
							//album.belt.removeChild(obj);
							cloneMap.removeKey(obj.image.src);
							//if (obj["image"]) obj.image.close();
							if ("dispose" in obj && obj.visible == false) {
								obj.dispose();
							}
						}
						cloneMap = new LinkedMap(false);
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
				collectionViewer.tagObject(obj, true);
			}
			else {		
				obj.rotation = 0;
				obj.x = location.x;
				obj.y = location.y;				
				collectionViewer.tagObject(obj, false);
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
					var index:int = clones.indexOf(e.target)				
					if (index >= 0) {
						var m:MenuAlbum = searchChildren("#menu1");
						var obj:* = previews[index];
						m.unSelect(obj);
					}
					else {
						index = cloneMap.searchIndex(e.value);
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
					trace("Disposing of target on timeout.");
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
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();	
		}
	}

}