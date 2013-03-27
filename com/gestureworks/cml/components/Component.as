package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.Frame;
	import com.gestureworks.cml.element.Graphic;
	import com.gestureworks.cml.element.Menu;
	import com.gestureworks.cml.element.ScrollPane;
	import com.gestureworks.cml.element.Text;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	import org.tuio.TuioTouchEvent;


	/**
	 * The Component manages a group of elements to create a high-level interactive touch container.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 
			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.element.TouchContainer
	 */	
	public class Component extends TouchContainer 
	{	
		public var textFields:Array;	
		public var fontArray:Array = new Array();
		private var timer:Timer;
		private var tween:TweenLite;
		private var _activity:Boolean = false;
		
		/**
		 * component Constructor
		 */
		public function Component() 
		{
			super();
			TweenPlugin.activate([GlowFilterPlugin]);
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{	
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			if (!menu)
				menu = searchChildren(Menu);
			if (!frame)
				frame = searchChildren(Frame);
			if (!background && back && back.hasOwnProperty("searchChildren"))
				background = back.searchChildren(Graphic);	
			
			textFields = [];
			textFields = searchChildren(Text, Array);
			for (var i:int = 0; i < textFields.length; i++)
				fontArray.push(textFields[i].fontSize);
			
			scrollPanes = [];
			scrollPanes = searchChildren(ScrollPane, Array);
			
			addEventListener(GWGestureEvent.RELEASE, noActivity);
			
			updateLayout();				
		}
		
		/**
		 * CML Initialisation callback
		 */
		override public function displayComplete():void
		{
			init();
		}
		
		private var _fontIncrement:Number = 2;
		/**
		 * font increment
		 * @default 2;
		 */	
		public function get fontIncrement():Number {return _fontIncrement}
		public function set fontIncrement(value:Number):void 
		{	
			_fontIncrement = value;			
		}
		
		private var _autoAlign:String = "center";
		/**
		 * Set the autoAlign for the auto text layout feature if desired. Options are "left", "center", "right".
		 * @default "center"
		 */
		public function get autoAlign():String { return _autoAlign; }
		public function set autoAlign(value:String):void {
			_autoAlign = value;
		}
				
		private var _front:*;
		/**
		 * Sets the front element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get front():* {return _front}
		public function set front(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_front = value;
			else 
				_front = searchChildren(value);		
			
			fronts = [];
			fronts = String(value).split(",");
			if (fronts.length > 1) {
				for (var i:int = 0; i < fronts.length; i++) 
				{
					fronts[i] = searchChildren(fronts[i]);
				}
			}
		}				
		
		
		private var _back:*;
		/**
		 * Sets the back element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get back():* {return _back}
		public function set back(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject) {
				_back = value;
			}
			else {
				_back = searchChildren(value);
			}
			backs = [];
			backs = String(value).split(",");
			if (backs.length > 1) {
				for (var i:int = 0; i < backs.length; i++) 
				{
					backs[i] = searchChildren(backs[i]);
				}
			}
		}		
		
		
		private var _background:*;
		/**
		 * Sets the back background element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get background():* {return _background}
		public function set background(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_background = value;
			else
				_background = searchChildren(value);				
		}
		
		
		private var _menu:*;
		/**
		 * Sets the menu element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get menu():* {return _menu}
		public function set menu(value:*):void 
		{
			if (!value) return;

			if (value is DisplayObject)
				_menu = value;
			else
				_menu = searchChildren(value);
		}			
		
		
		private var _frame:*;
		/**
		 * Sets the frame element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get frame():* {return _frame}
		public function set frame(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_frame = value;
			else
				_frame = searchChildren(value);				
		}			

		
		private var _hideFrontOnFlip:Boolean = false;
		/**
		 * Specifies whether the front is hidden when the the back is shown
		 * @default false
		 */		
		public function get hideFrontOnFlip():* {return _hideFrontOnFlip}
		public function set hideFrontOnFlip(value:*):void 
		{	
			_hideFrontOnFlip = value;			
		}				
		
		
		private var _autoTextLayout:Boolean = true;
		/**
		 * Specifies whether text fields will be automatically adjusted to the component's width
		 * @default true
		 */		
		public function get autoTextLayout():Boolean {return _autoTextLayout}
		public function set autoTextLayout(value:Boolean):void 
		{	
			_autoTextLayout = value;			
		}
		
		private var _timeout:Number = 0;
		/**
		 * Set the timeout value for when the elements were automatically close.
		 */
		public function get timeout():Number { return _timeout; }
		public function set timeout(value:Number):void {
			_timeout = value;
			//updateLayout();
		}
		
		private var _fadeoutDuration:Number = 0;
		/**
		 * Set the fadeout time for an object that's timed out.
		 */
		public function get fadeoutDuration():Number { return _fadeoutDuration; }
		public function set fadeoutDuration(value:Number):void {
			_fadeoutDuration = value;
		}
		
		private var _side:String = "front";
		/**
		 * Specifies the currently displayed side
		 * @default "front"
		 */
		protected function get side():String { return _side; }		
		public function get activity():Boolean { return _activity; }
				
		/**
		 * Manages the timer and dispatches a state event
		 */
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;			
			if (value && timer)
				restartTimer();
			else if (!value)
			{
				_activity = value;
				if(timer)
					timer.stop();
			}
				
			dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "visible", value));								
		}
		
		protected function updateLayout(event:*=null):void
		{	
			if (front)
			{
				front.width = width;
				front.height = height;				
			}			
			
			if (fronts && fronts.length > 1) {
				for (var k:int = 0; k < fronts.length; k++) 
				{
					fronts[k].width = width;
					fronts[k].height = height;
				}
			}
			
			if (back)
			{
				back.width = width;
				back.height = height;
			}
			
			if (backs && backs.length > 1) {
				for (var j:int = 0; j < backs.length; j++) 
				{
					backs[j].width = width;
					backs[j].height = height;
				}
			}
			
			if (background)
			{
				background.width = width;
				background.height = height;
			}
				
			if (frame)
			{
				frame.width = width;
				frame.height = height;
			}			
			
			if (menu)
			{
				menu.updateLayout(width, height);	
			}
			
			if ( timeout || (menu && menu.autoHide) ) {
				if (GestureWorks.activeTUIO){
					this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
					this.addEventListener(TuioTouchEvent.TOUCH_UP, onUp);
					this.addEventListener(TuioTouchEvent.TOUCH_OUT, onUp);
				}
				else if	(GestureWorks.supportsTouch){
					this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					this.addEventListener(TouchEvent.TOUCH_END, onUp);
					this.addEventListener(TouchEvent.TOUCH_OUT, onUp);
					}
				else{	
					this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
					this.addEventListener(MouseEvent.MOUSE_UP, onUp);
					this.addEventListener(MouseEvent.MOUSE_OUT, onUp);
				}				
			}				
			
			if (textFields && autoTextLayout)
			{
				for (var i:int = 0; i < textFields.length; i++) 
				{					
					textFields[i].x = textFields[i].paddingLeft;
					Text(textFields[i]).fontSize = Text(textFields[i]).fontSize;
					textFields[i].autoSize = "left";
					//Text(textFields[i]).textAlign = _autoAlign;
					if (textFields[i] == searchChildren(".info_title"))
						textFields[i].textAlign = "center";
					else textFields[i].textAlign = "left";
					textFields[i].width = width - textFields[i].paddingLeft - textFields[i].paddingRight;
					
					if (i == 0)
						textFields[i].y = textFields[i].paddingTop;
					else
						textFields[i].y = textFields[i].paddingTop + textFields[i - 1].paddingBottom + textFields[i - 1].height;
					
					if (textFields[i].parent is ScrollPane) {
						formatPane(textFields[i], textFields[i].parent);
					}
				}
			}
			
			if (textFields)	
				textSize();
			
			if (timeout > 0) {
				timer = new Timer(timeout * 1000, 1);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				
				if (visible && timer)
					timer.start();
			}
			
		}
		
		private function formatPane(t:Text, sp:ScrollPane):void {
			sp.y = t.y;
			t.y = 0;
			sp.width = width - sp.scrollMargin - sp.scrollThickness - t.paddingRight - t.paddingLeft;
			sp.x = t.paddingLeft;
			t.width = sp.width - ((t.paddingLeft + t.paddingRight));
			t.x = t.paddingLeft;
			sp.height = this.height - t.paddingBottom - sp.y;
			
			for (var z:Number = textFields.indexOf(t); z < textFields.length; z++ ) {
				if (t != textFields[z]) {
					sp.height -= textFields[z].height;
				}
			}
			if (menu) {
				sp.height -= menu.getChildAt(0).height + menu.paddingBottom + t.paddingBottom;
			}
			
			//sp.updateLayout(t.width, t.height);
		}
		
		/**
		 * handles touch event
		 * @param	event
		 */
		
		public function onDown(event:* = null):void
		{
			if (event) {
				_activity = visible;
			}
			if (timer) {
				timer.stop();
			}			
			if (menu){
				menu.visible = true;
				menu.startTimer();
			}
			if(tween && tween._active){
				tween.kill();
				this.alpha = 1;
			}						
		}

		/**
		 * handles event
		 * @param	event
		 */
		public function onUp(event:* = null):void
		{
			if (event) {
				_activity = false;
			}
			if (menu)
				menu.mouseChildren = true;
			
			if (timer) {
				restartTimer();
			}
			
			if(tween && tween._active){
				tween.kill;
				this.alpha = 1;
			}			
		}
		
		public function noActivity(e:GWGestureEvent):void
		{
			_activity = false;
		}
		
		private var textCount:Number = 4;
				
		private function textSize():void
		{
			if (textFields)
			{
				if (textCount >= 3)
				{
					for (var j:int = 0; j < textFields.length; j++)
					{
						if( textFields[j] != searchChildren(".info_title")){
							textFields[j].fontSize = fontArray[j];	
							if (textFields[j].parent is ScrollPane) {
								//var w:Number = width - sp.scrollMargin - sp.scrollThickness - t.paddingRight - t.paddingLeft;
								textFields[j].parent.updateLayout(textFields[j].parent.width, textFields[j].parent.height);
							}
						}
					}
					textCount = 0;
				}
				else
				{
					for (var i:int = 0; i < textFields.length; i++)
					{
						if ( textFields[i] != searchChildren(".info_title")){
							textFields[i].fontSize += fontIncrement;
							if (textFields[i].parent is ScrollPane) {
								//var w:Number = width - sp.scrollMargin - sp.scrollThickness - t.paddingRight - t.paddingLeft;
								textFields[i].parent.updateLayout(textFields[i].parent.width, textFields[i].parent.height);
							}
						}
					}
				}
            }
			//updateLayout();
		}
		
		protected function onStateEvent(event:StateEvent):void
		{
			//trace(event);
			if (event.value == "fontSize")
			{
				textSize();
				textCount++;
			}
			

			if (event.value == "info") 
			{
				if (back && backs.length == 1)
				{
					if (!back.visible) { 
						back.visible = true;
						_side = "back";
					}
					else { 
						back.visible = false;
					}
				}
				else if (backs && backs.length > 1) {
					for (var i:int = 0; i < backs.length; i++) 
					{
						backs[i].visible = !backs[i].visible;
					}
					if (backs[0].visible == false) {
						_side = "front";
					} else { _side = "back"; }
				}
				
				if (front && hideFrontOnFlip && fronts.length == 1)
				{
					if (!front.visible) { 
						front.visible = true;
						_side = "front";
						if (fronts.length > 1) {
							for (var j:int = 0; j < fronts.length; j++) 
							{
								fronts[j].visible = true;
							}
						}
					}
					else { 
						front.visible = false;
						if (fronts.length > 1) {
							for (var k:int = 0; k < fronts.length; k++) 
							{
								fronts[k].visible = false;
							}
						}
					}
				}
			}
			else if (event.value == "close")
			{
				this.visible = false;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "close", "quit"));
			}
			else if (event.property == "selectedLabel") {
				if (!isNaN(Number(event.value))) {
					var index:Number = Number(event.value);
					for (var l:int = 0; l < numChildren; l++) 
					{
						if ("snapTo" in getChildAt(l)) {
							getChildAt(l)["snapTo"](index);
						}
					}
				}
			}
			else if (event.value == "forward") {
				for (var m:int = 0; m < numChildren; m++) 
				{
					if ("next" in getChildAt(m)) {
						getChildAt(m)["next"]();
					}
				}
			}
			else if (event.value == "back") {
				for (var n:int = 0; n < numChildren; n++) 
				{
					if ("previous" in getChildAt(n)) {
						getChildAt(n)["previous"]();
					}
				}
			}
		}
		
		
		protected function onTimer(e:TimerEvent):void {
			timer.stop();
			
			if (fadeoutDuration > 0) {
				fadeOut(fadeoutDuration);
			}
			else { 
				this.visible = false; 
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "close", "timeout"));
			}
		}
	
		public function reset():void
		{
			if (front)
				front.visible = true;
			else if (fronts) {
				for (var y:Number = 0; y < fronts.length; y++) {
					fronts[y].visible = true;
				}
			}
			_side = "front";
			if (back)
				back.visible = false;
			else if (backs) {
				for (var z:Number = 0; z < backs.length; z++) {
					backs[z].visible = false;
				}
			}
			if(menu)
				menu.reset();
			if (timer)
				restartTimer();
				
			//reset gestureList to clear inertia cache
			if (gestureList)
			{
				var gestures:Object = gestureList;
				gestureList = gestures;
			}
		}		
		
		public function fadeIn(dur:Number=250):void
		{
			if (tween && tween._active)
				return;
				
			tween = TweenLite.to(this, dur, { alpha:1 } );
			tween.play();
		}
		

		public function fadeOut(dur:Number=250):void
		{
			if (tween && tween._active)
				return;
				
			tween = TweenLite.to(this, dur, { alpha:0, onComplete:function():void { 
					visible = false;
					dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "close", "timeout"));
				}} );
			tween.play();
		}			
		

		private var glowTween:TweenLite;
		private var scrollPanes:Array;
		public var backs:Array;
		public var fronts:Array;
		public var glowColor:uint = 0xFFFFFF;
		
		public function glowIn(dur:Number=1):void
		{
			if (glowTween && glowTween._active)
				return;
				
			glowTween = TweenLite.fromTo(this, dur, {
					glowFilter: {
						color: 0xFFFFFF,
						blurX: 25,
						blurY: 25
					}
				},{
					glowFilter: {
						color: 0xFFFFFF,
						blurX: 0,
						blurY: 0
					}
				});
				
			glowTween.play();
		}
		
		public function glowPulse():void
		{
			glowIn();
			glowTween.eventCallback("onComplete", glowOut);
		}
		
		

		public function glowOut(dur:Number=1):void
		{
			if (glowTween && glowTween._active)
				return;			
		
			glowTween = TweenLite.to(this, dur, {
				_glowFilter: {
					blurX: 0,
					blurY: 0, 
					color: 0xFFFFFF
				}
			});
			
			glowTween.play();		
		}			
		
		
		
		public function restartTimer():void
		{
			timer.reset();
			timer.start();
		}
		
		/**
		 * Returns clone of self
		 */
		override public function clone():* 
		{	
			var clone:Component = CloneUtils.clone(this, this.parent, cloneExclusions);
			
			CloneUtils.copyChildList(this, clone);			
			
			if (front)
				clone.front = String(front.id);
			
			if (back) {
				clone.back = String(back.id);
			}
			
			if (background)
				clone.background = String(background.id);
			
			if (menu)	
				clone.menu = String(menu.id);
			
			if (frame)
				clone.frame = String(frame.id);	
			
			//clone.resetMatrix();
			clone.displayComplete();
			
			return clone;
		}		
		
		public function resetMatrix():void {
			this.transform.matrix.identity();
		}
		
		public function invertMatrix(displayObject:DisplayObject, newParent:DisplayObjectContainer):void {
			var concatenatedChildMatrix:Matrix = displayObject.transform.concatenatedMatrix;
			var concatenatedNewParentMatrix:Matrix = newParent.transform.concatenatedMatrix;
			
			concatenatedNewParentMatrix.invert();
			concatenatedChildMatrix.concat(concatenatedNewParentMatrix);
			
			displayObject.transform.matrix = concatenatedChildMatrix;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			textFields = null;
			front = null;
			back = null;
			background = null;
			menu = null;
			frame = null;
			
			tween = null;
			if (timer){
				timer.stop();
				timer = null;
			}
			
			this.removeEventListener(StateEvent.CHANGE, onStateEvent);					
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);			
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);		
			this.removeEventListener(TouchEvent.TOUCH_END, onUp);			
			this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			this.removeEventListener(TuioTouchEvent.TOUCH_OUT, onUp);		
			this.removeEventListener(TouchEvent.TOUCH_OUT, onUp);			
			this.removeEventListener(MouseEvent.MOUSE_OUT, onUp);			
			this.removeEventListener(GWGestureEvent.RELEASE, noActivity);
		}
	}

}