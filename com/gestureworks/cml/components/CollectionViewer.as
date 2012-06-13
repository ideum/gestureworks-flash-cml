package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.easing.*;	
	import org.tuio.TuioTouchEvent;
	
	/**
	 * CollectionViewer
	 * @author Ideum
	 */
	public class CollectionViewer extends Component
	{
		public var amountToShow:int = -1;
		public var animateIn:Boolean = false;
		
		private var queue:List;
		private var currentTween:*;
		
		private var boundsTimer:Timer;
		
		public function CollectionViewer() 
		{
			super();
			queue = new List;
		}
		
		override public function displayComplete():void
		{
			boundsTimer = new Timer(1000);
			boundsTimer.addEventListener(TimerEvent.TIMER, onBoundsTimer);
			boundsTimer.start();
			
			if (amountToShow >= childList.length || amountToShow == -1)
				amountToShow = childList.length;
					
			//amountToShow = 10; sometimes not loading this property correctly !!! ugh, it is the cml parser - why the inconsistency!!
			
			var i:int = 0;	
			for (i = 0; i < childList.length; i++) 
			{	
				if (autoShuffle) 
				{
					if (GestureWorks.activeTUIO)
						childList.getIndex(i).addEventListener(TuioTouchEvent.TOUCH_DOWN, updateLayout);
					else if (GestureWorks.supportsTouch)
						childList.getIndex(i).addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
					else 
						childList.getIndex(i).addEventListener(MouseEvent.MOUSE_DOWN, updateLayout);	
				}
				
				childList.getIndex(i).addEventListener(StateEvent.CHANGE, onStateEvent);	
				//childList.getIndex(i).addEventListener(GWGestureEvent.COMPLETE, onGestureComplete);
				
				if (i < amountToShow)
				{					
					addChild(childList.getIndex(i));
				}
				else
				{					
					if (contains(childList.getIndex(i)))
						removeChild(childList.getIndex(i));
											
					queue.append(childList.getIndex(i));
				}	
			}	
		}			
		
		private function onBoundsTimer(event:TimerEvent):void
		{				
			trace(numChildren);				
							
			for (var i:int = 0; i < this.numChildren - 1; i++)
			{
				
				var offscreenBuffer:int = 50;
				var bounds:Rectangle =  getVisibility(this.getChildAt(i) as DisplayObject);
				
				trace(bounds);
				
				var offscreen:Boolean = false;
				
				// out left
				if (bounds.x + bounds.width <= offscreenBuffer)
					offscreen = true;
				
				// out right	
				if (bounds.x >= stage.stageWidth - offscreenBuffer)
					offscreen = true;
					
				// out top	
				if (bounds.y + bounds.height <= offscreenBuffer)
					offscreen = true;
					
				// out bottom	
				if (bounds.y >= stage.stageHeight - offscreenBuffer)
					offscreen = true;
				
					
				trace(offscreen);	
					
				if (offscreen)
				{
					
					trace(i);
					
					removeComponent(this.getChildAt(i));
					
					if (this.numChildren < amountToShow) {
						addNextComponent(this.getChildAt(i));
						
					}
				}
			}
		}
			
		
		private function getVisibility(obj:DisplayObject):Rectangle 
		{
			var vis:Rectangle;
		 
			if (obj.parent == null) return new Rectangle();
		 
			if (obj is DisplayObjectContainer) {
				vis = getChildVisibility(obj, obj.parent);
			} else {
				vis = obj.getBounds(obj.parent);
			}
		 
			// Is the DisplayObject masked?
			if (obj.mask != null) {
				vis = vis.intersection(obj.mask.getBounds(obj.parent));
			}
		 
			// Is the DisplayObject partly or completely off-stage?
			vis = vis.intersection(obj.stage.getBounds(obj.parent));
		 			
			return vis;
		}
		
		
		private function getChildVisibility(obj:*, target:DisplayObjectContainer):Rectangle {
		 
			var vis:Rectangle = new Rectangle();
			var child:DisplayObject;
			var childRect:Rectangle;
			var i:uint;
		 
			for (i = 1; i <= obj.numChildren; i++) {
				child = obj.getChildAt(i-1);
		 
				if (child != null) {
					if (child.visible) {
						if (child is DisplayObjectContainer) {
							childRect = getChildVisibility(child, target);
						} else {
							childRect = child.getBounds(target);
						}
						if (child.mask != null) {
							childRect = childRect.intersection(child.mask.getBounds(target));
						}
						vis = vis.union(childRect);
					}
				}
			}
			return vis;
		}
		
		
		private var tweens:Dictionary = new Dictionary(true)
		private function updateLayout(event:*=null):void
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
						
			
			if (target.parent is TouchContainer){
				if (contains(target.parent))
				{	
					removeChild(target.parent);
					addChild(target.parent);
				}
			}
			
		}
		

		private function onStateEvent(event:StateEvent):void
		{			
			if (event.value == "close") 
			{				
				removeComponent(event.currentTarget);				

				if (this.numChildren < amountToShow)
					addNextComponent(event.target);
			}	
		}	
		
		private function removeComponent(component:*):void
		{			
			//component.removeEventListener(StateEvent.CHANGE, onStateEvent);				
			//component.removeEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
			//component.removeEventListener(MouseEvent.MOUSE_DOWN, updateLayout);
			//component.removeEventListener(GWGestureEvent.COMPLETE, onGestureComplete);	
			
			if (contains(component as DisplayObject)) {
				removeChild(component as DisplayObject);
				queue.append(component);
			}	
		}
		
		private function addNextComponent(component:*):void
		{
			var newComponent:*;
			var removedIndex:int;
			
			
			function process():void
			{
				newComponent = queue.getIndex(0);
				queue.remove(0);
				
				
				if (newComponent)
				{				
					addChild(newComponent);
					
					//var randX:Number = (stage.width / 2) - 200;	
					//var randY:Number = (stage.height / 2) - 200;
											
					newComponent.x = -500;
					newComponent.y = -500;
					
					if (animateIn)
					{
						tweens[newComponent] = BetweenAS3.tween(newComponent, { x:stage.stageWidth/2, y:stage.stageHeight/2 }, null, 4, Exponential.easeOut)
						tweens[newComponent].onComplete = onTweenEnd;
						tweens[newComponent].play();
						newComponent.visible = true;							
					}
				}
				
				function onTweenEnd():void
				{			
					tweens[newComponent] = null;
				}
			}
			
			while (this.numChildren < amountToShow)
			{
				process();
			}
			

						
		}
	}
}