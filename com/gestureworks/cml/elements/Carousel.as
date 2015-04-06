package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.utils.ChildList;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * The Carousel element provides a circular list of display objects that can
	 * be scrolled circularly or horizontally using a drag gesture. Objects also
	 * snap to front when tapped on. Carousel supports tweening and snapping.
	 * 
	 * <codeblock xmll:space="preserve" class="+ topic/pre pr-d/codeblock ">
		var carousel:Carousel = new Carousel();
		carousel.width  = 400;
		carousel.height = 100;
		carousel.addChild(getImageElement("assets/wb3.jpg"));
		carousel.addChild(getImageElement("assets/USS_Macon_over_Manhattan.png"));
		carousel.addChild(getImageElement("assets/wb3.jpg"));
		carousel.init();
	 * </codeblock>
	 * 
	 * @author Ideum
	 */
	public class Carousel extends TouchContainer {
		
//==  VARIABLES  =============================================================//
		
		public static const LINEAR_DRAG    : Boolean =  false;
		public static const CIRCULAR_DRAG  : Boolean =  true;
		
		public static const ROTATE_UP      : int     =  0;
		public static const ROTATE_INWARD  : int     =  1;
		public static const ROTATE_OUTWARD : int     =  2;
		
		private var _friction              : Number  =  0.5;
		private var _rotationOffset        : Number  =  0;
		private var _dragScaling           : Number  =  1;
		private var _dragType              : Boolean =  CIRCULAR_DRAG;
		private var _rotationType          : int     =  ROTATE_UP;
		private var _onUpdate              : Function;
		
		private var  firstInit             : Boolean =  true;           // indicates whether this has been initialized once already
		private var  cloneExInit           : Boolean =  false;          // indicates whether cloneExclusions have been initialized already
		private var  snapTween             : TweenLite;                 // TweenLite object for animation
		private var  snapIndex             : int     =  0;              // index of currently "selected" element
		private var  oldSnapIndex          : int     = -1;              // index of "selected" element last time updateStackOrder() was called
		private var  targetRotation        : Number  =  0;              // target rotation for currentRotation, dragging modifies this
		private var  currentRotation       : Number  =  0;              // rendered rotation
		private var  releaseEvent          : GWGestureEvent;            // last gesture event before release event
		private var  orderedChildList      : Vector.<DisplayObject>;    // ring elements are stored in here in correct insertion order
		private var  containerList         : Vector.<DispObjContainer>; // mirror of orderedChildList containing the touchContainers holding the display objects
		private var  ring                  : TouchContainer;            // ring elements are rendered on here in correct z-stack order
		
//==  GETTERS/SETTERS  =======================================================//
		
		/**
		 * Amount of fricion to apply on inertia-release.
		 * Expects value x where 0 < x <= 1, where 1 disables tweening.
		 * @default 0.5
		 */
		public function get friction():Number { return _friction; }
		public function set friction(value:Number):void {
			if (value > 1) value = 1;
			else if (value <= 0) value = 0.5;
			_friction = value;
		}
		
		/**
		 * Rendered rotation offset angle.
		 * A value of 0 corresponds to the bottom of carousel.
		 * @default 0
		 */
		public function get rotationOffset():Number { return _rotationOffset; }
		public function set rotationOffset(offset:Number):void { _rotationOffset = offset; }
		
		/**
		 * Drag movement scaling factor.
		 * @default 1
		 */
		public function get dragScaling():Number { return _dragScaling; }
		public function set dragScaling(scale:Number):void { _dragScaling = scale; }
		
		/**
		 * Drag type.
		 * Expects either Carousel.LINEAR_DRAG (true) or Carousel.CIRCULAR_DRAG (false).
		 * Linear drag: dragging horizontally rotates the carousel, vertical movement is not considered.
		 * Circular drag: dragging around the carousel rotates it.
		 * @default Carousel.CIRCULAR_DRAG
		 */
		public function get dragType():Boolean { return _dragType; }
		public function set dragType(type:Boolean):void { _dragType = type; }
		
		/**
		 * Rotation type.
		 * Expects either Carousel.ROTATE_UP (0), Carousel.ROTATE_INWARD (1) or Carousel.ROTATE_OUTWARD (2).
		 * Rotate up: elements of the carousel point upwards.
		 * Rotate inward: elements of the carousel point towards the pivot point
		 * Rotate outward: elements of the carousel point away from the pivot point
		 */
		public function get rotationType():int { return _rotationType; }
		public function set rotationType(type:int):void{ _rotationType = type; }
		
		/**
		 * Function to apply to each element when the display is updated.
		 * Function should be of the form (DisplayObject,Number):void
		 * 
		 * <codeblock xmll:space="preserve" class="+ topic/pre pr-d/codeblock ">
			var carousel:Carousel = new Carousel();
			c_carousel.onUpdate = function(child:DisplayObject, theta:Number):void {
				child.rotation = theta * 180 / Math.PI + 90;
			}
		 * </codeblock>
		 * 
		 * @default undefined
		 */
		public function get onUpdate():Function { return _onUpdate; }
		public function set onUpdate(func:Function):void { _onUpdate = func; }
		
		/**
		 * Returns the currently snapped object
		 */
		public function getCurrent():DisplayObject {
			var n:int = numChildren;
			return getChildAt(((snapIndex % n) + n) % n);
		}
		
//==  INITIALIZATION  ========================================================//
		
		/**
		 * Constructor
		 */
		public function Carousel() {
			orderedChildList = new Vector.<DisplayObject>();
			containerList = new Vector.<DispObjContainer>();
			ring = new TouchContainer();
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void {
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "isLoaded", true, true));
			ring.mouseChildren = true;
			mouseChildren = true;
			
			if (firstInit) {
				firstInit = false;
				super.addChild(ring);
				initSnapTween();
			}
			
			initListeners();
			snapTween.play();
		}
		
