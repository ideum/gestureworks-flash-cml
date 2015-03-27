package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.Graphic;
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.utils.ChildList;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.GestureEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	public class Carousel extends TouchContainer {
		
		// child anchor points?
		// dynamic insertion of children?
		// will this include buttons? currently, users can set external buttons to control rotation using snap and rotation functions
		// ring spacing distribution function?
		// passive animation?
		// TODO: getters/setters
		
//==  VARIABLES  =============================================================//
		
		public static const LINEAR_DRAG   : Boolean = false;
		public static const CIRCULAR_DRAG : Boolean = true;
		
		private var rotationOffset        : Number  = 0;             // rendered rotation offset angle
		private var dragScaling           : Number  = 1;             // drag movement-scaling factor
		private var dragType              : Boolean = CIRCULAR_DRAG; // drag type

		private var snapIndex             : int     = 0;             // index of currently "selected" element
		private var targetRotation        : Number  = 0;             // target rotation for currentRotation, dragging modifies this
		private var currentRotation       : Number  = 0;             // rendered rotation
		private var orderedChildList      : Vector.<DisplayObject>;  // ring elements are stored in here in correct insertion order
		private var ring                  : TouchContainer;          // ring elements are rendered on here in correct z-stack order
		
//==  INITIALIZATION  ========================================================//
		
		public function Carousel() {
			super.mouseChildren = true;
			orderedChildList = new Vector.<DisplayObject>();
			ring = new TouchContainer();
			super.addChild(ring);
		}
		
		override public function init():void {
			updateStackOrder(); // DELETE
			updateCoords();     // DELETE
			
			var guide:Graphic = new Graphic;
			guide.graphics.lineStyle(2, 0xffffff, 1);
			guide.graphics.moveTo(width / 2, height / 2);
			guide.graphics.lineTo(width / 2, height);
			super.addChild(guide);
			
			ring.nativeTransform = false;
			ring.gestureList = { "n-drag":true };
			ring.addEventListener(GWGestureEvent.DRAG, dragType?circularDrag:linearDrag);
			
			// TODO: how to identify which element was tapped?
			ring.addEventListener(GWGestureEvent.START  , function(e:GWGestureEvent):void { trace("START"  ); } );
			ring.addEventListener(GWGestureEvent.RELEASE, function(e:GWGestureEvent):void { trace("RELEASE"); });
		}
		
//==  DRAGGING  ==============================================================//
		
		private function linearDrag(e:GWGestureEvent):void {
			// TODO: transform drag evt to local coords
		}
		
		private function circularDrag(e:GWGestureEvent):void {
			// TODO: transform drag evt to local coords
			var oldX:Number = (e.value.x - e.value.drag_dx - width /2) / width;
			var oldY:Number = (e.value.y - e.value.drag_dy - height/2) / height;
			var newX:Number = (e.value.x - width /2) / width;
			var newY:Number = (e.value.y - height/2) / height;
			var oldTheta:Number = Math.atan2(oldY, oldX);
			var newTheta:Number = Math.atan2(newY, newX);
			targetRotation += (newTheta - oldTheta) * dragScaling;
			snapToClosest();
			updateStackOrder();
			updateCoords();
		}
		
//==  SNAPPING  ==============================================================//
		
		public function setTo(index:int):void {
			snapIndex = index;
			targetRotation = currentRotation = (index / numChildren) * 2 * Math.PI;
		}
		
		public function snapTo(index:Number):void {
			var i:int = Math.round(index);
			var n:int = numChildren;
		}
		
		private function snapToClosest():void {
			var n:int = numChildren;
			snapIndex = -((targetRotation + (targetRotation>0?1:-1)*((2 * Math.PI / n) / 2)) / (2 * Math.PI)) * n;
		}
		
		public function rotateLeft ():void { snapTo(snapIndex - 1); }
		public function rotateRight():void { snapTo(snapIndex + 1); }
		
//==  ANCHORING  =============================================================//
		
		// public static const ANCHOR_TOP:Function = function() { };
		
		// public function setAnchor
		
//==  RENDERING  =============================================================//
		
		private function updateStackOrder():void {
			// dont do this if you dont need to? whats the check for this?
			ring.removeChildren();
			var n:int = numChildren;
			var i:int = snapIndex;
			    i = ((i % n) + n) % n;
			var dir:Boolean = false;
			for (var q:int = 0; q < n; ++q) {
				ring.addChildAt(getChildAt(i), 0);
				i += (q + 1) * ((dir = !dir)?1: -1); // iterate in stacking order
				i = ((i % n) + n) % n;
			}
		}
		
		private function updateCoords():void {
			var n:int = numChildren;
			for (var i:int = 0; i < n; ++i) {
				// TODO: rotation offset
				// TODO: currentRotation
				var child:DisplayObject = getChildAt(i);
				child.x = (width  + Math.cos(i / n * 2 * Math.PI + Math.PI / 2 + targetRotation + rotationOffset) * width  - child.width ) / 2;
				child.y = (height + Math.sin(i / n * 2 * Math.PI + Math.PI / 2 + targetRotation + rotationOffset) * height - child.height) / 2;
			}
		}
		
//==  ADD/REMOVE REDIRECTION  ================================================//
		
		// TODO: add stuff for ring touch container?
		
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