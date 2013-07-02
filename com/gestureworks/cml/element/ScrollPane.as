package com.gestureworks.cml.element
{
	import away3d.bounds.NullBounds;
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import com.gestureworks.cml.utils.CloneUtils;
		
	/**
	 * The ScrollPane creates a masked viewing area of a display object and dynamically updates two scrollbars as that content is optionally dragged or scaled inside the viewing area.
	 * The ScrollPane optionally allows content inside the area to be dragged (and/or scaled), and allows the option to explore the content by dragging or touching the scroll bars.
	 * @author Ideum
	 */
	
	public class ScrollPane extends TouchContainer
	{	
		public var _verticalScroll:ScrollBar;
		public var _horizontalScroll:ScrollBar;
		public var _vertical:Boolean = false;
		public var _horizontal:Boolean = false;
		public var _mask:Graphic;
		public var _vertStyleSet:Boolean = false;
		public var _horizStyleSet:Boolean = false;
		
		public var _horizontalMovement:Number;
		public var _verticalMovement:Number;
		
		private var oldY:Number;
		private var oldX:Number;
		
		public var _content:*;
		
		private var loaded:Boolean = false;
	
		
		public function ScrollPane()
		{
			super();
			
			disableNativeTransform = true;
		}	
		
		private var _width:Number = 0;
		/**
		 * Set the width of the window pane of the scrollPane.
		 */
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
			super.width = value;
			//if (loaded)
				//updateLayout(width, height);
		}
		
		private var _height:Number = 0;
		/**
		 * Set the height of the window pane of the scrollPane.
		 */
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
			super.height = value;
			//if (loaded)
				//updateLayout(width, height);
		}
		
		private var _paneStroke:Number = 1;
		/**
		 * Set the thickness of a border stroke around the pane.
		 */
		public function get paneStroke():Number { return _paneStroke; }
		public function set paneStroke(value:Number):void {
			_paneStroke = value;
		}
		
		private var _paneStrokeColor:uint = 0x777777;
		/**
		 * Set the color of the paneStroke.
		 */
		public function get paneStrokeColor():uint { return _paneStrokeColor; }
		public function set paneStrokeColor(value:uint):void {
			_paneStrokeColor = value;
		}
		
		private var _paneStrokeMargin:Number = 0;
		/**
		 * Set a margin if the border should be slightly separate from the content
		 */
		public function get paneStrokeMargin():Number { return _paneStrokeMargin; }
		public function set paneStrokeMargin(value:Number):void {
			_paneStrokeMargin = value;
		}
		
		private var _scrollMargin:Number = 5;
		/**
		 * Set the margin between the scroll bars and the content;
		 */
		public function get scrollMargin():Number { return _scrollMargin; }
		public function set scrollMargin(value:Number):void {
			_scrollMargin = value;
		}
		
		private var _scrollThickness:Number = 30;
		/**
		 * The only styling that can be set for the scroll bars in the scrollPane is their thickness.
		 * For all other custom styling, a ScrollBar item should be added in CML, or through the
		 * childToList function in AS3, and the ScrollPane class will automatically pull styles from that.
		 */
		public function get scrollThickness():Number { return _scrollThickness; }
		public function set scrollThickness(value:Number):void {
			_scrollThickness = value;
		}
		
		private var _scrollOnPane:Boolean = true;
		/**
		 * Set whether or not the pane can be scrolled on.
		 * @default true
		 */
		public function get scrollOnPane():Boolean { return _scrollOnPane; }
		public function set scrollOnPane(value:Boolean):void {
			_scrollOnPane = value;
		}
		
		private var _scaleOnPane:Boolean = true;
		/**
		 * Set whether or not the pane can be scaled on if the gesture is available.
		 * @default true
		 */
		public function get scaleOnPane():Boolean { return _scaleOnPane; }
		public function set scaleOnPane(value:Boolean):void {
			_scaleOnPane = value;
		}
		
		private var _multiFingerScroll:Boolean = false;
		/**
		 * Set single finger drag, multi-finger scroll functionality. If true, the pane will only be scrolled on two fingers or more.
		 * @default false
		 */
		public function get multiFingerScroll():Boolean { return _multiFingerScroll; }
		public function set multiFingerScroll(value:Boolean):void {
			_multiFingerScroll = value;
		}
		
		public function get content():* { return _content; }
		
		
		/*override public function clone():*{
			
			var v:Vector.<String> = new < String > ["childList", "_verticalScroll", "_horizontalScroll", "_mask" ]
			var clone:ScrollPane = CloneUtils.clone(this, null, v);
			
			CloneUtils.copyChildList(this, clone);	
			
			if (clone.parent)
				clone.parent.addChild(clone);
			else
				this.parent.addChild(clone);
			
			this._content.mask = _mask;
			
			for (var i:Number = 0; i < clone.numChildren; i++) {
				
				if (clone.getChildAt(i).name == _verticalScroll.name) {
					clone._verticalScroll = clone.getChildAt(i) as ScrollBar;
					//clone._verticalScroll.loaded = true;
					//clone._verticalScroll.init();
				}
				else if (clone.getChildAt(i).name == _horizontalScroll.name) {
					clone._horizontalScroll = clone.getChildAt(i) as ScrollBar;
					//clone._horizontalScroll.loaded = true;
					//clone._horizontalScroll.init();
				}
				else if (clone.getChildAt(i).name == _mask.name) {
					clone._mask = clone.getChildAt(i) as Graphic;
				}
				else if (clone.getChildAt(i).name == _content.name) {
					clone._content = clone.getChildAt(i);
					if (clone._mask && clone._content)
						clone._content.mask = clone._mask;
				}
			}
			
			if (clone._mask && clone._content)
				clone._content.mask = clone._mask;
			
			clone.init();
			//clone.createEvents();
			
			return clone;
		}*/
		
		override public function clone():*{
			this.removeChild(_mask);
			this.removeEvents();
			var v:Vector.<String> = cloneExclusions;
			//var v:Vector.<String> = new < String > ["childList", "_verticalScroll", "_horizontalScroll", "_mask", "_content" ];
			v.push("childList", "_verticalScroll", "_horizontalScroll", "_mask", "_content");
			trace(v);
			var clone:ScrollPane = CloneUtils.clone(this, null, v);
			
			CloneUtils.copyChildList(this, clone);	
			trace("Clone:", clone);
			
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
		
		override public function dispose():void {
			super.dispose();
			
			if (_verticalScroll)
				_verticalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			
			if (_horizontalScroll)
				_horizontalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			_mask = null;
			_verticalScroll = null;
			_horizontalScroll = null;
			
		}
		
		override public function displayComplete():void {
			init();
		}
		
		override public function init():void {

			// Check the child list. 
			// Iterate through each item, getting position, width, and height.
			// Check if total items width are larger than the container.
			
			if (!numChildren) return;
			
			var scrollBars:Array = searchChildren(ScrollBar, Array);
			
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
			
			if (!_content){
				for (var j:int = 0; j < numChildren; j++) {
					if (getChildAt(j) is ScrollBar || getChildAt(j) is GestureList || getChildAt(j) == _mask)
						continue;
					else 
						_content = getChildAt(j);
				}
			}
			
			// If one bar is set but not the other, set the other to match.
			if (_verticalScroll && !_horizontalScroll) {
				createHorizontal();
			}
			
			if (!_verticalScroll && _horizontalScroll) {
				createVertical();
			}
			
			if (!_verticalScroll && !_horizontalScroll) {
				// Create the scroll bars if they haven't been caught anywhere else.
				_verticalScroll = new ScrollBar();
				_horizontalScroll = new ScrollBar();
			}
			
			// Create the scroll bar properties that would not be affected by setting out a style.
			
			_verticalMovement = _content.height - height;
			_vertical = true;
			_verticalScroll.contentHeight = _content.height;
			_verticalScroll.height = height;
			
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
			
			// create mask and hitTouch.
			if(!_mask){
				_mask = new Graphic();
				_mask.shape = "rectangle";
				_mask.width = width;
				_mask.height = height;
				addChild(_mask);
				//_content.mask = _mask;
			}
			_content.mask = _mask;
			
			
			createEvents();
			
			loaded = true;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", "loaded"));
		}
		
		private function createVertical():void {
			_verticalScroll = new ScrollBar();
			_verticalScroll.height = _horizontalScroll.width;
			_verticalScroll.fill = _horizontalScroll.fill;
			_verticalScroll.buttonFill = _horizontalScroll.buttonFill;
			if (_verticalScroll.thumbFill)
				_verticalScroll.thumbFill = _horizontalScroll.thumbFill;
		}
		
		private function createHorizontal():void {
			_horizontalScroll = new ScrollBar();
			_horizontalScroll.orientation = "horizontal";
			_horizontalScroll.height = _verticalScroll.width;
			_horizontalScroll.fill = _verticalScroll.fill;
			_horizontalScroll.buttonFill = _verticalScroll.buttonFill;
			if (_verticalScroll.thumbFill)
				_horizontalScroll.thumbFill = _verticalScroll.thumbFill;
		}
		
		public function createEvents():void {
			
			if (contains(_horizontalScroll) || contains(_verticalScroll)) {
				addEventListener(GWGestureEvent.DRAG, onDrag);
				content.addEventListener(GWGestureEvent.DRAG, onDrag);
			}
			addEventListener(GWGestureEvent.SCALE, onScale);
			content.addEventListener(GWGestureEvent.SCALE, onScale);
			
			addEventListener(GWGestureEvent.COMPLETE, onComplete);
			content.addEventListener(GWGestureEvent.COMPLETE, onComplete);
			
			addEventListener(GWGestureEvent.ROTATE, onRotate);
			content.addEventListener(GWGestureEvent.ROTATE, onRotate);
			
			_verticalScroll.addEventListener(StateEvent.CHANGE, onScroll);
			_horizontalScroll.addEventListener(StateEvent.CHANGE, onScroll);
		}
		
		public function removeEvents():void {
			
			if (contains(_horizontalScroll) || contains(_verticalScroll)) 
				this.removeEventListener(GWGestureEvent.DRAG, onDrag);
			this.removeEventListener(GWGestureEvent.SCALE, onScale);
			this.removeEventListener(GWGestureEvent.COMPLETE, onComplete);
			
			this._verticalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			this._horizontalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
		}
		
		public function updateLayout(inWidth:Number, inHeight:Number):void {
			
			width = inWidth;
			height = inHeight;
			
			if(_mask){
				_mask.width = width;
				_mask.height = height;
			}
			
			if (_verticalScroll) {
				_verticalScroll.x = width + scrollMargin;
				_verticalScroll.height = height;
				_verticalScroll.resize(_content.height * _content.scaleY);
				_verticalMovement = _content.height * _content.scaleY - height;
				_verticalScroll.thumbPosition = _content.y / _verticalMovement;
				
				if (_content.height * _content.scaleY > height) {
					if (!(contains(_verticalScroll))) addChild(_verticalScroll);
				} else if (_content.height * _content.scaleY < height) {
					if (contains(_verticalScroll)) removeChild(_verticalScroll);
				}
			}
			
			if (_horizontalScroll) {
				_horizontalScroll.y = height + scrollMargin;
				_horizontalScroll.width = width;
				_horizontalScroll.resize(_content.width * _content.scaleX);
				_horizontalMovement = _content.width * _content.scaleX - width;
				_horizontalScroll.thumbPosition = _content.x / _horizontalMovement;
				
				if (_content.width * _content.scaleX > width) {
					if (!(contains(_horizontalScroll))) addChild(_horizontalScroll);
				} else if (_content.width * _content.scaleX < width) {
					if (contains(_horizontalScroll)) removeChild(_horizontalScroll);
				}
			}
			
			if ( _horizontalScroll || _verticalScroll) {
				if (contains(_horizontalScroll) || contains(_verticalScroll)) {
					addEventListener(GWGestureEvent.DRAG, onDrag);
					content.addEventListener(GWGestureEvent.DRAG, onDrag);
				}
				else {
					removeEventListener(GWGestureEvent.DRAG, onDrag);
				}
			}
		}
		
		public function reset():void {
			if (_verticalScroll)
				_verticalScroll.reset();
			if (_horizontalScroll)
				_horizontalScroll.reset();
				
			_content.x = 0;
			_content.y = 0;
		}
		
		private function onScroll(e:StateEvent):void {
			//trace("StateEvent:", e.value);
			if (e.target == _verticalScroll) {
				_content.y = _verticalMovement * e.value * -1;
			} else if (e.target == _horizontalScroll) {
				_content.x = _horizontalMovement * e.value * -1;
			}
		}
		
		private function onManipulate(e:GWGestureEvent):void {
			//onDrag(e);
			//onScale(e);
		}
		
		public var invertDrag:Boolean = false;
		
		private function onDrag(e:GWGestureEvent):void {
			//e.stopImmediatePropagation();
			
			if (this.parent) {
				if ("clusterBubbling" in parent) {
					if (parent["clusterBubbling"] == true) {
						return;
					}
				}
				
			}
			trace("E.target in !scrollOnPane:", e.target);
			if (!scrollOnPane) {
				
				if (this.parent) {
					passTouchUp();
					return;
				}
			}
			
			if (multiFingerScroll && e.value.n < 2 && this.parent) {
				passTouchUp();
				return;
			}
			
			function passTouchUp():void {
				TouchContainer(parent).x += e.value.drag_dx;
				TouchContainer(parent).y += e.value.drag_dy;
			}
			
			//trace(e);
			
			var newPos:Number;
			
			if (_vertical) {
				// Check the new position won't be further than the limits, and if so, clamp it.
				//trace("Vertical dragging");
				newPos = _content.y;
				
				if (!oldY) {
					oldY = e.value.localY;
					//newPos = oldY;
				}
				else if (oldY) {
					if (!invertDrag)
						newPos += e.value.localY - oldY;
					else
						newPos -= e.value.localY - oldY;
					oldY = e.value.localY;
				}
				// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				// Get the localY of the previous gesture call
				// Get the differential of the previous localY and the new localY
				// (Negative values should move the content upwards, positive values downwards)
				// Assign old localY to current localY.
				// Now clamp and apply differential.
				
				newPos = clampPos(newPos, "vertical");
				
				// Apply the new position.
				_content.y = newPos;
				_verticalScroll.thumbPosition = -newPos / _verticalMovement;
			}
			
			if (_horizontal) {
				
				newPos = _content.x;
				
				if (!oldX) {
					oldX = e.value.localX;
					//newPos = oldX;
				}
				else if (oldX) {
					if (!invertDrag)
						newPos -= e.value.localX  - oldX;
					else
						newPos += e.value.localX - oldX;
						
					oldX = e.value.localX;
				}
				
				// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
				// Get the localX of the previous gesture call
				// Get the differential of the previous localX and the new localX
				// (Negative values should move the content left, positive values right)
				// Assign old localX to current localX.
				// Now clamp and apply differential.
				
				newPos = clampPos(newPos, "horizontal");
				
				
				// Apply the new position.
				_content.x = newPos;
				_horizontalScroll.thumbPosition = -newPos / _horizontalMovement;
			}
		}
		
		private function onComplete(e:GWGestureEvent):void {
			//Reset the position values so the scrollPane will move cumulatively.
			oldX = 0;
			oldY = 0;
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
			
			if (scaleOnPane) {
				if (this.parent) {
					
					DisplayUtils.scaleFromPoint(this.parent, e.value.scale_dsx, e.value.scale_dsy, e.value.stageX, e.value.stageY);
					
					return;
				}
			}
			
			var xShift:Number = e.value.localX - _content.x;
			var yShift:Number = e.value.localY - _content.y;
			//_content.scale += e.value.scale_dsx + e.value.scale_dsy;
			_content.scaleX += e.value.scale_dsx;
			_content.scaleY += e.value.scale_dsy;
			if (_content.height * _content.scaleY > height) {
				
				_verticalScroll.resize(_content.height * _content.scaleY);
				_verticalMovement = _content.height * _content.scaleY - height;
				_verticalScroll.thumbPosition = _content.y / _verticalMovement;
				
				_vertical = true;
				
				if (!(contains(_verticalScroll))) addChild(_verticalScroll);
				
			} else if (_content.height * _content.scaleY < height) {
				
				if (contains(_verticalScroll)) removeChild(_verticalScroll);
				
			}
			if (_content.width * _content.scaleX > width) {
				
				_horizontalScroll.resize(_content.width * _content.scaleX);
				_horizontalMovement = _content.width * _content.scaleX - width;
				_horizontalScroll.thumbPosition = _content.x / _horizontalMovement;
				
				_horizontal = true;
				
				if (!(contains(_horizontalScroll))) addChild(_horizontalScroll);
				
			} else if (_content.width * _content.scaleX < width) {
				
				if (contains(_horizontalScroll)) removeChild(_horizontalScroll);
				
			}
			
			//_content.x -= xShift * _content.scale;
			//_content.y -= yShift * _content.scale;
			if (contains(_horizontalScroll) || contains(_verticalScroll)) {
				addEventListener(GWGestureEvent.DRAG, onDrag);
				//_hit.addEventListener(GWGestureEvent.DRAG, onDrag);
			} else {
				removeEventListener(GWGestureEvent.DRAG, onDrag);
				//_hit.removeEventListener(GWGestureEvent.DRAG, onDrag);
			}
		}
		
		private function onRotate(e:GWGestureEvent):void {
			if (!scrollOnPane) {
				if (this.parent) {
					//this.parent.dispatchEvent(e);
					//TouchContainer(parent).rotation += e.value.rotate_dtheta;
					DisplayUtils.rotateAroundPoint(this.parent, e.value.rotate_dtheta, e.value.stageX, e.value.stageY);
					//trace("Target:", e.target);
					return;
				}
			}
		}
	}
}