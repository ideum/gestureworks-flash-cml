package com.gestureworks.cml.components 
{
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
	
	
	/**
	 * The CollectionViewer component manages the display of components and elements. 
	 * 
	 * <p>It can load more objects than will display at any one time. The objects not displayed are put 
	 * into queue and the CollectionViwer cycles through the queue whenever a user closes an object or 
	 * moves it offscreen.</p>
	 *  
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 */	
	public class CollectionViewer extends Component
	{
		
		// file version		
		private var queue:List;
		private var currentTween:*;
		public var animateIn:Boolean = false;
		public var amountToShow:int = -1;
		private var hitBg:Sprite;
		private var tweens:Dictionary = new Dictionary(true)
		
		
		// database version
		private var connection:NetConnection;
		private var responder:Responder;
		private var entry:Text;
		private var data:Object;
		private var index:int = 0;
		private var templates:Array = [];
		private var docks:Dictionary;
		private var dockArray:Array = [];
		private var loadText:Text;	
		private var dockText:Array = [];
		private var dials:Array = [];
		private var searchTerms:Array = ["work_description:rug"];
		private var clones:Array = [];
		private var cloneLocations:Array;
		private var clIndex:int = 0;
		private var previews:Array = [];		
		private var loadCnt:int = 0;
		private var resultCnt:int = 0;
		private var maxLoad:int = 2;
		private var result:Object;		
		private var isLoading:Boolean = false;
		private var cloneMap:LinkedMap = new LinkedMap(false);
		
		
		/**
		 * CollectionViewer Constructor
		 */
		public function CollectionViewer() 
		{
			super();
			mouseChildren = true;
		}
		
		
		
		private var _gateway:String;		
		public function get gateway():String { return _gateway; }
		public function set gateway(g:String):void
		{
			_gateway = g;
		}	
		
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}	
		
		/**
		 * Initialization
		 */
		override public function init():void 
		{	
			// file version
			if (!gateway) {
				hitBg = new Sprite;
				hitBg.name = "hitbg";
				hitBg.graphics.beginFill(0x000000, 1);
				hitBg.graphics.drawRect(30, 30, stage.stageWidth - 60, stage.stageHeight - 60);
				hitBg.graphics.endFill();
				hitBg.cacheAsBitmap = true;
				hitBg.visible = false;
				addChildAt(hitBg, 0);		
				
				queue = new List;
				if (amountToShow >= childList.length || amountToShow == -1)
					amountToShow = childList.length;
			
				var i:int = 0;	
				for (i = 0; i < childList.length; i++) {	
					if (autoShuffle) 
					{
						if (GestureWorks.activeTUIO)
							childList.getIndex(i).addEventListener(TuioTouchEvent.TOUCH_DOWN, updateLayout);
						else if (GestureWorks.supportsTouch)
							childList.getIndex(i).addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
						else 
							childList.getIndex(i).addEventListener(MouseEvent.MOUSE_DOWN, updateLayout);	
					}
					
					childList.getIndex(i).addEventListener(StateEvent.CHANGE, onStateEvent, false, -1);
					childList.getIndex(i).addEventListener(GWGestureEvent.COMPLETE, onBoundsTimer);
					
					if (i < amountToShow) {					
						addChild(childList.getIndex(i));
					}
					else {					
						if (contains(childList.getIndex(i)))
							removeChild(childList.getIndex(i));
												
						queue.append(childList.getIndex(i));
					}	
				}
			}
			
			// database version
			else {
				dbInit();
			}
		}
		
				
		
		
		// database methods

		// initialize database version
		private function dbInit():void
		{		
			if (!gateway) return;
			
			
			dockText = CMLObjectList.instance.getCSSClass("dock-text").getValueArray();
			dials = CMLObjectList.instance.getCSSClass("dial-bot").getValueArray();			
			CMLParser.instance.addEventListener(CMLParser.COMPLETE, cmlInit);
			addEventListener(StateEvent.CHANGE, selection);
			
			for (var j:int = 0; j < dials.length; j++) {
				dials[j].addEventListener(StateEvent.CHANGE, onDialChange);
				searchTerms[j] = "";
			}			
			
			var i:int = 0;	
			
			// store templates and docks
			for (i = 0; i < numChildren; i++) {		
				if (getChildAt(i).hasOwnProperty("class_") && getChildAt(i)["class_"] == "search") {
					if (!docks) docks = new Dictionary();
					docks[getChildAt(i)] = new Array();
					dockArray.push(getChildAt(i));
				}
				else if (getChildAt(i).name != "hitbg")
					templates.push(getChildAt(i));
			}
						
			hideAll();
			connect();									
			
			/*
			entry = new Text();
			entry.width = 200;
			entry.height = 25;
			entry.type = "input";
			entry.visible = true;
			entry.background = true;
			entry.border = true;
			entry.addEventListener(KeyboardEvent.KEY_DOWN, query);
			addChild(entry);
			*/			
		}
		
		
		// connect to gateway
		private function connect():void
		{
			connection = new NetConnection;
			connection.connect(gateway);				
			responder = new Responder(onResult, onFault);	
		}			
		
		private var cmlIni:Boolean = false;
		
		// add dial listeners here to skip default selections
		private function cmlInit(e:Event):void
		{
			CMLParser.instance.removeEventListener(CMLParser.COMPLETE, cmlInit);
			cmlIni = true;
		}

		
		// get search terms from dial and submit query
		private function onDialChange(e:StateEvent):void 
		{
			var index:int = dials.indexOf(e.target);
			
			if (index == 0)
				searchTerms[index] = "work_description:" + e.value; 
			
			else if (index == 1)
				searchTerms[index] = "work_description:" + e.value; 
			
			else if (index == 2)
				searchTerms[index] = "work_description:" + e.value; 
			
			trace("searchTerms", searchTerms);
			
			if (cmlIni)
				query();
		}
		
		
		
		// submit query
		private function query(e:KeyboardEvent=null):void
		{
			if (isLoading)
				return;
			
			isLoading = true;
			var returnFields:Array = ["work_description", "copyrightdate"];
			
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
				//connection.call("./AMFTest.search_choose_return", responder, searchString, null, null, returnFields);
				//connection.call("./AMFTest.search_and_return", responder, searchString, null, null);
				//connection.call("./AMFTest.getalldata", responder, entry.text);
				//connection.call("./SetTest.set_search", responder, entry.text);
			//}			
			
			
			//hideAll();

			
			var album:Album = CMLObjectList.instance.getId("menu1");  //TODO: for testing purposes; need to provide more reliable access to album
			album.clear();
			
			previews = [];
			clones = [];
			
			dockText[1].text = "searching collection...";
			dockText[0].visible = true;
			dockText[1].visible = true;
			var resultTxt:Text = CMLObjectList.instance.getId("result_text");
			resultTxt.text = "";				
		}
		
		private function onResult(res:Object):void
		{			
			result = res;
			resultCnt = 0;		
			
			for (var n:* in result) {
				resultCnt++;	
			}
						
			if (!resultCnt)
				isLoading = false;
			
			getCloneLocations();

			if (amountToShow > resultCnt)
				amountToShow = resultCnt;			
			
			//printResult(result);
			
			loadClone();			
		}

		
		private function onFault(fault:Object):void
		{
			trace(fault.description);
		}		


		private function getCloneLocations():void
		{
			if (cloneLocations)
				return;
			
			cloneLocations = [];
			var top:Array = CMLObjectList.instance.getCSSClass("bg-rect-bot").getValueArray();
			for each(var val:* in top)
				cloneLocations.push(val);
		}
		
		private function loadClone():void
		{
			var num:int=0;
						
			num = maxLoad + loadCnt;
			
			if (num >= resultCnt)
				num = resultCnt;
				
			for (var i:int = loadCnt; i < num; i++) {				
				for (var j:* in result[i]) {
					searchExp(templates[0], String(j), result[i][j]);			
				}
				createClone(clones[i]);			
			}					
		}
		
		
		// creates image viewer clone
		private function createClone(clone:*):void
		{
			var src:String = templates[0].image.src;
			
			if (cloneMap.hasKey(src)) {
				clones.push(cloneMap.getKey(src));
				loadCnt++;
				if (loadCnt == resultCnt)
					loadEnd();
			}
			else {
				clone = templates[0].clone(); // TODO: remove hardcoded template item 			
				clone.image.close();
				clones.push(clone);
				clone.addEventListener(StateEvent.CHANGE, onCloneLoad);			
				clone.image.open(src);
				cloneMap.append(src, clone);
			}
		}		

		
		// image load data
		private function onCloneLoad(event:StateEvent=null):void 
		{			
			if (event.property == "percentLoaded") {
				dockText[1].text = "loading " + (String)(loadCnt + 1) + " of " + resultCnt + ": " + event.value;
			}
			
			else if (event.property == "isLoaded") {
				event.target.removeEventListener(StateEvent.CHANGE, onCloneLoad);			
				event.target.init();
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
			
			var resultTxt:Text = CMLObjectList.instance.getId("result_text");
			resultTxt.text = resultCnt + " Results";			
		
			var album:Album = CMLObjectList.instance.getId("menu1");  //TODO: for testing purposes; need to provide more reliable access to album
			album.clear();
			for each(var clone:* in clones)
				album.addChild(getPreview(clone));
				
			album.margin = 15;
			album.init();
		}
		
		
		private function getPreview(obj:ImageViewer):TouchContainer
		{
			var prv:TouchContainer = new TouchContainer();
			var img:Image = obj.image.clone();
													
			img.width = 0;
			img.height = 140;
			img.resample = true;
			img.scale = 1;
			img.resize();
						
			var title:Text = obj.back.childList.getKey("title").clone();
			title.width = img.width;
			title.textAlign = "center";
			title.fontSize = 10;
			title.y = img.height;			
			
			fadein(img, 1);
			
			prv.addChild(img);
			prv.addChild(title);
			prv.width = img.width;
			prv.height = img.height + 30;
			previews.push(prv);
			
			return prv;
		}
		

		private function selection(e:StateEvent):void
		{
			if (e.property == "selectedItem")
			{								
				var location:Graphic = cloneLocations[clIndex];				
				var obj:* = clones[previews.indexOf(e.value)];
				
				// if object is already on the stage
				if (obj.visible) {
					obj.restartTimer();					
					obj.glowPulse();
					return;				
				}
				
				obj.restartTimer();
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
				obj.x = location.x;
				obj.y = location.y;
				
				var deg:Number = NumberUtils.randomNumber( -2.5, 2.5);
				var point:Point = new Point(obj.x + obj.width / 2, obj.y + obj.height / 2);				
				var m:Matrix=obj.transform.matrix;
				m.tx -= point.x;
				m.ty -= point.y;
				m.rotate (deg*(Math.PI/180));
				m.tx += point.x;
				m.ty += point.y;
				obj.transform.matrix=m;
				
				obj.reset();
				moveBelowDock(obj);
				fadein(obj);				
				obj.visible = true;			
				
				cloneLocations[clIndex].lineColor = 0xbbbbbb;
				clIndex++;					
				clIndex = clIndex == cloneLocations.length  ? 0 : clIndex;	
				cloneLocations[clIndex].lineColor = 0x000000;
			}
		}
		
		
		private function moveB(e:*):void 
		{
			moveBelowDock(e.currentTarget as DisplayObject);
		}
		
		private function moveBelowDock(obj:DisplayObject):void 
		{
			addChildAt(obj, getChildIndex(DisplayObject(dockArray[0])) - 1);
		}
		
		private function onCloneChange(e:StateEvent):void
		{					
			e.target.removeEventListener(StateEvent.CHANGE, onCloneChange);
						
			if (e.property == "visible") {
				if (!e.value) {
					e.target.visible = false;
					var index:int = clones.indexOf(e.target)				
					if (index >= 0) {
						var m:MenuAlbum = CMLObjectList.instance.getId("menu1");
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
					
					if (str == prop) {
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
		
		
		
		
		
		
		
		// file version
		
		private function getNextComponent(c:*):*
		{
			var components:Array = searchChildren(c, Array);
			var component:*;
			var found:Boolean = false;
			
			for each(var comp:* in components)
			{
				if (!comp.visible)
				{
					component = comp;
					found = true;
				}
			}
			
			if (!found && components.length > 0)
				component = components[0];
				
							
			return component;
		}
					
				
		override protected function onStateEvent(event:StateEvent):void
		{	
			if (event.value == "close") 
			{				
				removeComponent(event.currentTarget);				
				if (numChildren-1 < amountToShow)
					addNextComponent();
			}	
		}	
		
		private function removeComponent(component:*):void
		{
			queue.append(component);
			if (contains(component as DisplayObject))
				removeChild(component as DisplayObject);
		}
		
		private function addNextComponent():void
		{
			var newComponent:*;							
			newComponent = queue.getIndex(0);
			queue.remove(0);
			
			if (newComponent)
			{
				newComponent.x = -500;
				newComponent.y = -500;
				addChild(newComponent);
				newComponent.visible = true;
				
				
				if (animateIn)
				{
					tweens[newComponent] = BetweenAS3.tween(newComponent, { x:stage.stageWidth/2, y:stage.stageHeight/2 }, null, 4, Exponential.easeOut)
					tweens[newComponent].onComplete = onTweenEnd;
					tweens[newComponent].play();
				}
			}
			
			function onTweenEnd():void
			{			
				tweens[newComponent] = null;
			}
						
		}		
		
		private function onBoundsTimer(event:GWGestureEvent=null):void
		{
			var onscreen:Boolean = CollisionDetection.isColliding(DisplayObject(event.target), hitBg, this, true, 0);								
			if (!onscreen)
				removeComponent(DisplayObject(event.target));			
				
			if (this.numChildren-1 < amountToShow)
				addNextComponent();			
		}
		   
		override protected function updateLayout(event:* = null):void 
		{
			var target:*;
			
			if (GestureWorks.activeTUIO && event.target.parent.hasOwnProperty("mouseChildren") && !event.target.parent.mouseChildren)
				target = event.target.parent;
			else
				target = event.target;
						
			if (tweens[target.parent])
			{
				tweens[target.parent].stop();
				tweens[target.parent] = null;
				delete tweens[target.parent];
			}
			
			moveToTop(target);
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
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			queue = null;			
			currentTween = null;			
			hitBg = null;			
			tweens = null;
			
			if (childList)
			{
				for (var i:int = 0; i < childList.length; i++) 
				{	
					childList.getIndex(i).removeEventListener(TuioTouchEvent.TOUCH_DOWN, updateLayout);
					childList.getIndex(i).removeEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
					childList.getIndex(i).removeEventListener(MouseEvent.MOUSE_DOWN, updateLayout);
					childList.getIndex(i).removeEventListener(StateEvent.CHANGE, onStateEvent);
				}
			}
		}		
		
		
		
		
		
		
		
		
		/*
		private function updateSets(result:Object):void
		{
			for each(var setObject:* in result)
			{
				for (var setProperty:* in setObject)
				{
					if (setProperty == "set_items")
					{
						for (var collection:* in setObject[setProperty])
						{
							var collectionType:* = setObject[setProperty][collection]["collection_display"];
							var component:* = collectionType == "slideshow" ? getNextComponent(AlbumViewer): getNextComponent(AlbumViewer);														
							var front:* = component.front;
							var back:* = component.back;
							
							component.clear();
							front.clear();
							back.clear();
							
							for (var object:* in setObject[setProperty][collection])
							{
								for (var property:* in setObject[setProperty][collection][object])
								{
									var val:* = setObject[setProperty][collection][object][property];
									switch(property)
									{
										case "name":											
											break;
										case "work_description":
											break;
										case "image":
											var img:Image = new Image();
											img.open(val);
											img.width = 400;
											img.height = 400;
											img.resample = true;
											
											front.addChild(img);											
											break;
										default:
											break;
									}
								}
							}
							
							front.init();
							component.init();
							component.visible = true;
						}
					}
				}
			}			
		}
		*/		
		
		
		
		
		
		
		
		
		
		
		
		
	}
}