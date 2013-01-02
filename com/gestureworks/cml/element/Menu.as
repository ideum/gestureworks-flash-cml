package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.element.Button;
	import com.gestureworks.cml.element.Container
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.cml.utils.StateUtils;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.DisplayObject;
	import flash.events.*;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * The Menu element constructs a custom menu using nested Buttons(s).
	 * It features auto-hiding and auto-positioning.
	 * 
	 * @author Ideum
	 * @see Button
	 * @see OrbMenu
	 * @see DropDownMenu
	 */
	public class Menu extends Container 
	{
		private var frameCount:int = 0;
		public var buttonArray:Array = [];
		public var slider:Slider;
 
		/**
		 * Constructor
		 */
		public function Menu() 
		{
			super();
		}

		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			buttonArray = null;
			
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onClick);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onClick);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
			
			GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, onFrame);
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
		
		/**
		 * CML Initialisation call back
		 */
		override public function displayComplete():void {
			//updateLayout(this.width, this.height)
			//init();
			addEventListener(StateEvent.CHANGE, onStateEvent);
		}
		
		/**
		 * Initialisation method
		 */
		public function init():void {
			updateLayout(this.width, this.height);	
			addEventListener(StateEvent.CHANGE, onStateEvent);
		}
		
		private function onClick(event:*):void
		{
			startTimer();
		}
		
		/**
		 * if autohide on, adds the listener 
		 */
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
		
		private function onStateEvent(e:StateEvent):void {
			//trace("Button event caught.");
			for (var i:int = 0; i < numChildren; i++) 
			{
				if(getChildAt(i) is Button)
					Button(getChildAt(i)).onFlip(e);
			}
		}
		
		/**
		 * Returns clone of self
		 */
		override public function clone():* 
		{
			var v:Vector.<String> = new <String>[];						
			var clone:Menu = CloneUtils.clone(this, null, v);
			
			CloneUtils.copyChildList(this, clone);
			//clone.buttonArray = [];
			/*for (var i:int = 0; i < clone.buttonArray.length; i++) 
			{
				for (var j:int = 0; j < clone.numChildren; j++) 
				{
					if (clone.buttonArray[i].name == clone.getChildAt(j).name) {
						clone.buttonArray[i] = clone.getChildAt(j);
					}
				}
			}*/

			//clone.displayComplete();
			clone.init();

			return clone;
		}		
		
		public function reset():void { 
			StateUtils.loadState(this, 0, true);
		}
		
		/**
		 * sets the layout depending on the position
		 * @param	containerWidth
		 * @param	containerHeight
		 */
		public function updateLayout(containerWidth:Number, containerHeight:Number):void
		{	
			//buttonArray = [];
			var margin:Number = paddingLeft + paddingRight;
			
			var i:int;
			
			for (i = 0; i < this.numChildren; i++) {
				if ( childList.getIndex(i) is Button) {
					Button(childList.getIndex(i)).updateLayout();
					margin += childList.getIndex(i).width;
				}
				else if (childList.getIndex(i) is Slider) {
					Slider(childList.getIndex(i)).updateLayout();
					margin += childList.getIndex(i).width;
				}
			}
			
			margin = containerWidth - margin;
			margin /= buttonArray.length - 1;
			
			//Experimental code
			
			if (position == "bottom" || position == "top")	
			{						
				// Find the margin.
				
				// position all but last buttons			
				for (i = 0; i < childList.length; i++) 
				{
					if (childList.getIndex(i) is Button || childList.getIndex(i) is Slider) {
						var num:Number = getChildIndex(childList.getIndex(i));
						// position first button
						if (num == 0) 
							getChildAt(num).x = paddingLeft;
							
						// position middle buttons
						else
							getChildAt(num).x = getChildAt(num - 1).x + getChildAt(num - 1).width + margin;
						
						// position y
						if (position == "bottom")
							getChildAt(num).y = containerHeight - getChildAt(num).height - paddingBottom;		
						else if (position == "top")
							getChildAt(num).y = paddingTop;
					}
				}
				
				
				/*if ( childList.length > 1){
					for (var j:int = childList.length - 1; j > 0; j--) {
						if (childList.getIndex(j) is DisplayObject) {
							var num2:Number = getChildIndex(childList.getIndex(j));
							
							if (getChildAt(num2) is Button || getChildAt(num2) is Slider) {
							getChildAt(num2).x = containerWidth - paddingRight - getChildAt(num2).width;	
							
							// position y
							if (position == "bottom")
								getChildAt(num2).y = containerHeight - getChildAt(num2).height - paddingBottom;				
							
							else if (position == "top")
								getChildAt(num2).y = paddingTop;
							}
						}
					}
				}*/
				
				// position last button, if more than one
				if (childList.length > 1 && childList.getIndex(childList.length - 1) is DisplayObject)  {
					var num2:Number = getChildIndex(childList.getIndex(childList.length - 1));
					if (getChildAt(num2) is Button || getChildAt(num2) is Slider) {
						getChildAt(num2).x = containerWidth - paddingRight - getChildAt(num2).width;	
						
						// position y
						if (position == "bottom")
							getChildAt(num2).y = containerHeight - getChildAt(num2).height - paddingBottom;				
						
						else if (position == "top")
							getChildAt(num2).y = paddingTop;
					}
					
				}
				
			}
			
			else if (position == "bottomLeft" || position == "topLeft")	
			{
				
				// position buttons		
				for (i = 0; i < childList.length; i++) 
				{
					if (childList.getIndex(i) is Button || childList.getIndex(i) is Slider) {
						var num:Number = getChildIndex(childList.getIndex(i));
						// position first button
						if (i == 0) 
							getChildAt(num).x = paddingLeft;
							
						// position the rest
						else
							getChildAt(num).x = getChildAt(num - 1).x + getChildAt(num - 1).width + paddingLeft + paddingRight;
							
						// position y
						if (position == "bottomLeft")
							getChildAt(num).y = containerHeight - getChildAt(num).height - paddingBottom;				
						
						else if (position == "topLeft")
							getChildAt(num).y = paddingTop;
					}
											
				}	
				
			}	
			
			else if (position == "bottomRight" || position == "topRight")	
			{																
				// position buttons		
				for (i = buttonArray.length-1; i >= 0; i--) 
				{
					if (childList.getIndex(i) is Button || childList.getIndex(i) is Slider) {
						var num:Number = getChildIndex(childList.getIndex(i));
						// position last button
						if (i == childList.length-1) 
							getChildAt(num).x = containerWidth - getChildAt(num).width - paddingRight;
							
						// position the rest
						else
							getChildAt(num).x = getChildAt(num + 1).x - getChildAt(num + 1).width - paddingLeft - paddingRight;										
						
						// position y
						if (position == "bottomRight")	
							getChildAt(num).y = containerHeight - getChildAt(num).height - paddingBottom;
						
						else if (position == "topRight")
							getChildAt(num).y = paddingTop;
					}
				}	
			}
			
			// Original code, scroll down. Experimental code, scroll up.
			
			/*if (position == "bottom" || position == "top")	
			{						
				// Find the margin.
				
				// position all but last buttons			
				for (i = 0; i < buttonArray.length-1; i++) 
				{
					// position first button
					if (i == 0) 
						buttonArray[i].x = paddingLeft;
						
					// position middle buttons
					else
						buttonArray[i].x = buttonArray[i - 1].x + buttonArray[i - 1].width + margin;
					
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
			}*/
			
			/*else if (position == "bottomLeft" || position == "topLeft")	
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
				
			}	*/	
			
			/*else if (position == "bottomRight" || position == "topRight")	
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
			}*/			
		}
	}
}