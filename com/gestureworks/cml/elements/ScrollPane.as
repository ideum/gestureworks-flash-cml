package com.gestureworks.cml.elements {
	import com.gestureworks.core.TouchSprite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	/**
	 * 
	 * 
	 * usage:
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
	 * </codeblock> 
	 */
	public class ScrollPane extends TouchContainer {
		private static const VERTICAL:String = "vertical";
		private static const HORIZONTAL:String = "horizontal";
		
		///public get/set vars used in cml
		private var _vertical:Boolean = true;
		private var _horizontal:Boolean = true;
		private var _scrollMargin:Number = 5;
		private var _scrollThickness:Number = 30;
		private var _invertDrag:Boolean = false;
		private var _autohide:Boolean = false;
		private var _autohideSpeed:Number = 0.5;
		
		//required child elements
		private var verticalScroll:ScrollBar;
		private var horizontalScroll:ScrollBar;
		private var content:DisplayObject;
		private var maskGraphic:Sprite;
		
		public function ScrollPane(_vto:Object=null) {
			super(_vto);
			super.mouseChildren = true;
			super.nativeTransform = false;
		}
		
		override public function init():void {
			content = fetchContent();
			if (!content) {
				trace('Error: ScrollPane requires that one child is not a ScrollBar. Aborting initialization.');
				return;
			}
			initScrollBars();
			initMask();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function fetchContent():DisplayObject {
			var displayObject:DisplayObject;
			var target:DisplayObject;
			var i:int;
			var length:int=super.numChildren;
			for (i = 0; i < length; i++) {
				displayObject = getChildAt(i);
				if (!(displayObject is ScrollBar)) {
					target = displayObject;
					break;
				}
			}
			return target;
		}
		
		private function initMask():void {
			maskGraphic = new Sprite();
			addChild(maskGraphic);
			maskGraphic.graphics.beginFill(0x000000, 1);
			maskGraphic.graphics.drawRect(0, 0, width, height);
			maskGraphic.graphics.endFill();
			content.mask = maskGraphic;
		}
		
		private function initScrollBars():void {
			//TODO: Scrollbar style inheritence logic
			var scrollBars:Array = searchChildren(ScrollBar, Array);
			var scrollBar:ScrollBar;
			switch(scrollBars.length) {
				case 0: //no scrollbars, initialize both
					scrollBars.push(initNewScrollBar(VERTICAL));
				case 1: //1 scrollbar, initialize other
					if (scrollBars[0].orientation == VERTICAL) {
						scrollBars.push(initNewScrollBar(HORIZONTAL));
					} else {
						scrollBars.push(initNewScrollBar(VERTICAL));
					}
				default: //get references to the first two 'distinct' scrollbars
					verticalScroll = getScrollbarByOrientation(scrollBars, VERTICAL);
					horizontalScroll = getScrollbarByOrientation(scrollBars, HORIZONTAL);
			}
			//position scrollbars
			width = width;
			height = height;
			
			//disable or enable scrollbars accordingly
			vertical = _vertical;
			horizontal = _horizontal;
			
			swapChildren(content, verticalScroll);
			swapChildren(verticalScroll, horizontalScroll);
		}
		
		/**
		 * searches through the supplied array for the first instance of a scrollbar with the desired orientation
		 * returning the result.
		 * @param	array Array of ScrollBars
		 * @param	orientation 'vertical' or 'horizontal'
		 * @return	ScrollBar instance with desired orientation, null if one was not in the array
		 */
		private function getScrollbarByOrientation(array:Array, orientation:String):ScrollBar {
			var scrollBar:ScrollBar;
			for (var i:int = 0; i < array.length; i++) {
				if (array[i].orientation == orientation) {
					scrollBar = array[i];
					break;
				}
			}
			return scrollBar;
		}
		
		/**
		 * Instantiates a new ScrollBar with the desired orientation, adds it to the display list and returns it.
		 * @param	orientation
		 * @return a new ScrollBar instance with the desired orientation
		 */
		private function initNewScrollBar(orientation:String):ScrollBar {
			var scrollBar:ScrollBar = new ScrollBar();
			scrollBar.orientation = orientation;
			addChild(scrollBar);
			return scrollBar;
		}
		
		private function onEnterFrame(e:Event = null):void {
			resize();
		}
		
		public function resize():void {
			var box:Rectangle = content.getBounds(content);
			verticalScroll.resize(height);
			horizontalScroll.resize(width);
		}
		
		/**
		 * 
		 */
		override public function set width(value:Number):void {
			super.width = value;
			if(verticalScroll) {
				verticalScroll.x = value + scrollMargin;
			}
		}
		
		/**
		 * 
		 */
		override public function set height(value:Number):void {
			super.height = value;
			if (horizontalScroll) {
				horizontalScroll.y = value + scrollMargin;
			}
		}
		
		public function get vertical():Boolean {
			return _vertical;
		}
		
		/**
		 * 
		 */
		public function set vertical(value:Boolean):void {
			if (verticalScroll) {
				verticalScroll.visible = value;
				verticalScroll.mouseEnabled = value;
			}
			_vertical = value;
		}
		
		public function get horizontal():Boolean {
			return _horizontal;
		}
		
		/**
		 * 
		 */
		public function set horizontal(value:Boolean):void {
			if (horizontalScroll) {
				horizontalScroll.visible = value;
				horizontalScroll.mouseEnabled = value;
			}
			_horizontal = value;
		}
		
		public function get scrollMargin():Number {
			return _scrollMargin;
		}
		
		/**
		 * 
		 */
		public function set scrollMargin(value:Number):void {
			_scrollMargin = value;
		}
		
		public function get scrollThickness():Number {
			return _scrollThickness;
		}
		
		/**
		 * 
		 */
		public function set scrollThickness(value:Number):void {
			_scrollThickness = value;
		}
		
		public function get invertDrag():Boolean {
			return _invertDrag;
		}
		
		/**
		 * 
		 */
		public function set invertDrag(value:Boolean):void {
			_invertDrag = value;
		}
		
		public function get autohide():Boolean {
			return _autohide;
		}
		
		/**
		 * 
		 */
		public function set autohide(value:Boolean):void {
			_autohide = value;
		}
		
		public function get autohideSpeed():Number {
			return _autohideSpeed;
		}
		
		/**
		 * 
		 */
		public function set autohideSpeed(value:Number):void {
			_autohideSpeed = value;
		}
		
		
		override public function dispose():void {
			//TODO: ...destroy!
			super.dispose();
		}
		
		public function reset():void {
			
		}
		
		public function updateLayout(width:Number, height:Number):void {
			
		}
	}

}