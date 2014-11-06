package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.events.*;
	import com.gestureworks.cml.events.StateEvent;
	import org.tuio.*;
	import com.gestureworks.cml.elements.Graphic;
	
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
	 * @author Ideum
	 * @see Menu
	 * @see OrbMenu
	 */
	public class DropDownMenu extends TouchContainer
	{
		protected var _open:Boolean = false;
		protected var _currentSelection:String;
		protected var _currentObject:Text;
		protected var _itemBackgrounds:Array;
		protected var _menuTitle:Text;
		protected var _menuItemsArray:Array;
		protected var _hit:Sprite;
		protected var _width:Number;
		protected var _height:Number;
		protected var triangle:Graphic;
		protected var _showTitleBg:Boolean = true;
		protected var _showPopupBg:Boolean = true;
		
		/**
		 * dropdown menu Constructor
		 */
		public function DropDownMenu():void {
			super();
			mouseChildren = true;
		}
		
		public function get open():Boolean { return _open; }
		
		protected var _title:String = "Menu Title";
		/**
		 * The menu's title that will always be visible.
		 */
		public function get menuTitle():String { return _title; }
		public function set menuTitle(value:String):void {
			_title = value;
		}
		
		protected var menuItemsArray:Array = ["Item1", "Item2"];
		
		protected var _menuItems:String = "Item1, Item2";
		/**
		 * The items that will populate the expanding menu panel
		 */
		public function get menuItems():String { return _menuItems; }
		public function set menuItems(value:String):void {
			_menuItems = value;
			menuItemsArray = _menuItems.split(",");
		}
		
		protected var _fill:uint = 0x777777;
		/**
		 * Background color for the menu, default grey
		 * @default 0x777777
		 */
		public function get fill():uint { return _fill; }
		public function set fill(value:uint):void {
			_fill = value;
		}
		
		/**
		 * Shows the title background
		 * @default 0x777777
		 */
		public function get showTitleBg():Boolean { return _showTitleBg; }
		public function set showTitleBg(value:Boolean):void {
			_showTitleBg = value;
		}
		
		/**
		 * Shows the popup background
		 * @default 0x777777
		 */
		public function get showPopupBg():Boolean { return _showPopupBg; }
		public function set showPopupBg(value:Boolean):void {
			_showPopupBg = value;
		}		
		
		protected var _font:String = "OpenSansRegular"
		/**
		 * Font style of the menu
		 * @default OpenSansRegular
		 */
		public function get font():String { return _font; }
		public function set font(value:String):void {
			_font = value;
		}
		
		protected var _color:uint = 0x0000ff;
		/**
		 * The text color
		 * @default blue
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			_color = value;
		}
		
		protected var _fontSize:Number = 15;
		/**
		 * defines the font size
		 * @default 15;
		 */
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(value:Number):void {
			_fontSize = value;
		}
		
		protected var _menuMarker:Boolean = true;
		/**
		 * Sets whether or not to display a triangle to help indicate this is a drop down menu.
		 * @default true
		 */
		public function get menuMarker():Boolean { return _menuMarker; }
		protected function set menuMarker(value:Boolean):void {
			_menuMarker = value;
		}
		
		/**
		 * inialisation method 
		 */
		override public function init():void
		{
			_menuItemsArray = new Array();
			createMenu();
		}
		
		protected function createMenu():void {
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
			
			widthField.font = _font;
			widthField.fontSize = _fontSize;
			widthField.autosize = true;	
			widthField.height *= 1.2;	
			addChild(widthField);
			
			if (_menuMarker)
				_width = Math.floor(widthField.width + (triangle.width * 2));
			else _width = Math.floor(widthField.width);
			_height = Math.floor(widthField.height);
			
			removeChild(widthField);
			
			for each (var i:String in menuItemsArray) {
				var iField:Text = new Text();
				iField.text = i;
				iField.font = _font;
				iField.fontSize = _fontSize;
				iField.autosize = true;				
				iField.height *= 1.2;			
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
			
			_menuTitle.addEventListener(GWTouchEvent.TOUCH_BEGIN, onDownHit);
			
			//Create Text for each menu item.
			for (var j:int = 0; j < menuItemsArray.length; j++) {
				
				_menuItemsArray[j] = createMenuItem(menuItemsArray[j]);
				_menuItemsArray[j].y = _menuTitle.y + (_height * (j + 1));
				addChild(_menuItemsArray[j]);
				_menuItemsArray[j].visible = false;
				
				_menuItemsArray[j].addEventListener(GWTouchEvent.TOUCH_OVER, onOver);
				_menuItemsArray[j].addEventListener(GWTouchEvent.TOUCH_OUT, onItemOut);
				_menuItemsArray[j].addEventListener(GWTouchEvent.TOUCH_END, onItemSelected);
			}
			if (_menuMarker){
				triangle.y = (_height / 2) + (triangle.height / 2);
				triangle.x = _width - (triangle.width / 2);
				addChild(triangle);
			}
			
			this.height = _menuTitle.height;
			this.width = _width;
		}
		
		protected function createHit():void {
			_hit = new Sprite();
			_hit.graphics.clear();
			_hit.graphics.beginFill(0x000000, 1);
			_hit.graphics.drawRect(x, y, _width, (_height * (menuItemsArray.length + 1)));
			_hit.graphics.endFill();
			_hit.alpha = 0;
			addChild(_hit);
			//AddEventListeners.
		}
		
		protected function createMenuItem(s:String, idIn:String=""):Text {
			var menuElement:Text = new Text();
			menuElement.width = _width;
			menuElement.height = _height;
			menuElement.text = s;
			menuElement.selectable = false;
			
			if (showTitleBg) {
				menuElement.background = true;
			}
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
		
		protected function onOver(event:*):void {
			event.currentTarget.backgroundColor = _fill;
			event.currentTarget.color = _color;
		}
		
		protected function onItemOut(event:*):void {
			event.currentTarget.backgroundColor = _color;
			event.currentTarget.color = _fill;
		}
		
		protected function onItemSelected(event:*):void {
			_currentSelection = event.target.text;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "itemSelected", event.target.text, true));
			hideMenu();
		}
		
		protected function onMenuOut(event:*):void {
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
				if (showPopupBg) {
					i.background = true;
				}
				i.visible = true;
				
				i.addEventListener(GWTouchEvent.TOUCH_OVER, onOver);
				i.addEventListener(GWTouchEvent.TOUCH_OUT, onItemOut);
				i.addEventListener(GWTouchEvent.TOUCH_END, onItemSelected);

				//_menuItemsArray[i].visible = true;
			}
			
			this.height = _height * _menuItemsArray.length + _menuTitle.height;
			
			_hit.addEventListener(GWTouchEvent.TOUCH_OUT, onMenuOut);
			
			if(!noDispatch)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "menu", "open", true));
		}
		
		public function hideMenu(noDispatch:Boolean = false):void {
			//Hide menu here.
			_open = false;
			
			this.height = _menuTitle.height;
			
			if (showTitleBg) {
				_menuTitle.background = true;
			}
			_menuTitle.backgroundColor = _fill;
			_menuTitle.color = _color;
			
			if (_menuMarker)	triangle.color = _color;
			
			for (var i:Number = 0; i < _menuItemsArray.length; i++) {
				//removeChild(i);
				_menuItemsArray[i].visible = false;
				
				_menuItemsArray[i].removeEventListener(GWTouchEvent.TOUCH_OVER, onOver);
				_menuItemsArray[i].removeEventListener(GWTouchEvent.TOUCH_OUT, onItemOut);
				_menuItemsArray[i].removeEventListener(GWTouchEvent.TOUCH_END, onItemSelected);
			}
			
			_hit.removeEventListener(GWTouchEvent.TOUCH_OUT, onMenuOut);					
			if(!noDispatch)
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "menu", "close", true));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
					
			for (var i:Number = 0; i < _menuItemsArray.length; i++) {
				_menuItemsArray[i].removeEventListener(GWTouchEvent.TOUCH_OVER, onOver);
				_menuItemsArray[i].removeEventListener(GWTouchEvent.TOUCH_OUT, onItemOut);
				_menuItemsArray[i].removeEventListener(GWTouchEvent.TOUCH_END, onItemSelected);
			}
			
			_itemBackgrounds = null;
			_menuTitle = null;
			_menuItemsArray = null;
			menuItemsArray = null;
			_hit = null;
			triangle = null;
		}
	}
	
}