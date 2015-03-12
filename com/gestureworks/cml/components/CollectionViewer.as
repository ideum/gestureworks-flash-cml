package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.elements.Dock;
	import com.gestureworks.cml.elements.Graphic;
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.layouts.FanLayout;
	import com.gestureworks.cml.layouts.ListLayout;
	import com.gestureworks.cml.layouts.PileLayout;
	import com.gestureworks.cml.layouts.PointLayout;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.greensock.easing.Expo;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	
	
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
	public class CollectionViewer extends Component {

		// local file version		
		protected var queue:List;
		protected var shown:List;
		
		private var currentTween:*;
		public var animateIn:Boolean = false;
		public var amountToShow:int = -1;
		private var hitBg:Sprite;
		private var tweens:Dictionary = new Dictionary(true);
		private var timer:Timer;
		private var components:Array;
		
		
		// database version
		private var loadBkg:Graphic;
		private var loadPercent:Text;
		private var loadScrnComplete:Boolean = false;		
		private var templates:Array = [];		
		private var docks:Array = [];
		private var _topContainer:TouchContainer;
		private var _bottomContainer:TouchContainer;
		private var containerTags:Dictionary = new Dictionary();
		private var positions:Dictionary;
		private var layoutThreshold:Boolean = true;
		private var totalProgress:Number = 0;		
		private var _gateway:String;		

		
		/**
		 * Constructor
		 */
		public function CollectionViewer() {
			super();
			mouseChildren = true;
		}
		

		
		/**
		 * @inheritDoc
		 */
		override public function init():void 
		{	
			// local file version
			if (!gateway) {
				localInit();
			}
			// database version
			else {
				dbInit();
			}
		}
		
		
		// local file version
		
		/**
		 * @private
		 * Initializes local file version
		 */
		private function localInit():void {
						
			// create hit background, useful for pixel-perfect determinations of whether the object is on or off stage.
			if(!hitBg){
				hitBg = new Sprite;
				hitBg.name = "hitbg";
				hitBg.graphics.beginFill(0x000000, 1);
				hitBg.graphics.drawRect(30, 30, stage.stageWidth - 60, stage.stageHeight - 60);
				hitBg.graphics.endFill();
				hitBg.cacheAsBitmap = true;
				hitBg.visible = false;
				addChildAt(hitBg, 0);		
			}
			
			// create component array to hold all components
			components = [];			
			
			// create queue to hold off-sscreen components
			queue = new List;
			
			// create list to hold on-screen components
			shown = new List;
			
			if (amountToShow >= childList.length || amountToShow == -1) {
				amountToShow = childList.length;
			}
		
			var i:int;	
			var c:DisplayObject;
			
			for (i = 0; i < childList.length; i++) {	
				c = childList.getIndex(i);
				
				if (c == hitBg) {
					continue;
				}
				
				// store all in components array
				components.push(c);
				
				// add component event listeners
				c.addEventListener(StateEvent.CHANGE, onStateEvent, false, -1);
				c.addEventListener(GWGestureEvent.COMPLETE, onGestureComplete);
				//if (autoShuffle) {
					c.addEventListener(GWTouchEvent.TOUCH_BEGIN, updateLayout);
				//}
				
				// set currently active components
				if (i < amountToShow) {					
					c.visible = true;
					shown.append(c);
				}
				else {					
					c.visible = false;						
					queue.append(c);
				}	
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}	
		
		/**
		 * Removes component.
		 */
		protected function removeComponent(c:DisplayObject):void {
			shown.remove( shown.search(c) );			
			queue.append(c);
			c.visible = false;
		}		
		
		/**
		 * Adds component.
		 */
		protected function addComponent(c:DisplayObject):void {			
			queue.remove( queue.search(c) );
			shown.append(c);
			c.visible = true;
		}
		
		/**
		 * Checks to see if the correct number of componets are currently shown.
		 */
		protected function checkComponents():void {
			if (shown.length < amountToShow) {
				addNextComponent();
			}			
		}
		
		/**
		 * Adds next component from queue.
		 */		
		protected function addNextComponent():void {
			var c:DisplayObject;							
			c = queue.getIndex(0);
			
			if (c) {
				c.x = -500;
				c.y = -500;
				addChild(c);
				if (animateIn) {
					tweens[c] = TweenLite.to(c, 4, { x:(stage.stageWidth/2-(c.width/2*c.scaleX)), y:(stage.stageHeight/2-(c.height/2*c.scaleY)), ease:Expo.easeOut, onComplete:onTweenEnd } ); 
					tweens[c].play();	
				}
				addComponent(c);
			}
			
			function onTweenEnd():void {			
				tweens[c] = null;
			}
		}			
		
		/**
		 * Enter frame event handler
		 */
		protected function onEnterFrame(e:Event):void {
			checkComponents();
		}		
		
		/**
		 * @inheritDoc
		 */		
		override protected function onStateEvent(event:StateEvent):void {	
			if (event.value == "close") {				
				removeComponent(event.currentTarget as DisplayObject);			
				checkComponents();
			}	
		}	
				
		/**
		 * Remove component when boundary check fails
		 * @param	event
		 */
		protected function onGestureComplete(event:GWGestureEvent = null):void {
			var v:TouchContainer = event.target as TouchContainer;
			var hCheck:Boolean = (v.x > 60 - v.width*v.scale) && (v.x < stage.stageWidth - 60);
			var vCheck:Boolean = (v.y > 60 - v.height*v.scale) && (v.y < stage.stageHeight - 60);
			if (!(hCheck && vCheck))
				removeComponent(DisplayObject(event.target));
		}
		  
		/**
		 * @inheritDoc
		 */
		override public function updateLayout():void {			
			//var target:DisplayObject = event.target;
			//if (tweens[target.parent]) {
				//tweens[target.parent].kill();
				//tweens[target.parent] = null;
				//delete tweens[target.parent];
			//}			
			//moveToTop(target);
		}			
		
		
		
		
		
		// database version

		
		/**
		 * Sets database gateway url
		 */
		public function get gateway():String { return _gateway; }
		public function set gateway(g:String):void {
			_gateway = g;
		}	
		
		/**
		 * Sets top container for double sided database version.
		 */
		public function get topContainer():* { return _topContainer; }
		public function set topContainer(c:*):void {
			if (!(c is TouchContainer))
				c = CMLObjectList.instance.getId(c.toString());
			if (c is TouchContainer)
			{
				_topContainer = c;
				_topContainer.addEventListener(GWGestureEvent.TAP, tapLayout);
			}
		}
		
		/**
		 * Sets bottom container for double sided database version.
		 */		
		public function get bottomContainer():* { return _bottomContainer; }
		public function set bottomContainer(c:*):void {
			if (!(c is TouchContainer))
				c = CMLObjectList.instance.getId(c.toString());
			if (c is TouchContainer)
			{
				_bottomContainer = c;
				_bottomContainer.addEventListener(GWGestureEvent.TAP, tapLayout);
			}			
		}			
		
				
		/**
		 * @private
		 * Initializes local file version
		 */
		private function dbInit():void {		
			if (!gateway) {
				return;
			}
			
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
				//docks[i].autoShuffle = autoShuffle;
				docks[i].templates = templates;
			}			
			
			hideAll();			
			getPlaceHolders();
			connect();	
		}
				
		/**
		 * @private
		 * Connect docks to gateway.
		 */
		public function connect():void {
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

		/**
		 * Classifies the object as either a top-container object or a bottom-container object.
		 * @param	top  container tag
		 * @param	obj  the object to tag
		 */		
		public function tagObject(top:Boolean, obj:*):void {
			if (!(containerTags[top]))
				containerTags[top] = new Array();
			containerTags[top].push(obj);
		}	
		
		/**
		 * Disassociates the provided object from the top or bottom containers.
		 * @param	obj
		 */
		public function untagObject(obj:*):void {
			var top:Number = containerTags[true] ? containerTags[true].indexOf(obj) : -1;			
			var bot:Number = containerTags[false] ? containerTags[false].indexOf(obj) : -1;			
			
			if (top >= 0)
				containerTags[true].splice(top, 1);
			else if (bot >= 0)
				containerTags[false].splice(bot, 1);
		}
		
		/**
		 * @private
		 */
		private function loadScreen():void {
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

		/**
		 * @private
		 */
		private function getPlaceHolders():void {
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
		private function addTapContainer(top:Boolean, placeHolder:*):void {
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
		private function assignTapContainers(container:TouchContainer, nested:Boolean=false):Array {
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
		private function tapLayoutInstance(type:Class, tapContainer:*):* {			
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
		private function tapLayout(e:GWGestureEvent):void {	
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
			switch(e.value.tap_n) {
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
		
	
		
		// util methods
		
		private function moveToTop(obj:*):void {
			if (obj.parent && obj.parent != this ) {
				moveToTop(obj.parent);
			}
			else if (obj.parent && obj.parent == this) {
				setChildIndex(obj, this.numChildren - 1);
			}
		}
		
		private function hideAll():void {			
			for (var i:int = 0; i < numChildren; i++)
			{
				if(getChildAt(i) is Component)
					getChildAt(i).visible = false;
			}
		}
			
		private function fadein(obj:DisplayObject, duration:Number=.25):void {
			var tween:TweenLite = TweenLite.fromTo(obj, duration, { alpha:0 }, { alpha:1 } );
			tween.play();
		}
		
		private function fadeout(obj:DisplayObject, duration:Number=.25):void {
			var tween:TweenLite = TweenLite.fromTo(obj, duration, { alpha:1 }, { alpha:0 } );
			tween.play();
		}		
		
		
		
		// dispose
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			queue = null;			
			currentTween = null;			
			hitBg = null;			
			tweens = null;
			templates = null;
			docks = null;
			containerTags = null;
			positions = null;
			topContainer = null;
			bottomContainer = null;
		}		
		
		
		
	}
}