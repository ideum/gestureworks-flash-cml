package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.easing.*;
	import org.tuio.*;	
	
	/**
	 * CollectionViewer is a template that uses a collection of Components to load various types of media and display the content on stage in the form of interactive windows. 
	 * This version loads an instance of the ImageViewer, VideoViewer, and MP3Player and randomly places and orients them on the stage.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
	 * @author Ideum
	 */
	
	public class CollectionViewer extends Component
	{
		public var amountToShow:int = -1;
		public var animateIn:Boolean = true;
		
		private var queue:List;
		private var currentTween:*;
		
		//private var boundsTimer:Timer;
		
		/**
		 * collection viewer constructor
		 */
		public function CollectionViewer() 
		{
			super();
			queue = new List;
		}
		
		/**
		 * initialisation method
		 */
		override public function init():void 
		{
			cover = new Sprite;
		
			cover.graphics.beginFill(0x000000, 1);
			cover.graphics.drawRect(30, 30, stage.stageWidth - 60, stage.stageHeight - 60);
			cover.graphics.endFill();
			cover.cacheAsBitmap = true;
			cover.visible = false;
			this.addChildAt(cover, 0);
						
			//boundsTimer = new Timer(500);
			//boundsTimer.addEventListener(TimerEvent.TIMER, onBoundsTimer);
			//boundsTimer.start();			
			
			if (amountToShow >= childList.length || amountToShow == -1)
				amountToShow = childList.length;
					
				
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
				
				childList.getIndex(i).addEventListener(StateEvent.CHANGE, onStateEvent, false, -1);
				childList.getIndex(i).addEventListener(GWGestureEvent.COMPLETE, onBoundsTimer);
				
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
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}			
		
		private var cover:Sprite;
		
		private function onBoundsTimer(event:GWGestureEvent):void
		{				
			var onscreen:Boolean = CollisionDetection.isColliding(DisplayObject(event.target), cover, this, true, 0);								
			trace(onscreen);
			if (!onscreen)
			{					
				removeComponent(DisplayObject(event.target));
				
				if (this.numChildren-1 < amountToShow)
					addNextComponent();
			}				
		}
			

		   
		private var tweens:Dictionary = new Dictionary(true)
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
						
			
			if (target.parent is TouchContainer){
				if (contains(target.parent))
				{	
					removeChild(target.parent);
					addChild(target.parent);
				}
			}
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
			trace("remove");
			queue.append(component);
			if (contains(component as DisplayObject))
				removeChild(component as DisplayObject);
		}
		
		private function addNextComponent():void
		{
			trace("add");
			var newComponent:*;							
			newComponent = queue.getIndex(0);
			queue.remove(0);
			
			trace(queue.length);
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
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			queue = null;			
			currentTween = null;			
			cover = null;			
			tweens = null;
			
			//if (boundsTimer)
			//{
				//boundsTimer.stop();
				//boundsTimer.removeEventListener(TimerEvent.TIMER,onBoundsTimer);
				//boundsTimer = null;
			//}
			
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
	}
}