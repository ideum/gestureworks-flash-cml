package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.layouts.ListLayout;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.greensock.easing.Expo;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * The Album element provides a list of display objects that can be 
	 * scrolled horizontally or vertically using a drag gesture. It 
	 * supports tweening and item snapping.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
		// horizontal album
		var h_album:AlbumElement = new AlbumElement();
		h_album.addChild(getImageElement("assets/wb3.jpg"));
		h_album.addChild(getImageElement("assets/USS_Macon_over_Manhattan.png"));
		h_album.addChild(getImageElement("assets/wb3.jpg"));
		h_album.init();

		// vertical album
		var v_album:AlbumElement = new AlbumElement();
		v_album.horizontal = false;			
		v_album.addChild(getImageElement("assets/wb3.jpg"));
		v_album.addChild(getImageElement("assets/USS_Macon_over_Manhattan.png"));						
		v_album.addChild(getImageElement("assets/wb3.jpg"));			
		v_album.init();
	
	// the supporting method getImageElement("src"), returns a Image display
	// object.
			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see TouchContainer
	 */
	public class Album extends TouchContainer
	{	
		private var _applyMask:Boolean = true;
		private var _horizontal:Boolean = true;
		private var _margin:Number = 1;
		private var _centerContent:Boolean = true;
		private var _dragAngle:Number = 0;
		private var _loop:Boolean = false;
		private var _loopQueue:Array;
		private var _belt:TouchContainer;
		private var _backgroundColor:uint = 0x000000;
		private var _backgroundAlpha:Number = 1;
		private var _snapping:Boolean = true;
		private var _snapOffset:Number = 0;
		
		private var _dimension:String;
		private var _axis:String;	
		private var _dragGesture:String = "n-drag-inertia";		
		private var _flickGesture:String;		
		private var snapPoints:Array;
		protected var albumMask:Graphic;
		private var snapTween:TweenLite;
		private var loopSnapTween:TimelineLite;
		private var boundary1:Number;
		private var boundary2:Number;
		private var released:Boolean = false;
		private var index:int = 0;
		private var frame:Rectangle;  //the dimensions of the largest object
		protected var snapIndex:Number = 0;
		private var initLoopOrder:Array;	
		private var _currentObject:*;
		private var loopClones:Dictionary = new Dictionary();
		private var tEnd:Boolean = false; //flag to differentiate between gwTouchEnd and gwTouchRollOut according to sequence	
				
		/**
		 * Constructor
		 */
		public function Album() 
		{
			mouseChildren = true;
			albumMask = new Graphic();
			albumMask.shape = "rectangle";	
			frame = new Rectangle(0, 0, 0, 0);  
			_belt = new TouchContainer();
			loopClones = new Dictionary();
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void
		{			
			if (loop && belt.numChildren < 2) loop = false;
			initBelt();
			checkMask();
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "isLoaded", true, true));	
			
			addEventListener(GWTouchEvent.TOUCH_BEGIN, inBounds);
			addEventListener(GWTouchEvent.TOUCH_END, outOfBounds);
			addEventListener(GWTouchEvent.TOUCH_ROLL_OVER, inBounds);	
			
			if(flickGesture){
				clusterBubbling = true;
				var gList:Object = new Object();
				gList[flickGesture] = true;
				gestureList = gList;
				addEventListener(GWGestureEvent.FLICK, flickSnap);
			}
			
			if (snapOffset) {
				if(loop)
					loopSnap(null, snapOffset);
				else
					belt[axis] = snapOffset;
			}
		}
		
		/**
		 * Flag indicating whether the contents are masked
		 * @default true
		 */
		public function get applyMask():Boolean { return _applyMask; }
		public function set applyMask(m:Boolean):void
		{
			_applyMask = m;
		}
		
		/**
		 * Flag indicating the scroll axis
		 * @default true
		 */
		public function get horizontal():Boolean { return _horizontal; }
		public function set horizontal(h:Boolean):void
		{
			_horizontal = h;
		}
		
		/**
		 * Sets the margin between the child display objects
		 * @default 1
		 */
		public function get margin():Number { return _margin; }
		public function set margin(m:Number):void
		{
			_margin = m;
		}
		
		/**
		 * The offset from the album's origin to snap the belt to.  
		 * @default 0
		 */
		public function get snapOffset():Number { return _snapOffset; }
		public function set snapOffset(s:Number):void {
			_snapOffset = s;
		}
		
		/**
		 * Flag indicating the album items should be centered horizontally and
		 * vertically
		 * @default true
		 */
		public function get centerContent():Boolean { return _centerContent; }
		public function set centerContent(c:Boolean):void
		{
			_centerContent = c;
		}
		
		/**
		 * Returns the space between two items based on the margin
		 */
		private function get space():Number { return 2 * margin;}
		
		/**
		 * Intended to account for the rotation of the parent object to apply to
		 * drag transformations. This value does NOT set the rotation of the
		 * AlbumElement. The rotation must be set through the rotation attribute(s).
		 */
		public function get dragAngle():Number { return _dragAngle; }
		public function set dragAngle(a:Number):void
		{
			_dragAngle = Math.PI * a / 180;
		}
		
		/**
		 * Specifies the GML drag gesture of the belt (e.g. n-drag, 2-finger-drag, etc.).
		 * @default n-drag-inertia
		 */
		public function get dragGesture():String { return _dragGesture; }
		public function set dragGesture(g:String):void
		{
			_dragGesture = g;
		}
		
		/**
		 * Specifies the GML flick gesture (e.g. n-flick, etc.) to execute next a previous calls based
		 * on flick direction.
		 * @default n-flick
		 */
		public function get flickGesture():String { return _flickGesture; }
		public function set flickGesture(g:String):void
		{
			_flickGesture = g;
		}		
		
		/**
		 * A flag instructing the album to continuously cycle through the objects opposed
		 * to stopping at the beginning or end. The album must have more than one child to
		 * set this flag.
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(l:Boolean):void
		{
			_loop = l;
			if (!_loopQueue) _loopQueue = new Array();
		}
		
		/**
		 * A flag indicating the snap animation of the objects into place
		 */
		public function get snapping():Boolean { return _snapping; }
		public function set snapping(e:Boolean):void
		{
			_snapping = e;
		}
		
		/**
		 * The queue storing the order of children in the loop from head to tail
		 */
		public function get loopQueue():Array { return _loopQueue; }
		
		/**
		 * The primary container and interactive object
		 */
		public function get belt():TouchContainer { return _belt; }
		
		/**
		 * Sets the width of the container and associated mask
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;	
			albumMask.width = value;
		}
		
		/**
		 * Sets the height of the container and associated mask
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			albumMask.height = value;
		}		
		
		/**
		 * The color of the album's background
		 */
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(c:uint):void
		{
			_backgroundColor = c;
		}
		
		/**
		 * The alpha of the ablum's background
		 */
		public function get backgroundAlpha():Number { return _backgroundAlpha; }
		public function set backgroundAlpha(a:Number):void 
		{
			_backgroundAlpha = a;
		}
		
		/**
		 * The album element is intended for a ListLayout only. The layout axis can be
		 * set by the "horizontal" attribute and the spacing can be adjusted through the
		 * "margin" attribute. 
		 */
		override public function set layout(value:*):void {}
		
		/**
		 * The album element is intended for a ListLayout only. The layout axis can be
		 * set by the "horizontal" attribute and the spacing can be adjusted through the
		 * "margin" attribute. 
		 */
		override public function applyLayout(value:Layout = null):void { }
		
		/**
		 * Synchronize the drag angle with the album's rotation
		 */
		override public function set rotation(value:Number):void 
		{
			dragAngle = value;
			super.rotation = value;
		}

		/**
		 * Synchronize the drag angle with the album's rotation
		 */		
		override public function set rotationX(value:Number):void 
		{
			dragAngle = value;
			super.rotationX = value;
		}
		
		/**
		 * Synchronize the drag angle with the album's rotation
		 */		
		override public function set rotationY(value:Number):void 
		{
			dragAngle = value;
			super.rotationY = value;
		}
		
		/**
		 * Returns the current object
		 */
		public function get currentObject():*{
			return _currentObject;
		}
		
		/**
		 * Returns the index of the current snap point
		 */
		public function get currentIndex():Number {
			return snapIndex;
		}
		
		/**
		 * Returns the object at the current stap point
		 * @param	point
		 * @return
		 */
		public function objectAtSnapPoint(point:int):*
		{
			return belt.getChildAt(point+1);  //add one to exclude background
		}
		
		/**
		 * Returns the "width" if horizontal and "height" if vertical
		 */
		private function get dimension():String
		{
			return horizontal ? "width" : "height";
		}
		
		/**
		 * Returns the "x" if horizontal and "y" if vertical
		 */		
		private function get axis():String
		{
			return horizontal ? "x" : "y";
		}
		
		/**
		 * Removes belt children and resets initial album states
		 */
		public function clear():void
		{
			while (belt.numChildren > 0) {
				if(loop){
					while(DisplayObjectContainer(belt.getChildAt(0)).numChildren > 0){
						DisplayObjectContainer(belt.getChildAt(0)).removeChildAt(0);
					}
				}
				belt.removeChildAt(0);
			}
			
			if (loop)
				_loopQueue = new Array();
			else
			{
				belt.x = 0;
				belt.y = 0;
			}
			frame.width = 0;
			frame.height = 0;
			snapIndex = 0;
			index = 0;
						
			belt.removeEventListener(GWGestureEvent.DRAG, scrollH);
			belt.removeEventListener(GWGestureEvent.DRAG, scrollV);
			belt.removeEventListener(GWGestureEvent.FLICK, flickSnap);
			belt.removeEventListener(GWGestureEvent.RELEASE, onRelease);
			belt.removeEventListener(GWGestureEvent.COMPLETE, snap);
			belt.removeEventListener(GWGestureEvent.COMPLETE, loopSnap);
			belt.removeEventListener(GWTouchEvent.TOUCH_BEGIN, resetDrag);			
		}
			
		/**
		 * Initializes the the belt container which is the nested container of the album that handles
		 * the scrolling of the child objects. 
		 */
		private function initBelt():void
		{		
			//initial dimensions
			belt.height = height;
			belt.width = width;

			belt.gestureReleaseInertia = true;
			belt.nativeTransform = false;
			belt.affineTransform = false;
			belt.clusterBubbling = clusterBubbling;
			
			var gList:Object = new Object();
			gList[dragGesture] = true;
			belt.gestureList = gList;
			
			//add gesture events
			var scrollType:Function = horizontal ? scrollH : scrollV;
			belt.addEventListener(GWGestureEvent.DRAG, scrollType);
			belt.addEventListener(GWGestureEvent.RELEASE, onRelease);				
			belt.addEventListener(GWTouchEvent.TOUCH_BEGIN, resetDrag);
			
			if (snapping)
			{
				var snapType:Function = loop ? loopSnap : snap;				
				belt.addEventListener(GWGestureEvent.COMPLETE, snapType);
			}
						
			//configure belt		
			setBeltLayout();
			setBeltDimensions();
			setBeltBackground();
			storeSnapPoints();
			setBoundaries();
			addUIComponent(belt);
			_currentObject = belt.numChildren > 1 ? belt.getChildAt(1): null;
		}
		
		/**
		 * Reroutes the addition of children from the album to the album's belt and sets the dimesions of the container 
		 * based on the greatest width and height of the child dimensions. If clusterBubbling is enabled, the children 
		 * are wrapped in a TouchSprite to enable interactivity.
		 */		
		override public function addChild(child:DisplayObject):DisplayObject 
		{		
			width = child.width > width ? child.width : width;
			height = child.height > height ? child.height: height;			
			frame.width = child.width > frame.width ? child.width: frame.width;
			frame.height = child.height > frame.height ? child.height : frame.height;

			childList.removeByValue(child);
			return belt.addChild(child);											
		}
		
		/**
		 * Reroutes the addition of children from the album to the album's belt and sets the dimesions of the container 
		 * based on the greatest width and height of the child dimensions. If clusterBubbling is enabled, the children 
		 * are wrapped in a TouchSprite to enable interactivity.
		 */		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{	
			index = index == 0 ? 1 : index;
			width = child.width > width ? child.width : width;
			height = child.height > height ? child.height: height;
			frame.width = child.width > frame.width ? child.width: frame.width;
			frame.height = child.height > frame.height ? child.height : frame.height;			

			childList.removeByValue(child);
			return belt.addChildAt(child, index);
		}
		
		/**
		 * Adds a child directly to the album object
		 * @param	child
		 */
		protected function addUIComponent(child:DisplayObject):void
		{
			super.addChild(child);
		}
		
		/**
		 * Stores the additive inverse of the x or y coordinates of each frame on the belt based on the horizontal
		 * flag. These points will drive the snap tweeining. 
		 */
		private function storeSnapPoints():void
		{
			snapPoints = new Array;	
			var offset:int = snapOffset ? snapOffset : 0;			
			var limit:Number = belt[dimension] - this[dimension] < offset ? offset : belt[dimension] - this[dimension];
			
			if (centerContent)
			{
				for (var i:int = offset; i <= limit; i = i + frame[dimension] + space)
				{
					if (i == offset)
						snapPoints.push(offset);
					else
						snapPoints.push( -i);
				}
			}
			else
			{
				for (i = 1; i < belt.numChildren; i++)
				{
					//TODO: incorporate offset into limit
					//if (belt.getChildAt(i)[axis] > limit)
					//{
						//snapPoints.push(-limit);
						//break;
					//}					
					snapPoints.push(offset-belt.getChildAt(i)[axis]);					
				}
			}			
		}
		
		/**
		 * Set the drag boundaries for the belt container based on the horiztonal state
		 * and album dimensions.
		 */
		private function setBoundaries():void
		{
			var half:Number = snapOffset ? (frame[dimension] / 2) + snapOffset : (frame[dimension] / 2);
			if (loop)
			{
				boundary1 = 0;				
				boundary2 = this[dimension];
			}
			else 
			{			
				boundary1 = half;
				boundary2 = this[dimension] < belt[dimension] ? -(belt[dimension] - (this[dimension] - half)) : -half;
			}
		}
		
		/**
		 * Generate a horiztonal/vertical list layout and apply it to the belt 
		 */
		private function setBeltLayout():void
		{
			belt.layout = new ListLayout();
			belt.layout.useMargins = true;
			belt.layout.marginX = margin;
			belt.layout.marginY = margin;
			belt.layout.type = horizontal ? "horizontal" : "vertical";	
			belt.layout.centerColumn = centerContent;			
			belt.layout.centerRow = centerContent;	
			belt.layout.continuousTransform = false; 
			applyLoopLayout();
			belt.applyLayout();			
		}
		
		/**
		 * Since album items are constantly being repositioned in loop mode, maintainging the layout requires more distribution management. 
		 * This function adds the items to a queue and sets their visibility. If centerContent is enabled, a new background object is generated 
		 * for each item to be centered on. The background provide a uniform reference to better evaluate boundary thresholds and tweening snap points. 
		 */
		private function applyLoopLayout():void
		{
			if (!loop) return;
			
			if (centerContent)
			{
				var holder:Array = new Array();
				while (belt.numChildren)
				{
					holder.unshift(belt.getChildAt(belt.numChildren - 1));
					belt.removeChildAt(belt.numChildren - 1);
				}
				
				for each(var obj:DisplayObject in holder)
				{
					var slide:Graphic = new Graphic();
					slide.shape = "rectangle";
					slide.fillAlpha = backgroundAlpha;					
					slide.color = backgroundColor;
					slide.lineStroke = 0;
					slide.width = frame.width;
					slide.height = frame.height;
					
					obj.x = slide.width / 2 - obj.width / 2;
					obj.y = slide.height / 2 - obj.height / 2;
					slide.addChild(obj);
					belt.addChild(slide);
				}
			}			
			
			for (var i:int = 0; i < belt.numChildren; i++)
			{
				var child:DisplayObject = belt.getChildAt(i);
				child.visible = child[axis] > this[dimension] ? false : true;
				loopQueue.push(child);
			}
			if (loopQueue) {
				initLoopOrder = new Array();
				initLoopOrder = initLoopOrder.concat(loopQueue);
			}
		}
		
		/**
		 * Sets the dimensions of the belt based on the last child's location and dimensions
		 */
		private function setBeltDimensions():void
		{
			if (!belt.numChildren) return;
			var last:* = belt.getChildAt(belt.numChildren - 1);
			var edge:Number = centerContent ? (last[axis] + last[dimension] / 2) + frame[dimension] / 2 : last[axis] + last[dimension];
			belt.width = horizontal ? edge : belt.width;
			belt.height = horizontal ? belt.height : edge;
		}
		
		/**
		 * Generates a background for the belt with the belt's dimensions and applies it to the belt
		 */
		private function setBeltBackground():void
		{		
			var g:Graphic = new Graphic();
			g.shape = "rectangle";
			g.width = belt.width;
			g.height = belt.height;
			g.color = backgroundColor;
			g.fillAlpha = backgroundAlpha;
			g.lineStroke = 0;
			
			var background:TouchSprite = new TouchSprite();
			background.addChild(g);
			background.width = g.width;
			background.height = g.height;
			background.targetParent = true;
			
			belt.addChildAt(background, 0);			
		}
		
		/**
		 * Apply the mask
		 */
		private function checkMask():void
		{			
			if (applyMask)
			{
				addUIComponent(albumMask);
				mask = albumMask;
			}
		}
		
		/**
		 * Dispatch a state event container the albums current state
		 */
		private function publishState():void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "albumState", this, true));
		}
		
		/**
		 * Intended to synchronize this album with another's state when album linking through the AlbumViewer.
		 * @param	album  the album to synch to
		 */
		public function updateState(album:Album):void
		{
			var belt2:TouchContainer = album.belt;
			var loopQueue2:Array = album.loopQueue;
			
			if (loop)
			{
				for (var i:int = 1; i < belt.numChildren; i++)  //skip the background
				{	
					belt.getChildAt(i)[axis] = belt2.getChildAt(i)[axis];					
					belt.getChildAt(i).visible = belt2.getChildAt(i).visible;					
					loopQueue[loopQueue2.indexOf(belt2.getChildAt(i))] = belt.getChildAt(i);					
				}
			}
			else
				belt[axis] = belt2[axis];
		}
		
		/**
		 * Animates a snapping action to the point provided or the closest snap point to the current belt location. 
		 * @param  e  the drag complete event
		 * @param  point  the point to snap to
		 * @param  tween  enable/disable tween
		 */
		private function snap(e:*=null, point:Number=NaN, tween:Boolean=true):void
		{				
			if (isNaN(point))
				point = horizontal ? getClosestSnapPoint(belt.x) : getClosestSnapPoint(belt.y);					
				
			if(tween){
				if (snapTween && snapTween._active)
					return;		
				
				snapIndex = snapPoints.indexOf(point);
				var destination:Object = { ease:Expo.easeOut, onUpdate:publishState, onComplete:dispatchCurrentObject };//horizontal ? { x:point } : { y:point };			
				if (horizontal)
					destination["x"] = point;
				else
					destination["y"] = point;
				
				snapTween = TweenLite.to(belt, .4, destination);
				snapTween.play();
			}
			else {
				belt.x = point;
			}
		}		
		
		/**
		 * Determines which child is closest to the album origin and moves each child the direction and distance
		 * necessary to align the closest child with the origin
		 * @param	e  the drag complete event
		 * @param   distance  the distance to move the belt
		 * @param   tween   enable/disable tween
		 */
		private function loopSnap(e:*= null, distance:Number=0, tween:Boolean = true):void
		{
			if (tween && loopSnapTween && loopSnapTween._active) return;			
			var childTweens:Array = new Array();
			var minDiff:Number = Number.MAX_VALUE;
			
			//get direction and distance to origin by inverting 
			//the axis coordinate of the closest child
			if (!distance)
			{
				for each(var child:* in loopQueue)
				{
					if (!child.visible) continue;
					
					if (Math.abs(child[axis] - snapOffset) < minDiff)
					{
						minDiff = Math.abs(child[axis] - snapOffset);
						distance = -(child[axis] - snapOffset);
						snapIndex = initLoopOrder.indexOf(child);
					}				
				}
			}

			//generate a tween for each child
			if(tween){
				for each(child in loopQueue)
				{
					var destination:Object = horizontal ? { x:child.x + distance, ease:Expo.easeOut } : { y:child.y + distance, ease:Expo.easeOut };				
					childTweens.push(TweenLite.to(child, .4, destination));
				}
								
				loopSnapTween = new TimelineLite( { onComplete:loopSnapComplete, onUpdate:publishState } );
				loopSnapTween.appendMultiple(childTweens);
				loopSnapTween.play();					
			}
			else {
				for each(child in loopQueue) 
				{
					child[axis] += distance;
					processLoop();
				}
				dispatchCurrentObject();
			}
		}
		
		/**
		 * Dispatch an event on snap complete with the object at the current snap point
		 */
		protected function dispatchCurrentObject():void
		{
			_currentObject = objectAtSnapPoint(snapIndex);
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "complete", _currentObject, true));
		}		
		
		/**
		 * Determines the snap point closest to the current belt location
		 * @param	n  the belt location
		 * @return  the closest snap point
		 */
		private function getClosestSnapPoint(n:Number):Number
		{
			var minDiff:Number = Number.MAX_VALUE;
			var diff:Number;
			var point:Number;
			
			if (n > 0)
				point = snapPoints[0];
			else if (n < snapPoints[snapPoints.length - 1])
				point = snapPoints[snapPoints.length - 1];
			else
			{
				for each(var p:Number in snapPoints)
				{
					diff = Math.abs(n - p);
					if (diff < minDiff)
					{
						minDiff = diff;
						point = p;
					}
				}
			}	
						
			index = snapPoints.indexOf(point);
			return point;
		}
		
		/**
		 * Snap to the next item on the belt
		 * @param tween  tween to next item
		 */
		public function next(tween:Boolean = true):void
		{
			if (loop)
			{
				if (loopSnapTween && loopSnapTween._active) return;
				loopQueue[0][axis] = -1;
				processLoop();
				loopSnap(null, -(this[dimension] + snapOffset + space - 1), tween);	
				snapIndex = snapIndex == loopQueue.length - 1 ? 0 : snapIndex + 1; 
			}
			else
			{
				if (index < snapPoints.length - 1) 
					index++;			
				snap(null, snapPoints[index], tween);
			}
		}
		
		/**
		 * Snap to the previous item on the belt
		 * @param tween  tween to previous item
		 */
		public function previous(tween:Boolean = true):void
		{			
			if (loop)
			{		
				if (loopSnapTween && loopSnapTween._active) return;
				loopQueue[0][axis] = 1;
				processLoop();
				loopSnap(null, this[dimension] + snapOffset + space - 1, tween)
				snapIndex = snapIndex == 0 ? loopQueue.length - 1 : snapIndex - 1; 
			}
			else
			{
				if (index > 0)
					index--;
				snap(null, snapPoints[index], tween);
			}
		}
		
		/**
		 * Snap to a specific child index
		 * @param  num  child index
		 * @param  enable/disable tween on snap
		 */
		public function snapTo(num:Number, tween:Boolean=true):void {
			if (loop && num >=0 && num < initLoopOrder.length) {
				//var searchObj:* = initLoopOrder[num];
				//var qIndex:int = loopQueue.indexOf(searchObj);
				//var s1:Array = loopQueue.slice(0,qIndex);
				//var s2:Array = loopQueue.slice(qIndex);
				//_loopQueue = s2.concat(s1);
				
				//TODO: update to work with loop tween by triggering next/previous when prior tween has completed
				var cnt:Number = Math.abs(num - snapIndex);
				var nxt:Boolean = num > snapIndex;
				for (var i:int = 0; i < cnt; i++){
					if (nxt) {
						next(false);
					}
					else {
						previous(false);
					}
				}
			}
			else if(!loop && num >=0 && num < snapPoints.length) {
				snap(null, snapPoints[num], tween);
			}
		}

		/**
		 * Reset to initial state
		 */
		public function reset():void {
			snapTo(0);
		}
				
		/**
		 * Disables the drag if the touch moves outside of the album
		 * @param	e
		 */
		protected function outOfBounds(e:*):void
		{
			if (e.type == "gwTouchEnd")
				tEnd = true;
			if (!tEnd && e.type == "gwTouchRollOut")	{		
				removeEventListener(GWTouchEvent.TOUCH_ROLL_OUT, outOfBounds);
				var scrollType:Function = horizontal ? scrollH : scrollV;
				belt.removeEventListener(GWGestureEvent.DRAG, scrollType);				
			}	
		}
		
		/**
		 * Enables the drag if the touch is inside or moves inside the album
		 * @param	e
		 */
		protected function inBounds(e:*):void
		{
			var scrollType:Function = horizontal ? scrollH : scrollV;
			belt.addEventListener(GWGestureEvent.DRAG, scrollType);			
			addEventListener(GWTouchEvent.TOUCH_ROLL_OUT, outOfBounds);
			tEnd = false;
		}
		
		/**
		 * Reactivates the drag handler, enables release inertia, and resets the released
		 * flag to indicate the belt is being touched. 
		 * @param	e  the touch event
		 */
		private function resetDrag(e:*):void
		{
			enableDrag();
			released = false;
		}
		
		/**
		 * Turns the released flag on to indicate the belt is not being touched
		 * @param	e the release event
		 */
		protected function onRelease(e:GWGestureEvent):void
		{
			released = true;
			if (!snapping && (belt[axis] > snapPoints[0] || belt[axis] < snapPoints[snapPoints.length-1]))
				snap();
		}	
		
		/**
		 * Snap to next or previous depending on flick direction
		 * @param	e
		 */
		protected function flickSnap(e:GWGestureEvent):void {
			var val:Number = horizontal ? e.value.flick_dx : e.value.flick_dy;
			if (val < 0) {
				next();
			}
			else {
				previous();
			}
		}
		
		/**
		 * Drag the belt horizontally within the boundaries. If boundaries are exceeded and the
		 * belt is not being touched, the drag is disabled and the belt snaps into place.
		 * @param	e the drag event
		 */
		protected function scrollH(e:GWGestureEvent):void
		{	
			var COS:Number = Math.cos(dragAngle);
			var SIN:Number = Math.sin(dragAngle);
			var dx:Number = e.value.drag_dy * SIN + e.value.drag_dx * COS;			
			
			if (loop)
				processLoop(dx);				
			else if (belt.x + dx < boundary1 && belt.x + dx > boundary2)	
				belt.x += dx;				
			else if(released)
			{
				enableDrag(false);
				snap();
			}
			
			publishState();
		}
				
		/**
		 * Drag the belt vertically within the boundaries. If boundaries are exceeded and the
		 * belt is not being touched, the drag is disabled and the belt snaps into place.
		 * @param	e the drag event
		 */
		protected function scrollV(e:GWGestureEvent):void
		{
			var COS:Number = Math.cos(dragAngle);
			var SIN:Number = Math.sin(dragAngle);
			var dy:Number = e.value.drag_dy * COS - e.value.drag_dx * SIN;			
			
			if (loop)
				processLoop(dy);
			else if (belt.y+dy < boundary1 && belt.y+dy > boundary2)
				belt.y += dy;
			else if(released)
			{
				enableDrag(false);
				snap();				
			}
			
			publishState();
		}
		
		/**
		 * Enables/disables drag gesture
		 * @param	enable true to enable false otherwise
		 */
		protected function enableDrag(enable:Boolean=true):void
		{
			var gList:Object = belt.gestureList;
			
			if(enable){
				gList[dragGesture] = true;
			}
			else{
				gList[dragGesture] = false;
				belt.gestureList = gList;
			}
		}
		
		/**
		 * Drags the belt children instead of the belt to allow the repositioning of individual children when they exceed the defined 
		 * boundaries.   
		 * @param	delta the drag delta
		 */
		private function processLoop(delta:Number=NaN):void
		{			
			for each(var child:* in loopQueue)
			{
				if (!isNaN(delta) && child.visible)
					child[axis] += delta;
				if (child[axis] > boundary2)
					child.visible = false;
			}
			
			var head:* = loopQueue[0];
			var edge1:Number = head[axis];
			var edge2:Number = head[axis] + head[dimension];
			var edge3:Number = edge1 + this[dimension];
			
			if (edge1 < boundary1)
				queueNext();			
			if (edge2 < boundary1)
				headToTail();
			if (edge3 > boundary2)
				tailToHead();			
		}
		
		/**
		 * Updates current object 
		 */
		private function loopSnapComplete():void
		{
			processLoop();
			dispatchCurrentObject();
		}
	
		/**
		 * Repositions the child at the tail of the list to the head and reorders the child's place in the queue to 
		 * reflect its new position in the belt.
		 */
		private function tailToHead():void
		{		
			if (loopSnapTween && loopSnapTween._active) return;	
			
			var tail:* = loopQueue[loopQueue.length - 1];
			tail.visible = true;
			tail[axis] = loopQueue[0][axis] - tail[dimension] - space;
			
			loopQueue.pop();
			loopQueue.unshift(tail);
		}
		
		/**
		 * Repositions the child at the head of the list to the tail and reorders the child's place in the queue to 
		 * reflect its new position in the belt.
		 */
		private function headToTail():void
		{			
			if (loopSnapTween && loopSnapTween._active) return;								
			
			var head:* = loopQueue[0];
			head.visible = false;
			head[axis] = 0;
			
			loopQueue.shift();
			loopQueue.push(head);
		}
		
		/**
		 * Determines the next child in the queue, enables its visiblity, and appends it to the end of
		 * the album. 
		 */
		private function queueNext():void
		{			
			for (var i:int = 0; i < loopQueue.length; i++)
			{
				//var head:* = loopQueue[0];
				//var tail:* = loopQueue[loopQueue.length - 1];				
				//if (head.visible){
					//var clone:* = head.clone();
					//loopClones[head] = clone;
					//clone[axis] = tail[axis] + tail[dimension] + space;
					//loopQueue.push(clone);
				//}
				if (!loopQueue[i].visible)
				{					
					loopQueue[i].visible = true;
					loopQueue[i][axis] = loopQueue[i - 1][axis] + loopQueue[i-1][dimension] + space;
					
					return;
				}
				else if (loopQueue[i][axis] > boundary2)
					return;
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();							
			_belt = null;
			_loopQueue = null;
			snapPoints = null;
			albumMask = null;
			snapTween = null;
			loopSnapTween = null;
			frame = null;
			initLoopOrder = null;
			_currentObject = null;
			loopClones = null;
		}		
		
		override public function clone():* {
			
			//exclude mask
			cloneExclusions.push("mask");						
			cloneExclusions.push("childList");	
			belt.cloneExclusions.push("childList");
			
			//bypass ui child clones since they are auto-generated at initialization
			this.removeChildren(); 
			
			//clone album
			var clone:Album = CloneUtils.clone(this, this.parent, cloneExclusions) as Album;  
			//clone belt
			belt.cloneExclusions.push("childList");
			var beltClone:TouchContainer = CloneUtils.clone(belt, null, belt.cloneExclusions); 
			
			//re-add ui elements to source
			addUIComponent(belt);			
			addUIComponent(albumMask);
			
			//add album items
			while(beltClone.numChildren > 1){
				clone.addChild(beltClone.getChildAt(1));
			}
			
			//initialize clone
			clone.addUIComponent(clone.belt);
			clone.addUIComponent(clone.albumMask);
			
			return clone;
		}
				
	}

}