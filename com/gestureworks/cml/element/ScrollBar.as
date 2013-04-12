package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Matrix;

	/**
	 * 
	 */
	public class ScrollBar extends TouchContainer
	{
		public var railGraphic:Graphic;
		public var railTouch:TouchContainer;
		
		public var scrollBtn1:Graphic;
		public var touchBtn1:TouchContainer;
		
		public var scrollBtn2:Graphic;
		public var touchBtn2:TouchContainer;
		
		public var thumb:Graphic;
		public var thumbTouch:TouchContainer;
		
		public var movementRail:Number;
		
		
		
		/**
		 * Constructor
		 */
		public function ScrollBar() 
		{			
			super();
			
			this.mouseChildren = true;
		}		
		
				
		
		private var _scrollPosition:Number;
		/**
		 * The position of the scroll thumb on the rail. This is to dispatch events to the 
		 * ScrollPane class to set the position of the content, it should not be accessed
		 * externally.
		 */
		public function get scrollPosition():Number { return _scrollPosition; }
		public function set scrollPosition(value:Number):void {
			_scrollPosition = value;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _scrollPosition, true));
		}
		
		
		
		/**
		 * This sets the thumbPosition, this is not to be accessed externally in CML or used in Actionscript,
		 * it is solely here for the ScrollPane class to reach when content is dragged.
		 */
		public function set thumbPosition(value:Number):void {
			if (orientation == "vertical") {
				if (buttonVisible)
					thumb.y = movementRail * value + scrollBtn1.height;
				else
					thumb.y = movementRail * value;
			}
			else if (orientation == "horizontal") {
				if (buttonVisible)
					thumb.x = movementRail * value + scrollBtn1.width;
				else
					thumb.x = movementRail * value;
			}
			clampThumb();
		}
		
		private var _width:Number = 0;
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
			super.width = value;
			if (_loaded)
				resizeGraphics();
		}
		
		private var _height:Number = 0;
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
			super.height = value;
			if (_loaded)
				resizeGraphics();
		}
		
		private var _loaded:Boolean = false;
		/**
		 * Checks to see if the element is loaded.
		 * Setter is only for cloning to be available to set a scrollbar is loaded, do not set this variable.
		 */
		public function get loaded():Boolean { return _loaded; }
		/*public function set loaded(value:Boolean):void {
			_loaded = value;
		}*/
		
		private var _orientation:String = "vertical";
		/**
		 * Designates the orientation of the scrollbar, "horizontal" or "vertical"
		 * @default vertical
		 */
		public function get orientation():String { return _orientation; }
		public function set orientation(value:String):void {
			_orientation = value;
		}
		
		// Colors and stuff.
		private var _fill:uint = 0x111111;
		/**
		 * The scrollbar fill (background color).
		 */
		public function get fill():uint { return _fill; }
		public function set fill(value:uint):void {
			_fill = value;
		}
		
		private var _buttonFill:uint = 0x555555;
		/**
		 * The color of the button's background.
		 */
		public function get buttonFill():uint { return _buttonFill; }
		public function set buttonFill(value:uint):void {
			_buttonFill = value;
		}
		
		
		private var _buttonAlpha:Number = 1.0;
		/**
		 * The color of the button's background.
		 */
		public function get buttonAlpha():Number { return _buttonAlpha; }
		public function set buttonAlpha(value:Number):void {
			_buttonAlpha = value;
		}
		
		
		private var _buttonVisible:Boolean = true;
		/**
		 * The color of the button's background.
		 */
		public function get buttonVisible():Boolean { return _buttonVisible; }
		public function set buttonVisible(value:Boolean):void {
			_buttonVisible = value;
		}			
		
		
		// TO DO: Button stroke, button triangle
		
		private var _thumbFill:uint;
		/**
		 * The color of the central thumb that slides up and down the scrollbar.
		 * If no color is set, it will default to match the button styles.
		 */
		public function get thumbFill():uint { return _thumbFill; }
		public function set thumbFill(value:uint):void {
			_thumbFill = value;
		}
		
		// TO DO: Thumb stroke, thumb gradient,
		
		// Shape, corner radius
		private var _shape:String = "roundRectangle";
		/**
		 * Sets the shape of the thumb, either "rectangle", or "roundRectangle".
		 * @default roundRectangle
		 */
		public function get shape():String { return _shape; }
		public function set shape(value:String):void {
			_shape = value;
		}
		
		private var _cornerHeight:Number = 10;
		/**
		 * Sets part of the corner radius for the ellipse used to round the rectangle of the thumb. Shape must be "roundRectangle" for this to be used.
		 * @default 10
		 */
		public function get cornerHeight():Number { return _cornerHeight; }
		public function set cornerHeight(value:Number):void {
			_cornerHeight = value;
		}
		
		private var _cornerWidth:Number = 10;
		/**
		 * Sets part of the corner radius for the ellipse used to round the rectangle of the thumb. Shape must be "roundRectangle" for this to be used.
		 * @default 10
		 */
		public function get cornerWidth():Number { return _cornerWidth; }
		public function set cornerWidth(value:Number):void {
			_cornerWidth = value;
		}
		
		// Size of the item the scollbar's container is holding.
		private var _contentHeight:Number = 100;
		/**
		 * The height of the content that needs to be scrolled.
		 */
		public function get contentHeight():Number { return _contentHeight; }
		public function set contentHeight(value:Number):void {
			_contentHeight = value;
		}
		
		private var _contentWidth:Number = 100;
		/**
		 * The width of the content that needs to be scrolled;
		 */
		public function get contentWidth():Number { return _contentWidth; }
		public function set contentWidth(value:Number):void {
			_contentWidth = value;
		}
		
		/**
		 * CML display callback Initialisation
		 */
		override public function displayComplete():void
		{			
			init();
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{ 
			if(!railTouch){
				railTouch = new TouchContainer();
				railTouch.gestureEvents = true;
				addChild(railTouch);
			}
			
			if(!touchBtn1){
				touchBtn1 = new TouchContainer();
				touchBtn1.gestureEvents = true;
				touchBtn1.gestureList = { "n-tap":true };
				addChild(touchBtn1);
			}
			
			if (!touchBtn2) {
			touchBtn2 = new TouchContainer();
			touchBtn2.gestureEvents = true;
			touchBtn2.gestureList = { "n-tap":true };
			addChild(touchBtn2);
			}
			
			if (!thumbTouch){
			thumbTouch = new TouchContainer();
			thumbTouch.gestureEvents = true;
			thumbTouch.gestureList = { "n-drag":true };
			thumbTouch.disableNativeTransform = true;
			addChild(thumbTouch);
			}
			
			// Create the rail.
			if (!railGraphic){
				railGraphic = new Graphic();
				railGraphic.color = _fill;
				railGraphic.height = this.height;
				railGraphic.width = this.width;
				railGraphic.lineStroke = 0;
				railGraphic.shape = "rectangle";
			}
			
			// Create and position buttons based upon either orientation.
			if (_orientation == "vertical" && !scrollBtn1 && !scrollBtn2) {
				
				if (buttonVisible) {
					scrollBtn1 = new Graphic();
					scrollBtn1.color = _buttonFill;
					scrollBtn1.alpha = buttonAlpha;
					scrollBtn1.width = this.width;
					scrollBtn1.height = this.width;
					scrollBtn1.shape = "rectangle";
					scrollBtn1.lineStroke = 0;
					
					scrollBtn2 = new Graphic();
					scrollBtn2.color = _buttonFill;
					scrollBtn2.alpha = buttonAlpha;
					scrollBtn2.width = this.width;
					scrollBtn2.height = this.width;
					scrollBtn2.shape = "rectangle";
					scrollBtn2.lineStroke = 0;
					scrollBtn2.y = this.height - scrollBtn2.height;
				}
				
				if (buttonVisible) {
					railGraphic.height = this.height - scrollBtn1.height - scrollBtn2.height;
					railGraphic.y = scrollBtn1.height;
				}
				else {
					railGraphic.height = this.height;
				}
			}
			else if (_orientation == "horizontal" && !scrollBtn1 && !scrollBtn2) {
				
				if (buttonVisible) {
					scrollBtn1 = new Graphic();
					scrollBtn1.shape = "rectangle";
					scrollBtn1.color = _buttonFill;
					scrollBtn1.alpha = buttonAlpha;				
					scrollBtn1.fill = "color";
					scrollBtn1.width = this.height;
					scrollBtn1.height = this.height;
					scrollBtn1.lineStroke = 0;
					scrollBtn1.y = railGraphic.y;
					
					scrollBtn2 = new Graphic();
					scrollBtn2.shape = "rectangle";
					scrollBtn2.color = _buttonFill;
					scrollBtn2.alpha = buttonAlpha;	
					scrollBtn2.width = this.height;
					scrollBtn2.height = this.height;
					scrollBtn2.x = this.width - scrollBtn2.width;
					scrollBtn2.lineStroke = 0;
					scrollBtn2.y = railGraphic.y;
				}
				
				if (buttonVisible) {
					railGraphic.width = this.width - scrollBtn1.width - scrollBtn2.width;
					railGraphic.x = scrollBtn1.width;
				}
				else {
					railGraphic.width = this.width;
				}				

			}
			
			if(!(railTouch.contains(railGraphic)))
				railTouch.addChild(railGraphic);
				
			if (buttonVisible) {	
				if(!(touchBtn1.contains(scrollBtn1)))
					touchBtn1.addChild(scrollBtn1);
				if(!(touchBtn2.contains(scrollBtn2)))
					touchBtn2.addChild(scrollBtn2);
			}
			
			// Create the thumb. 
				// Create the rectangle.
				// Round corners if necessary.
				// Etc.
			
			if(!thumb){
				thumb = new Graphic();
				thumb.shape = _shape;
				thumb.lineStroke = 0;
			}
			
			if (_orientation == "vertical"){
				thumb.width = this.width;
				thumb.height = (this.height / contentHeight) * railGraphic.height;
				movementRail = railGraphic.height - thumb.height;
				thumb.y = railGraphic.y;
			}
			else if (_orientation == "horizontal") {
				thumb.height = this.height;
				thumb.width = (this.width / contentWidth) * railGraphic.width;
				movementRail = railGraphic.width - thumb.width;
				thumb.x = railGraphic.x;
			}
			
			if (_shape == "roundRectangle") {
				thumb.cornerHeight = _cornerHeight;
				thumb.cornerWidth = _cornerWidth;
			}
			
			//Set thumb colors.
			if (!_thumbFill)
				_thumbFill = _buttonFill;
			
			thumb.color = _thumbFill;
			thumbTouch.addChild(thumb);
			
			_loaded = true;
			
			createEvents();
		}
		
		public function createEvents():void {
			if (buttonVisible) {
				touchBtn1.addEventListener(GWGestureEvent.TAP, onTap1);
				touchBtn2.addEventListener(GWGestureEvent.TAP, onTap2);
			}			
			thumbTouch.addEventListener(GWGestureEvent.DRAG, onDrag);
			
			if (parent && parent is ScrollPane && !parent["_hit"]) {
				thumbTouch.addEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin);
				thumbTouch.addEventListener(GWGestureEvent.RELEASE, onRelease);
			}
			thumbTouch.addEventListener(GWGestureEvent.COMPLETE, onComplete);			
		}
		
		private function onTap1(e:GWGestureEvent):void {
			switch(_orientation) {
				case "vertical":
					thumb.y -= movementRail * 0.1;
					clampThumb();
					// Dispatch position event.
					scrollPosition = (thumb.y - scrollBtn1.height) / movementRail;
					break;
				case "horizontal":
					thumb.x -= movementRail * 0.1;
					clampThumb();
					// Dispatch position event.
					scrollPosition = (thumb.x - scrollBtn1.width) / movementRail;
					break;
			}
		}
		
		private function onTap2(e:GWGestureEvent):void {
			
			// Check the orientation, and add a set amount of movement in that direction.
			switch(_orientation) {
				case "vertical":
					thumb.y += movementRail * 0.1;
					clampThumb();
					// Dispatch position event.
					scrollPosition = (thumb.y - scrollBtn1.height) / movementRail;
					break;
				case "horizontal":
					thumb.x += movementRail * 0.1;
					//thumb.y = thumbTouch.y;
					clampThumb();
					// Dispatch position event.
					scrollPosition = (thumb.x - scrollBtn1.width) / movementRail;
					break;
			}
		}
		
		public var invertDrag:Boolean = false;
		private var newPos:Number = 0;
		
		private function onDrag(e:GWGestureEvent):void {		
			e.stopImmediatePropagation();
			
			
			
			if(_orientation == "vertical") {
				// Check the new position won't be further than the limits, and if so, clamp it.
				//trace("Vertical dragging");
				//newPos = _content.y;
				
				if (!oldY) {
					oldY = e.value.localY;
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
				
				//trace(oldY, newPos, e.value.localY);
				
				// Apply the new position.
				thumb.y = newPos;
				if (buttonVisible)
					scrollPosition = (thumb.y - scrollBtn1.height) / movementRail;
				else
					scrollPosition = thumb.y / movementRail;
					
					
				//trace(e.value.localY, thumb.y);
			}			
			
			if (_orientation == "horizontal") {
				
				//newPos = _content.x;
				
				if (!oldX) {
					oldX = e.value.localX;
					//newPos = oldX;
				}
				else if (oldX) {
					if (invertDrag)
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
				thumb.x = newPos;
				if (buttonVisible)
					scrollPosition = (thumb.x - scrollBtn1.width) / movementRail;
				else
					scrollPosition = thumb.x / movementRail;
			}			
			
			/*
			if(_orientation == "vertical") {
				thumb.y += e.value.drag_dy;
				clampThumb();
				// Dispatch the scroll position.
				if (buttonVisible)
					scrollPosition = (thumb.y - scrollBtn1.height) / movementRail;
				else
					scrollPosition = thumb.y / movementRail;
			}
			else if (_orientation == "horizontal") {
				thumb.x += e.value.drag_dx;
				clampThumb();
				// Dispatch the scroll position.
				if (buttonVisible)
					scrollPosition = (thumb.x - scrollBtn1.width) / movementRail;
				else
					scrollPosition = thumb.x / movementRail;
			}
			*/
		}
		
		
		
		private function onBegin(e:GWTouchEvent):void {	
			var p1:TouchContainer = parent as TouchContainer;
			var p2:TouchContainer = p1.parent as TouchContainer;	
			p2.disableNativeTransform = true;			
		}
		
		private function onRelease(e:GWGestureEvent):void {
			var p1:TouchContainer = parent as TouchContainer;
			var p2:TouchContainer = p1.parent as TouchContainer;
	
			p1.cO.pointArray.length = 0;
			p2.cO.pointArray.length = 0;
			p2.disableNativeTransform = false;
						
		}
	
		private var oldX:Number = 0;
		private var oldY:Number = 0;
		
		private function onComplete(e:GWGestureEvent):void {
			//Reset the position values so the scrollPane will move cumulatively.
			oldX = 0;
			oldY = 0;
		}
		
		
		private function clampPos(pos:Number, direction:String):Number {			
			if (direction == "vertical"){
				if (pos < railGraphic.y) {
					pos = railGraphic.y;
				}
				if (pos > (railGraphic.y + movementRail)) {
					pos = railGraphic.y + movementRail;
				}
			}
			if (direction == "horizontal") {
				if (pos < railGraphic.x) 
				pos = railGraphic.x;
				if (pos > railGraphic.x + movementRail) 
				pos = railGraphic.x + movementRail;
			}
			
			return pos;
		}
		
			
		private function clampThumb():void {
			// Check the orientation, and make sure the thumb hasn't slid off the rail.
			
			if (_orientation == "vertical"){
				if (thumb.y < railGraphic.y) {
					thumb.y = railGraphic.y;
					////trace("Clamping rail min.");
				}
				if (thumb.y > (railGraphic.y + movementRail)) {
					thumb.y = railGraphic.y + movementRail;
					////trace("Clamping rail max");
				}
			}
			if (_orientation == "horizontal") {
				if (thumb.x < railGraphic.x) thumb.x = railGraphic.x;
				if (thumb.x > railGraphic.x + movementRail) thumb.x = railGraphic.x + movementRail;
			}
		}
		
		private function resizeGraphics():void {
			
			if (orientation == "vertical") {
				
				if (buttonVisible) {
					scrollBtn1.width = width;
					scrollBtn1.height = width;
					
					scrollBtn2.width = width;
					scrollBtn2.height = width;
					scrollBtn2.y = height - scrollBtn2.height;
					railGraphic.height = height - scrollBtn1.height - scrollBtn2.height;
				}
				else {
					railGraphic.height = height;
				}
				resize(_contentHeight);
			} else if (orientation == "horizontal") {
				if (buttonVisible) {
					scrollBtn1.height = height;
					scrollBtn1.width = height;
					
					scrollBtn2.height = height;
					scrollBtn2.width = height;
					scrollBtn2.x = width - scrollBtn2.width;
					railGraphic.width = width - scrollBtn1.width - scrollBtn2.width;
				}
				else {
					railGraphic.width = width;
				}
				
				resize(_contentWidth);
			}
			
		}
		
		/**
		 * Used by the ScrollPane class to resize the scrollbar when scrollable content is scaled larger or smaller.
		 * @param	newDimension
		 */
		public function resize(newDimension:Number):void {
			if (_orientation == "vertical") {
				contentHeight = newDimension;
				thumb.width = width;
				thumb.height = (height / contentHeight) * railGraphic.height;
				movementRail = railGraphic.height - thumb.height;
				if (buttonVisible) {
					railGraphic.height = this.height - scrollBtn1.height - scrollBtn2.height;
				}
				else {
					railGraphic.height = this.height;
				}
				//thumb.y = railGraphic.y;
			} else if (_orientation == "horizontal") {
				contentWidth = newDimension;
				thumb.height = height;
				thumb.width = (width / contentWidth) * railGraphic.width;
				
				movementRail = railGraphic.width - thumb.width;
				//thumb.x = railGraphic.x;
			}
		}
		
		override public function clone():*{
			//clone.displayComplete();
			//var v:Vector.<String> = new < String > ["childList", "initial", "hit", "up", "down", "over", "out",
			//"mouseUp", "mouseDown", "mouseOver", "mouseOut", "touchUp", "touchDown", "touchOver", "touchOut"];
			
			var v:Vector.<String> = new < String > ["railTouch", "railGraphic", "touchBtn1", "scrollBtn1", "touchBtn2", "scrollBtn2", "thumbTouch", "thumb" ];
			
			var clone:ScrollBar = CloneUtils.clone(this, null, v);
			
			if (clone.parent)
				clone.parent.addChild(clone);
			else
				this.parent.addChild(clone);
			
			for (var i:Number = 0; i < clone.numChildren; i++) {
				if (railTouch && clone.getChildAt(i).name == railTouch.name) {
					clone.railTouch = clone.getChildAt(i) as TouchContainer;
					clone.railGraphic = clone.railTouch.getChildAt(0) as Graphic;
				}
				else if (touchBtn1 && clone.getChildAt(i).name == touchBtn1.name) {
					clone.touchBtn1 = clone.getChildAt(i) as TouchContainer;
					if (clone.buttonVisible)
						clone.scrollBtn1 = clone.touchBtn1.getChildAt(0) as Graphic;
				}
				else if (touchBtn2 && clone.getChildAt(i).name == touchBtn2.name) {
					clone.touchBtn2 = clone.getChildAt(i) as TouchContainer;
					if (clone.buttonVisible)
						clone.scrollBtn2 = clone.touchBtn2.getChildAt(0) as Graphic;
				}
				else if (thumbTouch && clone.getChildAt(i).name == thumbTouch.name) {
					clone.thumbTouch = clone.getChildAt(i) as TouchContainer;
					clone.thumb = clone.thumbTouch.getChildAt(0) as Graphic;
				}
			}
			
			clone.createEvents();
			
			return clone;
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			
			if (touchBtn1)
				touchBtn1.removeEventListener(GWGestureEvent.TAP, onTap1);
			if (touchBtn2)
				touchBtn2.removeEventListener(GWGestureEvent.TAP, onTap2);
			
			thumbTouch.removeEventListener(GWGestureEvent.DRAG, onDrag);
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			touchBtn1 = null;
			scrollBtn1 = null;
			
			touchBtn2 = null;
			scrollBtn2 = null;
			
			thumbTouch = null;
			thumb = null;
			
			railTouch = null;
			railGraphic = null;
		}
		

	}
}