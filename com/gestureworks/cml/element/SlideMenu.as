package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author josh
	 */
	public class SlideMenu extends TouchContainer
	{
		private var _backButton:TouchContainer;
		private var tweening:Boolean;
		private var maskSprite:Sprite;
		private var origins:Dictionary = new Dictionary(true);
		
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
		public function set titleGradientRatios(value:String) {
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
		public function set itemGradientRatios(value:String) {
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
		
		protected var _itemFontColor = 0xffffff;
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
		public function set selectedGradientRatios(value:String) {
			selectedGradientRatiosArray = [];
			
			if (!value) return;
			_selectedGradientRatios = value;
			
			selectedGradientRatiosArray = _selectedGradientRatios.split(",");
		}
		
		//} endregion item selected properties
		
		//} endregion Item region
		
		//} endregion properties
		
		
		
		//{ region Read-Only properties

		protected var _title:TouchSprite;
		public function get title():TouchSprite { return _title; }
		
		protected var _item:TouchContainer;
		public function get item():TouchContainer { return _item; }
		
		protected var _selected:Sprite;
		public function get selected():Sprite { return _selected; }
		public function set selected(value:Sprite) {
			_selected = value;
		}
		
		protected var _menuItems:Array = [];
		public function get menuItems():Array { return _menuItems; }
		
		protected var _subMenus:Dictionary = new Dictionary();
		public function get subMenus():Dictionary { return _subMenus; }
		
		protected var _initialized:Boolean = false;
		public function get initialized():Boolean { return _initialized; }
		
		protected var _totalHeight:Number = 0;
		public function get totalHeight():Number { return _totalHeight; }
		
		//} endregion
		
		override public function init():void {
			
			if (_initialized) {
				return;
			}
			
			if (parent && parent is SlideMenu) {
				
				createItem();
				
				// If there's no children, and the parent is a Slidemenu, this isn't a menu itself, it's a menu item,
				// and will only be used to dispatch events, so lets just skip everything else move along.
				if (numChildren == 0) return;
				
				createBackButton();
			}
			
			createTitle();
			
			updateLayout();
			
			listenForEvents();
			
			this.mouseChildren = true;
			
			_initialized = true;
		}
		
		//{ region Object creation
		
		protected function createTitle():void {
			trace("Creating title.");
			_title = new TouchSprite();
			_title.disableNativeTransform = true;
			_title.disableAffineTransform = true;
			
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
				_title.mouseChildren = true;
				_title.clusterBubbling = true;
				_title.addChild(_backButton);
				_backButton.y = (_title.height - _backButton.height) / 2;
				_backButton.x = _backButton.y;
				if (_fontAutoSize != "center") {
					titleLabel.x += _backButton.x + _backButton.width;
					titleLabel.width -= _backButton.x + _backButton.width;
				}
			}
			
			//addChild(_title);
		}
		
		protected function createItem():void {
			_item = new TouchContainer();
			_item.disableNativeTransform = true;
			_item.disableAffineTransform = true;
			
			// Lets just set up the selected graphic at the same time.
			_selected = new Sprite();
			
			_item.gestureList = this.gestureList;
			
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
			
			_item.addChild(_selected);
			_selected.visible = false;
			
			var itemLabel:Text = new Text();
			
			itemLabel.width = itemWidth - _itemFontPaddingLeft - _fontPaddingRight;
			itemLabel.x = _itemFontPaddingLeft;
			itemLabel.height = itemHeight - _itemFontPaddingTop;
			itemLabel.y = _itemFontPaddingTop;
			
			itemLabel.text = _label;
			itemLabel.selectable = false;
			
			itemLabel.autoSize = _itemFontAutoSize;
			
			itemLabel.color = _itemFontColor;
			itemLabel.fontSize = _itemFontSize;
			
			if (_itemFontAutoSize == "center") {
				itemLabel.x = (itemWidth / 2) - (itemLabel.width / 2);
			}
			
			_item.addChild(itemLabel);
			_item.id = label;
			//addChild(_item);
		}
		
		protected function createBackButton():void {
			_backButton = new TouchContainer();
			
			var radius:Number = (this.height / 2) * 0.7;
			_backButton.graphics.lineStyle(1.5, 0xffffff);
			_backButton.graphics.beginFill(0x000000, 1);
			_backButton.graphics.drawCircle(radius, radius, radius);
			
			_backButton.gestureList = gestureList;
			_backButton.addEventListener(GWGestureEvent.TAP, onBackTap);
			_backButton.width = radius * 2;
			_backButton.height = radius * 2;
			if ("id" in parent) {
				_backButton.id = parent["id"];
			}
		}
		
		//} endregion
		
		//{ region Event handlers
		
		
		protected function onItemDown(e:GWTouchEvent):void 
		{
			if (_menuItems.indexOf(e.target) > -1) {
				
				var ind:int = _menuItems.indexOf(e.target);
				
				if (_menuItems[ind].id in origins) {
					// Pass along the menu item and the menu that originally created to keep with the styles of its originating tag.
					//callDownState(Sprite(e.target), origins[_menuItems[ind].id]);
					callDown(TouchContainer(e.target));
					
					_menuItems[ind].addEventListener(GWTouchEvent.TOUCH_END, onItemUp);
					_menuItems[ind].addEventListener(GWTouchEvent.TOUCH_OUT, onItemUp);
				}
			}
		}
		
		
		private function onItemUp(e:GWTouchEvent):void 
		{
			
			if (_menuItems.indexOf(e.target) > -1) {
				
				var ind:int = _menuItems.indexOf(e.target);
				
				if (_menuItems[ind].id in origins) {
					trace("up");
					// Pass along the menu item and the menu that originally created to keep with the styles of its originating tag.
					//callUpState(Sprite(e.target), origins[_menuItems[ind].id]);
					//SlideMenu(origins[_menuItems[ind].id]).callUp();
					callUp(TouchContainer(e.target));
					
					_menuItems[ind].removeEventListener(GWTouchEvent.TOUCH_END, onItemUp);
					_menuItems[ind].removeEventListener(GWTouchEvent.TOUCH_OUT, onItemUp);
				}
			}
		}
		
		protected function itemOnTap(e:GWGestureEvent):void 
		{
			trace("tap");
			if (tweening) return;
			
			if (e.target.id in _subMenus) {
				tweening = true;
				
				//callDownState(Sprite(e.target), _subMenus[e.target.id]);
				callDown(TouchContainer(e.target));
				
				var tweenXto:Number = this.x - (this.width + _itemSpacing);
				TweenMax.to(this, 0.5, { x:tweenXto, ease:Quad.easeInOut, onComplete:function():void { 
																			tweening = false; 
																			dispatchMenuState(e.target.id);  
																			} } );
				//TweenMax.to(maskSprite, 0.5, { x:-tweenXto, ease:Quad.easeInOut } );
			}
			else {
				dispatchMenuState(e.target.id);
			}
		}
		
		protected function onBackTap(e:GWGestureEvent):void 
		{
			if (tweening) return;
			
			tweening = true;
			
			var tweenXto:Number = parent.x + (this.width + _itemSpacing);
			TweenMax.to(parent, 0.5, { x:tweenXto, ease:Quad.easeInOut, onComplete:function():void { tweening = false; 
																		dispatchMenuState(parent["label"]); }} );
			
		}
		
		//} endregion Event Handlers
		
		//{ region Utility
		
		protected function updateLayout():void 
		{
			var numberOfChildren:int = numChildren;
			
			for (var j:int = 0; j < numberOfChildren; j++) {
				if (getChildAt(j) is SlideMenu) {
					
					var childMenu:SlideMenu = getChildAt(j) as SlideMenu;
					synchChildMenu(childMenu);
					_menuItems.push(childMenu.item);
					
					origins[childMenu.label] = childMenu;
					
					if (_totalHeight < childMenu.totalHeight)
						_totalHeight = childMenu.totalHeight;
					
					if (childMenu.title) {
						_subMenus[childMenu.label] = childMenu;
						addChild(_subMenus[childMenu.label]);
						childMenu.x = width + itemSpacing;
						//childMenu.addChild(childMenu.title);
					}
					this.addChild(_menuItems[j]);
				}
			}
			
			addChild(_title);
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
			maskSprite.graphics.beginFill(0xff00ff, 0);
			maskSprite.graphics.drawRect(0, 0, width, _totalHeight);
			maskSprite.graphics.endFill();
			this.parent.addChild(maskSprite);
			this.mask = maskSprite;
		}
		
		protected function synchChildMenu(childMenu:SlideMenu):void 
		{
			// Copy properties from parent as long as the child hasn't set them and the parent has.
			for (var s:String in this.state[0]) {
				
				if (!(s in childMenu.state[0])) {
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
			for (var i:int = 0; i < _menuItems.length; i++) {
				_menuItems[i].addEventListener(GWGestureEvent.TAP, itemOnTap);
				_menuItems[i].addEventListener(GWTouchEvent.TOUCH_BEGIN, onItemDown);
			}
		}
		
		protected function callDown(target:TouchContainer):void {
			trace("Down.");
			//_selected.visible = true;
			//trace(Sprite(_item).getChildIndex(_selected));
			target.getChildAt(0).visible = true;
		}
		
		protected function callUp(target:TouchContainer):void {
			//_selected.visible = false;
			
			
			
			
			target.getChildAt(0).visible = false;
		}
		
		protected function callDownState(target:Sprite, template:SlideMenu):void 
		{
			
			// Gradient fill
			target.graphics.clear();
			if (template.itemGradientType != "none") {
				var m:Matrix = new Matrix();
				m.createGradientBox(template.itemWidth, template.itemHeight, (Math.PI / 180) * 90);
				target.graphics.beginGradientFill(template.itemGradientType, template.selectedGradientColorArray, template.selectedGradientAlphasArray, template.selectedGradientRatiosArray, m);
			}
			// solid fill
			else {
				target.graphics.beginFill(template.selectedFill);
			}
			
			target.graphics.lineStyle(template.itemStroke, template.itemStrokeColor);
			
			if (template.itemShape == "roundRectangle") {
				target.graphics.drawRoundRect(0, 0, template.itemWidth, template.itemHeight, template.itemCornerWidth, template.itemCornerHeight)
			}
			else {
				target.graphics.drawRect(0, 0, template.itemWidth, template.itemHeight);
			}
			
			target.graphics.endFill();
		}
		
		protected function callUpState(target:Sprite, template:SlideMenu):void 
		{
			
			// Gradient fill
			target.graphics.clear();
			if (template.itemGradientType != "none") {
				var m:Matrix = new Matrix();
				m.createGradientBox(template.itemWidth, template.itemHeight, (Math.PI / 180) * 90);
				target.graphics.beginGradientFill(template.itemGradientType, template.itemGradientColorArray, template.itemGradientAlphasArray, template.itemGradientRatiosArray, m);
			}
			// solid fill
			else {
				target.graphics.beginFill(template.itemFill);
			}
			
			target.graphics.lineStyle(template.itemStroke, template.itemStrokeColor);
			
			if (template.itemShape == "roundRectangle") {
				target.graphics.drawRoundRect(0, 0, template.itemWidth, template.itemHeight, template.itemCornerWidth, template.itemCornerHeight)
			}
			else {
				target.graphics.drawRect(0, 0, template.itemWidth, template.itemHeight);
			}
			
			target.graphics.endFill();
		}
		
		protected function dispatchMenuState(selectedItem:String):void {
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "slideMenuState", selectedItem));
		}
		
		//} endregion Utility
	}

}