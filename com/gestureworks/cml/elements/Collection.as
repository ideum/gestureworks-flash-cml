package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.greensock.easing.Expo;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * The Collection controls the display of its children based on a set number of allowable display objects. All objects not displayed are 
	 * put into a queue to be invoked when the display count changes (either when an object becomes invisble or is moved offscreen) providing 
	 * a cyclical browsing of the collection objects. 
	 * @author Ideum
	 */
	public class Collection extends Container
	{				
		private var displayed:Vector.<TouchContainer>;		//currently displayed
		private var queued:Vector.<TouchContainer>;			//queued for display 
		private var objectWidth:Number; 					//child object width reference
		private var objectHeight:Number; 					//child object height reference
		
		private var _displayCount:int = 1; 		
		private var _displayBehavior:Function; 
		private var _background:*; 							
		
		/**
		 * Enables an alternative default display behavior that animates the queued display object to the center
		 * of the collection from a random off-screen position. 
		 * @default false; 
		 */
		public var animateIn:Boolean;
		
		/**
		 * Allow gesture interactions to interrupt active animations
		 * @default = true;
		 */
		public var prioritizeGesture:Boolean = true; 
		
		/**
		 * Color of default background when @see #background setting is enabled. Not applicable for custom
		 * background displays. 
		 * @default 0x000000
		 */
		public var backgroundColor:uint;
		
		/**
		 * Alpha of default background when @see #background setting is enabled. Not applicable for custom
		 * background displays.
		 * @default 1
		 */
		public var backgroundAlpha:Number = 1;
				
		/**
		 * Constructor 
		 */
		public function Collection() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, defaultDimensions);
			displayed = new Vector.<TouchContainer>();
			queued = new Vector.<TouchContainer>();				
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {						
			super.init();	
			
			//evaluate background value
			if (background) {				
				//default graphic
				if (background is Boolean) {
					graphics.clear();
					graphics.beginFill(backgroundColor, backgroundAlpha);
					graphics.drawRect(0, 0, width, height);
					graphics.endFill();
				}
				//display object
				else {
					background = displayById(background);
					addChildAt(background, 0);
				}
			}
			
			//restrict display to dimensions
			scrollRect = new Rectangle(0, 0, width, height);
			
			//stop animation on touch
			if (prioritizeGesture) {
				addEventListener(GWTouchEvent.TOUCH_BEGIN, function(e:GWTouchEvent):void {
					TweenLite.killTweensOf(e.target);
				});
			}
			
			//set display
			initializeQueue();
		}
		
		/**
		 * If undefined, inherit stage dimensions 
		 * @param	e
		 */
		private function defaultDimensions(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, defaultDimensions);
			width = width ? width : stage.stageWidth;
			height = height ? height : stage.stageHeight;
		}
			
		/**
		 * @inheritDoc
		 */
		override public function set width(value:Number):void {
			super.width = value;
			if (scrollRect) {
				scrollRect.width = value; 
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set height(value:Number):void {
			super.height = value;
			if (scrollRect) {
				scrollRect.height = value; 
			}
		}
		
		/**
		 * The background setting allows the generation of a default background graphic with standard Boolean values or
		 * the assignment (either directly or by id) of a display object. 
		 * @default null
		 */		
		public function get background():* { return _background; }
		public function set background(value:*):void {
			if (value == "true" || value == "false") {
				_background = Boolean(value);
			}
			else {
				_background = value; 
			}
		}
		
		///////////////////////////////////////////////////
		// Object Registration
		///////////////////////////////////////////////////
		
		/**
		 * Register collection object. Since collection management requires a higher level of child awareness, 
		 * only @see com.gestureworks.cml.elements.TouchContainer children can be added. 
		 * @param	child The TouchContainer instance to add as a collection object
		 * @return
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			if (child is TouchContainer) {
				return super.addChild(child);
			}
			return child; 
		}
		
		/**
		 * Register collection object. Since collection management requires a higher level of child awareness, 
		 * only @see com.gestureworks.cml.elements.TouchContainer children can be added. 
		 * @param	child The TouchContainer instance to add as a collection object
		 * @param	index The index position to which the child is added
		 * @return
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if (child is TouchContainer) {
				return super.addChildAt(child, index);
			}
			return child;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeChild(child:DisplayObject):DisplayObject {
			removeObject(child as TouchContainer);
			return super.removeChild(child);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeChildAt(index:int):DisplayObject {
			var child:DisplayObject = super.removeChildAt(index);
			removeObject(child as TouchContainer);
			return child; 
		}
		
		/**
		 * Unregister object
		 * @param	object Registered instance to remove
		 */
		private function removeObject(object:TouchContainer):void {
			
			//remove from display trackers
			if (queued.indexOf(object) != -1) {
				queued.splice(queued.indexOf(object), 1);
			}
			else if (displayed.indexOf(object) != -1) {
				displayed.splice(displayed.indexOf(object), 1);
			}
		}
		
		///////////////////////////////////////////////////
		// Display Management
		///////////////////////////////////////////////////		
		
		/**
		 * Setup display queue
		 */
		protected function initializeQueue():void {
			
			//display trackers
			displayed = new Vector.<TouchContainer>();
			queued = new Vector.<TouchContainer>();			
			
			//populate queue 
			var object:TouchContainer;
			var i:int = background is DisplayObject ? 1 : 0;
			for (i; i < numChildren; i++) {
				object = getChildAt(i) as TouchContainer;
				object.visible = false; 
				
				//track visibility
				object.addEventListener(StateEvent.CHANGE, visibilityCheck);
				
				//track position
				if (object.releaseInertia) {
					object.addEventListener(GWGestureEvent.COMPLETE, boundaryCheck);
				}
				
				queued.push(object);
			}
			
			//prevent display count from exceeding the number of objects
			if (displayCount > queued.length) {
				displayCount = queued.length;
			}
			
			//load the stage with the display limit
			while (displayed.length < displayCount) {
				displayNext();
			}
		}
		
		/**
		 * The fixed number of objects to display on screen. When an object is not displayed, either by disabling its visibility or 
		 * moving outside of the display area, another object is queued to replace it. The assigned value must be postive and cannot 
		 * exceed the number of objects in the collection.
		 * @default 1
		 */
		public function get displayCount():int { return _displayCount; }
		public function set displayCount(value:int):void {
			if(value >= 0){
				_displayCount = value; 
			}
		}
		
		/**
		 * Reference to currently displayed objects
		 */
		public function get onDisplay():Vector.<TouchContainer> { return displayed.concat(); }
		
		/**
		 * Reference to objects queued for display
		 */
		public function get onQueue():Vector.<TouchContainer> { return queued.concat(); }
		
		/**
		 * Display the next object in the queue
		 */
		protected function displayNext():void {
			var next:TouchContainer = queued.shift();
			displayed.push(next);
			next.visible = true;
			
			if (displayBehavior != null) {
				displayBehavior.call(null, next);
			}
			else if (animateIn) {
				animateToCenter(next);
			}
			else {
				centerFadeIn(next);
			}
		}
		
		/**
		 * Remove from display and append to queue
		 * @param	object The object to append
		 */
		protected function addToQueue(object:TouchContainer):void {			
			displayed.splice(displayed.indexOf(object), 1); 
			queued.push(object);			
			displayNext();
		}
		
		/**
		 * Transfer invisible objects from display to queue
		 * @param	object The subscribed object
		 */
		protected function visibilityCheck(event:StateEvent):void {
			if (event.property == "visible") {
				event.target.touchEnabled = event.target.visible; 
				if (!event.target.visible) {
					addToQueue(event.target as TouchContainer);
				}
			}
		}
		
		/**
		 * Transfer out of bounds objects from display to queue. Boundary checks only apply to objects with release
		 * inertia enabled. 
		 * @param	event Event fired on gesture complete
		 */
		protected function boundaryCheck(event:GWGestureEvent):void {
			if (event.target.visible && !this.hitTestObject(event.target as DisplayObject)) {
				addToQueue(event.target as TouchContainer);
			}
		}
		
		/**
		 * External hook invoked on object display for the purpose of customizing the display behavior (positioning, animation, etc.). 
		 * The callback function signature must match the following functionName(object:TouchContainer); object being the object to display.
		 */
		public function get displayBehavior():Function { return _displayBehavior; }
		public function set displayBehavior(value:Function):void {
			_displayBehavior = value; 
		}		
		
		/**
		 * This is the default display behavior that centers the object and executes a fade-in animation
		 * @param	object The object to display
		 */
		private function centerFadeIn(object:TouchContainer):void {
			object.resetTransform();
			objectWidth = object.width ? object.width : object.displayWidth;
			objectHeight = object.height ? object.height : object.displayHeight;
			object.x = width / 2 - objectWidth / 2;			
			object.y = height / 2 - objectHeight / 2;			
			TweenLite.fromTo(object, .5, { alpha:0 }, { alpha:1 } );
		}
		
		/**
		 * An alternate display behavior, enabled by the @see #animateIn setting, that animates objects from an offscreen position to the center of
		 * the collection
		 * @param	object The object to display
		 */
		private function animateToCenter(object:TouchContainer):void {
			object.resetTransform();	
			objectWidth = object.width ? object.width : object.displayWidth;
			objectHeight = object.height ? object.height : object.displayHeight;			
			TweenLite.fromTo(object, 3, { x:-objectWidth, y:-objectHeight }, { x:width / 2 - objectWidth / 2, y:height / 2 - objectHeight / 2, ease:Expo.easeOut } );
		}
		
		/**
		 * Remove all registered objects
		 */
		public function clear():void {
			var obj:TouchContainer;
			for each(obj in displayed) {
				removeChild(obj);
			}
			for each(obj in queued) {
				removeChild(obj);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {
			var i:int; 
			var object:TouchContainer;
			
			//temporarily disable visible callback
			for (i = background is DisplayObject ? 1 : 0; i < numChildren; i++) {
				object = getChildAt(i) as TouchContainer;
				object.removeEventListener(StateEvent.CHANGE, visibilityCheck);
			}
			
			//clone collection
			var clone:Collection = super.clone();
			
			//re-enable visible callback
			for (i = background is DisplayObject ? 1 : 0; i < numChildren; i++) {
				object = getChildAt(i) as TouchContainer;
				object.addEventListener(StateEvent.CHANGE, visibilityCheck);
			}			
			
			return clone;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			displayed = null;
			queued = null;
			_displayBehavior = null;
		}
	}
}