//==  CONTROLS  ==============================================================//
		
		/**
		 * Calculates the change of angle from a drag event.
		 * @param	e Event to calculate dTheta from
		 * @return dTheta, the change of angle
		 */
		private function calcDTheta(e:GWGestureEvent):Number {
			var oldX:Number = (e.value.x - e.value.drag_dx - width /2) / width;
			var oldY:Number = (e.value.y - e.value.drag_dy - height/2) / height;
			var newX:Number = (e.value.x - width /2) / width;
			var newY:Number = (e.value.y - height/2) / height;
			var oldTheta:Number = Math.atan2(oldY, oldX);
			var newTheta:Number = Math.atan2(newY, newX);
			var dTheta:Number = newTheta - oldTheta;
			return isNaN(dTheta)?0:dTheta;
		}
		
		/**
		 * Transforms an events value.x, value.y, value.drag_dx, and value.drag_dy to local coordinates
		 * @param	e Event to transform
		 * @return Event with values transformed
		 */
		private function getGlobalToLocalEvt(e:GWGestureEvent):GWGestureEvent {
			var   mtx:Matrix = this.transform.concatenatedMatrix.clone();
			var   pos:Point  = new Point(e.value.x      , e.value.y      );
			var delta:Point  = new Point(e.value.drag_dx, e.value.drag_dy);
			mtx.invert();
			pos   = mtx.transformPoint(pos);
			delta = mtx.deltaTransformPoint(delta);
			e.value.x = pos.x;
			e.value.y = pos.y;
			e.value.drag_dx = delta.x;
			e.value.drag_dy = delta.y;
			return e;
		}
		
		/**
		 * Initializes event listeners
		 */
		private function initListeners():void {
			for (var i:int = 0; i < containerList.length;++i) {
				var child:DispObjContainer = containerList[i];
				child.clearEvents();
				child.nativeTransform = false;
				child.gestureList = { "n-drag":true, "n-tap":true };
				child.addEventListener(GWGestureEvent.TAP,
					function(index:int):Function {
						return function(e:GWGestureEvent):void { snapTo(index); };
					}(i)
				);
			
				child.addEventListener(GWGestureEvent.START, function(e:GWGestureEvent):void { releaseEvent = e; });
				
				child.addEventListener(GWGestureEvent.DRAG, function(e:GWGestureEvent):void {
					e = getGlobalToLocalEvt(e);
					releaseEvent = e;
					targetRotation += dragType?(calcDTheta(e) * dragScaling)
											  :( -(isNaN(e.value.drag_dx)?0:e.value.drag_dx) / width * dragScaling);
					currentRotation = targetRotation;
					snapTween.play();
				});
				
				child.addEventListener(GWGestureEvent.RELEASE, function(e:GWGestureEvent):void {
					e = getGlobalToLocalEvt(e);
					var dTheta:Number = dragType?(calcDTheta(releaseEvent))
												:( -(isNaN(releaseEvent.value.drag_dx)?0:releaseEvent.value.drag_dx) / width);
					var n:int = numChildren;
					targetRotation += dTheta * (1 / friction);
					targetRotation = 2 * Math.PI * Math.round(targetRotation * n / (2 * Math.PI)) / n;
					snapTween.play();
				});
			}
		}
		
