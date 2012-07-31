package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.events.*;
	import org.tuio.TuioTouchEvent;
	
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
		
		
		override public function displayComplete():void {updateLayout(this.width, this.height)}
		
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
					frameCount = 0;
				}
			}
		}
		
		
		public function updateLayout(containerWidth:Number = 0, containerHeight:Number = 0):void
		{
			trace("updateLayout", containerWidth, containerHeight);
			
			buttonArray = this.childList.getClass(ButtonElement).getValueArray();
			
			var btnWidth:Number = 0;
			var btnHeight:Number = 0;		
			var maxBtnWidth:Number = 0;
			var maxBtnHeight:Number = 0;
			var i:int;
			
			
			for (i = 0; i < buttonArray.length; i++)
			{
				buttonArray[i].updateLayout();
				btnWidth = buttonArray[i].width;
				btnHeight = buttonArray[i].height;
				
				if (maxBtnWidth < btnWidth)
					maxBtnWidth = btnWidth;
				if (maxBtnHeight < btnHeight)
					maxBtnHeight = btnHeight;
			}
					
			
			if (position == "bottom" || position == "top")	
			{
				// position self
				if (position == "bottom")
					this.y = containerHeight - maxBtnHeight - paddingBottom;				
				else if (position == "top")
					this.y = paddingTop;			
						
				// position all but last buttons			
				for (i = 0; i < buttonArray.length-1; i++) 
				{
					// position first button
					if (i == 0) 
						buttonArray[i].x = paddingLeft;
						
					// position middle buttons
					else
						buttonArray[i].x = (containerWidth - paddingLeft - paddingRight) / (buttonArray.length - 1) * i;
				}	
				
				// position last button, if more than one
				if (buttonArray.length > 1)
					buttonArray[buttonArray.length - 1].x = containerWidth - paddingRight - buttonArray[buttonArray.length - 1].width;
			}
			
			else if (position == "bottomLeft" || position == "topLeft")	
			{
				// position self
				if (position == "bottomLeft")
					this.y = containerHeight - maxBtnHeight - paddingBottom;				
				else if (position == "topLeft")
					this.y = paddingTop;				
				
				// position buttons		
				for (i = 0; i < buttonArray.length; i++) 
				{
					// position first button
					if (i == 0) 
						buttonArray[i].x = paddingLeft;
						
					// position the rest
					else
						buttonArray[i].x = buttonArray[i - 1].x + buttonArray[i - 1].width + paddingLeft + paddingRight;
				}	
				
			}		
			
			else if (position == "bottomRight" || position == "topRight")	
			{
				// position self
				if (position == "bottomRight")
					this.y = containerHeight - maxBtnHeight - paddingBottom;				
				else if (position == "topRight")
					this.y = paddingTop;					
				
				// position buttons		
				for (i = buttonArray.length-1; i >= 0; i--) 
				{					
					// position last button
					if (i == buttonArray.length-1) 
						buttonArray[i].x = containerWidth - buttonArray[i].width - paddingRight;
						
					// position the rest
					else
						buttonArray[i].x = buttonArray[i + 1].x - buttonArray[i + 1].width - paddingLeft - paddingRight;
						
					
				}	
			}					
			
			
		}
		
	}
}