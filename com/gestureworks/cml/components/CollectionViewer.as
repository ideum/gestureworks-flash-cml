package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.layouts.FanLayout;
	import com.gestureworks.cml.layouts.ListLayout;
	import com.gestureworks.cml.layouts.PileLayout;
	import com.gestureworks.cml.layouts.PointLayout;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import com.greensock.easing.Expo;
	import com.greensock.TweenLite;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
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
		private var timer:Timer;
		
		
		// database version
		private var templates:Array = [];		
		private var docks:Array = [];
		private var _topContainer:TouchContainer;
		private var _bottomContainer:TouchContainer;
		private var containerTags:Dictionary = new Dictionary();
		private var positions:Dictionary;
		private var layoutThreshold:Boolean = true;
		private var totalProgress:Number = 0;		
		
		
		// tmp
		private var entry:Text;

		
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
		
		public function get topContainer():* { return _topContainer; }
		public function set topContainer(c:*):void
		{
			if (!(c is TouchContainer))
				c = CMLObjectList.instance.getId(c.toString());
			if (c is TouchContainer)
			{
				_topContainer = c;
				_topContainer.addEventListener(GWGestureEvent.TAP, tapLayout);
			}
		}
		
		public function get bottomContainer():* { return _bottomContainer; }
		public function set bottomContainer(c:*):void
		{
			if (!(c is TouchContainer))
				c = CMLObjectList.instance.getId(c.toString());
			if (c is TouchContainer)
			{
				_bottomContainer = c;
				_bottomContainer.addEventListener(GWGestureEvent.TAP, tapLayout);
			}			
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
						else if (GestureWorks.activeNativeTouch)
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
				
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER, timerCheck);
				timer.start();
			}
			
			// database version
			else {
				dbInit();
			}
		}
		
		/**
		 * Classifies the object as either a top-container object or a bottom-container object
		 * @param	top  container tag
		 * @param	obj  the object to tag
		 */		
		public function tagObject(top:Boolean, obj:*):void
		{
			if (!(containerTags[top]))
				containerTags[top] = new Array();
			containerTags[top].push(obj);
		}	
		
		/**
		 * Disassociates the provided object from the top or bottom containers
		 * @param	obj
		 */
		public function untagObject(obj:*):void
		{
			var top:Number = containerTags[true] ? containerTags[true].indexOf(obj) : -1;			
			var bot:Number = containerTags[false] ? containerTags[false].indexOf(obj) : -1;			
			
			if (top >= 0)
				containerTags[true].splice(top, 1);
			else if (bot >= 0)
				containerTags[false].splice(bot, 1);
		}
				
		private function timerCheck(e:TimerEvent):void {
			if (numChildren - 1 < amountToShow) {
				addNextComponent();
			}
		}
		
		// database methods

		// initialize database version
		private function dbInit():void
		{		
			if (!gateway) return;
			
			var i:int = 0;	
			
			
			// store templates and docks
			for (i = 0; i < numChildren; i++) {		
				if (getChildAt(i) is Dock) {
					docks.push(getChildAt(i));
				}
				else if (getChildAt(i).name != "hitbg")
					templates.push(getChildAt(i));
			}
			
			//set up docks
			for (i = 0; i < docks.length; i++) {		
				docks[i].amountToShow = amountToShow;
				docks[i].autoShuffle = autoShuffle;
				docks[i].templates = templates;
			}			
			
			
			hideAll();			
			getPlaceHolders();
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
				
		// connect docks to gateway
		public function connect():void
		{
			loadScreen();
			var progressCnt:int = 1;
			
			for (var i:int = 0; i < docks.length; i++) {
				docks[i].gateway = gateway;
				docks[i].connect();	
				totalProgress += docks[i].maxClones;
				docks[i].addEventListener(StateEvent.CHANGE, function(e:StateEvent):void {
					if (e.property == "preloaded")
					{
						loadPercent.text = String(int((progressCnt / totalProgress) * 100) + "%");
						progressCnt++;
						if (progressCnt > totalProgress)
						{
							removeChild(loadBkg);
							loadScrnComplete = true;
						}
					}
				});
			}
		}		

		private var loadBkg:Graphic;
		private var loadPercent:Text;
		private var loadScrnComplete:Boolean = false;
		
		private function loadScreen():void
		{
			loadBkg = new Graphic();
			loadBkg.shape = "rectangle";
			loadBkg.width = 1920;
			loadBkg.height = 1080;
			loadBkg.lineStroke = 0;
			loadBkg.color = 0x000000;
			
			var loadText:Text = new Text();
			loadText.fontSize = 50;
			loadText.color = 0xFFFFFF;
			loadText.autoSize = "left";
			loadText.textAlign = "left"
			loadText.y = 504;
			loadBkg.addChild(loadText);
			
			loadPercent = loadText.clone();
			loadPercent.addEventListener(Event.ENTER_FRAME, function loadNext(e:Event):void {
				for each(var dock:Dock in docks)
					dock.preloadClones();
				if (loadScrnComplete)
					loadPercent.removeEventListener(Event.ENTER_FRAME, loadNext);
			});
			
			loadText.text = "Loading...";
			loadText.x = 770;		
			loadPercent.x = 1040;
			
			addChild(loadBkg);
		}

		private function getPlaceHolders():void
		{
			// TODO: remove strict referencing
			var bot:Array = CMLObjectList.instance.getCSSClass("bg-rect-bot").getValueArray();
			var top:Array = CMLObjectList.instance.getCSSClass("bg-rect-top").getValueArray();		
			
			for (var i:int = 0; i < docks.length; i++) {
				if (i == 0) {
					for each(var val:* in bot) {
						docks[i].placeHolders.push(val);
						addTapContainer(false, val);
					}
				}
				
				if (i == 1) {
					for (var j:int = top.length - 1; j >= 0; j--) {
						docks[i].placeHolders.push(top[j]);
						addTapContainer(true, top[j]);
					}
				}
			}
			
		}
		
		/**
		 * Adds a second level of nested containers to apply layouts to on tap events. Also generates
		 * a positioning map to store the place holder locations.
		 * @param	top  flag indicating addition to the top or bottom container
		 */
		private function addTapContainer(top:Boolean, placeHolder:*):void
		{
			var container:TouchContainer = top ? topContainer : bottomContainer;
			var x:Number = placeHolder.x;
			var y:Number = placeHolder.y;
			
			var tapC:TouchContainer = new TouchContainer();
			tapC.className = "tap_container";
			
			if (top && topContainer)
				topContainer.addChild(tapC);
			else if (!top && bottomContainer)
				bottomContainer.addChild(tapC);
			else
				return;
				
			if (!positions)
				positions = new Dictionary();
				
			if (!(positions[top]))
				positions[top] = new Array();
				
			if (top)
			{
				x+=placeHolder.width;
				y+=placeHolder.height;
			}
			
			positions[top].push(new Point(x, y));
			var layoutLimit:Timer = new Timer(1000);
			layoutLimit.start();
			layoutLimit.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				layoutThreshold = true;
			});
		}
			
		/**
		 * Dynamically transfers objects from the CollectionViewer to temporary containers for layout applications
		 * @param container  the parent container
		 * @param nested   a flag indicating the distribution of objects to the nested containers
		 * @return  an array of the containers the objects were distributed to
		 */
		private function assignTapContainers(container:TouchContainer, nested:Boolean=false):Array
		{
			var containers:Array = nested ? container.childList.getCSSClass("tap_container").getValueArray() : [container];
			var top:Boolean = container == topContainer;
			var index:int = 0;
			
			for each(var obj:* in containerTags[top])
			{
				if (!obj.activity)
				{
					obj.reset();
					containers[index].addChild(obj);
					index = index == containers.length - 1 ? 0 : index + 1;					
				}
			}
			
			return containers;
		}
		
		/**
		 * Generates a layout template to instantiate all layouts with common settings
		 * @param	type  the type of layout
		 * @param	tapContainer   the container that dispatched the tap event
		 * @return
		 */
		private function tapLayoutInstance(type:Class, tapContainer:*):*
		{			
			var top:Boolean = tapContainer == topContainer;
			var source:Class = getDefinitionByName(getQualifiedClassName(type)) as Class;
			var layout:* = new source();
			layout.tween = true;
			layout.continuousTransform = false;
			layout.rotation = top ? 180 : 0;
			layout.scale = top ? -.6 : .6;
			layout.exclusions = DisplayUtils.getAllChildren(DisplayObjectContainer(tapContainer));
			
			return layout;
		}
		
		/**
		 * Applies different layouts depending on the number of touches dispatching the tap event
		 * @param	e
		 */
		private function tapLayout(e:GWGestureEvent):void
		{	
			//limits time between tap events
			if (layoutThreshold)
				layoutThreshold = false;
			else
				return;
				
			//determines which container dispatched the tap event	
			var top:Boolean = e.target == topContainer;
		
			//check requirements
			var tapLimit:Boolean = e.value.tap_n < 4;
			var taggedObj:Boolean = containerTags[top] && containerTags[top].length > 0;
			if (!tapLimit || !taggedObj) return;
			
			var dock:Dock = top ? docks[1] : docks[0];
			var layouts:Array = new Array();
			var tapContainers:Array;
			
			//transfer objects back to CollectionViewer
			var layoutComplete:Function = function ():void {
					for each(var child:* in containerTags[top])
					{
						addChild(child);
						dock.moveBelowDock(child);				
					}
				};

			//evaluate tap count and apply layouts
			switch(e.value.tap_n)
			{
				case 2:
					var point:PointLayout = tapLayoutInstance(PointLayout, e.target);
					tapContainers = assignTapContainers(TouchContainer(e.target));
					var position:int = 0;
					var numPoints:int = e.target.numChildren - point.exclusions.length;
					
					//reposition children to placeholders
					for (var i:int = 0; i < numPoints; i++)
					{
						var xPos:Number = positions[top][position].x;
						var yPos:Number = positions[top][position].y;
						if (point.points)
							point.points = point.points.concat("," + xPos + "," + yPos);
						else
							point.points = xPos + "," + yPos;						
						position = position == positions[top].length - 1 ? 0 : position + 1;
					}
					
					tapContainers[0].layoutComplete = layoutComplete;
					tapContainers[0].applyLayout(point);
					break;
				case 3:					
					var list:ListLayout = tapLayoutInstance(ListLayout, e.target);
					tapContainers = assignTapContainers(TouchContainer(e.target));
					list.originX = positions[top][0].x;
					list.originY = positions[top][0].y;					
					tapContainers[0].layoutComplete = layoutComplete;
					tapContainers[0].applyLayout(list);					
					break;
				case 4:
					tapContainers = assignTapContainers(TouchContainer(e.target), true);
					var count:int = 0;
					for (i=0; i < tapContainers.length; i++)
					{
						var pile:PileLayout = tapLayoutInstance(PileLayout, e.target);
						pile.scale = NaN;
						pile.originX = top ? positions[top][i].x - 150 : positions[top][i].x + 150;
						pile.originY = top ? positions[top][i].y - 150 : positions[top][i].y + 150;
						tapContainers[i].layoutComplete = function():void {
							if (count == tapContainers.length-1)
								layoutComplete();
							count++;
						};
						tapContainers[i].applyLayout(pile);
					}
					break;
				case 5:
					var fan:FanLayout = tapLayoutInstance(FanLayout, e.target);
					tapContainers = assignTapContainers(TouchContainer(e.target));
					fan.type = top ? "bottomLeftOrigin" : "bottomRightOrigin";
					fan.scale = NaN;
					fan.originX = top ? 1440 : 480;
					fan.originY = top ? 230: 850;
					fan.angle = top ? -10 : 10;
					tapContainers[0].layoutComplete = layoutComplete;
					tapContainers[0].applyLayout(fan);					
					break;
				default:
					break;
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
				
				if (numChildren - 1 < amountToShow) {
					addNextComponent();
				}
			}	
		}	
		
		private function removeComponent(component:*):void
		{
			queue.append(component);
			if (contains(component as DisplayObject)) {
				removeChild(component);
			}
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
					tweens[newComponent] = TweenLite.to(newComponent, 4, { x:stage.stageWidth / 2, y:stage.stageHeight / 2, ease:Expo.easeOut, onComplete:onTweenEnd } ); 
					tweens[newComponent].play();	
				}
			}
			
			function onTweenEnd():void
			{			
				tweens[newComponent] = null;
			}
			
			/*if (this.numChildren - 1 < amountToShow) {
				addNextComponent();
			}*/
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
				//tweens[target.parent].stop();
				tweens[target.parent].kill();
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
			else if (obj.parent && obj.parent == this) setChildIndex(obj, this.numChildren - 1);
				//addChild(obj);
		}
		
		private function hideAll():void
		{			
			for (var i:int = 0; i < numChildren; i++)
			{
				if(getChildAt(i) is Component)
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
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			queue = null;			
			currentTween = null;			
			hitBg = null;			
			tweens = null;
			templates = null;
			docks = null;
			containerTags = null;
			entry = null;
			positions = null;
			topContainer = null;
			bottomContainer = null;
			
			if (timer){
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, timerCheck);
				timer = null;
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