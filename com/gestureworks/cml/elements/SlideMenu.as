package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Ideum
	 */
	public class SlideMenu extends TouchContainer
	{
		private var _backButton:Sprite;
		private var _tweening:Boolean;
		public function get tweening():Boolean { return _tweening; }
		
		private var maskSprite:Sprite;
		private var origins:Dictionary = new Dictionary(true);
		private var _disabledItems:Dictionary = new Dictionary(false);
		
		public function SlideMenu() 
		{
			super();
		}
		
		//{ region Properties
		
		protected var _label:String = "";
		public function get label():String { return _label; }
		public function set label(value:String):void {
			_label = value;
		}
		
		protected var _itemSpacing:Number = 5;
		/**
		 * Sets the amount of space to have between each menu item, as well as the Title and the first menu item
		 */
		public function get itemSpacing():Number { return _itemSpacing; }
		public function set itemSpacing(value:Number):void {
			_itemSpacing = value;
		}
		
		protected var _font:String = "OpenSansRegular";
		public function get font():String { return _font; }
		public function set font(value:String):void {
			_font = value;
		}
		
		protected var _fontColor:uint = 0xffffff;
		public function get fontColor():uint { return _fontColor; }
		public function set fontColor(value:uint):void {
			_fontColor = value;
		}
		
		protected var _fontSize:Number = 18;
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(value:Number):void {
			_fontSize = value;
		}
		
		protected var _fontAutoSize:String = "left";
		public function get fontAutoSize():String { return _fontAutoSize; }
		public function set fontAutoSize(value:String):void {
			_fontAutoSize = value;
		}
		
		protected var _fontPaddingTop:Number = 10;
		public function get fontPaddingTop():Number { return _fontPaddingTop; }
		public function set fontPaddingTop(value:Number):void {
			_fontPaddingTop = value;
		}
		
		protected var _fontPaddingLeft:Number = 10;
		public function get fontPaddingLeft():Number { return _fontPaddingLeft; }
		public function set fontPaddingLeft(value:Number):void {
			_fontPaddingLeft = value;
		}
		
		protected var _fontPaddingRight:Number = 10;
		public function get fontPaddingRight():Number { return _fontPaddingRight; }
		public function set fontPaddingRight(value:Number):void {
			_fontPaddingRight = value;
		}
		
		private var _breadcrumbTrail:Boolean = true;
		/**
		 * Sets whether or not to leave the last item selected highlighted when returning to the previous menu.
		 */
		public function get breadcrumbTrail():Boolean { return _breadcrumbTrail; }
		public function set breadcrumbTrail(value:Boolean):void {
			_breadcrumbTrail = value;
		}
		
		private var _arrowIndicator:*;
		public function get arrowIndicator():* { return _arrowIndicator; }
		public function set arrowIndicator(value:*):void {
			if (!value) return;
			_arrowIndicator = value;
		}
		
		private var _returnIndicator:*;
		public function get returnIndicator():* { return _returnIndicator; }
		public function set returnIndicator(value:*):void {
			if (!value) return;
			_returnIndicator = value;
		}
		
		private var _level:int = 0;
		public function get level():int { return _level; }
		public function set level(value:int):void {
			_level = value;
		}		
		
		private var _enable:Boolean = true;
		public function get enable():Boolean { return _enable; }
		public function set enable(value:Boolean):void {
			_enable = value;
		}
		
		//{ region Background properties
		
		
		
		//} endregion Background properties
		
		
		//{ region title properties
		
		protected var _titleGradientType:String = "none";
		/**
		 * Sets up the gradient type, either "linear", "radial", or "none".
		 * @default none
		 */
		public function get titleGradientType():String { return _titleGradientType; }
		public function set titleGradientType(value:String):void {
			if (value == "linear")
				_titleGradientType = GradientType.LINEAR;
			else if (value == "radial")
				_titleGradientType = GradientType.RADIAL;
			else
				_titleGradientType = "none";
		}
		
		protected var titleGradientColorArray:Array = [0x000000, 0xffffff, 0x000000];
		protected var _titleGradientColors:String = "";
		public function get titleGradientColors():String { return _titleGradientColors; }
		public function set titleGradientColors(value:String):void {
			titleGradientColorArray = [];
			
			if (!value) return;
			_titleGradientColors = value;
			
			titleGradientColorArray = _titleGradientColors.split(",");
		}
		
		protected var titleGradientAlphasArray:Array = [1, 1, 1];
		protected var _titleGradientAlphas:String = "";
		public function get titleGradientAlphas():String { return _titleGradientAlphas; }
		public function set titleGradientAlphas(value:String):void {
			titleGradientAlphasArray = [];
			
			if (!value) return;
			_titleGradientAlphas = value;
			
			titleGradientAlphasArray = _titleGradientAlphas.split(",");
		}
		
		protected var titleGradientRatiosArray:Array = [0, 177, 255];
		protected var _titleGradientRatios:String = "";
		public function get titleGradientRatios():String { return _titleGradientRatios; }
		public function set titleGradientRatios(value:String):void {
			titleGradientRatiosArray = [];
			
			if (!value) return;
			_titleGradientRatios = value;
			
			titleGradientRatiosArray = _titleGradientRatios.split(",");
		}
		
		protected var _titleShape:String = "rectangle";
		/**
		 * Sets the shape of the title, either rectangle or roundRectangle
		 */
		public function get titleShape():String { return _titleShape; }
		public function set titleShape(value:String):void {
			_titleShape = value;
		}
		
		protected var _titleCornerWidth:Number = 15;
		public function get titleCornerWidth():Number { return _titleCornerWidth; }
		public function set titleCornerWidth(value:Number):void {
			_titleCornerWidth = value;
		}
		
		protected var _titleCornerHeight:Number = 15;
		public function get titleCornerHeight():Number { return _titleCornerHeight; }
		public function set titleCornerHEight(value:Number):void {
			_titleCornerHeight = value;
		}
		
		protected var _titleFill:uint = 0x555555;
		public function get titleFill():uint { return _titleFill; }
		public function set titleFill(value:uint):void {
			_titleFill = value;
		}
		
		protected var _titleStroke:Number = 0;
		public function get titleStroke():Number { return _titleStroke; }
		public function set titleStroke(value:Number):void {
			_titleStroke = value;
		}
		
		protected var _titleStrokeColor:uint = 0x333333;
		public function get titleStrokeColor():uint { return _titleStrokeColor; }
		public function set titleStrokeColor(value:uint):void {
			_titleStrokeColor = value;
		}
		
		//} endregion title properties
		
		
		//{ region item properties
		
		protected var _itemWidth:Number;
		public function get itemWidth():Number { return _itemWidth; }
		public function set itemWidth(value:Number):void {
			_itemWidth = value;
		}
		
		protected var _itemHeight:Number;
		public function get itemHeight():Number { return _itemHeight; }
		public function set itemHeight(value:Number):void {
			_itemHeight = value;
		}
		
		protected var _itemGradientType:String = "none";
		/**
		 * Sets up the gradient type, either "linear", "radial", or "none".
		 * @default none
		 */
		public function get itemGradientType():String { return _itemGradientType; }
		public function set itemGradientType(value:String):void {
			if (value == "linear")
				_itemGradientType = GradientType.LINEAR;
			else if (value == "radial")
				_itemGradientType = GradientType.RADIAL;
			else
				_itemGradientType = "none";
		}
		
		protected var itemGradientColorArray:Array = [0x000000, 0xffffff, 0x000000];
		protected var _itemGradientColors:String = "";
		public function get itemGradientColors():String { return _itemGradientColors; }
		public function set itemGradientColors(value:String):void {
			itemGradientColorArray = [];
			
			if (!value) return;
			_itemGradientColors = value;
			
			itemGradientColorArray = _itemGradientColors.split(",");
		}
		
		protected var itemGradientAlphasArray:Array = [1, 1, 1];
		protected var _itemGradientAlphas:String = "";
		public function get itemGradientAlphas():String { return _itemGradientAlphas; }
		public function set itemGradientAlphas(value:String):void {
			itemGradientAlphasArray = [];
			
			if (!value) return;
			_itemGradientAlphas = value;
			
			itemGradientAlphasArray = _itemGradientAlphas.split(",");
		}
		
		protected var itemGradientRatiosArray:Array = [0, 177, 255];
		protected var _itemGradientRatios:String = "";
		public function get itemGradientRatios():String { return _itemGradientRatios; }
		public function set itemGradientRatios(value:String):void {
			itemGradientRatiosArray = [];
			
			if (!value) return;
			_itemGradientRatios = value;
			
			itemGradientRatiosArray = _itemGradientRatios.split(",");
		}
		
		protected var _itemShape:String = "rectangle";
		/**
		 * Sets the shape of the item, either rectangle or roundRectangle
		 */
		public function get itemShape():String { return _itemShape; }
		public function set itemShape(value:String):void {
			_itemShape = value;
		}
		
		protected var _itemCornerWidth:Number = 15;
		public function get itemCornerWidth():Number { return _itemCornerWidth; }
		public function set itemCornerWidth(value:Number):void {
			_itemCornerWidth = value;
		}
		
		protected var _itemCornerHeight:Number = 15;
		public function get itemCornerHeight():Number { return _itemCornerHeight; }
		public function set itemCornerHeight(value:Number):void {
			_itemCornerHeight = value;
		}
		
		protected var _itemFill:uint = 0x555555;
		public function get itemFill():uint { return _itemFill; }
		public function set itemFill(value:uint):void {
			_itemFill = value;
		}
		
		protected var _itemStroke:Number = 0;
		public function get itemStroke():Number { return _itemStroke; }
		public function set itemStroke(value:Number):void {
			_itemStroke = value;
		}
		
		protected var _itemStrokeColor:uint = 0x333333;
		public function get itemStrokeColor():uint { return _itemStrokeColor; }
		public function set itemStrokeColor(value:uint):void {
			_itemStrokeColor = value;
		}
		
		//{ region Item font region
		protected var _itemFont:String = "OpenSansRegular";
		public function get itemFont():String { return _itemFont; }
		public function set itemFont(value:String):void {
			_itemFont = value;
		}
		
		protected var _itemFontSize:Number = 14;
		public function get itemFontSize():Number { return _itemFontSize; }
		public function set itemFontSize(value:Number):void {
			_itemFontSize = value;
		}
		
		protected var _itemFontColor:uint = 0xffffff;
		public function get itemFontColor():uint { return _itemFontColor; }
		public function set itemFontColor(value:uint):void {
			_itemFontColor = value;
		}
		
		protected var _itemFontAutoSize:String = "center";
		public function get itemFontAutoSize():String { return _itemFontAutoSize; }
		public function set itemFontAutoSize(value:String):void {
			_itemFontAutoSize = value;
		}
		
		protected var _itemFontPaddingBottom:Number = 0;
		public function get itemFontPaddingBottm():Number { return _itemFontPaddingBottom; }
		public function set itemFontPaddingBottom(value:Number):void {
			_itemFontPaddingBottom = value;
		}
		
		protected var _itemFontPaddingTop:Number = 10;
		public function get itemFontPaddingTop():Number { return _itemFontPaddingTop; }
		public function set itemFontPaddingTop(value:Number):void {
			_itemFontPaddingTop = value;
		}
		
		protected var _itemFontPaddingLeft:Number = 10;
		public function get itemFontPaddingLeft():Number { return _itemFontPaddingLeft; }
		public function set itemFontPaddingLeft(value:Number):void {
			_itemFontPaddingLeft = value;
		}
		
		protected var _itemFontPaddingRight:Number = 10;
		public function get itemFontPaddingRight():Number { return _itemFontPaddingRight; }
		public function set itemFontPaddingRight(value:Number):void {
			_itemFontPaddingRight = value;
		}
		//} endregion Item font region
		
		//{ region item selected properties
		
		protected var _selectedFill:uint = 0x333333;
		public function get selectedFill():uint { return _selectedFill; }
		public function set selectedFill(value:uint):void {
			_selectedFill = value;
		}
		
		protected var selectedGradientColorArray:Array = [0xffffff, 0x000000, 0xffffff];
		protected var _selectedGradientColors:String = "";
		public function get selectedGradientColors():String { return _selectedGradientColors; }
		public function set selectedGradientColors(value:String):void {
			selectedGradientColorArray = [];
			
			if (!value) return;
			_selectedGradientColors = value;
			
			selectedGradientColorArray = _selectedGradientColors.split(",");
		}
		
		protected var selectedGradientAlphasArray:Array = [1, 1, 1];
		protected var _selectedGradientAlphas:String = "";
		public function get selectedGradientAlphas():String { return _selectedGradientAlphas; }
		public function set selectedGradientAlphas(value:String):void {
			selectedGradientAlphasArray = [];
			
			if (!value) return;
			_selectedGradientAlphas = value;
			
			selectedGradientAlphasArray = _selectedGradientAlphas.split(",");
		}
		
		protected var selectedGradientRatiosArray:Array = [0, 177, 255];
		protected var _selectedGradientRatios:String = "";
		public function get selectedGradientRatios():String { return _selectedGradientRatios; }
		public function set selectedGradientRatios(value:String):void {
			selectedGradientRatiosArray = [];
			
			if (!value) return;
			_selectedGradientRatios = value;
			
			selectedGradientRatiosArray = _selectedGradientRatios.split(",");
		}
		
		protected var _selectedFontColor:uint = 0x000000;
		public function get selectedFontColor():uint { return _selectedFontColor; }
		public function set selectedFontColor(value:uint):void {
			_selectedFontColor = value;
		}
		
		//} endregion item selected properties
		
		//} endregion Item region
		
		//} endregion properties
		
		
		
		//{ region Read-Only properties

		protected var _title:Sprite;
		public function get title():Sprite { return _title; }
		
		protected var _item:Sprite;
		public function get item():Sprite { return _item; }
		
		protected var _selected:Sprite;
		public function get selected():Sprite { return _selected; }
		/*public function set selected(value:Sprite) {
			_selected = value;
		}*/
		
		protected var _menuItems:Array = [];
		//protected var _menuItems:Dictionary = new Dictionary();
		public function get menuItems():Array { return _menuItems; }
		//public function get menuItems():Dictionary { return _menuItems; }
		
		protected var _subMenus:Dictionary = new Dictionary();
		public function get subMenus():Dictionary { return _subMenus; }
		
		protected var _initialized:Boolean = false;
		public function get initialized():Boolean { return _initialized; }
		
		protected var _totalHeight:Number = 0;
		public function get totalHeight():Number { return _totalHeight; }
		
		protected var _menuState:String = "root";
		public function get menuState():String { return _menuState; }
		
		protected var _subMenu:SlideMenu;
		public function get subMenu():SlideMenu { return _subMenu; }
		
		//} endregion
		
		
		
		override public function init():void {
			
			if (_initialized)
				return;
						
			if (!(parent is SlideMenu) && level > 0) { 
				level = 1; 			
			
				var lastLevel:int = 0;				
				var nextLevel:int = 0;
				
				var slideMenus:List = new List();
				slideMenus.append(this);
				var levels:LinkedMap = new LinkedMap(true);
				
				for (var j:int = 0; j < numChildren; j++) {
					if (getChildAt(j) is SlideMenu)
						slideMenus.append(getChildAt(j));
				}
				for (var i:int = 1; i < slideMenus.length; i++) {
					nextLevel = slideMenus[i].level;
					if (nextLevel > lastLevel) {
						slideMenus[i - 1].addChild(slideMenus[i]);
						if (levels.hasKey(nextLevel))
							levels.replace(nextLevel, slideMenus[i]);
						else 
							levels.append(nextLevel, slideMenus[i]);
					}
					else if (nextLevel < lastLevel) {
						levels.getKey(nextLevel).parent.addChild(slideMenus[i]);
						levels.replace(nextLevel, slideMenus[i]);
					}
					else if (nextLevel == lastLevel) {
						slideMenus[i - 1].parent.addChild(slideMenus[i]);
						levels.replace(nextLevel, slideMenus[i]);
					}
					lastLevel = nextLevel;
				}
				
				slideMenus = null;
				levels = null;
				
				//DisplayUtils.traceDisplayList(this);
			}
			
			
			if (_arrowIndicator != undefined) {
				if (_arrowIndicator is XML)
					_arrowIndicator = searchChildren(XML(_arrowIndicator).toString());
				else 
					_arrowIndicator = searchChildren(_arrowIndicator);
				if (_arrowIndicator)
					removeChild(_arrowIndicator);
			}
			
			if (_returnIndicator != undefined) {
				if (_returnIndicator is XML)
					_returnIndicator = searchChildren(XML(_returnIndicator).toString());
				else 
					_returnIndicator = searchChildren(_returnIndicator);
				if (_returnIndicator)
					removeChild(_returnIndicator);
			}
			
			if (parent && parent is SlideMenu) {
				
				createItem();
				
				// If there's no children, and the parent is a Slidemenu, this isn't a menu itself, it's a menu item,
				// and will only be used to dispatch events, so lets just skip everything else move along.
				if (numChildren == 0) {
					if (_arrowIndicator is DisplayObject && _item.contains(_arrowIndicator))
						_item.removeChild(_arrowIndicator);
					return;
				}
				
				createBackButton();
			}
			
			createTitle();
			
			initialLayout();
			
			listenForEvents();
			
			mouseChildren = false;
			
			_menuState = _label;
			_initialized = true;
		}
		
		//{ region Object creation
		
		protected function createTitle():void {
			
			_title = new Sprite();
			
			// Gradient fill
			if (_titleGradientType != "none") {
				var m:Matrix = new Matrix();
				m.createGradientBox(width, height, (Math.PI / 180) * 90);
				_title.graphics.beginGradientFill(_titleGradientType, titleGradientColorArray, titleGradientAlphasArray, titleGradientRatiosArray, m);
			}
			// solid fill
			else {
				_title.graphics.beginFill(_titleFill);
			}
			
			_title.graphics.lineStyle(_titleStroke, _titleStrokeColor);
			
			if (_titleShape == "roundRectangle") {
				_title.graphics.drawRoundRect(0, 0, width, height, _titleCornerWidth, _titleCornerHeight)
			}
			else {
				_title.graphics.drawRect(0, 0, width, height);
			}
			
			_title.graphics.endFill();
			
			var titleLabel:Text = new Text();
			titleLabel.font = _font;
			titleLabel.width = width - _fontPaddingLeft - _fontPaddingRight;
			titleLabel.x = _fontPaddingLeft;
			titleLabel.height = height - fontPaddingTop;
			titleLabel.y = fontPaddingTop;
			
			titleLabel.text = _label;
			titleLabel.selectable = false;
			
			titleLabel.autoSize = _fontAutoSize;
			
			titleLabel.color = fontColor;
			titleLabel.fontSize = fontSize;
			
			if (_fontAutoSize == "center") {
				titleLabel.x = (width / 2) - (titleLabel.width / 2);
			}
			
			_title.addChild(titleLabel);
			
			if (_backButton) {
				
				_title.addChild(_backButton);
				_backButton.y = (_title.height - _backButton.height) / 2;
				_backButton.x = _backButton.y;
				if (_fontAutoSize != "center") {
					titleLabel.x += _backButton.x + _backButton.width;
					titleLabel.width -= _backButton.x + _backButton.width;
				}
			}
		}
		
		protected function createItem():void {
			_item = new Sprite();
			
			// Lets just set up the selected graphic at the same time.
			_selected = new Sprite();
			
			if (!_itemWidth || _itemWidth > width) _itemWidth = width;
			if (!_itemHeight) _itemHeight = height;
			
			// Gradient fill
			if (itemGradientType != "none") {
				var m:Matrix = new Matrix();
				m.createGradientBox(_itemWidth, _itemHeight, (Math.PI / 180) * 90);
				_item.graphics.beginGradientFill(_itemGradientType, itemGradientColorArray, itemGradientAlphasArray, itemGradientRatiosArray, m);
				_selected.graphics.beginGradientFill(_itemGradientType, selectedGradientColorArray, selectedGradientAlphasArray, selectedGradientRatiosArray, m);
			}
			// solid fill
			else {
				_item.graphics.beginFill(_itemFill);
				_selected.graphics.beginFill(_selectedFill);
			}
			
			_item.graphics.lineStyle(_itemStroke, _itemStrokeColor);
			// TO-DO: selected stroke, selected stroke color
			
			if (_itemShape == "roundRectangle") {
				_item.graphics.drawRoundRect(0, 0, _itemWidth, _itemHeight, _itemCornerWidth, _itemCornerHeight);
				_selected.graphics.drawRoundRect(0, 0, _itemWidth, _itemHeight, _itemCornerWidth, _itemCornerHeight);
			}
			else {
				_item.graphics.drawRect(0, 0, _itemWidth, _itemHeight);
				_selected.graphics.drawRect(0, 0, _itemWidth, _itemHeight);
			}
			
			_item.graphics.endFill();
			_selected.graphics.endFill();
			
			_item.height = _itemHeight;
			_item.width = _itemWidth;
			
			_selected.visible = false;
			
			var itemLabel:Text = new Text();
			itemLabel.font = _itemFont;
			var selectedLabel:Text = new Text();
			selectedLabel.font = _itemFont;
			
			itemLabel.width = itemWidth - _itemFontPaddingLeft - _fontPaddingRight;
			itemLabel.x = _itemFontPaddingLeft;
			itemLabel.height = itemHeight - _itemFontPaddingTop;
			itemLabel.y = _itemFontPaddingTop;
			
			selectedLabel.width = itemWidth - _itemFontPaddingLeft - _fontPaddingRight;
			selectedLabel.x = _itemFontPaddingLeft;
			selectedLabel.height = itemHeight - _itemFontPaddingTop;
			selectedLabel.y = _itemFontPaddingTop;
			
			itemLabel.text = _label;
			itemLabel.selectable = false;
			
			selectedLabel.text = _label;
			selectedLabel.selectable = false;
			
			itemLabel.autoSize = _itemFontAutoSize;
			selectedLabel.autoSize = _itemFontAutoSize;
			
			itemLabel.color = _itemFontColor;
			itemLabel.fontSize = _itemFontSize; 
			
			selectedLabel.color = _selectedFontColor;
			selectedLabel.fontSize = _itemFontSize;
			
			if (_itemFontAutoSize == "center") {
				itemLabel.x = (itemWidth / 2) - (itemLabel.width / 2);
				selectedLabel.x = (itemWidth / 2) - (itemLabel.width / 2);
			}
			
			_item.addChild(itemLabel);
			_selected.addChild(selectedLabel);
			_item.addChild(_selected);
			
			if (_arrowIndicator is DisplayObject) {
				_item.addChild(_arrowIndicator);
				_arrowIndicator.x = _item.width - _arrowIndicator.width - paddingRight;
				_arrowIndicator.y = (_item.height - _arrowIndicator.height) / 2;
				
				if (itemFontAutoSize == "right") {
					itemLabel.width -= _arrowIndicator.width + paddingRight;
					selectedLabel.width -= _arrowIndicator.width + paddingRight;
				}
			}
			_item.name = label;
			//addChild(_item);
		}
		
		protected function createBackButton():void {
			_backButton = new Sprite();
			if (_returnIndicator && _returnIndicator is DisplayObject) {
				_backButton.addChild(_returnIndicator);
				_backButton.width = _returnIndicator.width;
				_backButton.height = _returnIndicator.height;
			}
			else {
				var radius:Number = (this.height / 2) * 0.7;
				_backButton.graphics.lineStyle(1.5, 0xffffff);
				_backButton.graphics.beginFill(0x000000, 1);
				_backButton.graphics.drawCircle(radius, radius, radius);
				_backButton.width = radius * 2;
				_backButton.height = radius * 2;
			}
			
			if ("id" in parent) {
				_backButton.name = parent["id"];
			}
			else if ( !("id" in parent) && "name" in parent) {
				_backButton.name = parent["name"];
			}
		}
		
		//} endregion
		
		//{ region Event handlers
		
		
		private function onTap(e:GWGestureEvent):void 
		{
			if (_menuState == _label) {
				
				for (var i:int = 0; i < _menuItems.length; i++) {
					if (!_menuItems[i].visible) continue;
					
					//trace(DisplayObject(_menuItems[i]).hitTestPoint(e.value.localX, e.value.localY));
					
					if (DisplayObject(_menuItems[i]).hitTestPoint(e.value.stageX, e.value.stageY)) {
						tweenForward(_menuItems[i], this);
					}
				}
			}
			else {
				
				if (e.value.localY < height) {
					
					if (subMenu)
						tweenBackwards();
				}
				else {
					
					for (var j:int = 0; j < _subMenu.menuItems.length; j++) 
					{
						if (DisplayObject(_subMenu.menuItems[j]).hitTestPoint(e.value.stageX, e.value.stageY)) {
							tweenForward(_subMenu.menuItems[j], _subMenu);
						}
					}
					
				}
			}
		}
		
		//} endregion Event Handlers
		
		//{ region Utility
		
		private function initialLayout():void 
		{
			
			var numberOfChildren:int = numChildren;
			
			for (var j:int = 0; j < numberOfChildren; j++) {
				if (getChildAt(j) is SlideMenu) {
					
					var childMenu:SlideMenu = getChildAt(j) as SlideMenu;
					synchChildMenu(childMenu);
					if (childMenu.enable)
						_menuItems.push(childMenu.item);
					else
						_disabledItems.push(childMenu.item);
					
					origins[childMenu.label] = childMenu;
					
					if (_totalHeight < childMenu.totalHeight)
						_totalHeight = childMenu.totalHeight;
					
					if (childMenu.title) {
						childMenu.visible = false;
						_subMenus[childMenu.label] = childMenu;
						childMenu.x = width + itemSpacing;
					}
					this.addChild(_menuItems[_menuItems.length - 1]);
				}
			}

			
			addChildAt(_title, 0);
			var yPos:Number = _title.y + _title.height + itemSpacing;
			
			for (var i:int = 0; i < _menuItems.length; i++) {
				_menuItems[i].y = yPos;
				yPos = _menuItems[i].y + _menuItems[i].height + itemSpacing;
			}
			
			var testHeight:Number = yPos +  _menuItems[_menuItems.length - 1].height;
			if (_totalHeight < testHeight)
				_totalHeight = testHeight;
			
			if (this.parent && this.parent is SlideMenu)
				return;
				
			maskSprite = new Sprite();
			maskSprite.name = "SlideMenu-Mask";
			maskSprite.graphics.beginFill(0xff00ff, 0);
			//maskSprite.graphics.drawRect(0, 0, width, _totalHeight);
			maskSprite.graphics.drawRect(0, 0, width + _itemSpacing, _totalHeight);
			maskSprite.graphics.endFill();
			this.parent.addChild(maskSprite);
			this.mask = maskSprite;
			
		}
		
		
		public function updateLayout():void {
			if (!title) return;
			
			if (!(parent is SlideMenu))
				reset();
			
			for (var j:int = 0; j < numChildren; j++) {
				if (getChildAt(j) is SlideMenu) {
					
					var childMenu:SlideMenu = getChildAt(j) as SlideMenu;
					
					if (childMenu.title && !(childMenu.label in _subMenus)) {
						childMenu.visible = false;
						_subMenus[childMenu.label] = childMenu;
						childMenu.x = width + itemSpacing;
					}
						
					if (!(childMenu.label in origins)) {
						origins[childMenu.label] = childMenu;
						_menuItems.push(childMenu.item);
					}
				}
				
			}
			
			var yPos:Number = _title.y + _title.height + itemSpacing;
			for (var i:int = 0; i < _menuItems.length; i++) {
				if (_menuItems[i].name in origins) {
					if (origins[_menuItems[i].name].enable) {
						if (!contains(_menuItems[i])) {
							addChild(_menuItems[i]);
						}
						
						_menuItems[i].y = yPos;
						yPos = _menuItems[i].y + _menuItems[i].height + itemSpacing;
					}
					else if (!origins[_menuItems[i].name].enable) {
						if (contains(_menuItems[i]))
							removeChild(_menuItems[i]);
						if (_menuItems[i].name in _subMenus) {
							delete _subMenus[_menuItems[i].name];
						}
					}
				}
			}
			
			var testHeight:Number = yPos +  _menuItems[_menuItems.length - 1].height;
			if (_totalHeight < testHeight)
				_totalHeight = testHeight;
			
			if (this.parent && this.parent is SlideMenu)
				return;
			
			maskSprite.height = _totalHeight;
		}
		
		protected function synchChildMenu(childMenu:SlideMenu):void 
		{
			// Copy properties from parent as long as the child hasn't set them and the parent has.
			for (var s:String in this.state[0]) {
				
				if (!(s in childMenu.state[0]) && s!= "arrowIndicator" && s != "id") {
					childMenu.state[0][s] = this.state[0][s];
					childMenu[s] = this.state[0][s];
				}
			}
			
			// Initialize the child because we can't layout anything until it's ready.
			if (!childMenu.initialized)
				childMenu.init();
		}
		
		
		protected function listenForEvents():void 
		{
			if (parent && !(parent is SlideMenu)) {
				addEventListener(GWGestureEvent.TAP, onTap);
			}
		}
		
		protected function tweenBackwards():void 
		{
			if (_tweening) return;
			
			_tweening = true;
			
			var tweenXto:Number = subMenu.parent.x + (subMenu.width + _itemSpacing);
			
			TweenMax.to(subMenu.parent, 0.5, { x:tweenXto, ease:Quad.easeInOut, onComplete:function():void {
																		_tweening = false;
																		subMenu.visible = false;
																		clearTrail(SlideMenu(subMenu.parent));
																		dispatchBackMenu(subMenu.parent); 
																		}} );
			
		}
		
		protected function tweenForward(target:Sprite, menu:SlideMenu):void 
		{
			
			if (_tweening) return;
			
			if (target.name in menu.subMenus) {
				_tweening = true;
				callDown(target);
				
				menu.subMenus[target.name].visible = true;
				
				var tweenXto:Number = menu.x - (menu.width + _itemSpacing);
				
				TweenMax.to(target.parent, 0.5, { x:tweenXto, ease:Quad.easeInOut, onComplete:function():void { 
																			_tweening = false; 
																			dispatchMenuState(target.name);
																			if (!_breadcrumbTrail) callUp(target);
																			} } );
			}
			else {
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "slideMenuState", target.name, true));
			}
		}
		
		protected function callDown(target:Sprite):void {
			if (target.numChildren > 1)
				target.getChildAt(1).visible = true;
		}
		
		protected function callUp(target:Sprite):void {
			if (target.numChildren > 1)
				target.getChildAt(1).visible = false;
		}
		
		protected function dispatchMenuState(selectedItem:String):void {
			_menuState = selectedItem;
			if (!_subMenu)
				_subMenu = _subMenus[selectedItem];
			else {
				if (selectedItem != this._label)
					_subMenu = _subMenu.subMenus[selectedItem];
				else {
					_subMenu = null;
				}
			}
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "slideMenuState", selectedItem, true));
		}
		
		protected function dispatchBackMenu(subParent:*):void {
			if (subParent is SlideMenu) {
				_subMenu = subParent;
				_menuState = _subMenu.label;
			}
			else {
				_subMenu = null;
				_menuState = _label;
			}
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "slideMenuState", _menuState, true));
		}
		
		
		protected function clearTrail(objToClean:SlideMenu):void 
		{
			for (var i:int = 1; i < objToClean.numChildren; i++) {
				if (objToClean.getChildAt(i) is Sprite && !(objToClean.getChildAt(i) is SlideMenu)) {
					//if (objToClean.getChildAt(i) != objToClean.title)
						callUp(Sprite(objToClean.getChildAt(i)));
				}
			}
		}
		
		public function reset():void {
			if (_tweening)
				TweenMax.killAll();
			
			clearTrail(this);
			
			for each (var childMenu:SlideMenu in _subMenus) {
				childMenu.reset();
				childMenu.x += (this.width + _itemSpacing);
				childMenu.visible = false;
				
			}
			
			this.x = 0;
			_subMenu = null;
			_menuState = _label;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "slideMenuState", "reset"));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_backButton = null;
			maskSprite = null;
			origins = null;
			_disabledItems = null;
			_arrowIndicator = null;
			_returnIndicator = null;
			titleGradientAlphasArray = null;
			titleGradientColorArray = null;
			titleGradientRatiosArray = null;
			itemGradientAlphasArray = null;
			itemGradientColorArray = null;
			itemGradientRatiosArray = null;			
			selectedGradientAlphasArray = null;
			selectedGradientColorArray = null;
			selectedGradientRatiosArray = null;				
			_title = null;
			_item = null;
			_selected = null;
			_menuItems = null;
			_subMenu = null;
			_subMenus = null;
		}
		
		//} endregion Utility
	}

}