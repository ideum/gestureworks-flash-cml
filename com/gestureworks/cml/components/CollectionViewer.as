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
		
		public function CollectionViewer() 
		{
			super();
			queue = new List;
		}
		
		override public function displayComplete():void
		{			
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
		
		private function onGestureComplete(event:GWGestureEvent):void
		{
			var w:Number = event.target.width * event.target.scaleX;
			var h:Number = event.target.height * event.target.scaleY;
			
			
			if ((event.target.x - (w / 2) > stage.stageWidth) ||
				(event.target.x + (w / 2) < 0) ||
				(event.target.y - (h / 2) > stage.stageHeight) ||
				(event.target.y + (h / 2) < 0)
			)
			{
				removeComponent(event.target);
				addNextComponent(event.target);
			}			
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
				}
			
			}
			
			function onTweenEnd():void
			{			
				tweens[newComponent] = null;
			}				
			
		}
	}
}