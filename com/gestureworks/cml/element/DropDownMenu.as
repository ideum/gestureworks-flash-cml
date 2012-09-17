package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.element.TextElement;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.events.*;
	import com.gestureworks.cml.events.StateEvent;
	import org.tuio.*;
	
	/**
	 * ...
	 * @author josh
	 */
	public class DropDownMenu extends ElementFactory
	{
		private var _open:Boolean = false;
		private var _currentSelection:String;
		private var _itemBackgrounds:Array;
		private var _menuTitle:TextElement;
		private var _menuItemsArray:Array;
		private var _hit:Sprite;
		private var _width:Number;
		private var _height:Number;
		
		public function DropDownMenu():void {
			super();
		}
		
		private var _title:String = "Menu Title";
		public function get menuTitle():String { return _title; }
		public function set menuTitle(value:String):void {
			_title = value;
		}
		
		protected var menuItemsArray:Array = ["Item1", "Item2"];
		
		private var _menuItems:String = "Item1, Item2";
		/**
		 * The items that will populate the expanding menu panel
		 */
		public function get menuItems():String { return _menuItems; }
		public function set menuItems(value:String):void {
			_menuItems = value;
			menuItemsArray = _menuItems.split(",");
			//_menuItemsArray[menuItemsArray.length] = new Array();
		}
		
		private var _fill:uint = 0x777777;
		/**
		 * Background color for the menu, default grey
		 * @default: 0x777777
		 */
		public function get fill():uint { return _fill; }
		public function set fill(value:uint):void {
			_fill = value;
		}
		
		private var _font:String = "ArialFont"
		/**
		 * Font style of the menu
		 * @default: ArialFont
		 */
		public function get font():String { return _font; }
		public function set font(value:String):void {
			_font = value;
		}
		
		private var _color:uint = 0x0000ff;
		/**
		 * The text color
		 * @default: blue
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			_color = value;
		}
		
		private var _fontSize:Number = 15;
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(value:Number):void {
			_fontSize = value;
		}
		
		override public function displayComplete():void {
			super.displayComplete();
			
			_menuItemsArray = new Array();
			createMenu();
		}
		
		public function init():void
		{
			displayComplete();
		}
		
		private function createMenu():void {
			//Find longest string
			var widthField:TextElement = new TextElement();
			widthField.text = _title;
			widthField.autoSize = "left";
			addChild(widthField);
			
			_width = Math.floor(widthField.width);
			_height = Math.floor(widthField.height);
			
			removeChild(widthField);
			
			for each (var i:String in menuItemsArray) {
				var iField:TextElement = new TextElement();
				addChild(iField);
				if (Math.floor(iField.width) > _width) {
					_width = Math.floor(iField.width);
				}
				removeChild(iField);
			}
			
			//Create hit box based on width and number of items
			
			createHit();
			
			//Create TextElement specifically for the menu.
			_menuTitle = createMenuItem(_title, "menu");
			addChild(_menuTitle);
			//Add event listener for mouseDown/touchDown
			if (GestureWorks.supportsTouch)
					_menuTitle.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDownHit);
				else if (GestureWorks.activeTUIO)
					_menuTitle.addEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
				else
					_menuTitle.addEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
			
			//Create TextElement for each menu item.
			for (var j:int = 0; j < menuItemsArray.length; j++) {
				trace(menuItemsArray);
				trace(_menuItemsArray);
				trace("j = " + j);
				_menuItemsArray[j] = createMenuItem(menuItemsArray[j]);
				_menuItemsArray[j].y = y + (_height * (j + 1));
				if (GestureWorks.supportsTouch){
					_menuItemsArray[j].addEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[j].addEventListener(TuioTouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[j].addEventListener(TuioTouchEvent.TOUCH_UP, onItemSelected);
				}
				else if (GestureWorks.activeTUIO){
					_menuItemsArray[j].addEventListener(TouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[j].addEventListener(TouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[j].addEventListener(TouchEvent.TOUCH_END, onItemSelected);
				}
				else {
					_menuItemsArray[j].addEventListener(MouseEvent.MOUSE_OVER, onOver);
					_menuItemsArray[j].addEventListener(MouseEvent.MOUSE_OUT, onItemOut);
					_menuItemsArray[j].addEventListener(MouseEvent.MOUSE_UP, onItemSelected);
				}
			}
		}
		
		private function createHit():void {
			_hit = new Sprite();
			_hit.graphics.clear();
			_hit.graphics.beginFill(0x000000, 1);
			_hit.graphics.drawRect(x, y, _width, (_height * (menuItemsArray.length + 1)));
			_hit.graphics.endFill();
			_hit.alpha = 0;
			addChild(_hit);
			//_hit.buttonMode = true;
			//AddEventListeners.
		}
		
		private function createMenuItem(s:String, idIn:String=""):TextElement {
			var menuElement:TextElement = new TextElement();
			menuElement.width = _width;
			menuElement.height = _height;
			menuElement.text = s;
			
			menuElement.background = true;
			menuElement.backgroundColor = _fill;
			menuElement.textFormatColor = _color;
			
			menuElement.font = _font;
			menuElement.fontSize = _fontSize;
			if (idIn == "") {
				menuElement.id = s;
			}
			else {
				menuElement.id = idIn;
			}
			
			return menuElement;
		}
		
		private function onDownHit(event:*):void {
			if (!_open) {
				showMenu();
			}
			else if(_open) {
				hideMenu();
			}
		}
		
		private function onOver(event:*):void {
			event.currentTarget.backgroundColor = _fill;
			event.currentTarget.color = _color;
		}
		
		private function onItemOut(event:*):void {
			event.currentTarget.backgroundColor = _color;
			event.currentTarget.color = _fill;
		}
		
		private function onItemSelected(event:*):void {
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "itemSelected", event.target.text ));
			hideMenu();
		}
		
		private function onMenuOut(event:*):void {
			hideMenu();
		}
		
		private function showMenu():void {
			//Show menu here.
			_open = true;
			_menuTitle.backgroundColor = _color;
			_menuTitle.color = _fill;
			
			for each (var i:TextElement in _menuItemsArray) {
				i.backgroundColor = _color;
				i.color = _fill;
				addChild(i);
			}
			
			if (GestureWorks.supportsTouch)
				_hit.addEventListener(TuioTouchEvent.TOUCH_OUT, onMenuOut);
			else if (GestureWorks.activeTUIO)
				_hit.addEventListener(TouchEvent.TOUCH_OUT, onMenuOut);
			else
				_hit.addEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
		}
		
		private function hideMenu():void {
			//Hide menu here.
			_open = false;
			
			_menuTitle.backgroundColor = _fill;
			_menuTitle.color = _color;
			
			for each (var i:TextElement in _menuItemsArray) {
				removeChild(i);
			}
			
			if (GestureWorks.supportsTouch)
				_hit.removeEventListener(TuioTouchEvent.TOUCH_OUT, onMenuOut);
			else if (GestureWorks.activeTUIO)
				_hit.removeEventListener(TouchEvent.TOUCH_OUT, onMenuOut);
			else
				_hit.removeEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (GestureWorks.supportsTouch)
				_hit.removeEventListener(TuioTouchEvent.TOUCH_OUT, onMenuOut);
			else if (GestureWorks.activeTUIO)
				_hit.removeEventListener(TouchEvent.TOUCH_OUT, onMenuOut);
			else
				_hit.removeEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
				
			if (GestureWorks.supportsTouch)
					_menuTitle.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDownHit);
				else if (GestureWorks.activeTUIO)
					_menuTitle.removeEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
				else
					_menuTitle.removeEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
					
			for (var i:Number = 0; i < _menuItemsArray.length; i++) {
				if (GestureWorks.supportsTouch){
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_UP, onItemSelected);
				}
				else if (GestureWorks.activeTUIO){
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_END, onItemSelected);
				}
				else {
					_menuItemsArray[i].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
					_menuItemsArray[i].removeEventListener(MouseEvent.MOUSE_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(MouseEvent.MOUSE_UP, onItemSelected);
				}
			}
			
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
		}
	}
	
}