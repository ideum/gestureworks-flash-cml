package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.events.*;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.cml.interfaces.IButton;
	
	public class Menu extends Container 
	{
		private var frameCount:int = 0;
		private var buttonArray:Array = [];

		public function Menu() 
		{
			super();
		}

		
		private var _autoHide:Boolean = false;
		/**
		 * Specifies whether the menu automatically hides when not in use
		 */			
		public function get autoHide():Boolean { return _autoHide; }
		public function set autoHide(value:Boolean):void 
		{ 
			_autoHide = value;
			
			if (autoHide) {
				if (GestureWorks.activeTUIO)
					this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onClick);
				else if	(GestureWorks.supportsTouch)
					this.addEventListener(TouchEvent.TOUCH_BEGIN, onClick);
				else	
					this.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			}
		}
		
	
		private var _autoHideTime:Number = 2500;
		/**
		 * Specifies the auto-hide time
		 */	 		
		public function get autoHideTime():Number { return _autoHideTime; }
		public function set autoHideTime(value:Number):void 
		{ 
			_autoHideTime = value; 
		}
		
		private var _position:String = "bottom";
		/**
		 * Specifies the position alogorithm of the menu. 
		 * This includes the position of the buttons with in the menu.
		 * The button must be a child of the menu.
		 * @default bottom
		 */	 		
		override public function get position():String { return _position; }
		override public function set position(value:String):void 
		{ 
			_position = value; 
		}		
		
		
		override public function displayComplete():void {
			//**updateLayout(this.width, this.height)**//
			}
		
		private function onClick(event:*):void
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
			
			if(stage){
				if (1000 / stage.frameRate * frameCount >= autoHideTime)
				{
					GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, onFrame);				
					this.visible = false;
					this.mouseChildren = false;
					frameCount = 0;
				}
			}
		}
		
		
		public function updateLayout(containerWidth:Number, containerHeight:Number):void
		{
			
			for (var j:int = 0; j < childList.length; j++) 
			{
				if (childList.getIndex(j) is ButtonElement) {
					buttonArray.push(childList.getIndex(j));
				}	
			}
			
			var i:int;
		
			for (i = 0; i < buttonArray.length; i++)
			{
				buttonArray[i].updateLayout();
			}
			
			
			if (position == "bottom" || position == "top")	
			{						
				// position all but last buttons			
				for (i = 0; i < buttonArray.length-1; i++) 
				{
					// position first button
					if (i == 0) 
						buttonArray[i].x = paddingLeft;
						
					// position middle buttons
					else
						buttonArray[i].x = (containerWidth - paddingLeft - paddingRight) / (buttonArray.length - 1) * i;

						
					// position y
					if (position == "bottom")
						buttonArray[i].y = containerHeight - buttonArray[i].height - paddingBottom;				
					
					else if (position == "top")
						buttonArray[i].y = paddingTop;					
				
				}
				
				// position last button, if more than one
				if (buttonArray.length > 1)  {
					buttonArray[buttonArray.length - 1].x = containerWidth - paddingRight - buttonArray[buttonArray.length - 1].width;	
					
					// position y
					if (position == "bottom")
						buttonArray[buttonArray.length - 1].y = containerHeight - buttonArray[i].height - paddingBottom;				
					
					else if (position == "top")
						buttonArray[buttonArray.length - 1].y = paddingTop;
					
				}
				
			}
			
			else if (position == "bottomLeft" || position == "topLeft")	
			{
				
				
				// position buttons		
				for (i = 0; i < buttonArray.length; i++) 
				{
					// position first button
					if (i == 0) 
						buttonArray[i].x = paddingLeft;
						
					// position the rest
					else
						buttonArray[i].x = buttonArray[i - 1].x + buttonArray[i - 1].width + paddingLeft + paddingRight;
						
					// position y
					if (position == "bottomLeft")
						buttonArray[i].y = containerHeight - buttonArray[i].height - paddingBottom;				
					
					else if (position == "topLeft")
						buttonArray[i].y = paddingTop;
											
				}	
				
			}		
			
			else if (position == "bottomRight" || position == "topRight")	
			{																
				// position buttons		
				for (i = buttonArray.length-1; i >= 0; i--) 
				{
					// position last button
					if (i == buttonArray.length-1) 
						buttonArray[i].x = containerWidth - buttonArray[i].width - paddingRight;
						
					// position the rest
					else
						buttonArray[i].x = buttonArray[i + 1].x - buttonArray[i + 1].width - paddingLeft - paddingRight;										
					
					// position y
					if (position == "bottomRight")	
						buttonArray[i].y = containerHeight - buttonArray[i].height - paddingBottom;
					
					else if (position == "topRight")
						buttonArray[i].y = paddingTop;
				}	
			}			
		}
	}
}