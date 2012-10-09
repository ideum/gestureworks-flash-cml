package com.gestureworks.cml.element
{	
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.IButton;
	import com.gestureworks.core.GestureWorks;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.utils.Dictionary;
	import org.tuio.TuioTouchEvent;

    /**
	 * ButtonElement hides or shows DisplayObjects on specified state events.
	 * The available button states are initial, down, up, over and out.
	 * 
	 * 
	 * @author ...
	 */
	
	public class ButtonElement extends Container implements IButton
	{
		public var debug:Boolean = false;		
		protected var buttonStates:Dictionary;		
		public var hitObject:*;
		public var dispatchDefault:Boolean = false;
		private var dispatchDict:Dictionary;		
		
		/**
		 * Contructor
		 */
		public function ButtonElement()
		{
			super();
			buttonStates = new Dictionary(true);
		}		
		
		/**
		 * Initialization function
		 */
		public function init():void
		{
			// try to auto-find initital
			if (!initial && (childList.length > 0))
				initial = childList.getIndex(0);			
			
			for each (var state:* in buttonStates)
			{
				if (state != initial)
					hideKey(state);	
			}				

			if (!hit && (childList.length > 0))
				hitObject = childList.getIndex(0) as DisplayObject;
			else
				hitObject = childList.getKey(hit);

			// float hit area to the top of the display list
			if (hitObject)
				addChildAt(hitObject, numChildren - 1);
			
			//initial mouse events	
			if (mouseOver)
				hitObject.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);				
			if (mouseDown)
				hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
			//inital touch events	
			if (touchDown && GestureWorks.activeTUIO)
				hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
			else if (touchDown)
				hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			
			//initial auto events
			if (down)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				else if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				else
					hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}			
			if (over)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
				else if(GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_OVER, onOver);			
				else
					hitObject.addEventListener(MouseEvent.MOUSE_OVER, onOver);
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

		/**
		 * CML display initialization callback
		 */
		override public function displayComplete():void
		{
			init();
		}
		
		/**
		 * sets the dimensions
		 */
		public function updateLayout():void
		{								
			// we need containers to automatically take on the dimensions of the largest child, so I don't have to do this!!
			if (childList.getKey(buttonStates["initial"]) is Container)
			{
				if (childList.getKey(buttonStates["initial"]).width == 0)
				{
					for each (var item:* in childList.getKey(buttonStates["initial"]).childList.getValueArray()) 
					{
						if (item.hasOwnProperty("width"))
						{							
							if (item.width > this.width)
								this.width = item.width;								
						}						
					}
				}
				
				if (childList.getKey(buttonStates["initial"]).height == 0)
				{
					for each (var item2:* in childList.getKey(buttonStates["initial"]).childList.getValueArray()) 
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
		
		
		private var _hit:*;
		/**
		 * Sets hit object
		 */
		public function get hit():* {return _hit;}
		public function set hit(value:*):void 
		{
			if (value is DisplayObject)
			{
				_hit = "hit_area";
				childToList(_hit, value);
				addChild(value);
			}
			else
			{
				_hit = value.toString();
			}
		}		
				
		
		private var _initial:*;
		/**
		 * Sets button state association with mouse down event
		 */
		public function get initial():* {return _initial;}
		public function set initial(value:*):void 
		{
			if (value is DisplayObject)
			{
				_initial = "initial";
				childToList(_initial, value);
				addChild(value);
				buttonStates[_initial] = _initial;
			}
			else
			{
				value = value.toString();
				_initial = value;
				buttonStates["initial"] = value;						
			}
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
		
		
		private var _down:*;
		/**
		 * Sets button state association with down event
		 */		
		public function get down():* {return _down;}
		public function set down(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_down = "down";
				childToList(_down, value);
				addChild(value);
				buttonStates[_down] = _down;
			}
			else
			{
				value = value.toString();
				_down = value;
				buttonStates["down"] = value;						
			}			
		}
		
		private var _over:*;
		/**
		 * Sets button state association with over event (mouse only)
		 */		
		public function get over():* {return _over;}
		public function set over(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_over = "over";
				childToList(_over, value);
				addChild(value);
				buttonStates[_over] = _over;
			}
			else
			{
				value = value.toString();
				_over = value;
				buttonStates["over"] = value;						
			}			
		}
		
		
		private var _up:*;
		/**
		 * Sets button state association with up event
		 */		
		public function get up():String {return _up;}
		public function set up(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_up = "up";
				childToList(_up, value);
				addChild(value);
				buttonStates[_up] = _up;
			}
			else
			{
				value = value.toString();
				_up = value;
				buttonStates["up"] = value;						
			}			
		}			

		
		private var _out:*;
		/**
		 * Sets button state association with out event
		 */		
		public function get out():* {return _out;}
		public function set out(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_out = "out";
				childToList(_out, value);
				addChild(value);
				buttonStates[_out] = _out;
			}
			else
			{
				value = value.toString();
				_out = value;
				buttonStates["out"] = value;						
			}			
		}
		
		
		
		////////////////////////////////////////////////////
		/// MOUSE EVENT HANDLERS
		///////////////////////////////////////////////////
		
		
		protected function onMouseDown(event:MouseEvent):void
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
		
		
		protected function onMouseUp(event:MouseEvent):void
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
		
		
		protected function onMouseOver(event:MouseEvent):void
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
		
				
		protected function onMouseOut(event:MouseEvent):void
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
		
		
		protected function onTouchDown(event:*):void
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
		
		
		protected function onTouchUp(event:TouchEvent):void
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
		
		
		protected function onTouchOut(event:TouchEvent):void
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
		
		protected function onDown(event:*):void
		{	
			if (debug)
				trace("down");
				
			listenDown(false);																				
			for each (var state:* in buttonStates)
			{
				if (state != down)
					hideKey(state);	
			}
			
			showKey(buttonStates["down"]);
				
			//listen for up event to proceed down event
			if (up)
				listenUp();
				
			//listen for out event
			if (out)
				listenOut();
			
			//prevent over event from executing after down event
			if (over)
				listenOver(false);
			
			if (dispatchDict["down"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["down"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "down", true, true));		
		}
		
		protected function onOver(event:*):void
		{						
			if (debug)			
				trace("over");											
																		
			listenOver(false);
			for each (var state:* in buttonStates)
			{
				if (state != over)
					hideKey(state);	
			}				
	
			showKey(buttonStates["over"]);	
			
			//listen for up event
			if (up)
				listenUp();
			
			//listen for out event to proceed over event
			if (out)
				listenOut();
						
			if (dispatchDict["over"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["over"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "over", true, true));					
											
		}	
		
		protected function onUp(event:*):void
		{	
			if (debug)
				trace("up");
			
			listenUp(false);								
			for each (var state:* in buttonStates)
			{
				if (state != up)
					hideKey(state);	
			}
			
			showKey(buttonStates["up"]);
				
			//listen for down event
			if (down)
				listenDown();
			
			//listen for over events
			if (over)
				listenOver();
			
			//prevent out event from proceeding up event
			if (out)
				listenOut(false);
			
			if (dispatchDict["up"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["up"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "up", true, true));		
		}		
				
		protected function onOut(event:*):void
		{	
			if (debug)
				trace("out");
			
			listenOut(false);											
			for each (var state:* in buttonStates)
			{
				if (state != out)
					hideKey(state);	
			}
			
			showKey(buttonStates["out"]);
			
			//listen for over events
			if (over)
				listenOver();
			
			//listen for down events
			if (down)
				listenDown();
			
			if (dispatchDict["out"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["out"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "out", true, true));		
		}
		
		private function listenDown(listen:Boolean = true):void
		{
			if (listen)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				else if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				else
					hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onDown);			
			}
			else
			{
				if (GestureWorks.activeTUIO)
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				else if (GestureWorks.supportsTouch)
					hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				else
					hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);					
			}
		}
			
		private function listenUp(listen:Boolean = true):void
		{
			if (listen)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_UP, onUp);
				else if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_END, onUp);
				else
					hitObject.addEventListener(MouseEvent.MOUSE_UP, onUp);				
			}
			else
			{
				if (GestureWorks.activeTUIO)
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
				else if (GestureWorks.supportsTouch)
					hitObject.removeEventListener(TouchEvent.TOUCH_END, onUp);
				else
					hitObject.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			}
		}
		
		private function listenOver(listen:Boolean = true):void
		{
			if (listen)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
				else if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_OVER, onOver);
				else
					hitObject.addEventListener(MouseEvent.MOUSE_OVER, onOver);							
			}
			else
			{
				if (GestureWorks.activeTUIO)
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
				else if (GestureWorks.supportsTouch)
					hitObject.removeEventListener(TouchEvent.TOUCH_OVER, onOver);
				else
					hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onOver);					
			}
		}		
		
		private function listenOut(listen:Boolean = true):void
		{
			if (listen)
			{
				if (GestureWorks.activeTUIO)
					hitObject.addEventListener(TuioTouchEvent.TOUCH_OUT, onOut);
				else if (GestureWorks.supportsTouch)
					hitObject.addEventListener(TouchEvent.TOUCH_OUT, onOut);
				else
				hitObject.addEventListener(MouseEvent.MOUSE_OUT, onOut);										
			}
			else
			{
				if (GestureWorks.activeTUIO)
					hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onOut);
				else if (GestureWorks.supportsTouch)
					hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
				else
					hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);					
			}
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
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			buttonStates = null;
			dispatchDict = null;						
			
			if (hitObject)
			{
				hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
				hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				hitObject.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);				
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onOver);	
				hitObject.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
				hitObject.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				hitObject.removeEventListener(MouseEvent.MOUSE_UP, onUp);
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);			
				hitObject.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
				hitObject.removeEventListener(TouchEvent.TOUCH_END, onTouchUp);
				hitObject.removeEventListener(TouchEvent.TOUCH_END, onUp);
				hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onOut);
				hitObject.removeEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
				hitObject.removeEventListener(TouchEvent.TOUCH_OVER, onOver);			
				hitObject.removeEventListener(TouchEvent.TOUCH_OVER, onOver);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onOut);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_OUT, onTouchOut);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onTouchUp);
				hitObject.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);		
				hitObject = null;
			}
			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onToggle);			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onToggle);
			this.removeEventListener(MouseEvent.MOUSE_OVER, onToggle);				
			this.removeEventListener(MouseEvent.MOUSE_UP, onToggle);		
			this.removeEventListener(MouseEvent.MOUSE_UP, onToggle);	
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onToggle);
			this.removeEventListener(TouchEvent.TOUCH_END, onToggle);
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onToggle);
			this.removeEventListener(TuioTouchEvent.TOUCH_UP, onToggle);			
		}
		
		
	}
}