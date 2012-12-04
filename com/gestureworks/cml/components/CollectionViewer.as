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
		private var templates:Array = [];		
		private var docks:Array = [];
		
		
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
			getCloneLocations();
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
			for (var i:int = 0; i < docks.length; i++) {
				docks[i].gateway = gateway;
				docks[i].connect();
			}
		}		


		private function getCloneLocations():void
		{
			// TODO: remove strict referencing
			var bot:Array = CMLObjectList.instance.getCSSClass("bg-rect-bot").getValueArray();
			var top:Array = CMLObjectList.instance.getCSSClass("bg-rect-top").getValueArray();		
			
			for (var i:int = 0; i < docks.length; i++) {
				if (i == 0) {
					for each(var val:* in bot) {
						docks[i].cloneLocations.push(val);
					}
				}
				
				if (i == 1) {
					for each(var val:* in top) {
						docks[i].cloneLocations.push(val);
					}
				}
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