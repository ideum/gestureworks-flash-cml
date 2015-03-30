package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.utils.ChildList;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Carousel extends TouchContainer {
		
		// child anchor points?
		// elementFocused callback?
		// elementSelected callback?
		
//==  VARIABLES  =============================================================//
		
		public static const LINEAR_DRAG   : Boolean =  false;
		public static const CIRCULAR_DRAG : Boolean =  true;
		
		private var _rotationOffset       : Number  =  0;             // rendered rotation offset angle
		private var _dragScaling          : Number  =  1;             // drag movement-scaling factor
		private var _dragType             : Boolean =  CIRCULAR_DRAG; // drag type
		private var _transformFunc        : Function;                 // this gets applied to every element
		
		private var  snapTween            : TweenLite;                // TweenLite object for animation
		private var  snapIndex            : int     =  0;             // index of currently "selected" element
		private var  oldSnapIndex         : int     = -1;             // index of "selected" element last time updateStackOrder() was called
		private var  targetRotation       : Number  =  0;             // target rotation for currentRotation, dragging modifies this
		private var  currentRotation      : Number  =  0;             // rendered rotation
		private var  releaseEvent         : GWGestureEvent;           // last gesture event before release event
		private var  orderedChildList     : Vector.<DisplayObject>;   // ring elements are stored in here in correct insertion order
		private var  ring                 : TouchContainer;           // ring elements are rendered on here in correct z-stack order
		
//==  GETTERS/SETTERS  =======================================================//
		
		public function get rotationOffset():Number { return _rotationOffset; }
		public function set rotationOffset(offset:Number):void { _rotationOffset = offset; }
		
		public function get dragScaling():Number { return _dragScaling; }
		public function set dragScaling(scale:Number):void { _dragScaling = scale; }
		
		// function should be of the form (DisplayObject,Number):void
		public function get transformFunc():Function { return _transformFunc; }
		public function set transformFunc(func:Function):void { _transformFunc = func; }
		
		// should be set to either Carousel.LINEAR_DRAG or Carousel.CIRCULAR_DRAG
		public function get dragType():Boolean { return _dragType; }
		public function set dragType(type:Boolean):void { _dragType = type; }
		
		// TODO: get snapIndex?
		
//==  INITIALIZATION  ========================================================//
		
		public function Carousel() {
			super.mouseChildren = true;
			orderedChildList = new Vector.<DisplayObject>();
			ring = new TouchContainer();
			super.addChild(ring);
			initSnapTween();
			initListeners();
		}
		
		override public function init():void {
			updateStackOrder();
			updateCoords();
		}
		
//==  DRAGGING  ==============================================================//
		
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
		
		private function initListeners():void {
			// TODO: how to identify which element was tapped?
			
			ring.nativeTransform = false;
			ring.gestureList = { "n-drag":true, "n-tap":true };
			
			ring.addEventListener(GWGestureEvent.TAP, function(e:GWGestureEvent):void { trace("TAP"); } );
			
			ring.addEventListener(GWGestureEvent.START, function(e:GWGestureEvent):void { releaseEvent = e; });
			
			ring.addEventListener(GWGestureEvent.DRAG, function(e:GWGestureEvent):void {
				e = getGlobalToLocalEvt(e);
				releaseEvent = e;
				targetRotation += dragType?(calcDTheta(e) * dragScaling)
				                          :(-e.value.drag_dx / width * dragScaling);
				currentRotation = targetRotation;
				updateSnapIndex();
				updateStackOrder();
				updateCoords();
			});
			
			ring.addEventListener(GWGestureEvent.RELEASE, function(e:GWGestureEvent):void {
				e = getGlobalToLocalEvt(e);
				var dTheta:Number = dragType?(calcDTheta(releaseEvent))
				                            :(-releaseEvent.value.drag_dx / width);
				var n:int = numChildren;
				targetRotation += dTheta * 10;
				targetRotation = 2 * Math.PI * Math.round(targetRotation * n / (2 * Math.PI)) / n;
				snapTween.play();
			});
		}
		
//==  SNAPPING  ==============================================================//
		
		public function setTo(index:int):void {
			snapIndex = index;
			currentRotation = targetRotation = (index / numChildren) * 2 * Math.PI;
		}
		
		public function snapTo(index:Number):void {
			targetRotation = 2 * Math.PI * Math.round(index) / numChildren;
			snapTween.play();
		}
		
		private function updateSnapIndex():void {
			snapIndex = -Math.round(currentRotation * numChildren / (2 * Math.PI));
		}
		
		// TODO: fix this
		public function rotateLeft ():void { snapTo(targetRotation-(2*Math.PI)/numChildren); }
		public function rotateRight():void { snapTo(snapIndex + 1); }
		
//==  RENDERING  =============================================================//
		
		private function initSnapTween():void {
			snapTween = TweenLite.to(this, int.MAX_VALUE, { onUpdate:function():void {
				currentRotation += ((targetRotation - currentRotation) * 0.1);
				if (Math.abs(currentRotation - targetRotation) < 0.0001) currentRotation = targetRotation;
				updateSnapIndex();
				updateStackOrder();
				updateCoords();
				if (targetRotation == currentRotation) snapTween.pause();
			}});
		}
		
		private function updateStackOrder():void {
			if (oldSnapIndex == snapIndex) return;
			oldSnapIndex = snapIndex;

			ring.removeChildren();
			var n:int = numChildren;
			var i:int = snapIndex;
			    i = ((i % n) + n) % n;
			var dir:Boolean = false;
			for (var q:int = 0; q < n; ++q) {
				ring.addChildAt(getChildAt(i), 0);
				i += (q + 1) * ((dir = !dir)?1: -1);
				i = ((i % n) + n) % n;
			}
		}
		
		private function updateCoords():void {
			var n:int = numChildren;
			for (var i:int = 0; i < n; ++i) {
				var child:DisplayObject = getChildAt(i);
				var theta:Number = i / n * 2 * Math.PI + Math.PI / 2 + currentRotation + rotationOffset;
				var x:Number = child.x = (width  + Math.cos(theta) * width  - child.width ) / 2;
				var y:Number = child.y = (height + Math.sin(theta) * height - child.height) / 2;
				if (transformFunc != null) transformFunc(child, theta);
			}
		}
		
//==  ADD/GET/REMOVE REDIRECTION  ============================================//
		
		override public function get numChildren():int { return orderedChildList.length; }
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if (getChildIndex(child) != -1) return child;
			orderedChildList.splice(index, 0, child);
			return child;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			if (getChildIndex(child) != -1) return child;
			orderedChildList.push(child);
			return child;
		}
		
		override public function getChildAt(index:int):DisplayObject { return orderedChildList[index]; }
		override public function getChildIndex(child:DisplayObject):int { return orderedChildList.indexOf(child); }
		override public function getChildByName(name:String):DisplayObject {
			var i:int, n:int = numChildren;
			for (i = 0; i < n; ++i) {
				var child:DisplayObject = getChildAt(i);
				if (child.name == name) return child;
			}
			
			return null;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject { return removeChildAt(getChildIndex(child)); }
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void { orderedChildList.splice(beginIndex, endIndex-beginIndex); }
		override public function removeChildAt(index:int):DisplayObject {
			var removedChild:DisplayObject = getChildAt(index);
			orderedChildList.splice(index, 1);
			return removedChild;
		}
		
//==  MISC  ==================================================================//
		
		override public function set layout(value:*):void { }
		override public function applyLayout(value:Layout = null):void { }
		override public function clone():* { } // TODO
		override public function dispose():void { super.dispose(); } // TODO
	}
}