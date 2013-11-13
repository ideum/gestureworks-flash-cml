package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TouchEvent;
	
	/**
	 * The Tab element is a container with a tab extension. The container's contents will be visible when the selected state is true and hidden othewise.
	 * Intended to be grouped and toggled between other tab elements in a <code>TabbedContainer</code>. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 	
		var tab:Tab = new Tab();
		tab.title = "tab1";
		tab.init();
		addChild(tab);
		
		var square:Graphic = new Graphic();
		square.color = 0x00FF00;
		square.shape = "rectangle";
		square.width = 200;
		square.height = 200;
		square.y = 100;
		tab.addChild(square);
	 * 
	 * </codeblock>	
	 * 
	 * @author Shaun
	 * @see TabbedContainer
	 */
	public class Tab extends TouchContainer
	{
		private var _title:String = "";
		private var _displayColor:uint = 0x000000;
		private var _isSelected:Boolean = true;
		private var _applyMask:Boolean = true;
		
		private var _tabFont:String = "OpenSansRegular";
		private var _tabFontSize:Number = 20;
		private var _tabFontColor:uint = 0xFFFFFF;
		private var _tabX:Number;
		private var _tabWidth:Number;
		private var _tabHeight:Number;
		private var _tabLeftRadius:Number;
		private var _tabRightRadius:Number;
		private var _displayTopLeftRadius:Number;
		private var _displayTopRightRadius:Number
		private var _displayBottomLeftRadius:Number;
		private var _displayBottomRightRadius:Number
		
		private var contentContainer:Container;
		private var displayBkg:Graphic;
		private var tabGE:Graphic;	
		private var text:Text;
		private var contentMask:Graphic;
		
		
		/**
		 * Constructor
		 */
		public function Tab() 
		{
			super();
			mouseChildren = true;
			width = 462;
			height = 423;

			text = new Text();
			tabGE = new Graphic();
			contentContainer = new Container();
			displayBkg = new Graphic();
			contentMask = new Graphic();
		}
		
		/**
		 * Initialization call
		 */
		override public function init():void
		{
			if(!(parent is TabbedContainer))
				setupUI();
		}

		/**
		 * The text displayed on the container's tab
		 * @default ""
		 */
		public function get title():String { return _title; } 
		public function set title(t:String): void
		{
			_title = t;
		}
		
		/**
		 * Mask the content to prevent objects from exceeding the boundaries 
		 */
		public function get applyMask():Boolean { return _applyMask; }
		public function set applyMask(m:Boolean):void
		{
			_applyMask = m;
		}
		
		/**
		 * The background color of the container
		 * @default 0x000000
		 */
		public function get displayColor():uint { return _displayColor; }
		public function set displayColor(c:uint):void
		{
			_displayColor = c;
		}
						
		/**
		 * The font of tab's text
		 * @default OpenSansRegular
		 */
		public function get tabFont():String { return _tabFont; }
		public function set tabFont(f:String):void
		{
			_tabFont = f;
		}
		
		/**
		 * The font size of the tab's text
		 * @default 20
		 */
		public function get tabFontSize():Number { return _tabFontSize; }
		public function set tabFontSize(s:Number):void
		{
			_tabFontSize = s;
		}
		
		/**
		 * The font color of the tab's text
		 * @default 0xFFFFFF
		 */
		public function get tabFontColor():Number { return _tabFontColor; }
		public function set tabFontColor(c:Number):void
		{
			_tabFontColor = c;
		}
		
		/**
		 * The the x location of the tab relative to the tab container
		 */
		public function get tabX():Number { return _tabX; }
		public function set tabX(tx:Number):void
		{
			_tabX = tx;
			if (tabGE) tabGE.x = _tabX;
		}
		
		/**
		 * The selected state of the tab container
		 */
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(s:Boolean):void
		{
			_isSelected = s;
			alpha = _isSelected ? 1 : .5;
			tabGE.fill = _isSelected ? "color" : "gradient";
			updateDisplay();
		}		
				
		/**
		 * The height of the container 
		 * @default 385
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (contentContainer && tabGE) 
			{
				contentContainer.height = value - tabGE.height;
				displayBkg.height = contentContainer.height;
				if (contentMask) contentMask.height = contentContainer.height;
			}
		}
		
		/**
		 * The width of the container 
		 * @default 500
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			if (contentContainer) 
			{
				contentContainer.width = value;
				displayBkg.width = value;
				if (contentMask) contentMask.width = value;
			}
		}
		
		/**
		 * The width of the tab
		 */
		public function get tabWidth():Number { return _tabWidth; }
		public function set tabWidth(w:Number):void
		{
			_tabWidth = w;
		}
		
		/**
		 * The height of the tab
		 */
		public function get tabHeight():Number { return _tabHeight; }
		public function set tabHeight(h:Number):void
		{
			_tabHeight = h;
		}
		
		/**
		 * The radius of the upper left corner of the tab in pixels
		 */
		public function get tabLeftRadius():Number { return _tabLeftRadius; }
		public function set tabLeftRadius(r:Number):void
		{
			_tabLeftRadius = r;
		}
		
		/**
		 * The radius of the upper right corner of the tab in pixels
		 */
		public function get tabRightRadius():Number { return _tabRightRadius; }
		public function set tabRightRadius(r:Number):void
		{
			_tabRightRadius = r;
		}

		/**
		 * The radius of the upper left corner of the display in pixels
		 */
		public function get displayTopLeftRadius():Number { return _displayTopLeftRadius; }
		public function set displayTopLeftRadius(r:Number):void
		{
			_displayTopLeftRadius = r;
		}
		
		/**
		 * The radius of the upper right corner of the display in pixels
		 */
		public function get displayTopRightRadius():Number { return _displayTopRightRadius; }
		public function set displayTopRightRadius(r:Number):void
		{
			_displayTopRightRadius = r;
		}
	
		/**
		 * The radius of the lower left corner of the display in pixels
		 */
		public function get displayBottomLeftRadius():Number { return _displayBottomLeftRadius; }
		public function set displayBottomLeftRadius(r:Number):void
		{
			_displayBottomLeftRadius = r;
		}
		
		/**
		 * The radius of the lower right corner of the display in pixels
		 */
		public function get displayBottomRightRadius():Number { return _displayBottomRightRadius; }
		public function set displayBottomRightRadius(r:Number):void
		{
			_displayBottomRightRadius = r;
		}		
				
		[Deprecated(replacement="displayTopLeftRadius")]	
		public function get displayLeftRadius():Number { return _displayTopLeftRadius; }
		public function set displayLeftRadius(r:Number):void
		{
			displayTopLeftRadius = r;
		}
		
		[Deprecated(replacement="displayTopRightRadius")]	
		public function get displayRightRadius():Number { return _displayTopRightRadius; }
		public function set displayRightRadius(r:Number):void
		{
			displayTopRightRadius = r;
		}		
		
		/**
		 * Configures all of the UI elements of the container
		 * @private
		 */
		public function setupUI():void
		{	
			//setup text
			text.text = title;
			text.textAlign = "center";
			text.verticalAlign = true;
			text.selectable = false;			
			text.fontSize = tabFontSize;
			text.font = tabFont;
			text.textColor = tabFontColor;
			text.width = tabWidth ? tabWidth : text.width;
			text.height = tabHeight ? tabHeight : text.height;			
			
			//setup tab graphics
			tabWidth = text.width;
			tabHeight = text.height;
			tabGE.lineStroke = 0;
			tabGE.color = displayColor;
			tabGE.shape = "roundRectangleComplex";
			tabGE.topLeftRadius = tabLeftRadius ? tabLeftRadius : 13;
			tabGE.topRightRadius = tabRightRadius ? tabRightRadius : 13;
			tabGE.width = text.width;
			tabGE.height = text.height;
			tabGE.x = tabX;
						
			tabGE.fill = "gradient";
			tabGE.gradientWidth = tabWidth;
			tabGE.gradientHeight = tabWidth;
			tabGE.gradientRotation = 90;
			tabGE.gradientColors = tabGE.color+","+tabGE.color;
			tabGE.gradientAlphas = "1,.5";
			tabGE.addChild(text);
			addUIComponent(tabGE);	
			
			//setup content container
			contentContainer.width = width;
			contentContainer.height = height - tabHeight;
			if (!isSelected) contentContainer.visible = false;
			addUIComponent(contentContainer);
			
			//setup content background 
			displayBkg.lineStroke = 0;
			displayBkg.color = displayColor;
			displayBkg.shape = "roundRectangleComplex";
			
			displayBkg.topLeftRadius = displayTopLeftRadius ? displayTopLeftRadius : 0;
			displayBkg.topRightRadius = displayTopRightRadius ? displayTopRightRadius : 0;
			displayBkg.bottomLeftRadius = displayBottomLeftRadius ? displayBottomLeftRadius : 0;
			displayBkg.bottomRightRadius = displayBottomRightRadius ? displayBottomRightRadius : 0;			
			
			displayBkg.width = contentContainer.width;
			displayBkg.height = contentContainer.height;
			displayBkg.y = tabGE.height - 1;
			contentContainer.addChildAt(displayBkg,0);			
			
			//create mask and apply it to the content container
			if (applyMask)
			{				
				contentMask.shape = "rectangle";
				contentMask.width = width;
				contentMask.height = displayBkg.height;
				contentMask.y = displayBkg.y;
				contentContainer.addChild(contentMask)
				contentContainer.mask = contentMask;
			}
		}
		
		/**
		 * Adds child to the <code>TabElement</code> rather than the content container
		 * @param	child  the object to add
		 */
		private function addUIComponent(child:DisplayObject):void
		{
			super.addChild(child);
		}
		
		/**
		 * Reroutes children addition to the content container
		 * @param	child  object to add
		 * @return  the object added
		 */
		override public function addChild(child:DisplayObject):DisplayObject 
		{	
			childList.removeByValue(child);
			return contentContainer.addChild(child);
		}
		
		/**
		 * Reroutes children addition at a specified index to the content container
		 * @param	child  object to add
		 * @param	index  the content container's index
		 * @return  the object added
		 */
		override public function addChildAt(child:DisplayObject, index:int):flash.display.DisplayObject 
		{
			childList.removeByValue(child);
			index = index == 0 ? 1 : index;  //index 0 is reserved for background
			return contentContainer.addChildAt(child, index);
		}
				
		/**
		 * Sets the mouseChildren flag 
		 * @param value  true to enable, false otherwise
		 */
		override public function set mouseChildren(value:Boolean):void 
		{
			super.mouseChildren = value;
			if(contentContainer)
				contentContainer.mouseChildren = value;
		}
		
		/**
		 * Return layout from content container
		 */
		override public function get layout():* 
		{
			return contentContainer.layout;
		}
		
		/**
		 * Add layout to content container
		 */
		override public function set layout(value:*):void 
		{
			contentContainer.layout = value;
			contentContainer.layoutList = layoutList;
		}
		
		/**
		 * Apply layout to content container
		 * @param	value
		 */
		override public function applyLayout(value:* = null):void 
		{
			contentContainer.applyLayout(value);
		}
		
		/**
		 * Hides or displays content depending on the selected state
		 */
		private function updateDisplay():void
		{
			if (isSelected)
				contentContainer.visible = true;
			else 
				contentContainer.visible = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			displayBkg = null;
			tabGE = null;
			text = null;
			contentContainer = null;
			contentMask = null;
		}
						
	}

}