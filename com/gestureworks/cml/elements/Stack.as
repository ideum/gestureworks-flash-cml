package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	
	/**
	 * The Stack element is a container that gathers its children into a stack, and allows the user to move through the list using a specified user input.
	 * The Stack can hold any display object.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var stack:Stack = new Stack();
		stack.toggle = "up";
		stack.loop = false;
		addChild(stack);
		
		stack.addChild(text1);
		stack.childToList("text", text1);
		
		stack.addChild(img1);
		stack.childToList("img1", img1);
		
		stack.addChild(text2);
		stack.childToList("text2", text2);
		
		stack.init();
		addChild(stack);
	 *
	 * </codeblock>
	 * @author ...
	 */
	public class Stack extends TouchContainer
	{
		
		/**
		 * Constructor
		 */
		public function Stack() 
		{
			super();
		}
		 
		
		private var _toggle:String = "up";
		/**
		 * sets toggle event by string name:
		 * mouseOver, mouseDown, mouseUp, touchDown, touchUp, down, and up 
		 * (the last two auto-switch between input device)
		 * @default up
		 */		
		public function get toggle():String {return _toggle}
		public function set toggle(value:String):void 
		{			
			_toggle = value;		
		}			
		
		
		private var _loop:Boolean = true;
		/**
		 * Specifies whether the stack loops to the beginning and continues while toggling
		 */		
		public function get loop():Boolean {return _loop}
		public function set loop(value:Boolean):void 
		{			
			_loop = value;		
		}
		
		/**
		 * Resets the stack order
		 */		
		public function reset():void
		{
			childList.reset();
		}
		
		/**
		 * CML initialization method
		 * @internal do not call super here
		 */
		override public function init():void
		{			
			// hide all but first child
			for (var i:int = 1; i < childList.length; i++) 
			{
				childList[i].visible = false;
			}
			
			childList.reset();
			
			if (toggle == "mouseOver")
				this.addEventListener(MouseEvent.MOUSE_OVER, onToggle);	
			
			else if (toggle == "mouseDown")
				this.addEventListener(MouseEvent.MOUSE_DOWN, onToggle);
				
			else if (toggle == "mouseUp")
				this.addEventListener(MouseEvent.MOUSE_UP, onToggle);	
				
			else if (toggle == "touchDown")
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onToggle);
				
			else if (toggle == "touchUp")
				this.addEventListener(TouchEvent.TOUCH_END, onToggle);
				
			else if (toggle == "down")
			{
				this.addEventListener(GWTouchEvent.TOUCH_BEGIN, onToggle);
			}
			else if (toggle == "up")
			{
				this.addEventListener(GWTouchEvent.TOUCH_END, onToggle);
			}			
		}		
			

		// event handlers // 
		
		private function onToggle(event:*):void
		{			
			if (childList.hasNext() && !(childList.getIndex(childList.currentIndex + 1) is GestureList))
			{
				childList.currentValue.visible = false
				childList.next().visible = true;
			}
			else if (loop)
			{
				childList.currentValue.visible = false				
				childList.reset();
				childList.currentValue.visible = true				
			}
							
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "toggle", cmlIndex, true, true));			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
	}
}