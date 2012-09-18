package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.Menu;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.core.GestureWorks;
	import org.tuio.TuioTouchEvent;
	import flash.events.TouchEvent
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Component extends TouchContainer 
	{
		
		private var menu:Menu;
		
		public function Component() 
		{
			super();
		}
		
		override public function init():void
		{
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			menu = searchChildren(Menu);
			
			if (menu)
			{
				menu.updateLayout(width, height);
				
				if (menu.autoHide) {
					if (GestureWorks.activeTUIO)
						this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
					else if	(GestureWorks.supportsTouch)
						this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					else	
						this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				}					
			}			
		}
		
		override public function displayComplete():void
		{
			init();
		}
		
		private function onDown(event:*):void
		{
			if (menu)
			{
				menu.visible = true;
				menu.startTimer();
			}
		}	
		
		protected function onStateEvent(event:StateEvent):void
		{				
			if (event.value == "close") 
				this.visible = false;				
		}
		
		override public function dispose():void 
		{
			super.dispose();
			menu = null;
			
			this.removeEventListener(StateEvent.CHANGE, onStateEvent);
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
	}

}