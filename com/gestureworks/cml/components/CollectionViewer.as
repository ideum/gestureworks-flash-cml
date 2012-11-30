package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.easing.*;
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
		public var amountToShow:int = -1;
		public var animateIn:Boolean = true;
		
		private var queue:List;
		private var currentTween:*;
		
		private var _gateway:String;
		private var connection:NetConnection;
		private var responder:Responder;
		private var entry:Text;
		private var data:Object;
		private var index:int = 0;
		
		//private var boundsTimer:Timer;
		
		/**
		 * collection viewer Constructor
		 */
		public function CollectionViewer() 
		{
			super();
			queue = new List;
			mouseChildren = true;
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void 
		{
			cover = new Sprite;
			cover.name = "hitbg";
		
			cover.graphics.beginFill(0x000000, 1);
			cover.graphics.drawRect(30, 30, stage.stageWidth - 60, stage.stageHeight - 60);
			cover.graphics.endFill();
			cover.cacheAsBitmap = true;
			cover.visible = false;
			this.addChildAt(cover, 0);		
			
			//if (amountToShow >= childList.length || amountToShow == -1)
			//	amountToShow = childList.length;
					
				
			var i:int = 0;	
			for (i = 0; i < childList.length; i++) 
			{	
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
				
				if (i < amountToShow)
				{					
					addChild(childList.getIndex(i));
				}
				else
				{					
					if (contains(childList.getIndex(i)))
						removeChild(childList.getIndex(i));
											
					queue.append(childList.getIndex(i));
				}	
			}
			
				dbInit();
		}
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}	
		
		private var cover:Sprite;
		
		private function onBoundsTimer(event:GWGestureEvent=null):void
		{
			var onscreen:Boolean = CollisionDetection.isColliding(DisplayObject(event.target), cover, this, true, 0);								
			if (!onscreen)
				removeComponent(DisplayObject(event.target));			
				
			if (this.numChildren-1 < amountToShow)
				addNextComponent();			
		}
			

		   
		private var tweens:Dictionary = new Dictionary(true)
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
		
		private function moveToTop(obj:*):void
		{
			if (obj.parent && obj.parent != this )
				moveToTop(obj.parent);
			else
				addChild(obj);
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
		
		
		public function get gateway():String { return _gateway; }
		public function set gateway(g:String):void
		{
			_gateway = g;
		}
		
		
		
		
		
		
		private var templates:Array = [];
		private var docks:Dictionary;
		
		
	
		
		private var loadText:Text;
		
		private function dbInit():void
		{		
			if (!gateway) return;
					
			// store templates and docks
			for (var i:int = 0; i < numChildren; i++) 
			{		
				if (getChildAt(i).hasOwnProperty("class_") && getChildAt(i)["class_"] == "search")
				{
					if (!docks) docks = new Dictionary();
					docks[getChildAt(i)] = new Array();
				}
				else if (getChildAt(i).name != "hitbg")
					templates.push(getChildAt(i));
			}
						
			
			hideAll();
			connect();						
			
			// test text box
			if(1)//if (!docks)
			{				
				// tmp load status
				loadText = new Text;
				loadText.color = 0xFFFFFF;
				loadText.width = 500;
				loadText.height = 500;
				loadText.text = "load status";
				loadText.y = 50;
				addChild(loadText);
			
				entry = new Text();
				entry.width = 200;
				entry.height = 25;
				entry.type = "input";
				entry.visible = true;
				entry.background = true;
				entry.border = true;
				entry.addEventListener(KeyboardEvent.KEY_DOWN, query);
				addChild(entry);
			}
			
			addEventListener(StateEvent.CHANGE, selection);
			
		}
		
		
		
		private function query(e:KeyboardEvent):void
		{
			//entry.text
			//var searchString:String = "ca_objects.work_description:This is a yellow flower man";
			//var searchString:String = "ca_object_labels.name:Yellow Flower";
			//var searchString:String = "ca_objects.work_description:This is a AND ca_object_labels.name:Yellow";
			var searchString:String = "ca_objects.work_description:This is a";
			
			//var searchFields:Array = ["work_description:This is a", "copyrightdate:August"];
			var searchFields:Array = [];
			var returnFields:Array = ["work_description", "copyrightdate"];
			
			// original
			// mediumlarge
			// medium
			// small
			// etc -- see collective access
			
			if (e.keyCode == 13) {
				hideAll();
				//connection.call("./ObjectSearchTest.search_choose_return", responder, searchFields, returnFields, "mediumlarge");				
				connection.call("./AMFTest.search_choose_return", responder, searchString, null, null, returnFields);
				//connection.call("./AMFTest.search_and_return", responder, searchString, null, null);
				//connection.call("./AMFTest.getalldata", responder, entry.text);
				//connection.call("./SetTest.set_search", responder, entry.text);
			}
		}
		
		
		
		private function connect():void
		{
			connection = new NetConnection;
			connection.connect(gateway);				
			responder = new Responder(onResult, onFault);	
		}
		
		
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
				
		
		private function onResult(res:Object):void
		{	
			result = res;
			resultCnt = 0;
			for (var n:* in result) {
				resultCnt++;	
			}
			trace("resultCnt", resultCnt);
			printResult(result);
			updateObjects();
		}
		
		
		private var clones:Array = [];
		private var previews:Array = [];		
		private var loadCnt:int = 0;
		private var resultCnt:int = 0;
		private var maxLoad:int = 2;
		private var result:Object;
		
		
		private function updateObjects():void
		{	
			if (amountToShow > resultCnt)
				amountToShow = resultCnt;
				
			loadClone();
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
			
			var resultTxt:Text = CMLObjectList.instance.getId("result_text");
			resultTxt.text = resultCnt + " Results";
		}
		
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
		
		
		private function createClone(clone:*):void
		{
			trace("create clone");
			
			clone = templates[0].clone(); // TODO: remove hardcoded template item 
			
			var src:String = clone.image.src;			
			clone.image.close();
			
			clones.push(clone);
			
			clone.addEventListener(StateEvent.CHANGE, onLoadComplete);
			clone.addEventListener(StateEvent.CHANGE, onPercentLoad);
			
			clone.image.open(src);
		}		

		
		
		private function onPercentLoad(event:StateEvent):void 
		{			
			if (event.property == "percentLoaded") {
				loadText.text = "loading " + (String)(loadCnt+1) + " of " + resultCnt + ": " + event.value;
			}
		}						
		
		private function onLoadComplete(event:StateEvent=null):void 
		{
			if (event.property == "isLoaded") {
				event.target.removeEventListener(StateEvent.CHANGE, onLoadComplete);
				event.target.removeEventListener(StateEvent.CHANGE, onPercentLoad);
				event.target.init();
				loadCnt++;
				
				if (loadCnt == amountToShow) {
					//showClones();
				}
				else if (loadCnt == resultCnt) {
					displayResults();
					loadCnt = 0;
				}
				
				else if ( (loadCnt % maxLoad) == 0 ) {
					loadClone();
				}
				else {
					trace((loadCnt % maxLoad))
				}				
			}	
		}
		
		private function showClones():void
		{	
			for (var i:int = 0; i < amountToShow; i++) {
				clones[i].visible = true;
				
				if (autoShuffle) {
					if (GestureWorks.activeTUIO)
						clones[i].addEventListener(TuioTouchEvent.TOUCH_DOWN, updateLayout);
					else if (GestureWorks.supportsTouch)
						clones[i].addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
					else 
						clones[i].addEventListener(MouseEvent.MOUSE_DOWN, updateLayout);	
				}					
			}					
		}
		
		private function displayResults():void
		{			
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
			title.y = img.height;			
			
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
				clones[previews.indexOf(e.value)].visible = true;
		}
				
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
		
		private function onFault(fault:Object):void
		{
			////trace(fault.description);
		}
		
		private function hideAll():void
		{			
			for (var i:int = 0; i < numChildren; i++)
			{
				if(getChildAt(i) is TouchContainer)
					getChildAt(i).visible = false;
			}
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			queue = null;			
			currentTween = null;			
			cover = null;			
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
	}
}