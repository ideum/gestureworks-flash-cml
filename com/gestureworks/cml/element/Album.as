package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.layouts.ListLayout;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.events.TouchEvent;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Exponential;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	
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
	 * @author Shaun
	 * @see TouchContainer
	 */
	public class Album extends TouchContainer
	{	
		private var _applyMask:Boolean = true;
		private var _horizontal:Boolean = true;
		private var _margin:Number = 1;
		private var _dragAngle:Number = 0;
		private var _loop:Boolean = false;
		private var _loopQueue:Array;
		private var _belt:TouchContainer;
		private var _backgroundColor:uint = 0x000000;
		
		private var _dimension:String;
		private var _axis:String;		
		
		private var snapPoints:Array;
		private var albumMask:Graphic;
		private var snapTween:ITween;
		private var loopSnapTween:ITweenGroup;
		private var boundary1:Number;
		private var boundary2:Number;
		private var isLoaded:Boolean = false;		
		private var released:Boolean = false;
		private var index:int = 0;
		
		/**
		 * Constructor
		 */
		public function Album() 
		{
			mouseChildren = true;
			albumMask = new Graphic();
			albumMask.shape = "rectangle";
		}
				
		/**
		 * CML initialization
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
			if (loop && numChildren < 2) loop = false;
			sizeAlbumToContent();
			initBelt();
			checkMask();
			isLoaded = true;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isLoaded", isLoaded, true));	
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
			if (albumMask) albumMask.width = value;
		}
		
		/**
		 * Sets the height of the container and associated mask
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (albumMask) albumMask.height = value;
		}
		
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(c:uint):void
		{
			_backgroundColor = c;
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
		override public function applyLayout(value:* = null):void { }
		
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
		 * Initializes the the belt container which is the nested container of the album that handles
		 * the scrolling of the child objects. All children are transferred from the album container
		 * to the belt. 
		 */
		private function initBelt():void
		{
			_belt = new TouchContainer();
			belt.gestureReleaseInertia = true;
			belt.disableNativeTransform = true;
			belt.gestureList = { "n-drag-inertia":true };
			belt.disableAffineTransform = true;
			
			//add gesture events
			var scrollType:Function = horizontal ? scrollH : scrollV;
			var snapType:Function = loop ? loopSnap : snap;
			belt.addEventListener(GWGestureEvent.DRAG, scrollType);
			belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
			belt.addEventListener(GWGestureEvent.COMPLETE, snapType);
			belt.addEventListener(TouchEvent.TOUCH_BEGIN, resetDrag);
						
			//transfer children to belt
			for (var i:int = numChildren - 1; i >= 0; i--)	
			{
				if (loop) _loopQueue.push(getChildAt(i));
				belt.addChild(getChildAt(i));					
			}
			
			addChild(belt);
			
			setBeltLayout();
			setBeltDimensions();
			setBeltBackground();
			storeSnapPoints();
			setBoundaries();
		}
		
		/**
		 * Generates a default list layout when one is not provided
		 * @return  horizontal list layout
		 */
		private function defaultLayout():ListLayout
		{
			var lLayout:ListLayout = new ListLayout();
			lLayout.useMargins = true;
			lLayout.marginX = 1;
			return lLayout;
		}
		
		/**
		 * Sets the dimesions of the container based on the greatest width and height of
		 * the child dimensions.
		 */
		private function sizeAlbumToContent():void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				width = width < child.width ? child.width : width;								
				height = height < child.height ? child.height : height;				
			}
		}
		
		/**
		 * Stores the additive inverse of the x or y coordinates of each frame on the belt based on the horizontal
		 * flag. These points will drive the snap tweeining. 
		 */
		private function storeSnapPoints():void
		{
			snapPoints = new Array;			
			for (var i:int = 0; i < belt[dimension]; i = i + this[dimension] + 2*margin)
				snapPoints.push( -i);
		}
		
		/**
		 * Set the drag boundaries for the belt container based on the horiztonal state
		 * and album dimensions.
		 */
		private function setBoundaries():void
		{
			var frame:Number = horizontal ? width: height;				
			if (loop)
			{
				boundary1 = 0;				
				boundary2 = belt[dimension];
			}
			else if (snapPoints.length > 0)
			{			
				boundary1 = snapPoints[0] + frame / 2;
				boundary2 = snapPoints[snapPoints.length - 1] - frame / 2;
			}
		}
		
		/**
		 * Generates a horiztonal/vertical list layout and applies it to the belt
		 */
		private function setBeltLayout():void
		{
			belt.layout = new ListLayout();
			belt.layout.useMargins = true;
		    belt.layout.marginX = margin;
			belt.layout.marginY = margin;
			belt.layout.type = horizontal ? "horizontal" : "vertical";
			belt.layout.centerColumn = true;			
			belt.layout.centerRow = true;			
			belt.applyLayout();				
		}
		
		/**
		 * Sets the dimensions of the belt based on the children dimensions
		 */
		private function setBeltDimensions():void
		{
			for (var i:int = 0; i < belt.numChildren; i++ )
			{
				var child:* = belt.getChildAt(i);
				if (horizontal)
				{
					belt.width = child.x + child.width;  //last child in the list
					belt.height = child.height > belt.height ? child.height : belt.height;  //greatest height
				}
				else
				{
					belt.width = child.width > belt.width ? child.width : belt.width;  //last child in the list
					belt.height = child.y + child.height; //greatest width
				}				
			}			
		}
		
		/**
		 * Generates a background for the belt with the belt's dimensions and applies it to the belt
		 */
		private function setBeltBackground():void
		{
			var background:Graphic = new Graphic();
			background.shape = "rectangle";
			background.width = belt.width;
			background.height = belt.height;
			background.color = backgroundColor;
			background.lineStroke = 0;
			belt.addChildAt(background, 0);			
		}
		
		/**
		 * Apply the mask
		 */
		private function checkMask():void
		{
			if (applyMask)
			{
				addChild(albumMask);
				mask = albumMask;
			}
		}
		
		/**
		 * Dispatch a state event container the albums current state
		 */
		private function publishState():void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "albumState", this, true));
		}
		
		/**
		 * Intended to synchronize this album with another's state during album linking through the AlbumViewer.
		 * @param	album  the album to synch to
		 */
		public function updateState(album:Album):void
		{
			var belt2:TouchContainer = album.belt;
			var loopQueue2:Array = album.loopQueue;
			
			if (loop)
			{
				for (var i:int = 0; i < belt.numChildren; i++)
				{					
					belt.getChildAt(i)[axis] = belt2.getChildAt(i)[axis];
					loopQueue[loopQueue2.indexOf(belt2.getChildAt(i))] = belt.getChildAt(i);					
				}
			}
			else
				belt[axis] = belt2[axis];
		}
		
		/**
		 * Animates a snaping action to the point provided or the closest snap point to the current belt location. 
		 * @param  e  the drag complete event
		 * @param  point  the point to snap to
		 */
		private function snap(e:*=null, point:Number=NaN):void
		{	
			if (snapTween && snapTween.isPlaying)
				return;
					
			if (isNaN(point))
				point = horizontal ? getClosestSnapPoint(belt.x) : getClosestSnapPoint(belt.y);
				
			var destination:Object = horizontal ? { x:point } : { y:point };			
			snapTween = BetweenAS3.tween(belt, destination, null, .4, Exponential.easeOut);
			snapTween.onUpdate = publishState;
			snapTween.play();
		}
		
		/**
		 * Determines which child is closest to the album origin and moves each child the direction and distance
		 * necessary to align the closest child with the origin
		 * @param	e  the drag complete event
		 * @param   distance  the distance to move the belt
		 */
		private function loopSnap(e:*= null, distance:Number=0):void
		{
			if (loopSnapTween && loopSnapTween.isPlaying) return;			
			var childTweens:Array = new Array();
			var minDiff:Number = Number.MAX_VALUE;
			
			//get direction and distance to X origin by inverting 
			//the x coordinate of the closest child
			if (!distance)
			{
				for each(var child:* in _loopQueue)
				{
					if (Math.abs(child[axis]) < minDiff)
					{
						minDiff = Math.abs(child[axis]);
						distance = -child[axis];
					}				
				}
			}
						
			//generate a tween for each child
			for each(child in _loopQueue)
			{
				var destination:Object = horizontal ? { x:child.x + distance } : { y:child.y + distance };				
				childTweens.push(BetweenAS3.tween(child, destination, null, .4, Exponential.easeOut));
			}
							
			loopSnapTween = BetweenAS3.parallel.apply(null, childTweens);
			loopSnapTween.onComplete = processLoop;
			loopSnapTween.onUpdate = publishState;
			loopSnapTween.play();
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
		 * Snap to the next point on the belt
		 */
		public function next():void
		{
			if (loop)
			{
				var distance:Number = horizontal ? -(width+2*margin) : -(height+2*margin);
				loopSnap(null, distance);
			}
			else
			{
				if (index < snapPoints.length - 1) 
					index++;			
				snap(null, snapPoints[index]);
			}
		}
		
		/**
		 * Snap to the previous point on the belt
		 */
		public function previous():void
		{			
			if (loop)
			{		
				moveToHead(_loopQueue[_loopQueue.length - 1]);
				loopSnap(null, _loopQueue[_loopQueue.length - 1][dimension]+(2*margin))
			}
			else
			{
				if (index > 0)
					index--;
				snap(null, snapPoints[index]);
			}
		}		
		
		/**
		 * Reactivates the drag handler, enables release inertia, and resets the released
		 * flag to indicate the belt is being touched. 
		 * @param	e  the touch event
		 */
		private function resetDrag(e:TouchEvent):void
		{
			var scrollType:Function = horizontal ? scrollH : scrollV;
			belt.addEventListener(GWGestureEvent.DRAG, scrollType);	
			belt.gestureReleaseInertia = true;
			released = false;
		}
		
		/**
		 * Turns the released flag on to indicate the belt is not being touched
		 * @param	e the release event
		 */
		private function onRelease(e:GWGestureEvent):void
		{
			released = true;
		}		
		
		/**
		 * Drag the belt horizontally within the boundaries. If boundaries are exceeded and the
		 * belt is not being touched, the drag is disabled and the snaps into place.
		 * @param	e the drag event
		 */
		private function scrollH(e:GWGestureEvent):void
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
				belt.removeEventListener(GWGestureEvent.DRAG, scrollH);
				belt.gestureReleaseInertia = false;
				snap();				
			}
			
			publishState();
		}
				
		/**
		 * Drag the belt vertically within the boundaries
		 * @param	e the drag event
		 */
		private function scrollV(e:GWGestureEvent):void
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
				belt.removeEventListener(GWGestureEvent.DRAG, scrollV);
				belt.gestureReleaseInertia = false;
				snap();				
			}
			
			publishState();
		}
		
		/**
		 * Drags the belt children instead of the belt to allow the repositioning of individual children when they exceed the designated 
		 * boundaries. If a child crosses boundary 1 it is placed at boundary 2 and vice versa. 
		 * @param	dx  the horizontal drag delta
		 */
		private function processLoop(delta:Number=NaN):void
		{			
			for each(var child:* in _loopQueue)
			{
				if(!isNaN(delta))
					child[axis] += delta;
				
				//move to boundary1 if exceeds boundary 2
				if (child[axis] + child[dimension]> boundary2)
					moveToHead(child);
				//move to boundary2 if exceeds boundary1
				if (child[axis] + child[dimension] < boundary1)
					moveToTail(child);
			}
		}
		
		/**
		 * Repositions the child to the head (horizontal:left/vertical:top) of the belt and reorders the child's place in 
		 * the queue to reflect its new position in the belt.
		 * @param	child
		 */
		private function moveToHead(child:*):void
		{		
			if (loopSnapTween && loopSnapTween.isPlaying) return;			
			child[axis] = _loopQueue[0][axis] - child[dimension] - (2 * margin);
			_loopQueue.pop();
			_loopQueue.unshift(child);
		}
		
		/**
		 * Repositions the child to the tail (horizontal:right/vertical:bottom) of the belt and reorders the child's place in 
		 * the queue to reflect its new position in the belt.
		 * @param	child
		 */		
		private function moveToTail(child:*):void
		{			
			if (loopSnapTween && loopSnapTween.isPlaying) return;			
			child[axis] = _loopQueue[_loopQueue.length - 1][axis] + _loopQueue[_loopQueue.length - 1][dimension] + (2 * margin);
			_loopQueue.shift();
			_loopQueue.push(child);
		}

		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			
			belt.removeEventListener(GWGestureEvent.DRAG, scrollH);
			belt.removeEventListener(GWGestureEvent.DRAG, scrollV);
			belt.removeEventListener(GWGestureEvent.RELEASE, onRelease);
			belt.removeEventListener(GWGestureEvent.COMPLETE, snap);
			belt.removeEventListener(GWGestureEvent.COMPLETE, loopSnap);
			belt.removeEventListener(TouchEvent.TOUCH_BEGIN, resetDrag);			
			
			_belt = null;
			_loopQueue = null;
			snapPoints = null;
			albumMask = null;
			snapTween = null;
			loopSnapTween = null;
		}
				
	}

}