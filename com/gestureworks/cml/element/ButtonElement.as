package com.gestureworks.cml.element
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;	
	import flash.utils.Dictionary;
	import com.gestureworks.cml.events.StateEvent;

	public class ButtonElement extends Container
	{
		private var debug:Boolean = false;		
		private var buttonStates:Dictionary;		
		private var hitObject:Object;
		
		
		public function ButtonElement()
		{
			super();
			buttonStates = new Dictionary(false);
			hitObject = new Object;	
		}		
		
		
		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			for each (var state:* in buttonStates)
			{
				if (state != init)
					hideKey(state);	
			}
			
			showKey(init);
			hitObject = childList.getKey(hit);	
			
			if (mouseOver)
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);	
			
			if (mouseDown)
				hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);	
				
			if (touchDown)
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);					
		}
		
		
		private var _hit:String;
		/**
		 * Sets hit object
		 */
		public function get hit():String {return _hit;}
		public function set hit(value:String):void 
		{
			_hit = value;
		}		
				
		
		private var _init:String;
		/**
		 * Sets button state association with mouse down event
		 */
		public function get init():String {return buttonStates["init"];}
		public function set init(value:String):void 
		{
			buttonStates["init"] = value;						
		}
		
		
		////////////////////////////////////////////////////
		/// MOUSE STATES
		///////////////////////////////////////////////////		
		
		private var _mouseOver:String;
		/**
		 * Sets button state association with mouse over event
		 */		
		public function get mouseOver():String {return buttonStates["mouseOver"];}
		public function set mouseOver(value:String):void 
		{			
			buttonStates["mouseOver"] = value;			
		}			
		

		private var _mouseDown:String;
		/**
		 * Sets button state association with mouse down event
		 */
		public function get mouseDown():String {return buttonStates["mouseDown"];}
		public function set mouseDown(value:String):void 
		{
			buttonStates["mouseDown"] = value;													
		}
		
		
		private var _mouseUp:String;
		/**
		 * Sets button state association with mouse up event
		 */		
		public function get mouseUp():String {return buttonStates["mouseUp"];}
		public function set mouseUp(value:String):void 
		{			
			buttonStates["mouseUp"] = value;											
		}		
		
		
		private var _mouseOut:String;
		/**
		 * Sets button state association with mouse out event
		 */		
		public function get mouseOut():String {return buttonStates["mouseOut"];}
		public function set mouseOut(value:String):void 
		{			
			buttonStates["mouseOut"] = value;												
		}			

		
		
		////////////////////////////////////////////////////
		/// TOUCH STATES
		///////////////////////////////////////////////////		
		
		
		private var _touchDown:String;
		/**
		 * Sets button state association with touch down event
		 */		
		public function get touchDown():String {return buttonStates["touchDown"];}
		public function set touchDown(value:String):void 
		{			
			buttonStates["touchDown"] = value;
		}
		
		
		private var _touchUp:String;
		/**
		 * Sets button state association with touch up event
		 */		
		public function get touchUp():String {return buttonStates["touchUp"];}
		public function set touchUp(value:String):void 
		{			
			buttonStates["touchUp"] = value;
		}			

		
		
		////////////////////////////////////////////////////
		/// MOUSE EVENT HANDLERS
		///////////////////////////////////////////////////
		
		
		private function onMouseDown(event:MouseEvent):void
		{
			if (debug)
				trace("mouse down");
			
			hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);															
			
			for each (var state:* in buttonStates)
			{
				if (state != mouseDown)
					hideKey(state);	
			}
			
			showKey(buttonStates["mouseDown"]);
				
			if (mouseUp)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);												
				hitObject.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseDown", true, true));															
		}
		
		
		private function onMouseUp(event:MouseEvent):void
		{
			if (debug)
				trace("mouse up");
				
			hitObject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			for each (var state:* in buttonStates)
			{
				if (state != mouseUp)
					hideKey(state);	
			}

			showKey(buttonStates["mouseUp"]);
			
			if (mouseDown)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);												
				hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			
			if (mouseOut)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);												
				hitObject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseOut", true, true));												
		}		
		
		
		private function onMouseOver(event:MouseEvent):void
		{
			if (debug)			
				trace("mouse over");											
			
			hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);															
			
			for each (var state:* in buttonStates)
			{
				if (state != mouseOver)
					hideKey(state);	
			}				
	
			showKey(buttonStates["mouseOver"]);	
			
			if (mouseOut)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);												
				hitObject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseOver", true, true));									
		}	
		
				
		private function onMouseOut(event:MouseEvent):void
		{
			if (debug)
				trace("mouse out");
			
			hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);															
			
			for each (var state:* in buttonStates)
			{
				if (state != mouseOut)
					hideKey(state);	
			}				
	
			showKey(buttonStates["mouseOut"]);
			
			if (mouseOver)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOut);												
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseOut", true, true));						
		}		
		
		

		////////////////////////////////////////////////////
		/// TOUCH EVENT HANDLERS
		///////////////////////////////////////////////////
		
		
		private function onTouchDown(event:TouchEvent):void
		{
			if (debug)
				trace("touch down");
			
			hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
			
			for each (var state:* in buttonStates)
			{
				if (state != touchDown)
					hideKey(state);	
			}
			
			showKey(buttonStates["touchDown"]);
				
			if (touchUp)
			{
				hitObject.removeEventListener(TouchEvent.TOUCH_END, onTouchUp);															
				hitObject.addEventListener(TouchEvent.TOUCH_END, onTouchUp);															
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchDown", true, true));			
		}
		
		
		private function onTouchUp(event:TouchEvent):void
		{
			if (debug)
				trace("touch up");
			
			hitObject.removeEventListener(TouchEvent.TOUCH_END, onTouchUp);															
			
			for each (var state:* in buttonStates)
			{
				if (state != touchUp)
					hideKey(state);	
			}
			
			showKey(buttonStates["touchUp"]);
				
			if (touchDown)
			{
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchUp", true, true));						
		}			
		
	}
}