package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.events.*;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
		
	/**
	 * The ScrollPane creates a masked viewing area of a display object and dynamically updates two scrollbars as that content is optionally dragged or scaled inside the viewing area.
	 * The ScrollPane optionally allows content inside the area to be dragged (and/or scaled), and allows the option to explore the content by dragging or touching the scroll bars.
	 * @author Ideum
	 */
	
	public class ScrollPane extends TouchContainer
	{
		private var tweening:Boolean;	
		private var loaded:Boolean = false;	
		
		private var oldY:Number;
		private var oldX:Number;
		
		public var _mask:Graphic;
		
		public var _horizontalMovement:Number;
		public var _verticalMovement:Number;
		
		private var _invertDrag:Boolean = true;
		
		private var _autohide:Boolean = false;
		private var _autohideSpeed:Number = 0.5;
		
		private var _fill:String = "0x333333";
		private var _buttonFill:String = "0x222222";
		private var _thumbFill:String = "0x222222";
		
		private var _paneStroke:Number = 1;
		private var _paneStrokeColor:uint = 0x777777;
		private var _paneStrokeMargin:Number = 0;

		private var _scrollMargin:Number = 5;
		private var _scrollThickness:Number = 20;
		
		/**
		 * Constructor
		 */
		public function ScrollPane() {
			super();	
			mouseChildren = true;
			nativeTransform = true;
			
			_content = new TouchContainer();
			
			// Drag and scale gestures on _content are applied programatically
			// by this class. This resolves jerky behavior from nativeTransforms, which
			// would otherwise enable moving _content OOBs of the scrollpane (an
			// inevitable call to updateLayout would cause them to "snap" back in bounds).
			_content.nativeTransform = false;
		}	
		
		/**
		 * Sets whether to auto-hides scroll bars.
		 * @default false
		 */
		public function get autohide():Boolean { return _autohide; }
		public function set autohide(value:Boolean):void {
			_autohide = value;
		}
		
		/**
		 * Sets the auto-hide tween speed.
		 * @default .5
		 */
		public function get autohideSpeed():Number { return _autohideSpeed; }
		public function set autohideSpeed(value:Number):void {
			_autohideSpeed = value;
		}
		
		/**
		 * Sets the thickness of a border stroke around the pane.
		 * @default 1
		 */
		public function get paneStroke():Number { return _paneStroke; }
		public function set paneStroke(value:Number):void {
			_paneStroke = value;
		}
		
		/**
		 * Sets the color of the pane stroke.
		 * @default 0x777777
		 */
		public function get paneStrokeColor():uint { return _paneStrokeColor; }
		public function set paneStrokeColor(value:uint):void {
			_paneStrokeColor = value;
		}
		
		/**
		 * Set a margin if the border should be slightly separate from the content.
		 * @default 0
		 */
		public function get paneStrokeMargin():Number { return _paneStrokeMargin; }
		public function set paneStrokeMargin(value:Number):void {
			_paneStrokeMargin = value;
		}
		
		/**
		 * Set the margin between the scroll bars and the content.
		 * @default 5
		 */
		public function get scrollMargin():Number { return _scrollMargin; }
		public function set scrollMargin(value:Number):void {
			_scrollMargin = value;
		}
		
		/**
		 * The only styling that can be set for the scroll bars in the scrollPane is their thickness.
		 * For all other custom styling, a ScrollBar item should be added in CML, or through the
		 * childToList function in AS3, and the ScrollPane class will automatically pull styles from that.
		 * @default 30
		 */
		public function get scrollThickness():Number { return _scrollThickness; }
		public function set scrollThickness(value:Number):void {
			_scrollThickness = value;
		}
		
		/**
		 * Sets whether to invert drag.
		 * @default false
		 */
		public function get invertDrag():Boolean { return _invertDrag;}
		public function set invertDrag(value:Boolean):void {
			_invertDrag = value;
		}
		
		private var _content:TouchContainer;
		/**
		 * Returns content of pane.
		 */
		public function get content():TouchContainer { return _content; }
		
		private var _vBar:ScrollBar;
		public function get vBar():ScrollBar { return _vBar; }
		public function set vBar(value:*):void {
			if (value is XML) { _vBar = getElementById(value); }
			else if (value is ScrollBar) { _vBar = value; }
		}
		
		private var _hBar:ScrollBar;
		public function get hBar():ScrollBar { return _hBar; }
		public function set hBar(value:*):void {
			if (value is XML) { _hBar = getElementById(value); }
			else if (value is ScrollBar) { _hBar = value; }
		}
		
		//private var _contentGestures:Object;
		public function get contentGestures():Object { return _content.gestureList; }
		/**
		 * Setter for the GestureList array. Takes a comma separated list and converts
		 * it into an array.
		 *
		 * Gestures to apply to the ScrollPane's content container.
		 * If contentGestures is set, nativeTransform on the ScrollPane will be disabled 
		 * (many gestures on actual ScrollPane will not work). Leave it blank to allow dragging
		 * or scaling of the entire ScrollPane rather than its "contents"
		 */
		public function set contentGestures(value:Object):void {
			if (!value || value.length == 0) {
				nativeTransform = true;
				return;
			}
			
			var gArray:* = value.split(",");
			var gestureList:Object = new Object();
			for (var i:* in gArray) {
				gestureList[gArray[i]] = true;
			}
			_content.gestureList = gestureList;
			nativeTransform = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			_content.init();
			
			// prevent gestures from directly moving the content
			super.addChild(_content);
		
			// "setup" the Scrollpane's ScrollBars, which are hidden when the content is smaller than the SrollPane
			if (!_vBar) { _vBar = createDefaultScrollBar(true); } // create a default vertical scrollbar
			initScrollBarLayout(_vBar, true);
			_vBar.init(); 
			super.addChild(_vBar);
			
			if (!_hBar) { _hBar = createDefaultScrollBar(false); } // create a default horizontal scrollbar
			initScrollBarLayout(_hBar, false);
			_hBar.init(); 
			super.addChild(_hBar);
			
			// create mask
			if (!_mask){
				_mask = new Graphic();
				_mask.shape = "rectangle";
				_mask.width = width;
				_mask.height = height;
				super.addChild(_mask);
			}
			_content.mask = _mask;

			// create events
			createEvents();
			
			// set up autohide
			if (_autohide) {
				_vBar.alpha = 0;
				_hBar.alpha = 0;
			}
			
			updateLayout();
			
			// use to prevent calls to updateLayout in overriden addChild and removeChild before initialization
			loaded = true; 
			
			// ¿¿¿ use if there's an embedded greensock, etc., loader ???
			//dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "value", "loaded")); 
		}		
		
		private function initScrollBarLayout(bar:ScrollBar, isVertical:Boolean):void {
			if (isVertical) {
				bar.contentHeight = _content.height;
				bar.height = height;
				_verticalMovement = bar.contentHeight - bar.height;

				// set default thickness, if needed
				if (!bar.width || bar.width <= 0) { bar.width = _scrollThickness; }
				bar.x = width + scrollMargin;
				bar.orientation = "vertical";
				bar.scrollCallback = onScroll;
				return;
			}
			
			bar.contentWidth = _content.width;
			bar.width = width;
			_horizontalMovement = bar.contentWidth - bar.width;

			// set default thickness, if needed
			if (!bar.height || bar.height <= 0) { bar.height = _scrollThickness; }
			bar.y = height + scrollMargin;
			bar.orientation = "horizontal";
			bar.scrollCallback = onScroll;
		}
		
		// create vertical scroll bar
		private function createDefaultScrollBar(isVertical:Boolean):ScrollBar {
			var bar:* = new ScrollBar();
			if (isVertical) {
				bar.height = height;
				bar.width = _scrollThickness;
			} else {
				bar.height = _scrollThickness;
				bar.width = width;
			}
			bar.fill = _fill;
			bar.buttonFill = _buttonFill;
			bar.thumbFill = _thumbFill;
			
			return bar;
		}
		
		// after intitialization, child additions are redirected to the content container
		override public function addChild(child:DisplayObject):flash.display.DisplayObject {
			var retVal:*;
			if (_content && !(child is ScrollBar)) { retVal = _content.addChild(child); }
			else { retVal = super.addChild(child); }
			
			// only updateLayout once we've called init()
			if (loaded) { updateLayout(); } 

			return retVal;
		}
		
		override public function removeChild(child:DisplayObject):flash.display.DisplayObject {
			var retVal:*;
			if (_content && !(child is ScrollBar)) { retVal = _content.removeChild(child); }
			else { retVal = super.removeChild(child); }
			
			// only updateLayout once we've called init()
			if (loaded) { updateLayout(); } 

			return retVal;
		}
		
		/**
		 * Creates scroll pane events
		 */
		public function createEvents():void {		
			if (contentGestures) {
				_content.addEventListener(GWGestureEvent.DRAG, onDrag);
				_content.addEventListener(GWGestureEvent.SCALE, onScale);
			}
			
			// only deal with tweening...
			//addEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin);
			//addEventListener(GWGestureEvent.COMPLETE, onEnd);
		}
		
		/**
		 * Removes scroll pane events
		 */
		public function removeEvents():void {
			if (contentGestures) {
				_content.removeEventListener(GWGestureEvent.DRAG, onDrag);			
				_content.removeEventListener(GWGestureEvent.SCALE, onScale);
			}
			
			// only deal with tweening...
			//removeEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin);
			//removeEventListener(GWGestureEvent.COMPLETE, onEnd);
		}
		
		/**
		 * Updates scroll pane layout
		 * @param	inWidth
		 * @param	inHeight
		 */
		public function updateLayout(inWidth:Number = NaN, inHeight:Number = NaN):void {
			var display:DisplayObject = _content as DisplayObject;
			//if (!display) { return; } ... we instantiate _content in the constructor ...
			var rect:Rectangle = display.getBounds(display);
			
			if (!isNaN(inWidth)) { width = inWidth; }
			if (!isNaN(inHeight)) { height = inHeight; }
			
			if (_mask){
				_mask.width = width;
				_mask.height = height;
			}
			
			// reset content size and position
			if (_content) {
				_content.width = rect.width;
				_content.height = rect.height;
				_content.x = 0;
				_content.y = 0;
			}

			// reset scrollbars to initial position
			_vBar.reset();
			_hBar.reset();
			
			// update scrollbars
			if (rect.height * _content.scaleY > height) { 
				_vBar.x = width + scrollMargin;
				_vBar.height = height;
				_vBar.resize(rect.height * _content.scaleY);
				_verticalMovement = (rect.height * _content.scaleY) - height;
				_vBar.visible = true;
			} else { _vBar.visible = false; }
			
			if (rect.width * _content.scaleX > width) { 
				_hBar.y = height + scrollMargin;
				_hBar.width = width;
				_hBar.resize(rect.width * _content.scaleX);
				_horizontalMovement = (rect.width * _content.scaleX) - width;
				_hBar.visible = true;
			} else { _hBar.visible = false; }
	
			// no longer needed as we use y_lock and x_lock to disable direct translation of _content.
			//enableScroll = _vBar.visible || _hBar.visible;
		}
		
		/*public function set enableScroll(value:Boolean):void {
			if (value) {
				//addEventListener(GWGestureEvent.DRAG, onDrag);
				//_content.addEventListener(GWGestureEvent.DRAG, onDrag);
				_content.gestureList["n-drag"] = true;
				//_content.gestureList["n-scale"] = true;
			}
			else {
				//removeEventListener(GWGestureEvent.DRAG, onDrag);
				//_content.removeEventListener(GWGestureEvent.DRAG, onDrag);
				_content.gestureList["n-drag"] = false;
				//_content.gestureList["n-scale"] = false; // uncomment and and enjoy the show...
			}
		}*/
		
		/**
		 * Reset scroll positions
		 */
		public function reset():void {
			if (_vBar)
				_vBar.reset();
			if (_hBar)
				_hBar.reset();
				
			_content.x = 0;
			_content.y = 0;
		}
		
		// events
		//
		
		// thumb drag callback
		private function onScroll(orientation:String, value:Number):void {
			if (orientation == "vertical") {
				_content.y = _verticalMovement * value * -1;
			} else if (orientation == "horizontal") {
				_content.x = _horizontalMovement * value * -1;
			}
		}
		
		private function onDrag(e:GWGestureEvent):void {
			if (_vBar.visible == true && _vBar.hitTestPoint(e.value.stageX, e.value.stageY, true) ) {
				if (_vBar.thumb.hitTestPoint(e.value.stageX, e.value.stageY, true)) // check if hit on thumb
					_vBar.onDrag(e);
				return;
			}
			else if (_hBar.visible == true && _hBar.thumb.hitTestPoint(e.value.stageX, e.value.stageY, true) ) {
				if (_hBar.thumb.hitTestPoint(e.value.stageX, e.value.stageY, true))
					_hBar.onDrag(e);
				return;
			}
			
			var newXPos:Number;
			var newYPos:Number;
			
			if (_vBar.visible == true) {
				// Check the new position won't be further than the limits, and if so, clamp it.
				newYPos = _content.y;
				
				if (!releaseInertia) {
					if (!oldY) {
						oldY = e.value.localY;
					} else if (oldY) {
						if (!invertDrag) newYPos -= e.value.localY - oldY;
						else newYPos += e.value.localY - oldY;
						oldY = e.value.localY;
					}
				} else {
					if (!invertDrag) newYPos -= e.value.drag_dy;
					else newYPos += e.value.drag_dy;
				}
				
				// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				// Get the localY of the previous gesture call
				// Get the differential of the previous localY and the new localY
				// (Negative values should move the content upwards, positive values downwards)
				// Assign old localY to current localY.
				// Now clamp and apply differential.
				
				newYPos = clampPos(newYPos, "vertical");
				
				// Apply the new position.
				_content.y = newYPos;
				_vBar.thumbPosition = -newYPos / _verticalMovement;
			} 
			// not needed if nativeTransform is disabled on _content
			// prevent dragging OOB if content is wide enough to have an hBar (dragging still enabled)
			//else if ( _content.y < 0 || _content.y > height - _content.height) { _content.y = 0; }
			
			if (_hBar.visible == true) {
				newXPos = _content.x;
				
				if (!releaseInertia) {
					if (!oldX) {
						oldX = e.value.localX;
					} else if (oldX) {
						if (!invertDrag) newXPos -= e.value.localX  - oldX;
						else newXPos += e.value.localX - oldX;
						oldX = e.value.localX;
					}
				} else {
					if (!invertDrag) newXPos -= e.value.drag_dx;
					else newXPos += e.value.drag_dx;
				}
				
				// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				// Get the localX of the previous gesture call
				// Get the differential of the previous localX and the new localX
				// (Negative values should move the content left, positive values right)
				// Assign old localX to current localX.
				// Now clamp and apply differential.
				
				newXPos = clampPos(newXPos, "horizontal");

				// Apply the new position.
				_content.x = newXPos;
				_hBar.thumbPosition = -newXPos / _horizontalMovement;
			}
			// not needed if nativeTransform is disabled on _content
			// prevent dragging OOB if content is tall enough to have an vBar (dragging still enabled)
			//else if ( _content.x < 0 || _content.x > width - _content.width) { _content.x = 0; }
		}
		
		/*private function onBegin(e:GWTouchEvent):void {
			//Reset the position values so the scrollPane will move cumulatively.
			oldX = 0;
			oldY = 0;
			if (_autohide) {
				if (tweening) { TweenMax.killAll(); }
				tweening = true;
				TweenMax.allTo([_vBar, _hBar], _autohideSpeed, { alpha:1, onComplete:function():void { tweening = false;} } );
			}
		}
		
		private function onEnd(e:GWGestureEvent):void {
			if (_autohide) {
				if (tweening) { TweenMax.killAll(); }
				TweenMax.allTo([_vBar, _hBar], _autohideSpeed, { alpha:0, onComplete:function():void { tweening = false;} } );
			}
		}*/
		
		private function clampPos(pos:Number, direction:String):Number {
			if (direction == "vertical") {
				if (pos < -_verticalMovement) pos = -_verticalMovement;
				else if (pos > 0) pos = 0;
			}
			if (direction == "horizontal"){
				if (pos < -_horizontalMovement) pos = -_horizontalMovement;
				else if (pos > 0) pos = 0;
			}
			return pos;
		}
		
		protected function onScale(e:GWGestureEvent):void {
			var c:DisplayObject = DisplayObject(content);
			var dsx:Number = e.value.scale_dsx;
			var dsy:Number = e.value.scale_dsy;
			
			var m:Matrix = c.transform.matrix;
			m.translate(-e.value.localX, -e.value.localY);
			m.scale(1 + dsx, 1 + dsy);
			m.translate(e.value.localX, e.value.localY);
			c.transform.matrix = m;
			
			/*if (c.height * c.scaleY > height) {
				_vBar.resize(c.height * c.scaleY);
				_verticalMovement = c.height * c.scaleY - height;
				_vBar.visible = true;	
			} else { _vBar.visible = false; }

			if (c.width * c.scaleX > width) {
				_hBar.resize(c.width * c.scaleX);
				_horizontalMovement = c.width * c.scaleX - width;
				_hBar.visible = true;
			} else { _hBar.visible = false; }*/
			
			
			// keeps ScrollBars in sync, has desirable side effect of causing 
			// _content to scale to and from (0, 0) and (+inf, +inf).
			// Without this scaled content may end up OOB
			updateLayout();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {
			var v:Vector.<String> = cloneExclusions;
			v.push("childList", "_vBar", "_hBar", "_mask");// , "_content");
			var clone:ScrollPane = CloneUtils.clone(this, this.parent, v);
			//CloneUtils.copyChildList(this, clone);	
			
			clone.vBar = _vBar.clone();
			clone.hBar = _hBar.clone();
			clone.init();			
			return clone;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			
			// TODO remove content children
			_content = null;
			_mask = null;
			_vBar = null;
			_hBar = null;		
		}		
	}
}