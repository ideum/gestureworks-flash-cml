package com.gestureworks.cml.kits 
{
	import com.gestureworks.cml.element.*;	
	import flash.events.Event;
	
	public class BackgroundKit extends Container
	{
		public function BackgroundKit() 
		{
			super();
		}
		
		override public function displayComplete():void
		{
			//stage.addEventListener(Event.RESIZE, updateLayout);
			updateLayout();
		}
		
		
		public function updateLayout(event:Event=null):void
		{
			var child:*;
			for (var i:int = 0; i < numChildren; i++) 
			{
				child = getChildAt(i);
				child.x = (stage.stageWidth - child.width) / 2;
				child.y = (stage.stageHeight -  child.height) / 2;				
			}			
		}
		
	}
}