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
		
		private var _content:*;
		
		public var _mask:Graphic;
		
		public var _verticalScroll:ScrollBar;
		public var _horizontalScroll:ScrollBar;
		
		public var _vertical:Boolean = false;
		public var _horizontal:Boolean = false;	
		public var _vertStyleSet:Boolean = false;
		public var _horizStyleSet:Boolean = false;
		public var _horizontalMovement:Number;
		public var _verticalMovement:Number;
		
		private var _invertDrag:Boolean = false;
		
		private var _autohide:Boolean = false;
		private var _autohideSpeed:Number = 0.5;
		
		private var _paneStroke:Number = 1;
		private var _paneStrokeColor:uint = 0x777777;
		private var _paneStrokeMargin:Number = 0;

		private var _scrollMargin:Number = 5;
		private var _scrollThickness:Number = 30;
		
		
		/**
		 * Constructor
		 */
		public function ScrollPane() {
			super();	
			mouseChildren = true;
			nativeTransform = false;
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
		
		
		
		/**
		 * Returns content of pane.
		 */
		public function get content():* {
			return _content;
		}
		
		

		/**
		 * @inheritDoc
		 */
		override public function init():void {
			// Check the child list. 
			// Iterate through each item, getting position, width, and height.
			// Check if total items width are larger than the container.
			
			if (!numChildren) { return; }
			
			// search for content
			if (!_content){
				for (var j:int = 0; j < numChildren; j++) {
					if (getChildAt(j) is ScrollBar || 
						getChildAt(j) is GestureList || 
						getChildAt(j) == _mask) {
						continue;
						}
					else { 
						_content = getChildAt(j);
					}
				}
			}			
			
		
			// get scrollbars
			var scrollBars:Array = searchChildren(ScrollBar, Array);
			
			// set up scroll bars
			if (scrollBars.length > 0){
				for (var i:int = 0; i < scrollBars.length; i++) {
					if (ScrollBar(scrollBars[i]).orientation == "vertical") {
						_vertStyleSet = true;
						_verticalScroll = scrollBars[i];
					}
					else if (ScrollBar(scrollBars[i]).orientation == "horizontal") {
						_horizStyleSet = true;
						_horizontalScroll = scrollBars[i];
					}
				}
			}
			
			// If one bar is set but not the other, set the other to match.
			if (_verticalScroll && !_horizontalScroll) {
				createHorizontal();
			}
			if (!_verticalScroll && _horizontalScroll) {
				createVertical();
			}
			
			// Create the scroll bars if they haven't been caught anywhere else.			
			if (!_verticalScroll && !_horizontalScroll) {
				_verticalScroll = new ScrollBar();
				_horizontalScroll = new ScrollBar();
			}
			
			// Create the scroll bar properties that would not be affected by setting out a style.
			_vertical = true;
			_verticalScroll.contentHeight = _content.height;
			_verticalScroll.height = height;
			_verticalMovement = _content.height - height;
			
			// Check if the scroll's thickness has already been set. If not, use the default or thickness listed in CML.
			if (!_verticalScroll.width || _verticalScroll.width <= 0){
				_verticalScroll.width = _scrollThickness;
			}
			if(!_vertStyleSet){
				_verticalScroll.init();
			}
			_verticalScroll.x = width + scrollMargin;
			
			// Check if the scroll bar is needed. If so, add to display list.
			if (_content.height > height) {
				addChild(_verticalScroll);
				_vertical = true;
			} else { _vertical = false; }
						
			_horizontalMovement = _content.width - width;
			_horizontal = true;
			_horizontalScroll.orientation = "horizontal";
			
			// Check if the scroll's thickness has already been set. If not, use the default or thickness listed in CML.
			if (!_horizontalScroll.height || _horizontalScroll.height <= 0 ){
				_horizontalScroll.height = _scrollThickness;
			}
			
			_horizontalScroll.contentWidth = _content.width;
			_horizontalScroll.width = width;
			
			if(!_horizStyleSet) {
				_horizontalScroll.init();
			}
			_horizontalScroll.y = height + scrollMargin;
			
			if (_content.width > width) {
				addChild(_horizontalScroll);
				
				_horizontal = true;
			} else { _horizontal = false; }
			
			
			// create mask
			if (!_mask){
				_mask = new Graphic();
				_mask.shape = "rectangle";
				_mask.width = width;
				_mask.height = height;
				addChild(_mask);
			}
			_content.mask = _mask;
			
			
			// create events
			createEvents();
			
			
			// set up autohide
			if (_autohide) {
				_verticalScroll.alpha = 0;
				_horizontalScroll.alpha = 0;
			}
			
			// loaded
			loaded = true;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", "loaded"));
		}		
		
		
		// create vertical scroll bar
		private function createVertical():void {
			_verticalScroll = new ScrollBar();
			_verticalScroll.height = _horizontalScroll.width;
			_verticalScroll.fill = _horizontalScroll.fill;
			_verticalScroll.buttonFill = _horizontalScroll.buttonFill;
			if (_verticalScroll.thumbFill)
				_verticalScroll.thumbFill = _horizontalScroll.thumbFill;
		}
		
		// create horizontal scroll bar
		private function createHorizontal():void {
			_horizontalScroll = new ScrollBar();
			_horizontalScroll.orientation = "horizontal";
			_horizontalScroll.height = _verticalScroll.width;
			_horizontalScroll.fill = _verticalScroll.fill;
			_horizontalScroll.buttonFill = _verticalScroll.buttonFill;
			if (_verticalScroll.thumbFill)
				_horizontalScroll.thumbFill = _verticalScroll.thumbFill;
		}
		
		
		
		/**
		 * Creates scroll pane events
		 */
		public function createEvents():void {
			if (contains(_horizontalScroll) || contains(_verticalScroll)) {
				addEventListener(GWGestureEvent.DRAG, onDrag);
				content.addEventListener(GWGestureEvent.DRAG, onDrag);
			}
			addEventListener(GWGestureEvent.SCALE, onScale);
			addEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin);
			addEventListener(GWGestureEvent.COMPLETE, onEnd);
			
			_verticalScroll.addEventListener(StateEvent.CHANGE, onScroll);
			_horizontalScroll.addEventListener(StateEvent.CHANGE, onScroll);
		}
		
		/**
		 * Removes scroll pane events
		 */
		public function removeEvents():void {
			if (contains(_horizontalScroll) || contains(_verticalScroll)) {
				this.removeEventListener(GWGestureEvent.DRAG, onDrag);
			}
			removeEventListener(GWGestureEvent.SCALE, onScale);
			removeEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin);
			removeEventListener(GWTouchEvent.TOUCH_END, onEnd);			
			_verticalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			_horizontalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
		}
		
		
		/**
		 * Updates scroll pane layout
		 * @param	inWidth
		 * @param	inHeight
		 */
		public function updateLayout(inWidth:Number=NaN, inHeight:Number=NaN):void {
			if (!isNaN(inWidth)) {
				width = inWidth; 
			}
			if (!isNaN(inHeight)) {
				height = inHeight; 
			}
			
			if (_mask){
				_mask.width = width;
				_mask.height = height;
			}
			var display:DisplayObject = _content as DisplayObject;
			var rect:Rectangle = display.getBounds(display);
			if (_verticalScroll) {
				_verticalScroll.x = width + scrollMargin;
				_verticalScroll.height = height;
				_verticalScroll.resize(rect.height * _content.scaleY);
				_verticalMovement = rect.height * _content.scaleY - height;
				_verticalScroll.thumbPosition = _content.y / _verticalMovement;
				
				if (rect.height * _content.scaleY > height) {
					if (!(contains(_verticalScroll))) addChild(_verticalScroll);
				} else if (rect.height * _content.scaleY < height) {
					if (contains(_verticalScroll)) removeChild(_verticalScroll);
				}
			}
			
			if (_horizontalScroll) {
				_horizontalScroll.y = height + scrollMargin;
				_horizontalScroll.width = width;
				_horizontalScroll.resize(rect.width * _content.scaleX);
				_horizontalMovement = rect.width * _content.scaleX - width;
				_horizontalScroll.thumbPosition = _content.x / _horizontalMovement;
				
				if (rect.width * _content.scaleX > width) {
					if (!(contains(_horizontalScroll))) addChild(_horizontalScroll);
				} else if (rect.height * _content.scaleX < width) {
					if (contains(_horizontalScroll)) removeChild(_horizontalScroll);
				}
			}
			
			if ( _horizontalScroll || _verticalScroll) {
				enableScroll = contains(_horizontalScroll) || contains(_verticalScroll)
			}
		}
		
		/**
		 * Drag event registration
		 */
		public function set enableScroll(value:Boolean):void {
			if (value) {
				addEventListener(GWGestureEvent.DRAG, onDrag);
				content.addEventListener(GWGestureEvent.DRAG, onDrag);
			}
			else {
				removeEventListener(GWGestureEvent.DRAG, onDrag);
				content.removeEventListener(GWGestureEvent.DRAG, onDrag);
			}
		}
		
		/**
		 * Resets scroll positions.
		 */
		public function reset():void {
			if (_verticalScroll)
				_verticalScroll.reset();
			if (_horizontalScroll)
				_horizontalScroll.reset();
				
			_content.x = 0;
			_content.y = 0;
		}
		
		
		
		// events
		
		
		private function onScroll(e:StateEvent):void {
			if (e.target == _verticalScroll) {
				_content.y = _verticalMovement * e.value * -1;
			} else if (e.target == _horizontalScroll) {
				_content.x = _horizontalMovement * e.value * -1;
			}
		}
		
		
		private function onDrag(e:GWGestureEvent):void {
			if (_verticalScroll && contains(_verticalScroll) && _verticalScroll.hitTestPoint(e.value.stageX, e.value.stageY, true) ) {
				if (_verticalScroll.thumb.hitTestPoint(e.value.stageX, e.value.stageY, true))
					_verticalScroll.onDrag(e);
				return;
			}
			else if (_horizontalScroll && contains(_horizontalScroll) && _horizontalScroll.thumb.hitTestPoint(e.value.stageX, e.value.stageY, true) ) {
				if (_horizontalScroll.thumb.hitTestPoint(e.value.stageX, e.value.stageY, true))
					_horizontalScroll.onDrag(e);
				return;
			}
								
			var newXPos:Number;
			var newYPos:Number;
					
			if (contains(_verticalScroll)) {
				// Check the new position won't be further than the limits, and if so, clamp it.
				newYPos = _content.y;
				
				if (!releaseInertia) {
					if (!oldY) {
						oldY = e.value.localY;
					}
					else if (oldY) {
						if (!invertDrag) newYPos -= e.value.localY - oldY;
						else newYPos += e.value.localY - oldY;
						oldY = e.value.localY;
					}
				}
				else {
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
				_verticalScroll.thumbPosition = -newYPos / _verticalMovement;
			}
			
			if (contains(_horizontalScroll)) {
				newXPos = _content.x;
				
				if (!releaseInertia) {
					if (!oldX) {
						oldX = e.value.localX;
					}
					else if (oldX) {
						if (!invertDrag) newXPos -= e.value.localX  - oldX;
						else newXPos += e.value.localX - oldX;
						oldX = e.value.localX;
					}
				}
				else {
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
				_horizontalScroll.thumbPosition = -newXPos / _horizontalMovement;
			}
		}
		
		private function onBegin(e:GWTouchEvent):void {
			//Reset the position values so the scrollPane will move cumulatively.
			oldX = 0;
			oldY = 0;
			if (_autohide) {
				if (tweening)
					TweenMax.killAll();
				tweening = true;
				TweenMax.allTo([_verticalScroll, _horizontalScroll], _autohideSpeed, { alpha:1, onComplete:function():void { tweening = false;} } );
			}
		}
		
		private function onEnd(e:GWGestureEvent):void {
			if (_autohide) {
				if (tweening)
					TweenMax.killAll();
				
				TweenMax.allTo([_verticalScroll, _horizontalScroll], _autohideSpeed, { alpha:0, onComplete:function():void { tweening = false;} } );
			}
		}
		
		private function clampPos(pos:Number, direction:String):Number {
			if (direction == "vertical") {
				if (pos < -_verticalMovement) pos = -_verticalMovement;
				else if (pos > 0) pos = 0;
			}
			if(direction == "horizontal"){
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
			
			if (c.height * c.scaleY > height) {
				_verticalScroll.resize(c.height * c.scaleY);
				_verticalMovement = c.height * c.scaleY - height;
				_vertical = true;
				
				if (!(contains(_verticalScroll))) {
					addChild(_verticalScroll);
				}
				
			} 
			else if (_content.height * c.scaleY < height) {
				if (contains(_verticalScroll)) 
					removeChild(_verticalScroll);
			}
			if (c.width * c.scaleX > width) {
				_horizontalScroll.resize(c.width * c.scaleX);
				_horizontalMovement = c.width * c.scaleX - width;
				_horizontal = true;
				
				if (!(contains(_horizontalScroll))) {
					addChild(_horizontalScroll);
				}
			} 
			else if (c.width * c.scaleX < width) {
				if (contains(_horizontalScroll)) {
					removeChild(_horizontalScroll);
				}	
			}
			
			if (contains(_horizontalScroll) || contains(_verticalScroll)) {
				addEventListener(GWGestureEvent.DRAG, onDrag);
			} else {
				removeEventListener(GWGestureEvent.DRAG, onDrag);
			}
		}
		
		
		/**
		 * Updates / replaces content with given value. If you are only changing the dimensions of the 
		 * content, such as a string change on a text field, the method updateLayout will be faster.
		 * @param	value
		 */
		public function updateContent(value:DisplayObject):void {			
			if ( _content && contains(_content)) {
				removeChild(_content);
				_content = null;
			}			
			_content = value;
			addChild(_content);
			init();
			updateLayout();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function clone():*{
			this.removeChild(_mask);
			this.removeEvents();
			var v:Vector.<String> = cloneExclusions;
			v.push("childList", "_verticalScroll", "_horizontalScroll", "_mask", "_content");
			var clone:ScrollPane = CloneUtils.clone(this, null, v);
			
			CloneUtils.copyChildList(this, clone);	
			
			if (clone.parent)
				clone.parent.addChild(clone);
			else
				this.parent.addChild(clone);
			
			this.addChild(_mask);
			this.content.mask = _mask;
			this.createEvents();
			
			clone.init();
			
			return clone;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_content = null;
			_mask = null;
			_verticalScroll = null;
			_horizontalScroll = null;		
		}		
	}
}