//==  SNAPPING  ==============================================================//
		
		/**
		 * Sets the carousels rotation to the specified index without tweening
		 * @param	index Index to rotate to
		 */
		public function setTo(index:int):void {
			snapIndex = index;
			currentRotation = targetRotation = (index / numChildren) * 2 * Math.PI;
			snapTween.play();
		}
		
		/**
		 * Snaps the carousel to the specified index without modulus
		 * @param	index Index to snap to
		 */
		public function snapToNoMod(index:Number):void {
			snapIndex = index;
			targetRotation = -2 * Math.PI * Math.round(index) / numChildren;
			snapTween.play();
		}
		
		/**
		 * Snaps the carousel to the specified index
		 * @param	index Index to snap to
		 */
		public function snapTo(index:Number):void {
			var       n:int = numChildren;
			var current:int = ((snapIndex % n) + n) % n;
			var  target:int = ((index % n) + n) % n;
			if (Math.abs(target - n - current) < n / 2) target -= n;
			else if (Math.abs(target + n - current) < n / 2) target += n;
			snapToNoMod(snapIndex + (target - current));
		}
		
		/**
		 * Updates the snap index according to the current rotation of the carousel
		 */
		private function updateSnapIndex():void {
			snapIndex = -Math.round(currentRotation * numChildren / (2 * Math.PI));
		}
		
		/**
		 * Rotates the carousel left
		 */
		public function rotateLeft ():void { snapTo(snapIndex - 1); }
		
		/**
		 * Rotates the carousel right
		 */
		public function rotateRight():void { snapTo(snapIndex + 1); }
		
//==  RENDERING  =============================================================//
		
		/**
		 * Initializes the TweenLite object used for snapping animation
		 */
		private function initSnapTween():void {
			snapTween = TweenLite.to(this, int.MAX_VALUE, { onUpdate:function():void {
				currentRotation += ((targetRotation - currentRotation) * friction);
				if (Math.abs(currentRotation - targetRotation) < 0.0001) currentRotation = targetRotation;
				updateSnapIndex();
				updateStackOrder();
				updateCoords();
				if (targetRotation == currentRotation) snapTween.pause();
			}});
		}
		
		/**
		 * Updates the z-order of the rendered objects according to snapIndex
		 */
		private function updateStackOrder():void {
			if (oldSnapIndex == snapIndex) return;
			oldSnapIndex = snapIndex;
			ring.removeChildren();
			var n:int = numChildren;
			var i:int = snapIndex;
			    i = ((i % n) + n) % n;
			var dir:Boolean = false;
			for (var q:int = 0; q < n; ++q) {
				ring.addChildAt(containerList[i], 0);
				i += (q + 1) * ((dir = !dir)?1: -1);
				i = ((i % n) + n) % n;
			}
		}
		
		/**
		 * Updates the positions of all the display objects in a circular fashion
		 */
		private function updateCoords():void {
			var n:int = numChildren;
			for (var i:int = 0; i < n; ++i) {
				var child:DisplayObject = getChildAt(i);
				var theta:Number = i / n * 2 * Math.PI + Math.PI / 2 + currentRotation + rotationOffset;
				child.x = (width  + Math.cos(theta) * width  - child.width ) / 2;
				child.y = (height + Math.sin(theta) * height - child.height) / 2;
				if (onUpdate != null) onUpdate(child, theta);
				
				var rotateFunc:Function = function(angle:Number):void {
					child.rotation = 0;
					var mtx:Matrix = child.transform.matrix;
					var x:Number = mtx.tx+child.width/2, y:Number = mtx.ty+child.width/2;
					mtx.translate( -x, -y);
					mtx.rotate(angle);
					mtx.translate(x, y);
					child.transform.matrix = mtx;
				};
				
				switch(rotationType) {
					case ROTATE_INWARD:  rotateFunc(theta - Math.PI / 2); break;
					case ROTATE_OUTWARD: rotateFunc(theta + Math.PI / 2); break;
				}
			}
		}
		
