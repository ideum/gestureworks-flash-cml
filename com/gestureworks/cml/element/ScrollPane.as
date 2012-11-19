package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
		
	/**
	 * 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 	
		
		
	 * </codeblock>
	 * @author Ideum
	 */
	
	public class ScrollPane extends Container
	{				
		private var _itemList:List;
		private var _verticalScroll:ScrollBar;
		private var _horizontalScroll:ScrollBar;
		private var _vertical:Boolean = false;
		private var _horizontal:Boolean = false;
		private var _mask:Graphic;
		private var _hit:TouchContainer;
		private var _vertStyleSet:Boolean = false;
		private var _horizStyleSet:Boolean = false;
		
		private var _horizontalMovement:Number;
		private var _verticalMovement:Number;
		
		public function ScrollPane()
		{
			super();
			_itemList = new List();
		}	
		
		private var _paneWidth:Number;
		/**
		 * Set the width of the window pane of the scrollPane.
		 */
		public function get paneWidth():Number { return _paneWidth; }
		public function set paneWidth(value:Number):void {
			_paneWidth = value;
		}
		
		private var _paneHeight:Number;
		/**
		 * Set the height of the window pane of the scrollPane.
		 */
		public function get paneHeight():Number { return _paneHeight; }
		public function set paneHeight(value:Number):void {
			_paneHeight = value;
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
		 * For all other custom styling, a <ScrollBar> item should be added in CML, or through the
		 * childToList function in AS3, and the ScrollPane class will automatically pull styles from that.
		 */
		public function get scrollThickness():Number { return _scrollThickness; }
		public function set scrollThickness(value:Number):void {
			_scrollThickness = value;
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (_hit) {
				_hit.removeEventListener(GWGestureEvent.DRAG, onDrag);
				_hit.removeEventListener(GWGestureEvent.SCALE, onScale);
			}
			
			if (_verticalScroll)
				_verticalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			
			if (_horizontalScroll)
				_horizontalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			_hit = null;
			_mask = null;
			_verticalScroll = null;
			_horizontalScroll = null;
			
			_itemList = null;
		}
		
		override public function displayComplete():void {
			init();
		}
		
		public function init():void {
			// Check the child list. 
			// Iterate through each item, getting position, width, and height.
			// Check if total items width are larger than the container.
			
			_itemList.array = childList.getValueArray();
			
			// Check if there's any scroll bars already set.
			for (var i:Number = 0; i < _itemList.length; i++) {
				if (_itemList.array[i] is ScrollBar) {
					switch(_itemList.array[i].orientation) {
						case "vertical":
							_verticalScroll = _itemList.array[i];
							removeChild(_itemList.array[i]);
							_itemList.array.splice(i, 1);
							_vertStyleSet = true;
							i--;
							break;
						case "horizontal":
							_horizontalScroll = _itemList.array[i];
							removeChild(_itemList.array[i]);
							_itemList.array.splice(i, 1);
							_horizStyleSet = true;
							i--;
							break;
					}
				}
				if (_itemList.array[i] is TouchContainer) {
					_hit = _itemList.array[i];
					addChild(_hit);
					_hit.disableNativeTransform = true;
					removeChild(_itemList.array[i]);
					_itemList.array.splice(i, 1);
					i--;
				}
			}
			
			// If one bar is set but not the other, set the other to match.
			if (_verticalScroll && !_horizontalScroll) {
				_horizontalScroll = new ScrollBar();
				_horizontalScroll.orientation = "horizontal";
				_horizontalScroll.height = _verticalScroll.width;
				_horizontalScroll.fill = _verticalScroll.fill;
				_horizontalScroll.buttonFill = _verticalScroll.buttonFill;
				if (_verticalScroll.thumbFill)
					_horizontalScroll.thumbFill = _verticalScroll.thumbFill;
			}
			
			if (!_verticalScroll && _horizontalScroll) {
				_verticalScroll = new ScrollBar();
				_verticalScroll.height = _horizontalScroll.width;
				_verticalScroll.fill = _horizontalScroll.fill;
				_verticalScroll.buttonFill = _horizontalScroll.buttonFill;
				if (_verticalScroll.thumbFill)
					_verticalScroll.thumbFill = _horizontalScroll.thumbFill;
			}
			if (!_verticalScroll && !_horizontalScroll) {
				// Create the scroll bars if they haven't been caught anywhere else.
				_verticalScroll = new ScrollBar();
				_horizontalScroll = new ScrollBar();
			}
			
			// Create the scroll bar properties that would not be affected by setting out a style.
			_verticalMovement = _itemList.array[0].height - paneHeight;
			_vertical = true;
			_verticalScroll.contentHeight = _itemList.array[0].height;
			_verticalScroll.height = paneHeight;
			// Check if the scroll's thickness has already been set. If not, use the default or thickness listed in CML.
			if (!_verticalScroll.width || _verticalScroll.width <= 0){
				_verticalScroll.width = _scrollThickness;
			}
			if(!_vertStyleSet){
				_verticalScroll.init();
			}
			_verticalScroll.x = paneWidth + scrollMargin;
			
			// Check if the scroll bar is needed. If so, add to display list.
			if (_itemList.array[0].height > paneHeight) {
				addChild(_verticalScroll);
				this.width = paneWidth + _verticalScroll.width;
			}
			
			_horizontalMovement = _itemList.array[0].width - paneWidth;
			_horizontal = true;
			_horizontalScroll.orientation = "horizontal";
			// Check if the scroll's thickness has already been set. If not, use the default or thickness listed in CML.
			if (!_horizontalScroll.height || _horizontalScroll.height <= 0 ){
				_horizontalScroll.height = _scrollThickness;
			}
			_horizontalScroll.contentWidth = _itemList.array[0].width;
			_horizontalScroll.width = paneWidth;
			if(!_horizStyleSet) {
				_horizontalScroll.init();
			}
			_horizontalScroll.y = paneHeight + scrollMargin;
			
			if (_itemList.array[0].width > paneWidth) {
				addChild(_horizontalScroll);
				this.height = _horizontalScroll.width + paneHeight;
			}
			
			// create mask and hitTouch.
			
			_mask = new Graphic();
			_mask.shape = "rectangle";
			_mask.width = paneWidth;
			_mask.height = paneHeight;
			addChild(_mask);
			_itemList.array[0].mask = _mask;
			
			if (_hit) {
				_hit.width = paneWidth;
				_hit.height = paneHeight;
				_hit.init();
				addChild(_hit);
				
				// Use a graphic to give the touch container some "context", otherwise
				// it's just empty space. This also works to form the pane's border.
				var _hitBox:Graphic = new Graphic();
				_hitBox.shape = "rectangle";
				_hitBox.width = paneWidth + _paneStrokeMargin;
				_hitBox.height = paneHeight + _paneStrokeMargin;
				_hitBox.fillAlpha = 0;
				_hitBox.lineStroke = _paneStroke;
				_hitBox.lineColor = _paneStrokeColor;
				if (_paneStrokeMargin > 0) {
					_hitBox.x -= _paneStrokeMargin / 2;
					_hitBox.y -= _paneStrokeMargin / 2;
				}
				_hit.addChild(_hitBox);
				_hit.addEventListener(GWGestureEvent.DRAG, onDrag);
				_hit.addEventListener(GWGestureEvent.SCALE, onScale);
			}
			
			
			
			_verticalScroll.addEventListener(StateEvent.CHANGE, onScroll);
			_horizontalScroll.addEventListener(StateEvent.CHANGE, onScroll);
		}
		
		private function onScroll(e:StateEvent):void {
			if (e.target == _verticalScroll) {
				_itemList.array[0].y = _verticalMovement * e.value * -1;
			} else if (e.target == _horizontalScroll) {
				_itemList.array[0].x = _horizontalMovement * e.value * -1;
			}
		}
		
		private function onDrag(e:GWGestureEvent):void {
			
			var newPos:Number;
			if (_vertical) {
				// Check the new position won't be further than the limits, and if so, clamp it.
				newPos = _itemList.array[0].y + e.value.drag_dy;
				newPos = clampPos(newPos, "vertical");
				// Apply the new position.
				_itemList.array[0].y = newPos;
				_verticalScroll.thumbPosition = -newPos / _verticalMovement;
			}
			
			if (_horizontal) {
				// Check the new position won't be further than the limits, and if so, clamp it.
				newPos = _itemList.array[0].x + e.value.drag_dx;
				newPos = clampPos(newPos, "horizontal");
				// Apply the new position.
				_itemList.array[0].x = newPos;
				_horizontalScroll.thumbPosition = -newPos / _horizontalMovement;
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
		
		private function onScale(e:GWGestureEvent):void {
			var xShift:Number = e.value.localX - _itemList.array[0].x;
			var yShift:Number = e.value.localY - _itemList.array[0].y;
			_itemList.array[0].scale += e.value.scale_dsx + e.value.scale_dsy;
			if (_itemList.array[0].height * _itemList.array[0].scale > paneHeight) {
				
				_verticalScroll.resize(_itemList.array[0].height * _itemList.array[0].scale);
				_verticalMovement = _itemList.array[0].height * _itemList.array[0].scale - paneHeight;
				_verticalScroll.thumbPosition = _itemList.array[0].y / _verticalMovement;
				
				_vertical = true;
				
				if (!(contains(_verticalScroll))) addChild(_verticalScroll);
				
			} else if (_itemList.array[0].height * _itemList.array[0].scale < paneHeight) {
				
				if (contains(_verticalScroll)) removeChild(_verticalScroll);
				
			}
			if (_itemList.array[0].width * _itemList.array[0].scale > paneWidth) {
				
				_horizontalScroll.resize(_itemList.array[0].width * _itemList.array[0].scale);
				_horizontalMovement = _itemList.array[0].width * _itemList.array[0].scale - paneWidth;
				_horizontalScroll.thumbPosition = _itemList.array[0].x / _horizontalMovement;
				
				_horizontal = true;
				
				if (!(contains(_horizontalScroll))) addChild(_horizontalScroll);
				
			} else if (_itemList.array[0].width * _itemList.array[0].scale < paneWidth) {
				
				if (contains(_horizontalScroll)) removeChild(_horizontalScroll);
				
			}
			
			//_itemList.array[0].x -= xShift * _itemList.array[0].scale;
			//_itemList.array[0].y -= yShift * _itemList.array[0].scale;
		}
	}
}