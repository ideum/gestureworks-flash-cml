package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.element.Text;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.events.*;
	import com.gestureworks.cml.events.StateEvent;
	import org.tuio.*;
	import com.gestureworks.cml.element.Graphic;
	
	/**
	 * Drop down menu is used to create a simple menu from a text string of items.
	 * The menuItems are a comma separated list of items to populate the menu.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
		var ddMenu:DropDownMenu = new DropDownMenu();
		ddMenu.x = 500;
		ddMenu.y = 150;
		ddMenu.fill = 0xf2d4c2;
		ddMenu.color = 0xA66874;
		ddMenu.fontSize = 36;
		ddMenu.menuTitle = "Images";
		ddMenu.menuItems = "Image1,Image2,Image3,Image4,Image5";
		addChild(ddMenu);
		ddMenu.init();
				
					
		// This is the event listener for when a menu item has been selected.
		ddMenu.addEventListener(StateEvent.CHANGE, onItemSelected);
		
		
		function onItemSelected(e:StateEvent):void {
			trace("OnItemSelected", e.value);
		}

	 * </codeblock>
	 * 
	 * @author josh
	 * @see Menu
	 * @see OrbMenu
	 */
	public class DropDownMenu extends ElementFactory
	{
		private var _open:Boolean = false;
		private var _currentSelection:String;
		private var _itemBackgrounds:Array;
		private var _menuTitle:Text;
		private var _menuItemsArray:Array;
		private var _hit:Sprite;
		private var _width:Number;
		private var _height:Number;
		private var triangle:Graphic;
		
		/**
		 * dropdown menu Constructor
		 */
		public function DropDownMenu():void {
			super();
			mouseChildren = true;
		}
		
		public function get open():Boolean { return _open; }
		
		private var _title:String = "Menu Title";
		/**
		 * The menu's title that will always be visible.
		 */
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
		}
		
		private var _fill:uint = 0x777777;
		/**
		 * Background color for the menu, default grey
		 * @default 0x777777
		 */
		public function get fill():uint { return _fill; }
		public function set fill(value:uint):void {
			_fill = value;
		}
		
		private var _font:String = "OpenSansRegular"
		/**
		 * Font style of the menu
		 * @default OpenSansRegular
		 */
		public function get font():String { return _font; }
		public function set font(value:String):void {
			_font = value;
		}
		
		private var _color:uint = 0x0000ff;
		/**
		 * The text color
		 * @default blue
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			_color = value;
		}
		
		private var _fontSize:Number = 15;
		/**
		 * defines the font size
		 * @default 15;
		 */
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(value:Number):void {
			_fontSize = value;
		}
		
		private var _menuMarker:Boolean = true;
		/**
		 * Sets whether or not to display a triangle to help indicate this is a drop down menu.
		 * @default true
		 */
		public function get menuMarker():Boolean { return _menuMarker; }
		private function set menuMarker(value:Boolean):void {
			_menuMarker = value;
		}
		
		/**
		 * CML display initialization callback
		 * creates menu
		 */
		override public function displayComplete():void {
			super.displayComplete();
			
			_menuItemsArray = new Array();
			createMenu();
		}
		
		/**
		 * inialisation method 
		 */
		override public function init():void
		{
			displayComplete();
		}
		
		private function createMenu():void {
			if (_menuMarker){
				triangle = new Graphic();
				triangle.shape = "triangle";
				triangle.width = _fontSize / 2;
				triangle.height = _fontSize / 2;
				triangle.color = _color;
				triangle.lineAlpha = 0;
				triangle.rotation = 180;
			}
			
			//Find longest string
			var widthField:Text = new Text();
			widthField.text = _title;
			widthField.autoSize = "left";
			widthField.font = _font;
			widthField.fontSize = _fontSize;
			addChild(widthField);
			
			if (_menuMarker)
				_width = Math.floor(widthField.width + (triangle.width * 2));
			else _width = Math.floor(widthField.width);
			_height = Math.floor(widthField.height);
			
			removeChild(widthField);
			
			for each (var i:String in menuItemsArray) {
				var iField:Text = new Text();
				iField.text = i;
				iField.autoSize = "left";
				iField.font = _font;
				iField.fontSize = _fontSize;
				addChild(iField);
				if(_menuMarker){
					if (Math.floor(iField.width + (triangle.width * 2)) > _width) {
						_width = Math.floor(iField.width + (triangle.width * 2));
					}
				} else {
					if (Math.floor(iField.width) > _width) {
						_width = Math.floor(iField.width);
					}
				}
				removeChild(iField);
				iField.visible = false;
			}
			
			//Create hit box based on width and number of items
			
			createHit();
			
			//Create Text specifically for the menu.
			_menuTitle = createMenuItem(_title, "menu");
			addChild(_menuTitle);
			
			//Add event listener for mouseDown/touchDown
			if (GestureWorks.activeNativeTouch)
				_menuTitle.addEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
			else if (GestureWorks.activeTUIO)
				_menuTitle.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDownHit);
			else
				_menuTitle.addEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
			
			//Create Text for each menu item.
			for (var j:int = 0; j < menuItemsArray.length; j++) {
				
				_menuItemsArray[j] = createMenuItem(menuItemsArray[j]);
				_menuItemsArray[j].y = _menuTitle.y + (_height * (j + 1));
				addChild(_menuItemsArray[j]);
				_menuItemsArray[j].visible = false;
				
				if (GestureWorks.activeNativeTouch){
					_menuItemsArray[j].addEventListener(TouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[j].addEventListener(TouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[j].addEventListener(TouchEvent.TOUCH_END, onItemSelected);
				}
				else if (GestureWorks.activeTUIO){
					_menuItemsArray[j].addEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[j].addEventListener(TuioTouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[j].addEventListener(TuioTouchEvent.TOUCH_UP, onItemSelected);
				}
				else {
					_menuItemsArray[j].addEventListener(MouseEvent.MOUSE_OVER, onOver);
					_menuItemsArray[j].addEventListener(MouseEvent.MOUSE_OUT, onItemOut);
					_menuItemsArray[j].addEventListener(MouseEvent.MOUSE_UP, onItemSelected);
				}
			}
			if (_menuMarker){
				triangle.y = (_height / 2) + (triangle.height / 2);
				triangle.x = _width - (triangle.width / 2);
				addChild(triangle);
			}
			
			this.height = _menuTitle.height;
			this.width = _width;
		}
		
		private function createHit():void {
			_hit = new Sprite();
			_hit.graphics.clear();
			_hit.graphics.beginFill(0x000000, 1);
			_hit.graphics.drawRect(x, y, _width, (_height * (menuItemsArray.length + 1)));
			_hit.graphics.endFill();
			_hit.alpha = 0;
			addChild(_hit);
			//AddEventListeners.
		}
		
		private function createMenuItem(s:String, idIn:String=""):Text {
			var menuElement:Text = new Text();
			menuElement.width = _width;
			menuElement.height = _height;
			menuElement.text = s;
			menuElement.selectable = false;
			
			menuElement.background = true;
			menuElement.backgroundColor = _fill;
			menuElement.color = _color;
			
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
		
		public function onDownHit(event:*=null):void {
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
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "itemSelected", event.target.text, true));
			hideMenu();
		}
		
		private function onMenuOut(event:*):void {
			hideMenu();
		}
		
		public function showMenu(noDispatch:Boolean = false):void {
			//Show menu here.
			_open = true;
			_menuTitle.backgroundColor = _color;
			_menuTitle.color = _fill;
			
			if (_menuMarker)	triangle.color = _fill;
			
			for each (var i:Text in _menuItemsArray) {
				i.backgroundColor = _color;
				i.color = _fill;
				i.visible = true;
				if (GestureWorks.supportsTouch){
					i.addEventListener(TouchEvent.TOUCH_OVER, onOver);
					i.addEventListener(TouchEvent.TOUCH_OUT, onItemOut);
					i.addEventListener(TouchEvent.TOUCH_END, onItemSelected);
				}
				else if (GestureWorks.activeTUIO){
					i.addEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
					i.addEventListener(TuioTouchEvent.TOUCH_OUT, onItemOut);
					i.addEventListener(TuioTouchEvent.TOUCH_UP, onItemSelected);
				}
				else {
					i.addEventListener(MouseEvent.MOUSE_OVER, onOver);
					i.addEventListener(MouseEvent.MOUSE_OUT, onItemOut);
					i.addEventListener(MouseEvent.MOUSE_UP, onItemSelected);
				}
				//_menuItemsArray[i].visible = true;
				
			}
			
			this.height = _height * _menuItemsArray.length + _menuTitle.height;
			
			if (GestureWorks.activeNativeTouch)
				_hit.addEventListener(TouchEvent.TOUCH_OUT, onMenuOut);
			else if (GestureWorks.activeTUIO)
				_hit.addEventListener(TuioTouchEvent.TOUCH_OUT, onMenuOut);
			else
				_hit.addEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
			
			if(!noDispatch)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "menu", "open", true));
		}
		
		public function hideMenu(noDispatch:Boolean = false):void {
			//Hide menu here.
			_open = false;
			
			this.height = _menuTitle.height;
			
			_menuTitle.backgroundColor = _fill;
			_menuTitle.color = _color;
			
			if (_menuMarker)	triangle.color = _color;
			
			for (var i:Number = 0; i < _menuItemsArray.length; i++) {
				//removeChild(i);
				_menuItemsArray[i].visible = false;
				if (GestureWorks.supportsTouch){
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_END, onItemSelected);
				}
				else if (GestureWorks.activeTUIO){
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_UP, onItemSelected);
				}
				else {
					_menuItemsArray[i].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
					_menuItemsArray[i].removeEventListener(MouseEvent.MOUSE_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(MouseEvent.MOUSE_UP, onItemSelected);
				}
			}
			
			if (GestureWorks.activeNativeTouch)
				_hit.removeEventListener(TouchEvent.TOUCH_OUT, onMenuOut);
			else if (GestureWorks.activeTUIO)
				_hit.removeEventListener(TuioTouchEvent.TOUCH_OUT, onMenuOut);
			else
				_hit.removeEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
			
			if(!noDispatch)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "menu", "close", true));
		}
		
		/**
		 * Dispose methods and remove listeners
		 */
		override public function dispose():void {
			super.dispose();
			
			if (GestureWorks.activeNativeTouch)
				_hit.removeEventListener(TouchEvent.TOUCH_OUT, onMenuOut);
			else if (GestureWorks.activeTUIO)
				_hit.removeEventListener(TuioTouchEvent.TOUCH_OUT, onMenuOut);
			else
				_hit.removeEventListener(MouseEvent.MOUSE_OUT, onMenuOut);
				
			if (GestureWorks.activeNativeTouch)
					_menuTitle.removeEventListener(TouchEvent.TOUCH_BEGIN, onDownHit);
				else if (GestureWorks.activeTUIO)
					_menuTitle.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDownHit);
				else
					_menuTitle.removeEventListener(MouseEvent.MOUSE_DOWN, onDownHit);
					
			for (var i:Number = 0; i < _menuItemsArray.length; i++) {
				if (GestureWorks.activeNativeTouch){
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(TouchEvent.TOUCH_END, onItemSelected);
				}
				else if (GestureWorks.activeTUIO){
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_OVER, onOver);
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_OUT, onItemOut);
					_menuItemsArray[i].removeEventListener(TuioTouchEvent.TOUCH_UP, onItemSelected);
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