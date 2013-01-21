package com.gestureworks.cml.element 
{
	import away3d.materials.methods.AlphaMaskMethod;
	import com.adobe.webapis.flickr.Photo;
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
		private var _searchFieldsArray:Array;
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

		private var flickrQuery:FlickrQuery;

		public var pos:String;
		
		/**
		 * Constructor
		 */
		public function Dock() 
		{
			super();
		
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
			
			_searchFieldsArray = searchFields.split(",");
			
			dockText = searchChildren(".dock-text", Array);

			var c:Container = childList.getCSSClass("dials", 0);
			dials = c.searchChildren(Dial, Array)
			
			
			album = searchChildren(MenuAlbum);  //TODO: for testing purposes; need to provide more reliable access to album		
			//trace(album, dockText, dials);
			
			if (!flickrQuery) {
				flickrQuery = searchChildren(FlickrQuery);
				//flickrQuery = new FlickrQuery();
				trace("Initiating dock. FlickrQuery:", flickrQuery);
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
		private function onDialChange(e:StateEvent):void 
		{
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
						flickrQuery[_searchFieldsArray[i]] = "hyena " + dials[2].currentString;
						trace("FlickrQuery text:", flickrQuery.text);
					}
					if (_searchFieldsArray[i] == "tags") {
						//flickrQuery[_searchFieldsArray[i]] += dials[i].currentString + ", ";
						flickrQuery[_searchFieldsArray[i]] = "striped, hyena, africa";
						trace("FlickrQuery tags:", flickrQuery.tags);
					}
				}
				
				// Set up event listener and run a search here.
			}
			
			if (cmlIni && !flickrQuery)
				query();
			else if (cmlIni && flickrQuery)
				queryFlickr();
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
			flickrQuery.tags = "";
			flickrQuery.text = "";
		}
		
		private function onQueryLoad(e:StateEvent):void {
			flickrQuery.removeEventListener(StateEvent.CHANGE, onQueryLoad);
			
			resultCnt = flickrQuery.resultPhotos.length;
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
				if (result){
					for (var j:* in result[i]) {
						searchExp(templates[0], String(j), result[i][j]);	
						//searchExp(templates[1], String(j), result[i][j]);
					}
				}
				else if (flickrQuery && !result) {
					for (var k:int = 0; k < templates.length; k++) {
						if (templates[k] is FlickrViewer) {
							trace("Hi, I found your flickrViewr for you, so now you know how to safely search for the results you're expecting, have a nice day.");
							//trace(flickrQuery.resultPhotos[i]);
							var tempObj:Object = flickrQuery.resultPhotos[i];
							var flickrPhoto:Photo =  new Photo();
							flickrPhoto = flickrQuery.resultPhotos[i];
							trace(flickrPhoto);
							for (var l:String in flickrPhoto) {
								trace("l:", l);
								searchExp(templates[k], String(l), flickrPhoto[l]);
							}
							trace("Checking id:", flickrPhoto["id"]);
							trace("Checking title:", flickrPhoto["title"]);
							trace("Method test:", "id" in flickrPhoto);
							searchExp(templates[k], "id", flickrPhoto["id"]);
							searchExp(templates[k], "title", flickrPhoto["title"]);
							searchExp(templates[k], "description", flickrPhoto["description"]);
						}
					}
				}
				createClone(clones[i]);			
			}					
		}
		
		
		// creates image viewer clone
		private function createClone(clone:*):void
		{
			//var src:String = templates[0].image.src;
			var src:String = templates[1].image.src;
			
			if (cloneMap.hasKey(src)) {
				clones.push(cloneMap.getKey(src));
				
				if (loadCnt >= resultCnt)
					loadEnd();
				else 
					onCloneLoad();
			}
			else {
				//clone = templates[0].clone(); // TODO: remove hardcoded template item 			
				clone = templates[1].clone();
				clone.image.close();
				clones.push(clone);
				clone.addEventListener(StateEvent.CHANGE, onCloneLoad);			
				//clone.image.open(src);
				//clone.init();
				cloneMap.append(src, clone);
			}
		}		

		
		// image load data
		private function onCloneLoad(event:StateEvent=null):void 
		{			
			if (event && event.property == "percentLoaded") {
				dockText[1].text = "loading " + (String)(loadCnt + 1) + " of " + resultCnt + ": " + event.value;
			}
			
			else if ( (!event) || event.property == "isLoaded") {
				if (event) {
					event.target.removeEventListener(StateEvent.CHANGE, onCloneLoad);			
					event.target.init();
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
		
		
		private function displayResults():void
		{
			for (var i:int = 0; i < dockText.length; i++) {
				dockText[i].visible = false;
			}
			
			var resultTxt:Text = searchChildren("#result_text");
			resultTxt.text = resultCnt + " Results";			
		
			//var album:Album = ("menu1");  //TODO: for testing purposes; need to provide more reliable access to album
			album.clear();
			for each(var clone:* in clones)
				album.addChild(getPreview(clone));
				
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
				selectItem(clones[previews.indexOf(e.value)]);
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
			}
			else {		
				obj.x = location.x;
				obj.y = location.y;				
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
		
		private function moveBelowDock(obj:DisplayObject):void 
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
		
		
		// searches for expressions attributes and replaces with result data
		private function searchExp(obj:*, prop:String=null, val:*=null):void
		{	
			if (!obj.propertyStates) return;
			
			for (var p:String in obj.propertyStates[0]) {
				if ((String(obj.propertyStates[0][p]).indexOf("{") != -1)) {					
					var str:String = String(obj.propertyStates[0][p]).substring(1, String(obj.propertyStates[0][p]).length -1);
					
					if (str == prop && val != null) {
						obj[p] = val;
					}
				}
			}
			
			// recursion
			if (obj is DisplayObjectContainer) {
				for (var i:int = 0; i < obj.numChildren; i++) {
					searchExp(obj.getChildAt(i), prop, val);		
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