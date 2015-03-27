package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.Graphic;
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.utils.ChildList;
	import com.gestureworks.core.TouchSprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	public class Carousel extends TouchContainer
	{
		// rotation offset?
		// drag scaling?
		// child anchor points?
		// dynamic insertion of children?
		// will this include buttons? currently, users can set external buttons to control rotation using snap and rotation functions
		// ring spacing distribution function?
		// passive animation?
		
//==  VARIABLES  =============================================================//
		
		private var snapIndex        : int    = 0;             // index of currently "selected" element
		private var targetRotation   : Number = 0;             // target rotation for currentRotation, dragging modifies this
		private var currentRotation  : Number = 0;             // rendered rotation
		private var orderedChildList : Vector.<DisplayObject>; // ring elements are stored in here in correct insertion order
		private var ring             : TouchContainer;         // ring elements are rendered on here in correct z-stack order
		
//==  INITIALIZATION  ========================================================//
		
		public function Carousel()
		{
			super.mouseChildren = true;
			orderedChildList = new Vector.<DisplayObject>();
			ring = new TouchContainer();
			super.addChild(ring);
		}
		
		override public function init():void
		{
			updateStackOrder(); // DELETE
			render();           // DELETE
		}
		
//==  SNAPPING  ==============================================================//
		
		public function setTo(index:int):void
		{
			snapIndex = index;
			targetRotation = currentRotation = (index / numChildren) * 2 * Math.PI;
		}
		
		public function snapTo(index:Number):void
		{
			var i:int = Math.round(index);
			var n:int = numChildren;
			snapIndex = ((i % n) + n) % n; // DELETE?
		}
		
		public function rotateLeft ():void { snapTo(snapIndex - 1); }
		public function rotateRight():void { snapTo(snapIndex + 1); }
		
		private function snapToClosest():void
		{
			// TODO: snap targetRotation
		}
		
//==  ANCHORING  =============================================================//
		
		// public static const ANCHOR_TOP:Function = function() { };
		
		// public function setAnchor
		
//==  RENDERING  =============================================================//
		
		private function updateStackOrder():void
		{
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
		
		private function render():void
		{
			var n:int = numChildren;
			for (var i:int = 0; i < n; ++i) {
				// TODO: rotation offset
				// TODO: currentRotation
				var child:DisplayObject = getChildAt(i);
				child.x = (width  + Math.cos(i / n * 2 * Math.PI + Math.PI / 2) * width  - child.width ) / 2;
				child.y = (height + Math.sin(i / n * 2 * Math.PI + Math.PI / 2) * height - child.height) / 2;
			}
		}
		
//==  ADD/REMOVE REDIRECTION  ================================================//
		
		// TODO: add stuff for ring touch container?
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			// if orderedChildList doesnt contain child
			orderedChildList.splice(index, 0, child);
			return child;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			// if orderedChildList doesnt contain child
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
		
		override public function removeChildAt(index:int):DisplayObject {
			var removedChild:DisplayObject = getChildAt(index);
			orderedChildList.splice(index, 1);
			return removedChild;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject { return removeChildAt(getChildIndex(child)); }
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void { orderedChildList.splice(beginIndex, endIndex-beginIndex); }
		override public function get numChildren():int { return orderedChildList.length; }
		
//==  MISC  ==================================================================//
		
		override public function set layout(value:*):void { }
		override public function applyLayout(value:Layout = null):void { }
		override public function clone():* { } // TODO
		override public function dispose():void { super.dispose(); } // TODO
	}
}