//==  ADD/GET/REMOVE CHILD REDIRECTION  ======================================//
		
		/**
		 * @inheritDoc
		 */
		override public function get numChildren():int { return orderedChildList.length; }
			
		/**
		 * @inheritDoc
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if (getChildIndex(child) != -1) return child;
			orderedChildList.splice(index, 0, child);
			var container:DispObjContainer = new DispObjContainer();
			container.addChild(child);
			containerList.splice(index, 0, container);
			return child;
		}
			
		/**
		 * @inheritDoc
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			if (getChildIndex(child) != -1) return child;
			orderedChildList.push(child);
			var container:DispObjContainer = new DispObjContainer();
			container.addChild(child);
			containerList.push(container);
			return child;
		}
			
		/**
		 * @inheritDoc
		 */
		override public function getChildIndex(child:DisplayObject):int { return orderedChildList.indexOf(child); }
			
		/**
		 * @inheritDoc
		 */
		override public function getChildAt(index:int):DisplayObject { return orderedChildList[index]; }
			
		/**
		 * @inheritDoc
		 */
		override public function getChildByName(name:String):DisplayObject {
			var i:int, n:int = numChildren;
			for (i = 0; i < n; ++i) {
				var child:DisplayObject = getChildAt(i);
				if (child.name == name) return child;
			}
			
			return null;
		}
			
		/**
		 * @inheritDoc
		 */
		override public function removeChild(child:DisplayObject):DisplayObject { return removeChildAt(getChildIndex(child)); }
			
		/**
		 * @inheritDoc
		 */
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			for (var i:int = beginIndex; i < endIndex; ++i) containerList[i].removeChildAt(0);
			orderedChildList.splice(beginIndex, endIndex - beginIndex);
			containerList.splice(beginIndex, endIndex - beginIndex);
		}
			
		/**
		 * @inheritDoc
		 */
		override public function removeChildAt(index:int):DisplayObject {
			var removedChild:DisplayObject = getChildAt(index);
			containerList[index].removeChildAt(0);
			orderedChildList.splice(index, 1);
			containerList.splice(index, 1);
			return removedChild;
		}
		
//==  MISC  ==================================================================//
		
		/**
		 * The Carousel element ignores the layout parameter. The Carousels
		 * appearance can be modified by changing its width and height, as well
		 * as its rotationOffset and onUpdate function.
		 */
		override public function set layout(value:*):void { }
		
		/**
		 * The Carousel element ignores the layout parameter. The Carousels
		 * appearance can be modified by changing its width and height, as well
		 * as its rotationOffset and onUpdate function.
		 */
		override public function applyLayout(value:Layout = null):void { }
		
		/**
		 * @inheritDoc
		 */
		override public function clone(parent:* = null):* {
			// this implementation assumes a clone will be followed by an init call before use
			
			if (!cloneExInit) {
				cloneExInit = true;
				cloneExclusions.push("childList"); // this is already in here by default
				cloneExclusions.push("snapTween");
				cloneExclusions.push("orderedChildList");
				cloneExclusions.push("containerList");
				cloneExclusions.push("ring");
			}
			
			var clone:Carousel = CloneUtils.clone(this, parent?parent:this.parent, cloneExclusions) as Carousel;
			    clone.orderedChildList = new Vector.<DisplayObject>();
			    clone.containerList = new Vector.<DispObjContainer>();
			    clone.ring = new TouchContainer();
			    clone.firstInit = true;
			return clone;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_onUpdate        = null;
			snapTween        = null;
			releaseEvent     = null;
			orderedChildList = null;
			containerList    = null;
			ring             = null;
		}
	}
}

/**
 * Helper class to make event clearing easier
 */
class DispObjContainer extends com.gestureworks.cml.elements.TouchContainer {
	private var eventList:Array = [];
	public function clearEvents():void { for each(var i:Object in eventList) if (hasEventListener(i.type)) removeEventListener(i.type, i.listener); }
	override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		eventList.push( { type:type, listener:listener } );
	}
}