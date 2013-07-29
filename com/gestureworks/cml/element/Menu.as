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
	public class Menu extends TouchContainer 
	{
		private var frameCount:int = 0;
		public var buttonArray:Array = [];
		public var slider:Slider;
		
		private var _layoutComplete:Boolean = false;
 
		/**
		 * Constructor
		 */
		public function Menu() 
		{
			super();
			mouseChildren = true;
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
				else if	(GestureWorks.activeNativeTouch)
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
		override public function init():void {
			
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (!(childList.getIndex(i) is DisplayObject) || childList.getIndex(i) is String)
					childList.removeIndex(i);
			}
			
			if (!_layoutComplete)
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
			for (var i:int = 0; i < numChildren; i++) 
			{
				if(getChildAt(i) is Button) {
					Button(getChildAt(i)).onFlip(e);
				}
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
			
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (!(contains(childList.getIndex(i)))){
					childList.removeIndex(i);
					i--;
				}
				
			}
			
			clone.init();

			return clone;
		}		
		
		public function reset():void { 
			StateUtils.loadState(this, 0, true);
			for (var i:int = 0; i < this.numChildren; i++) 
			{
				if (getChildAt(i) is Button) {
					Button(getChildAt(i)).reset();
				}
			}
		}
		
		/**
		 * sets the layout depending on the position
		 * @param	containerWidth
		 * @param	containerHeight
		 */
		public function updateLayout(containerWidth:Number, containerHeight:Number):void
		{	
			var margin:Number = paddingLeft + paddingRight;
			var i:int = 0;
			var itemCount:Number = 0;
			for (i = 0; i < this.numChildren; i++) {
				if ( getChildAt(i) is Button) {
					Button(getChildAt(i)).updateLayout();
					margin += getChildAt(i).width;
					itemCount++;
				}
				else if (getChildAt(i) is Slider) {
					Slider(getChildAt(i)).updateLayout();
					slider = getChildAt(i) as Slider;
					margin += getChildAt(i).width;
					itemCount++;
				}
			}
			
			margin = containerWidth - margin;
			//margin /= buttonArray.length - 1;
			margin /= (itemCount - 1);
			
			//Experimental code
			var num:Number
			
			if (position == "bottom" || position == "top")	
			{						
				// Find the margin.
				
				// position all but last buttons			
				for (i = 0; i < numChildren; i++) 
				{
					//if (childList.getIndex(i) is Button || childList.getIndex(i) is Slider) {
						//num = getChildIndex(childList.getIndex(i));
						num = i;
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
					//}
				}
				
				
				// position last button, if more than one
				/*if (childList.length > 1 && childList.getIndex(childList.length - 1) is DisplayObject)  {
					var num2:Number = getChildIndex(childList.getIndex(childList.length - 1));
					if (getChildAt(num2) is Button || getChildAt(num2) is Slider) {
						getChildAt(num2).x = containerWidth - paddingRight - getChildAt(num2).width;	
						
						// position y
						if (position == "bottom")
							getChildAt(num2).y = containerHeight - getChildAt(num2).height - paddingBottom;				
						
						else if (position == "top")
							getChildAt(num2).y = paddingTop;
					}
					
				}*/
				
				if (numChildren > 1 && getChildAt(numChildren - 1) is DisplayObject)  {
					var num2:Number = numChildren - 1;
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
						num = getChildIndex(childList.getIndex(i));
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
				
				for (i = numChildren - 1; i >= 0; i--) 
				{
					if (childList.getIndex(i) is Button || childList.getIndex(i) is Slider) {
						num = getChildIndex(childList.getIndex(i));
						
						if (i == numChildren-1) 
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
			
			i = 0;
			_layoutComplete = true;
		}
	}
}