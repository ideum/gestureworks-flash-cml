package com.gestureworks.cml.element 
{
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.core.GestureWorks;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Menu extends Container 
	{
		private var frameCount:int = 0;	

		public function Menu() 
		{
			super();
		}
		
		/**
		 * Specifies whether the menu automatically hides when not in use
		 */		
		private var _autoHide:Boolean = false;
		public function get autoHide():Boolean { return _autoHide; }
		public function set autoHide(value:Boolean):void 
		{ 
			_autoHide = value;
			
			if (autoHide)
				this.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
		}
		
		/**
		 * Specifies the auto-hide time
		 */		
		private var _autoHideTime:Number = 2500;
		public function get autoHideTime():Number { return _autoHideTime; }
		public function set autoHideTime(value:Number):void 
		{ 
			_autoHideTime = value; 
		}			
		
		override public function displayComplete():void {}
		
		private function onClick(event:MouseEvent):void
		{
			startTimer();
		}
		
		
		public function startTimer():void
		{	
			if (autoHide)
			{
				GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, onFrame);				
				GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, onFrame);
				frameCount = 0;
			}
		}
		
		private function onTimerComplete(event:TimerEvent):void
		{			
			GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, onFrame);				
			this.visible = false;
		}
		
		
		private function onFrame(event:GWEvent):void
		{
			frameCount++;
						
			if (1000 / stage.frameRate * frameCount >= autoHideTime)
			{
				GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, onFrame);				
				this.visible = false;
				frameCount = 0;
			}	
		}		
		
	}
}