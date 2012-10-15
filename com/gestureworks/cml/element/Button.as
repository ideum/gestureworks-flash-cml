package com.gestureworks.cml.element
{	
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.core.GestureWorks;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.utils.Dictionary;
	import org.tuio.TuioTouchEvent;

    /**
	 * The Button hides or shows DisplayObjects on specified state events. The available button states are exclusive touch states, exclusive mouse states, and auto-states.
	 * Mouse states are triggered by <code>MouseEvent</code> events and touch states are triggered by <code>TuioTouchEvent</code> and <code>TouchEvent</code> event types. Auto-states
	 * automate the registration of event types based on system properties. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 			
		var button:Button = new Button();			
		button.x = 750;
		button.y = 200;
		button.dispatch = "initial:initial:down:down:up:up:over:over:out:out";
		button.addEventListener(StateEvent.CHANGE, buttonState);			
		
		//assign a different color to each button state
		button.hit = getCircle(0x000000, 0);;  //hit area
		button.initial = getCircle(0xFFFFFF);  //white
		button.down = getCircle(0x0000FF);     //blue
		button.up = getCircle(0xFF0000);       //red
		button.over = getCircle(0x00FF00);     //green
		button.out = getCircle(0xFF00FF);      //purple
		
		button.init();
		addChild(button);
					
		//displays the current button state
		text = new Text();
		text.x = 810;
		text.y = 420;
		text.text = "initial";
		text.autoSize = "center";
		text.fontSize = 50;
		text.textColor = 0xFFFFFF;
		addChild(text);
		
		
		function getCircle(color:uint, alpha:Number = 1):Graphic
		{
			var circle:Graphic = new Graphic();
			circle.shape = "circle";
			circle.radius = 100;
			circle.color = color;
			circle.alpha = alpha;
			circle.lineStroke = 0;
			return circle;
		}
		
		
		function buttonState(e:StateEvent):void
		{
			text.text = e.value;
		}

	 * </codeblock>
	 * @author Ideum
	 */
	public class Button extends Container
	{
		public var debug:Boolean = false;		
		protected var buttonStates:Array;		
		public var dispatchDefault:Boolean = false;
		private var dispatchDict:Dictionary;
		private var buttonId:int = 0;
		
		/**
		 * Contructor
		 */
		public function Button()
		{
			super();
			buttonStates = new Array();
		}		
		
		/**
		 * Initialization function
		 */
		public function init():void
		{
			//initialize toggle listener
			if (toggle)
			{
				listenToggle();
				for (var i:int = 1; i < childList.length; i++)
					childList.getIndex(i).visible = false;
				return; //if toggle is used, bypass state events
			}
			
			// try to auto-find initital and hit
			if (!initial && (childList.length > 0))
				initial = childList.getIndex(0);			
			if (!hit && (childList.length > 0))
				hit = childList.getIndex(0) as DisplayObject;				
			
			//hide all but initial state
			for each(var state:* in buttonStates)
			{
				if (state != initial)
					state.visible = false;	
			}				

			// float hit area to the top of the display list
			if (hit)
				addChildAt(hit, numChildren - 1);
				
			//initialize auto listeners 
			if (down) listenDown();
			if (over) listenOver();
			
			//initaialize exclusive touch listeners
			if (touchDown) listenTouchDown();
			if (touchOver) listenTouchOver();
			
			//initialize exclusive mouse listeners
			if (mouseDown) listenMouseDown();
			if (mouseOver) listenMouseOver();
						
			updateLayout();
		}

		override public function displayComplete():void
		{
			init();
		}
		
		/**
		 * Adds child to display list and, if not already added, the child list
		 * TODO: This mechanism should be abstracted to better syncrhonize child and display lists  
		 * @param	child
		 * @return
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{
			if (!childList.search(child))
				childToList("button_" + buttonId++, child);
			
			return super.addChild(child);
		}
		
		/**
		 * Adds or removes a listener based on the value of the <code>add</code> flag
		 * @param	type  the type of event
		 * @param	listener  the listener function that processes the event
		 * @param	add  the flag indicating to add or remove the event
		 * @param	obj  the object to add/remove the event to/from, defaults to this object
		 */
		private function addListener(type:String, listener:Function, add:Boolean=true, obj:*=null):void
		{
			if (!obj) obj = this;
			if (add)
				obj.addEventListener(type, listener);
			else
				obj.removeEventListener(type, listener);
		}
		
		/**
		 * Updates dimensions
		 */
		public function updateLayout():void
		{								
			sizeToChildren();			
		}
		
		/**
		 * Recursively accesses the children of the button element hierarchy and sets its dimensions to the maximum child dimensions.
		 * NOTE: This funcition will be unceccessary when containers automatically resize to children.
		 * @param	obj
		 */
		private function sizeToChildren(obj:* = null):void
		{
			if (!obj) 
				obj = this;	
			
			if (!obj.hasOwnProperty("numChildren"))
				return;
			
			for (var i:int = 0; i < obj.numChildren; i++)
			{
				var child:* = obj.getChildAt(i);
				
				if (child is Button) child.updateLayout();
				
				if (child.hasOwnProperty("width") && (child.width > this.width))
					this.width = child.width;
					
				if (child.hasOwnProperty("height") && (child.height > this.height))
					this.height = child.height;
					
				sizeToChildren(child);
			}
		}
		
		private var _toggle:String;		
		/**
		 * An alternative to button state events, the toggle displays the next child at each event defined by the 
		 * <code>toggle</code> value (e.g. toggle="up" or toggle="mouseDown"). Setting the toggle value bypasses the 
		 * button state events. The original intention of the toggle mechanism, was to allow a button element to house 
		 * multiple button elements and toggle between them without interfering with their individual states. 
		 */
		public function get toggle():String {return _toggle}
		public function set toggle(value:String):void 
		{			
			if (_toggle)
				listenToggle(false);
			_toggle = value;
		}	
										
		private var _dispatch:String;		
		/**
		 * Assigns a message to dispatch with a button state event. The value is a colon-delimited string defining
		 * events and associated messages (e.g. "down:button is down:up:button is up").
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
		 * The hit object is the object recieving the input events
		 */
		public function get hit():* {return _hit;}
		public function set hit(value:*):void 
		{
			if (value is DisplayObject)
			{
				_hit = value;
				addChild(value);
			}
			else
			{
				value = value.toString();
				_hit = childList.getKey(value);
			}
		}		
				
		
		private var _initial:*;
		/**
		 * Sets the initial button state object
		 */
		public function get initial():* {return _initial;}
		public function set initial(value:*):void 
		{
			if (value is DisplayObject)
			{
				_initial = value;
				addChild(_initial);
				buttonStates.push(_initial);
			}
			else
			{
				value = value.toString();
				_initial = childList.getKey(value);
				buttonStates.push(_initial);						
			}
		}
		
		
		////////////////////////////////////////////////////
		/// MOUSE STATES
		///////////////////////////////////////////////////					
		
		private var _mouseDown:*;
		/**
		 * Sets button state association with mouse down event
		 */
		public function get mouseDown():* {return _mouseDown;}
		public function set mouseDown(value:*):void 
		{
			if (value is DisplayObject)
			{
				_mouseDown = value;
				addChild(_mouseDown);
				buttonStates.push(_mouseDown);
			}
			else
			{
				value = value.toString();
				_mouseDown = childList.getKey(value);
				buttonStates.push(_mouseDown);						
			}	
		}
		
		
		private var _mouseUp:*;
		/**
		 * Sets button state association with mouse up event
		 */		
		public function get mouseUp():* {return _mouseUp;}
		public function set mouseUp(value:*):void 
		{
			if (value is DisplayObject)
			{
				_mouseUp = value;
				addChild(_mouseUp);
				buttonStates.push(_mouseUp);
			}
			else
			{
				value = value.toString();
				_mouseUp = childList.getKey(value);
				buttonStates.push(_mouseUp);						
			}										
		}		
		
		private var _mouseOver:*;
		/**
		 * Sets button state association with mouse over event
		 */		
		public function get mouseOver():* {return _mouseOver;}
		public function set mouseOver(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_mouseOver = value;
				addChild(_mouseOver);
				buttonStates.push(_mouseOver);
			}
			else
			{
				value = value.toString();
				_mouseOver = childList.getKey(value);
				buttonStates.push(_mouseOver);						
			}
		}
		
		private var _mouseOut:*;
		/**
		 * Sets button state association with mouse out event
		 */		
		public function get mouseOut():* {return _mouseOut;}
		public function set mouseOut(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_mouseOut = value;
				addChild(_mouseOut);
				buttonStates.push(_mouseOut);
			}
			else
			{
				value = value.toString();
				_mouseOut = childList.getKey(value);
				buttonStates.push(_mouseOut);						
			}												
		}			
		
		
		////////////////////////////////////////////////////
		/// TOUCH STATES
		///////////////////////////////////////////////////		
		
		
		private var _touchDown:*;
		/**
		 * Sets button state association with touch down event
		 */		
		public function get touchDown():* {return _touchDown;}
		public function set touchDown(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_touchDown = value;				
				addChild(_touchDown);
				buttonStates.push(_touchDown);
			}
			else
			{
				value = value.toString();
				_touchDown = childList.getKey(value);
				buttonStates.push(_touchDown);						
			}
		}
		
		
		private var _touchUp:*;
		/**
		 * Sets button state association with touch up event
		 */		
		public function get touchUp():* {return _touchUp;}
		public function set touchUp(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_touchUp = value;				
				addChild(_touchUp);
				buttonStates.push(_touchUp);
			}
			else
			{
				value = value.toString();
				_touchUp = childList.getKey(value);
				buttonStates.push(_touchUp);						
			}
		}			
		
		private var _touchOver:*;
		/**
		 * Sets button state association with touch out event
		 */		
		public function get touchOver():* {return _touchOver;}
		public function set touchOver(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_touchOver = value;				
				addChild(_touchOver);
				buttonStates.push(_touchOver);
			}
			else
			{
				value = value.toString();
				_touchOver = childList.getKey(value);
				buttonStates.push(_touchOver);						
			}
		}		
		
		private var _touchOut:*;
		/**
		 * Sets button state association with touch out event
		 */		
		public function get touchOut():* {return _touchOut;}
		public function set touchOut(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_touchOut = value;				
				addChild(_touchOut);
				buttonStates.push(_touchOut);
			}
			else
			{
				value = value.toString();
				_touchOut = childList.getKey(value);
				buttonStates.push(_touchOut);						
			}
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
				_down = value;				
				addChild(_down);
				buttonStates.push(_down);
			}
			else
			{
				value = value.toString();
				_down = childList.getKey(value);
				buttonStates.push(_down);						
			}	
		}
				
		private var _up:*;
		/**
		 * Sets button state association with up event
		 */		
		public function get up():* {return _up;}
		public function set up(value:*):void 
		{			
			if (value is DisplayObject)
			{
				_up = value;
				addChild(_up);
				buttonStates.push(_up);
			}
			else
			{
				value = value.toString();
				_up = childList.getKey(value);
				buttonStates.push(_up);						
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
				_over = value;
				addChild(_over);				
				buttonStates.push(_over);
			}
			else
			{
				value = value.toString();
				_over = childList.getKey(value);
				buttonStates.push(_over);						
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
				_out = value;
				addChild(_out);
				buttonStates.push(_out);
			}
			else
			{
				value = value.toString();
				_out = childList.getKey(value);
				buttonStates.push(_out);						
			}			
		}
		
		
		
		////////////////////////////////////////////////////
		/// MOUSE EVENT HANDLERS
		///////////////////////////////////////////////////			
		
		/**
		 * Processes the mouse down event by displaying the mouseDown state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the mouse down event
		 */
		protected function onMouseDown(event:*):void
		{	
			if (debug)
				trace("mouseDown");
				
			listenMouseDown(false);																				
			for each(var state:* in buttonStates)
			{
				if (state != mouseDown)
					state.visible = false;
			}
			
			mouseDown.visible = true;
				
			//listen for mouseUp event to proceed mouseDown event
			if (mouseUp)
				listenMouseUp();
				
			//listen for mouseOut event
			if (mouseOut)
				listenMouseOut();
			
			//prevent mouseOver event from executing after mouseDown event
			if (mouseOver)
				listenMouseOver(false);
			
			if (dispatchDict["mouseDown"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseDown"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseDown", true, true));		
		}
		
		/**
		 * Processes the mouse up event by displaying the mouseUp state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the mouse up event
		 */			
		protected function onMouseUp(event:*):void
		{	
			if (debug)
				trace("mouseUp");
			
			listenMouseUp(false);								
			for each(var state:* in buttonStates)
			{
				if (state != mouseUp)
					state.visible = false;	
			}
			
			mouseUp.visible = true;
				
			//listen for mouseDown event
			if (mouseDown)
				listenMouseDown();
			
			//listen for mouseOver events
			if (mouseOver)
				listenMouseOver();
			
			//prevent mouseOut event from proceeding mouseUp event
			if (mouseOut)
				listenMouseOut(false);
			
			if (dispatchDict["mouseUp"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseUp"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseUp", true, true));		
		}
		
		/**
		 * Processes the mouse over event by displaying the mouseOver state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the mouse over event
		 */		
		protected function onMouseOver(event:*):void
		{						
			if (debug)			
				trace("mouseOver");											
																		
			listenMouseOver(false);
			for each(var state:* in buttonStates)
			{
				if (state != mouseOver)
					state.visible = false;	
			}				
	
			mouseOver.visible = true;	
			
			//listen for mouseUp event
			if (mouseUp)
				listenMouseUp();
			
			//listen for mouseOut event to proceed mouseOver event
			if (mouseOut)
				listenMouseOut();
						
			if (dispatchDict["mouseOver"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseOver"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseOver", true, true));					
											
		}			
				
		/**
		 * Processes the mouse out event by displaying the mouseOut state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the mouse out event
		 */			
		protected function onMouseOut(event:*):void
		{	
			if (debug)
				trace("mouseOut");
			
			listenMouseOut(false);											
			for each(var state:* in buttonStates)
			{
				if (state != mouseOut)
					state.visible = false;	
			}
			
			mouseOut.visible = true;
			
			//listen for mouseOver events
			if (mouseOver)
				listenMouseOver();
			
			//listen for mouseDown events
			if (mouseDown)
				listenMouseDown();
			
			if (dispatchDict["mouseOut"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["mouseOut"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "mouseOut", true, true));		
		}
		
		/**
		 * Enables ore disables mouse down events
		 * @param	listen  adds mouse listener if true, removes if false
		 */
		private function listenMouseDown(listen:Boolean = true):void
		{
			addListener(MouseEvent.MOUSE_DOWN, onMouseDown, listen, hit);			
		}

		/**
		 * Enables ore disables mouse up events
		 * @param	listen  adds mouse listener if true, removes if false
		 */		
		private function listenMouseUp(listen:Boolean = true):void
		{
			addListener(MouseEvent.MOUSE_UP, onMouseUp, listen, hit);				
		}
		
		/**
		 * Enables ore disables mouse over events
		 * @param	listen  adds mouse listener if true, removes if false
		 */		
		private function listenMouseOver(listen:Boolean = true):void
		{
			addListener(MouseEvent.MOUSE_OVER, onMouseOver, listen, hit);							
		}		
		
		/**
		 * Enables ore disables mouse out events
		 * @param	listen  adds mouse listener if true, removes if false
		 */		
		private function listenMouseOut(listen:Boolean = true):void
		{
			addListener(MouseEvent.MOUSE_OUT, onMouseOut, listen, hit);														
		}		
				

		////////////////////////////////////////////////////
		/// TOUCH EVENT HANDLERS
		///////////////////////////////////////////////////
		
		/**
		 * Processes the touch down event by displaying the touchDown state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the touch down event
		 */		
		protected function onTouchDown(event:*):void
		{	
			if (debug)
				trace("touchDown");
				
			listenTouchDown(false);																				
			for each(var state:* in buttonStates)
			{
				if (state != touchDown)
					state.visible = false;
			}
			
			touchDown.visible = true;
				
			//listen for touchUp event to proceed touchDown event
			if (touchUp)
				listenTouchUp();
				
			//listen for touchOut event
			if (touchOut)
				listenTouchOut();
			
			//prevent touchOver event from executing after touchDown event
			if (touchOver)
				listenTouchOver(false);
			
			if (dispatchDict["touchDown"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchDown"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchDown", true, true));		
		}
		
		/**
		 * Processes the touch over event by displaying the touchOver state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the touch over event
		 */				
		protected function onTouchOver(event:*):void
		{						
			if (debug)			
				trace("touchOver");											
																		
			listenTouchOver(false);
			for each(var state:* in buttonStates)
			{
				if (state != touchOver)
					state.visible = false;	
			}				
	
			touchOver.visible = true;	
			
			//listen for touchUp event
			if (touchUp)
				listenTouchUp();
			
			//listen for touchOut event to proceed touchOver event
			if (touchOut)
				listenTouchOut();
						
			if (dispatchDict["touchOver"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchOver"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchOver", true, true));					
											
		}	
		
		/**
		 * Processes the touch up event by displaying the touchUp state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the touch up event
		 */				
		protected function onTouchUp(event:*):void
		{	
			if (debug)
				trace("touchUp");
			
			listenTouchUp(false);								
			for each(var state:* in buttonStates)
			{
				if (state != touchUp)
					state.visible = false;	
			}
			
			touchUp.visible = true;
				
			//listen for touchDown event
			if (touchDown)
				listenTouchDown();
			
			//listen for touchOver events
			if (touchOver)
				listenTouchOver();
			
			//prevent touchOut event from proceeding touchUp event
			if (touchOut)
				listenTouchOut(false);
			
			if (dispatchDict["touchUp"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchUp"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchUp", true, true));		
		}		
			
		/**
		 * Processes the touch out event by displaying the touchOut state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the touch out event
		 */				
		protected function onTouchOut(event:*):void
		{	
			if (debug)
				trace("touchOut");
			
			listenTouchOut(false);											
			for each(var state:* in buttonStates)
			{
				if (state != touchOut)
					state.visible = false;	
			}
			
			touchOut.visible = true;
			
			//listen for touchOver events
			if (touchOver)
				listenTouchOver();
			
			//listen for touchDown events
			if (touchDown)
				listenTouchDown();
			
			if (dispatchDict["touchOut"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["touchOut"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "touchOut", true, true));		
		}
		
		/**
		 * Enables ore disables touch down events
		 * @param	listen  adds touch listener if true, removes if false
		 */				
		private function listenTouchDown(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_DOWN, onTouchDown, listen, hit);
			else 
				addListener(TouchEvent.TOUCH_BEGIN, onTouchDown, listen, hit);			
		}

		/**
		 * Enables ore disables touch up events
		 * @param	listen  adds touch listener if true, removes if false
		 */						
		private function listenTouchUp(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_UP, onTouchUp, listen, hit);
			else 
				addListener(TouchEvent.TOUCH_END, onTouchUp, listen, hit);
		}
		
		/**
		 * Enables ore disables touch over events
		 * @param	listen  adds touch listener if true, removes if false
		 */						
		private function listenTouchOver(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_OVER, onTouchOver, listen, hit);
			else 
				addListener(TouchEvent.TOUCH_OVER, onTouchOver, listen, hit);
		}		
		
		/**
		 * Enables ore disables touch out events
		 * @param	listen  adds touch listener if true, removes if false
		 */						
		private function listenTouchOut(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_OUT, onTouchOut, listen, hit);
			else 
				addListener(TouchEvent.TOUCH_OUT, onTouchOut, listen, hit);								
		}

		////////////////////////////////////////////////////
		/// AUTO EVENT HANDLERS
		///////////////////////////////////////////////////
		
		/**
		 * Processes the down event by displaying the down state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the down event
		 */				
		protected function onDown(event:*):void
		{	
			if (debug)
				trace("down");
				
			listenDown(false);																				
			for each(var state:* in buttonStates)
			{
				if (state != down)
					state.visible = false;
			}
			
			down.visible = true;
				
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
		
		/**
		 * Processes the over event by displaying the over state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the over event
		 */			
		protected function onOver(event:*):void
		{						
			if (debug)			
				trace("over");											
																		
			listenOver(false);
			for each(var state:* in buttonStates)
			{
				if (state != over)
					state.visible = false;	
			}				
	
			over.visible = true;	
			
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
		
		/**
		 * Processes the down event by displaying the up state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the up event
		 */			
		protected function onUp(event:*):void
		{	
			if (debug)
				trace("up");
			
			listenUp(false);								
			for each(var state:* in buttonStates)
			{
				if (state != up)
					state.visible = false;	
			}
			
			up.visible = true;
				
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
			
		/**
		 * Processes the out event by displaying the out state and hiding the other states. Enables
		 * and disables appropriate listeners to control event flow.
		 * @param	event  the out event
		 */			
		protected function onOut(event:*):void
		{	
			if (debug)
				trace("out");
			
			listenOut(false);											
			for each(var state:* in buttonStates)
			{
				if (state != out)
					state.visible = false;	
			}
			
			out.visible = true;
			
			//listen for over events
			if (over)
				listenOver();
			
			//listen for down events
			if (out)
				listenDown();
			
			if (dispatchDict["out"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", dispatchDict["out"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "buttonState", "out", true, true));		
		}
		
		/**
		 * Enables ore disables touch/mouse down events
		 * @param	listen  adds touch/mouse listener if true, removes if false
		 */			
		private function listenDown(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_DOWN, onDown, listen, hit);
			else if (GestureWorks.supportsTouch)
				addListener(TouchEvent.TOUCH_BEGIN, onDown, listen, hit);
			else
				addListener(MouseEvent.MOUSE_DOWN, onDown, listen, hit);			

		}
		
		/**
		 * Enables ore disables touch/mouse up events
		 * @param	listen  adds touch/mouse listener if true, removes if false
		 */					
		private function listenUp(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_UP, onUp, listen, hit);
			else if (GestureWorks.supportsTouch)
				addListener(TouchEvent.TOUCH_END, onUp, listen, hit);
			else
				addListener(MouseEvent.MOUSE_UP, onUp, listen, hit);				
		}
		
		/**
		 * Enables ore disables touch/mouse over events
		 * @param	listen  adds touch/mouse listener if true, removes if false
		 */					
		private function listenOver(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_OVER, onOver, listen, hit);
			else if (GestureWorks.supportsTouch)
				addListener(TouchEvent.TOUCH_OVER, onOver, listen, hit);
			else
				addListener(MouseEvent.MOUSE_OVER, onOver, listen, hit);							
		}		
		
		/**
		 * Enables ore disables touch/mouse out events
		 * @param	listen  adds touch/mouse listener if true, removes if false
		 */					
		private function listenOut(listen:Boolean = true):void
		{
			if (GestureWorks.activeTUIO)
				addListener(TuioTouchEvent.TOUCH_OUT, onOut, listen, hit);
			else if (GestureWorks.supportsTouch)
				addListener(TouchEvent.TOUCH_OUT, onOut, listen, hit);
			else
				addListener(MouseEvent.MOUSE_OUT, onOut, listen, hit);										
		}
			
		
		////////////////////////////////////////////////////
		/// TOGGLE EVENT HANDLER
		///////////////////////////////////////////////////
		
		/**
		 * Displays the the next child on the specified button event. If toggle is used, 
		 * the button states are ignored. 
		 * @param	event
		 */
		protected function onToggle(event:*):void
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
			
			if (dispatchDict["toggle"])
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "toggle", dispatchDict["toggle"], true, true));	
			else if (dispatchDefault)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "toggle", "toggle", true, true));			
		}
		
		/**
		 * Enables ore disables touch/mouse events
		 * @param	listen  adds touch/mouse listener if true, removes if false
		 */					
		private function listenToggle(listen:Boolean = true):void
		{
			if (!toggle) return;			
			switch(toggle)
			{
				case "mouseDown":
					addListener(MouseEvent.MOUSE_DOWN, onToggle, listen);
					break;
				case "mouseUp":
					addListener(MouseEvent.MOUSE_UP, onToggle, listen);
					break;
				case "mouseOver":
					addListener(MouseEvent.MOUSE_OVER, onToggle, listen);
					break;
				case "mouseOut":
					addListener(MouseEvent.MOUSE_OUT, onToggle, listen);
					break;	
				case "touchDown":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_DOWN, onToggle, listen);
					else
						addListener(TouchEvent.TOUCH_BEGIN, onToggle, listen);
					break;
				case "touchUp":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_UP, onToggle, listen);
					else
						addListener(TouchEvent.TOUCH_END, onToggle, listen);
					break;
				case "touchOver":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_OVER, onToggle, listen);
					else
						addListener(TouchEvent.TOUCH_OVER, onToggle, listen);
					break;
				case "touchOut":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_OUT, onToggle, listen);
					else
						addListener(TouchEvent.TOUCH_OUT, onToggle, listen);
					break;	
				case "down":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_DOWN, onToggle, listen);
					else if (GestureWorks.supportsTouch)
						addListener(TouchEvent.TOUCH_BEGIN, onToggle, listen);
					else
						addListener(MouseEvent.MOUSE_DOWN, onToggle, listen);
					break;
				case "up":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_UP, onToggle, listen);
					else if (GestureWorks.supportsTouch)
						addListener(TouchEvent.TOUCH_END, onToggle, listen);
					else
						addListener(MouseEvent.MOUSE_UP, onToggle, listen);
					break;
				case "over":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_OVER, onToggle, listen);
					else if (GestureWorks.supportsTouch)
						addListener(TouchEvent.TOUCH_OVER, onToggle, listen);
					else
						addListener(MouseEvent.MOUSE_OVER, onToggle, listen);
					break;
				case "out":
					if (GestureWorks.activeTUIO)
						addListener(TuioTouchEvent.TOUCH_OUT, onToggle, listen);
					else if (GestureWorks.supportsTouch)
						addListener(TouchEvent.TOUCH_OUT, onToggle, listen);
					else
						addListener(MouseEvent.MOUSE_OUT, onToggle, listen);
					break;
				default:
					break;
			}			
		}
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			buttonStates = null;
			dispatchDict = null;
			mouseDown = null;
			mouseUp = null;
			mouseOver = null;
			mouseOut = null;
			touchDown = null;
			touchUp = null;
			touchOver = null;
			touchOut = null;
			down = null;
			up = null;
			over = null;
			out = null;
			
			if (hit)
			{
				listenMouseDown(false);
				listenMouseUp(false);
				listenMouseOver(false);
				listenMouseOut(false);
				listenTouchDown(false);
				listenTouchUp(false);
				listenTouchOver(false);
				listenTouchOut(false);
				listenDown(false);
				listenUp(false);
				listenOver(false);
				listenOut(false);				
				hit = null;
			}
			
			listenToggle(false);
		}
		
		
	}
}