package com.gestureworks.cml.element 
{
	import com.gestureworks.core.TouchSprite;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author josh
	 */
	public class SlideMenu extends Container
	{
		
		
		public function SlideMenu() 
		{
			super();
		}
		
		//{ region Properties
		
		//{ region Background properties
		
		
		
		//} endregion
		
		
		//{ region title properties
		
		var _titleGradientType:String = "none";
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
		
		var titleGradientColorArray:Array = [0x000000, 0xffffff, 0x000000];
		var _titleGradientColors:String = "";
		public function get titleGradientColors():String { return _titleGradientColors; }
		public function set titleGradientColors(value:String):void {
			titleGradientColorArray = [];
			
			if (!value) return;
			_titleGradientColors = value;
			
			titleGradientColorArray = _titleGradientColors.split(",");
		}
		
		var titleGradientAlphasArray:Array = [1, 1, 1];
		var _titleGradientAlphas:String = "";
		public function get titleGradientAlphas():String { return _titleGradientAlphas; }
		public function set titleGradientAlphas(value:String):void {
			titleGradientAlphasArray = [];
			
			if (!value) return;
			_titleGradientAlphas = value;
			
			titleGradientAlphasArray = _titleGradientAlphas.split(",");
		}
		
		var titleGradientRatiosArray:Array = [0, 177, 255];
		var _titleGradientRatios:String = "";
		public function get titleGradientRatios():String { return _titleGradientRatios; }
		public function set titleGradientRatios(value:String) {
			titleGradientRatiosArray = [];
			
			if (!value) return;
			_titleGradientRatios = value;
			
			titleGradientRatiosArray = _titleGradientRatios.split(",");
		}
		
		var _titleShape:String = "rectangle";
		/**
		 * Sets the shape of the title, either rectangle or roundRectangle
		 */
		public function get titleShape():String { return _titleShape; }
		public function set titleShape(value:String):void {
			_titleShape = value;
		}
		
		var _titleFill:uint = 0x555555;
		public function get titleFill():uint { return _titleFill; }
		public function set titleFill(value:uint):void {
			_titleFill = value;
		}
		
		var _titleStroke:Number = 0;
		public function get titleStroke():Number { return _titleStroke; }
		public function set titleStroke(value:Number):void {
			_titleStroke = value;
		}
		
		var _titleStrokeColor:uint = 0x333333;
		public function get titleStrokeColor():uint { return _titleStrokeColor; }
		public function set titleStrokeColor(value:uint):void {
			_titleStrokeColor = value;
		}
		
		//} endregion
		
		
		//{ region item properties
		
		var _itemWidth:Number;
		public function get itemWidth():Number { return _itemWidth; }
		public function set itemWidth(value:Number):void {
			_itemWidth = value;
		}
		
		var _itemHeight:Number;
		public function get itemHeight():Number { return _itemHeight; }
		public function set itemHeight(value:Number):void {
			_itemHeight = value;
		}
		
		var _itemGradientType:String = "none";
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
		
		var itemGradientColorArray:Array = [0x000000, 0xffffff, 0x000000];
		var _itemGradientColors:String = "";
		public function get itemGradientColors():String { return _itemGradientColors; }
		public function set itemGradientColors(value:String):void {
			itemGradientColorArray = [];
			
			if (!value) return;
			_itemGradientColors = value;
			
			itemGradientColorArray = _itemGradientColors.split(",");
		}
		
		var itemGradientAlphasArray:Array = [1, 1, 1];
		var _itemGradientAlphas:String = "";
		public function get itemGradientAlphas():String { return _itemGradientAlphas; }
		public function set itemGradientAlphas(value:String):void {
			itemGradientAlphasArray = [];
			
			if (!value) return;
			_itemGradientAlphas = value;
			
			itemGradientAlphasArray = _itemGradientAlphas.split(",");
		}
		
		var itemGradientRatiosArray:Array = [0, 177, 255];
		var _itemGradientRatios:String = "";
		public function get itemGradientRatios():String { return _itemGradientRatios; }
		public function set itemGradientRatios(value:String) {
			itemGradientRatiosArray = [];
			
			if (!value) return;
			_itemGradientRatios = value;
			
			itemGradientRatiosArray = _itemGradientRatios.split(",");
		}
		
		var _itemShape:String = "rectangle";
		/**
		 * Sets the shape of the item, either rectangle or roundRectangle
		 */
		public function get itemShape():String { return _itemShape; }
		public function set itemShape(value:String):void {
			_itemShape = value;
		}
		
		var _itemCornerWidth:Number = 15;
		public function get itemCornerWidth():Number { return _itemCornerWidth; }
		public function set itemCornerWidth(value:Number):void {
			_itemCornerWidth = value;
		}
		
		var _itemCornerHeight:Number = 15;
		public function get itemCornerHeight():Number { return _itemCornerHeight; }
		public function set itemCornerHeight(value:Number):void {
			_itemCornerHeight = value;
		}
		
		var _itemFill:uint = 0x555555;
		public function get itemFill():uint { return _itemFill; }
		public function set itemFill(value:uint):void {
			_itemFill = value;
		}
		
		var _itemStroke:Number = 0;
		public function get itemStroke():Number { return _itemStroke; }
		public function set itemStroke(value:Number):void {
			_itemStroke = value;
		}
		
		var _itemStrokeColor:uint = 0x333333;
		public function get itemStrokeColor():uint { return _itemStrokeColor; }
		public function set itemStrokeColor(value:uint):void {
			_itemStrokeColor = value;
		}
		
		//} endregion
		
		//} endregion
		
		
		
		//{ region Read-Only properties

		protected var _title:TouchSprite;
		public function get title():TouchSprite { return _title; }
		
		protected var _item:TouchSprite;
		public function get item():TouchSprite { return _item; }
		
		protected var _menuItems:Array = [];
		public function get menuItems():Array { return _menuItems; }
		
		//} endregion
		
		override public function init():void {
			
			if (parent && parent is SlideMenu) {
				
				createItem();
				
				// If there's no children, and the parent is a Slidemenu, this isn't a menu itself, it's a menu item,
				// and will only be used to dispatch events, so lets just skip everything else move along.
				if (numChildren == 0) return;
			}
			
			createTitle();
			
			updateLayout();
		}
		
		//{ region Object creation
		
		protected function createTitle():void {
			_title = new TouchSprite();
			_title.disableNativeTransform = true;
			_title.disableAffineTransform = true;
		}
		
		protected function createItem():void {
			_item = new TouchSprite();
			_item.disableNativeTransform = true;
			_item.disableAffineTransform = true;
			
			if (!_itemWidth || _itemWidth > width) _itemWidth = width;
			if (!_itemHeight) _itemHeight = height;
			
			// Gradient fill
			if (itemGradientType != "none") {
				var m:Matrix = new Matrix();
				m.createGradientBox(_itemWidth, _itemHeight, (Math.PI / 180) * 90);
				_item.graphics.beginGradientFill(_itemGradientType, itemGradientColorArray, itemGradientAlphasArray, itemGradientRatiosArray, m);
			}
			// solid fill
			else {
				_item.graphics.beginFill(_itemFill);
			}
			
			_item.graphics.lineStyle(_itemStroke, _itemStrokeColor);
			
			if (_itemShape == "roundRectangle") {
				_item.graphics.drawRoundRect(0, 0, _itemWidth, _itemHeight, _itemCornerWidth, _itemCornerHeight)
			}
			else {
				_item.graphics.drawRect(0, 0, _itemWidth, _itemHeight);
			}
			
			_item.graphics.endFill();
			addChild(_item);
		}
		
		//} endregion
		
		
		//{ region Utility
		
		private function updateLayout():void 
		{
			
		}
		
		//} endregion
	}

}