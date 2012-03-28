package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	//import com.gestureworks.cml.events.*;
	///import com.gestureworks.cml.kits.*;
	//import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	
	import com.gestureworks.events.GWGestureEvent;
	
	/**
	 * CollectionViewer
	 * @author Ideum
	 */
	public class CollectionViewer extends Component 
	{
		
		public function CollectionViewer() 
		{
			super();			
		}
		
		override public function displayComplete():void
		{
			addTouchListeners()		
		}			
		
		private function updateLayout(event:TouchEvent):void
		{
			if (event.target.parent is TouchContainer) {
				//trace("shuffle", event.target.parent);
				removeChild(event.target.parent);
				addChild(event.target.parent);
			}
		}
		
		public function addTouchListeners():void
		{	
			//trace("hello", autoShuffle,numChildren, childList.length);
			if(autoShuffle){
				for (var i:int = 0; i < childList.length; i++) 
				{
					//trace("adding listener to:", getChildAt(i));
					getChildAt(i).addEventListener(TouchEvent.TOUCH_BEGIN, updateLayout);
				}
			}
		}
		
	}
	
}