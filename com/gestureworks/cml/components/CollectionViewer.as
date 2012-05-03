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
		
		public function CollectionViewer() 
		{
			super();
			queue = new List;
		}
		
		override public function displayComplete():void
		{
			//addTouchListeners(); // now adding on only the amount on stage			
			
			if (amountToShow > childList.length || amountToShow == -1)
				amountToShow = childList.length;
			
				
			var i:int = 0;	
			for (i = 0; i < childList.length; i++) 
			{	
				
				if (autoShuffle) 
				{
					if (GestureWorks.supportsTouch)
						childList.getIndex(i).addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
					else 
						childList.getIndex(i).addEventListener(MouseEvent.MOUSE_DOWN, updateLayout);
				}
				
				childList.getIndex(i).addEventListener(StateEvent.CHANGE, onStateEvent);	
				childList.getIndex(i).addEventListener(GWGestureEvent.COMPLETE, onGestureComplete);
				
				
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
			
		/*
		public function downHandler(displayObject:DisplayObject):void
		{
			if (displayObject.parent && displayObject.parent == this)
			{
				if (tweens[displayObject]){
					tweens[displayObject].stop();
					tweens[displayObject] = null;
					delete tweens[displayObject];
				}
					
				if (displayObject is TouchContainer){
					if (contains(displayObject)){	
						removeChild(displayObject);
						addChild(displayObject);
					}
				}
				
			}
			
			if (displayObject.hasOwnProperty("onDown"))
			{
				displayObject["onDown"](null);
			}
		
		}
		*/
		
		private function onGestureComplete(event:GWGestureEvent):void
		{
			if (event.target.x + event.target.width * event.target.scaleX <= 10 || 
				event.target.y + event.target.height * event.target.scaleY <= 10 || 
				event.target.x >= stage.stageWidth - 10 || 
				event.target.y >= stage.stageHeight - 10)
			{
				removeComponent(event.target);
				addNextComponent(event.target);				
			}
		}
		
		
		private var tweens:Dictionary = new Dictionary(true)
		private function updateLayout(event:*=null):void
		{
			
			if (tweens[event.target.parent])
			{
				tweens[event.target.parent].stop();
				tweens[event.target.parent] = null;
				delete tweens[event.target.parent];
			}
				
			if (event.target.parent is TouchContainer){
				if (contains(event.target.parent))
				{	
					removeChild(event.target.parent);
					addChild(event.target.parent);
				}
			}
		}
		
		public function addTouchListeners():void
		{	
			if(autoShuffle){
				for (var i:int = 0; i < childList.length; i++) 
				{
					getChildAt(i).addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
				}
			}
		}
		
		private function onStateEvent(event:StateEvent):void
		{			
			if (event.value == "close") 
			{
				addNextComponent(event.currentTarget);
				removeComponent(event.currentTarget);				
			}	
		}	
		
		private function removeComponent(component:*):void
		{			
			//component.removeEventListener(StateEvent.CHANGE, onStateEvent);				
			//component.removeEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
			//component.removeEventListener(MouseEvent.MOUSE_DOWN, updateLayout);
			//component.removeEventListener(GWGestureEvent.COMPLETE, onGestureComplete);	
			
			if (contains(component as DisplayObject))
				removeChild(component as DisplayObject);
				
			queue.append(component);
		}
		
		private function addNextComponent(component:*):void
		{
			var newComponent:*;
			var removedIndex:int;
			
			
			newComponent = queue.getIndex(0);
			queue.remove(0);
			
			
			if (newComponent)
			{
				//newComponent.updateProperties(0);

				/*
				if (autoShuffle) {
					newComponent.addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);					
					newComponent.addEventListener(MouseEvent.MOUSE_DOWN, updateLayout);					
				}
				*/
				
				addChild(newComponent);
				
				var randX:Number = (stage.width / 2) - 200;	
				var randY:Number = (stage.height / 2) - 200;
										
				newComponent.x = -500;
				newComponent.y = -500;
				
				if (animateIn)
				{
					tweens[newComponent] = BetweenAS3.tween(newComponent, { x:randX, y:randY }, null, 4, Exponential.easeOut)
					tweens[newComponent].onComplete = onTweenEnd;
					tweens[newComponent].play();
					newComponent.visible = true;
										
					//newComponent.addEventListener(StateEvent.CHANGE, onStateEvent);
					//newComponent.addEventListener(GWGestureEvent.COMPLETE, onGestureComplete);							
				}
			
			}
			
			function onTweenEnd():void
			{			
				tweens[newComponent] = null;
			}				
			
		}
	}
}