package com.gestureworks.cml.kits 
{
	import com.gestureworks.cml.element.*;	
	import flash.events.Event;
	
	/**
	 * The BackgroundKit updates background
	 */
	public class BackgroundKit extends Container
	{
		/**
		 * constructor
		 */
		public function BackgroundKit() 
		{
			super();
		}
		
		/**
		 * automatically update
		 */
		public var autoupdate:Boolean = true;
		
		/**
		 * CML call back initialisation
		 */
		override public function displayComplete():void
		{
			if (autoupdate)
				stage.addEventListener(Event.RESIZE, updateLayout);
			updateLayout();
		}
		
		/**
		 * method updates the child x and y position
		 * @param	event
		 */
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