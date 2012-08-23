package com.gestureworks.cml.element
{	
	import com.gestureworks.cml.interfaces.IButton;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;	
	import flash.utils.Dictionary;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.GestureWorks;
	import org.tuio.TuioTouchEvent;

	public class ButtonElement extends Container implements IButton
	{
		public var debug:Boolean = false;		
		protected var buttonStates:Dictionary;		
		public var hitObject:*;
		public var dispatchDefault:Boolean = false;
		private var dispatchDict:Dictionary;		
		
		public function ButtonElement()
		{
			super();
			buttonStates = new Dictionary(true);
		}		
		
		
	override public function dispose():void
		{
			super.dispose();
			buttonStates = null;
			dispatchDict = null;	
			hitObject = null;
			
			if (over)
			{
			hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onOver);	
			hitObject = null;
			}
			if (mouseOver)
			{
			hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);	
			hitObject = null;
			}
			if (mouseDown)
			{
			hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			hitObject = null;
			}
			if (mouseUp)
			{
			hitObject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);												
			hitObject = null;
			}
			if (mouseOut)
			{
			hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);												
			hitObject = null;
			}
			if (up)
			{
			hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
			hitObject = null;
			}
			if(up)
			{
			hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
			hitObject.removeEventListener(TouchEvent.TOUCH_END, onUp);
			hitObject.removeEventListener(MouseEvent.MOUSE_UP, onUp);	
			hitObject = null;
			}
			if(out)
			{
			hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onUp);
			hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
			hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			hitObject = null;
			}
			if(down)
			{
			hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
			hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);	
			hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
			hitObject = null;
			}
			hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
			hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp);
		    hitObject.removeEventListener(TouchEvent.TOUCH_END, onTouchUp);	
		    hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onTouchOut);
				
		}

		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			// try to auto-find init
			if (!init && (childList.length > 0))
				init = childList.getIndex(0);			
			
			for each (var state:* in buttonStates)
			{
				if (state != init)
					hideKey(state);	
			}
				

			if (!hit && (childList.length > 0))
				hitObject = childList.getIndex(0) as DisplayObject;
			else
				hitObject = childList.getKey(hit);
			
			// float hit area to the top of the display list
			if (hitObject)
				addChildAt(hitObject, numChildren - 1);
			
			if (mouseOver)
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);	
			
			if (mouseDown)
				hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			if (touchDown && GestureWorks.activeTUIO)
				hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
			else if (touchDown)
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			
			if (over)
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onOver);
				
			if (down)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				else if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				else
					hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
						

			// toggle
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
				if (GestureWorks.activeTUIO)
					this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onToggle);
				else if (GestureWorks.supportsTouch)
					this.addEventListener(TouchEvent.TOUCH_BEGIN, onToggle);
				else
					this.addEventListener(MouseEvent.MOUSE_DOWN, onToggle);
			}
			else if (toggle == "up")
			{
				if (GestureWorks.activeTUIO)
					this.addEventListener(TuioTouchEvent.TOUCH_UP, onToggle);
				else if (GestureWorks.supportsTouch)
					this.addEventListener(TouchEvent.TOUCH_END, onToggle);
				else
					this.addEventListener(MouseEvent.MOUSE_UP, onToggle);					
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
			
			

			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i) is ButtonElement) {
					childList.getIndex(i).updateLayout();
					this.width = childList.getIndex(i).width ;
					this.height = childList.getIndex(i).height;
				}
			
			}	
			
		}

		
		private var _toggle:String = "";
		/**
		 * sets toggle event by string name:
		 * mouseOver, mouseDown, mouseUp, touchDown, touchUp, down, and up 
		 * (the last two auto-switch between input device)
		 * @default ""
		 */		
		public function get toggle():String {return _toggle}
		public function set toggle(value:String):void 
		{			
			_toggle = value;		
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
		
		private var _over:String;
		/**
		 * Sets button state association with over event (mouse only)
		 */		
		public function get over():String {return buttonStates["over"];}
		public function set over(value:String):void 
		{			
			buttonStates["over"] = value;
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
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseOver"], true, true));	
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
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);												
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
		
		
		private function onTouchDown(event:*):void
		{	
			if (debug)
				trace("touch down");
			
			if (GestureWorks.activeTUIO)	
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
			else 
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			
			for each (var state:* in buttonStates)
			{
				if (state != touchDown)
					hideKey(state);	
			}
			
			showKey(buttonStates["touchDown"]);
				
			if (touchUp)
			{
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp);
				}
				else {
					hitObject.removeEventListener(TouchEvent.TOUCH_END, onTouchUp);															
					hitObject.addEventListener(TouchEvent.TOUCH_END, onTouchUp);
				}															
			}
			
			if (touchOut)
			{
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onTouchOut);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OUT, onTouchOut);
				}
				else {
					hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onTouchOut);											
					hitObject.addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
				}
				
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
			
			if (GestureWorks.activeTUIO)
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onTouchUp);															
			else
				hitObject.removeEventListener(TouchEvent.TOUCH_END, onTouchUp);															
			
			for each (var state:* in buttonStates)
			{
				if (state != touchUp)
					hideKey(state);	
			}
			
			showKey(buttonStates["touchUp"]);
				
			if (touchDown)
			{
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);															
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
				}
				else {
					hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
				}
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
			
			if (GestureWorks.activeTUIO)
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onTouchOut);															
			else
				hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onTouchOut);															
			
			for each (var state:* in buttonStates)
			{
				if (state != touchOut)
					hideKey(state);	
			}
			
			showKey(buttonStates["touchOut"]);
			
			if (touchDown)
			{
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);															
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
				}
				else {
					hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);															
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
				}
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
			
			if (GestureWorks.activeTUIO)
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
			else if (GestureWorks.supportsTouch)
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
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_UP, onUp);
				}
				else if (GestureWorks.supportsTouch) {
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
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onUp);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OUT, onUp);
				}
				else if (GestureWorks.supportsTouch) {
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
		
		private function onOver(event:*):void
		{
			if (debug)			
				trace("over");											
			
			hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onOver);															
			
			for each (var state:* in buttonStates)
			{
				if (state != over)
					hideKey(state);	
			}				
	
			showKey(buttonStates["over"]);	
			
			if (out)
			{
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onOut);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OUT, onOut);	
				}
				else if (GestureWorks.supportsTouch) {
					hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
					hitObject.addEventListener(TouchEvent.TOUCH_OUT, onOut);
				}	
				else {
					hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);	
					hitObject.addEventListener(MouseEvent.MOUSE_OUT, onOut);	
				}
			}
			
			if (dispatchDict["over"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["over"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "over", true, true));					
											
		}	
		
		private function onUp(event:*):void
		{	
			if (debug)
				trace("up");
			
			if (GestureWorks.activeTUIO)
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
			else if (GestureWorks.supportsTouch)
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
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				}
				else if (GestureWorks.supportsTouch) {
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
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onOut);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OUT, onOut);	
				}
				else if (GestureWorks.supportsTouch) {
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
			
			if (GestureWorks.activeTUIO)
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onOut);
			else if (GestureWorks.supportsTouch)
				hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
			else
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);	
											
			for each (var state:* in buttonStates)
			{
				if (state != out)
					hideKey(state);	
			}
			
			showKey(buttonStates["out"]);
			
			if (over)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onOver);												
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			}
			
			if (down)
			{
				if (GestureWorks.activeTUIO) {
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				}
				else if (GestureWorks.supportsTouch) {
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
		
				
		private function onToggle(event:*):void
		{			
			if (childList.hasNext())
			{
				
				childList.currentValue.visible = false;
				childList.next().visible = true;
			}
			else
			{
				childList.currentValue.visible = false;				
				childList.reset();
				childList.currentValue.visible = true;			
			}
			
			
			//dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "toggle", cmlIndex, true, true));			
		}		
		
		
	}
}