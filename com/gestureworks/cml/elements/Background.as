package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.elements.*;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * The BackgroundKit resizes its children to the center of the stage.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var bg:BackgroundKit = new BackgroundKit;
		bg.addChild(img1);
		bg.addChild(img2);
		bg.init();
		bg.addChild();
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Container
	 */
	public class Background extends TouchContainer
	{
		/**
		 * Constructor
		 */
		public function Background() 
		{
			super();
			mouseChildren = true;
		}
		
		/**
		 * Automatically updates background to stage size. This adds an event listener
		 * to the stage which listens for resize events, and adjust accordingly.
		 * @default false
		 */
		public var _autoupdate:Boolean = false;
		public function get autoupdate():Boolean{return _autoupdate;}
		public function set autoupdate(value:Boolean):void
		{
			_autoupdate = value;
			
			if (_autoupdate)
				stage.addEventListener(Event.RESIZE, updateLayout);
			else 
				stage.removeEventListener(Event.RESIZE, updateLayout);				
		}		

		/**
		 * CML callback initialisation
		 */
		override public function init():void
		{
			updateLayout();
		}		
		
		/**
		 * Updates the child x and y position to the center of the stage
		 * @param	event
		 */
		public function updateLayout(event:Event=null):void
		{
			var child:DisplayObject;
			for (var i:int = 0; i < numChildren; i++) 
			{
				child = getChildAt(i) as DisplayObject;
				child.x = (stage.stageWidth - child.width) / 2;
				child.y = (stage.stageHeight -  child.height) / 2;				
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{	
			super.dispose();
			stage.removeEventListener(Event.RESIZE, updateLayout);
		}		
		
	}
}