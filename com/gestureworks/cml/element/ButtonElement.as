package com.gestureworks.cml.element
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;	
	import flash.utils.Dictionary;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.GestureWorks;

	public class ButtonElement extends Container
	{
		protected var debug:Boolean = true;		
		protected var buttonStates:Dictionary;		
		public var hitObject:*;
		public var dispatchDefault:Boolean = false;
		private var dispatchDict:Dictionary;		
		
		public function ButtonElement()
		{
			super();
			buttonStates = new Dictionary(true);
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
			
			// float hit area to the top of the display list
			addChildAt(hitObject, numChildren - 1);
			
			if (mouseOver)
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);	
			
			if (mouseDown)
				hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
			if (touchDown)
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			
			if (down)
			{
				if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				else
					hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
				
			updateLayout();
		}
		
		
		public function updateLayout():void
		{
			// we need containers to automatically take on the dimensions of the largest child, so I don't have to do this!!
			if (childList.getKey(buttonStates["init"]) is Container)
			{
				if (childList.getKey(buttonStates["init"]).width == 0)
				{
					for each (var item:* in childList.getKey(buttonStates["init"]).childList.getValueArray()) 
					{
						if (item.hasOwnProperty("width"))
						{							
							if (item.width > this.width)
								this.width = item.width;								
						}						
					}
				}
				
				if (childList.getKey(buttonStates["init"]).height == 0)
				{
					for each (var item2:* in childList.getKey(buttonStates["init"]).childList.getValueArray()) 
					{
						if (item.hasOwnProperty("height"))
						{
							if (item2.height > this.height)
								this.height = item2.height;
						}						
					}
				}				
			}			
		}
		
				
		private var _dispatch:String;
		/**
		 * Sets type of button, returned in the down event string
		 */
		public function get dispatch():String {return _dispatch;}
		public function set dispatch(value:String):void 
		{
			if (!dispatchDict)
				dispatchDict = new Dictionary(true);
			
			_dispatch = value;
			
			var arr:Array = _dispatch.split(":");
			
			for (var i:int = 0; i < arr.length-1; i+=2) 
			{
				dispatchDict[arr[i]] = arr[i + 1];				
			}
			
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

		
		private var _touchOut:String;
		/**
		 * Sets button state association with touch out event
		 */		
		public function get touchOut():String {return buttonStates["touchOut"];}
		public function set touchOut(value:String):void 
		{			
			buttonStates["touchOut"] = value;
		}			
		
		
		
		////////////////////////////////////////////////////
		/// AUTO STATES
		///////////////////////////////////////////////////		
		
		
		private var _down:String;
		/**
		 * Sets button state association with down event
		 */		
		public function get down():String {return buttonStates["down"];}
		public function set down(value:String):void 
		{			
			buttonStates["down"] = value;
		}
		
		
		private var _up:String;
		/**
		 * Sets button state association with up event
		 */		
		public function get up():String {return buttonStates["up"];}
		public function set up(value:String):void 
		{			
			buttonStates["up"] = value;
		}			

		
		private var _out:String;
		/**
		 * Sets button state association with out event
		 */		
		public function get out():String {return buttonStates["out"];}
		public function set out(value:String):void 
		{			
			buttonStates["out"] = value;
		}
		
		
		
		////////////////////////////////////////////////////
		/// MOUSE EVENT HANDLERS
		///////////////////////////////////////////////////
		
		
		public function onMouseDown(event:MouseEvent):void
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
			
			if (mouseOut)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);												
				hitObject.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}			
			
			if (dispatchDict["mouseDown"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseDown"], true, true));
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseDown", true, true));
		}
		
		
		public function onMouseUp(event:MouseEvent):void
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
			
			
			if (dispatchDict["mouseUp"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseUp"], true, true));
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseUp", true, true));			
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
			
			if (dispatchDict["mouseOver"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseDown"], true, true));	
			else if (dispatchDefault)
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
			
			if (mouseDown)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);												
				hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}			
			
			if (dispatchDict["mouseOut"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseOut"], true, true));	
			else if (dispatchDefault)
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
			
			if (touchOut)
			{
				hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onTouchOut);											
				hitObject.addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
			}	
			
			if (dispatchDict["touchDown"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchDown"], true, true));	
			else if (dispatchDefault)
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
			
			if (touchDown)
			{
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
			}
			
			if (dispatchDict["touchUp"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchUp"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchUp", true, true));					
		}			
		
		
		private function onTouchOut(event:TouchEvent):void
		{
			if (debug)
				trace("touch out");
			
			hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onTouchOut);															
			
			for each (var state:* in buttonStates)
			{
				if (state != touchOut)
					hideKey(state);	
			}
			
			showKey(buttonStates["touchOut"]);
				
			if (touchOut)
			{
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
			}
			
			if (dispatchDict["touchOut"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchOut"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchOut", true, true));					
		}


		////////////////////////////////////////////////////
		/// AUTO EVENT HANDLERS
		///////////////////////////////////////////////////
		
		
		private function onDown(event:*):void
		{	
			if (debug)
				trace("down");
			
			if (GestureWorks.supportsTouch)
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
			else
				hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);	
											
			for each (var state:* in buttonStates)
			{
				if (state != down)
					hideKey(state);	
			}
			
			showKey(buttonStates["down"]);
				
			if (up)
			{				
				if (GestureWorks.supportsTouch) {
					hitObject.removeEventListener(TouchEvent.TOUCH_END, onUp);
					hitObject.addEventListener(TouchEvent.TOUCH_END, onUp);
				}	
				else {
					hitObject.removeEventListener(MouseEvent.MOUSE_UP, onUp);	
					hitObject.addEventListener(MouseEvent.MOUSE_UP, onUp);	
				}
			}
			
			if (out)
			{				
				if (GestureWorks.supportsTouch) {
					hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
					hitObject.addEventListener(TouchEvent.TOUCH_OUT, onOut);
				}	
				else {
					hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);	
					hitObject.addEventListener(MouseEvent.MOUSE_OUT, onOut);	
				}
			}
			
			if (dispatchDict["down"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["down"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "down", true, true));		
		}
		
		
		private function onUp(event:*):void
		{	
			if (debug)
				trace("up");
			
			if (GestureWorks.supportsTouch)
				hitObject.removeEventListener(TouchEvent.TOUCH_END, onUp);
			else
				hitObject.removeEventListener(MouseEvent.MOUSE_UP, onUp);	
											
			for each (var state:* in buttonStates)
			{
				if (state != up)
					hideKey(state);	
			}
			
			showKey(buttonStates["up"]);
				
			if (down)
			{				
				if (GestureWorks.supportsTouch) {
					hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				}	
				else {
					hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);	
					hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onDown);	
				}
			}
			
			if (out)
			{				
				if (GestureWorks.supportsTouch) {
					hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
					hitObject.addEventListener(TouchEvent.TOUCH_OUT, onOut);
				}	
				else {
					hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);	
					hitObject.addEventListener(MouseEvent.MOUSE_OUT, onOut);	
				}
			}
			
			if (dispatchDict["up"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["up"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "up", true, true));		
		}		
		
		
		private function onOut(event:*):void
		{	
			if (debug)
				trace("out");
			
			if (GestureWorks.supportsTouch)
				hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
			else
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);	
											
			for each (var state:* in buttonStates)
			{
				if (state != out)
					hideKey(state);	
			}
			
			showKey(buttonStates["out"]);
			
			if (down)
			{				
				if (GestureWorks.supportsTouch) {
					hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				}	
				else {
					hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);	
					hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onDown);	
				}
			}
			
			if (dispatchDict["out"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["out"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "out", true, true));		
		}
		
		
	}
}