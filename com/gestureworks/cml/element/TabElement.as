package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TouchEvent;
	
	/**
	 * A container with a tab extension. The container's contents will be visible when the selected state is true and hidden othewise.
	 * Intended to be grouped and toggled between other tab elements in a <code>TabbedContainer</code>. 
	 * 
	 *<codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 	
	    override protected function gestureworksInit():void
		{
			trace("gestureWorksInit()");
			tabElementTestAS();
		}
		
		private function tabElementTestAS():void
		{
			var tab:TabElement = new TabElement();
			tab.title = "tab1";
			tab.init();
			addChild(tab);
			
			var square:GraphicElement = new GraphicElement();
			square.color = 0x00FF00;
			square.shape = "rectangle";
			square.width = 200;
			square.height = 200;
			square.y = 100;
			tab.addChild(square);			
		}
	 * 
	 * </codeblock>
	 * @author Shaun
	 */
	public class TabElement extends Container
	{
		private var _title:String = "";
		private var _displayColor:uint = 0x000000;
		private var _isSelected:Boolean = true;
		
		private var _tabFont:String = "OpenSansRegular";
		private var _tabFontSize:Number = 20;
		private var _tabFontColor:uint = 0xFFFFFF;
		private var _tabX:Number;
		private var _tabWidth:Number;
		private var _tabHeight:Number;
		private var _tabLeftRadius:Number;
		private var _tabRightRadius:Number;
		
		private var standAlone:Boolean = true;
		private var display:GraphicElement;
		private var tabGE:GraphicElement;	
		private var text:TextElement;
		
		
		/**
		 * Constructor
		 */
		public function TabElement() 
		{
			super();
			addEventListener(Event.ADDED, tabAdded);
			width = 462;
			height = 423;
			mouseChildren = false;
			
			text = new TextElement();
			tabGE = new GraphicElement();
			display = new GraphicElement();			
		}
		
		/**
		 * Initialization call
		 */
		public function init():void
		{
			setupUI();
		}
		
		/**
		 * CML initialization call
		 */
		override public function displayComplete():void 
		{
			init();
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "updateTab", this, true));	 
			addAllChildren();
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
		 * The the x location of the tab
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
			updateDisplayList();
		}		
				
		/**
		 * The height of the container 
		 * @default 385
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (display && tabGE) display.height = value - tabGE.height;
		}
		
		/**
		 * The width of the container 
		 * @default 500
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			if (display) display.width = value;
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
		
		public function get tabLeftRadius():Number { return _tabLeftRadius; }
		public function set tabRightRadius(r:Number):void
		{
			_tabLeftRadius = r;
		}
		
		public function get tabRightRadius():Number { return _tabRightRadius; }
		public function set tabRighRadius(r:Number):void
		{
			_tabRightRadius = r;
		}
		
		/**
		 * Configures all of the UI elements of the container
		 */
		private function setupUI():void
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
			tabGE.lineStroke = 0;
			tabGE.color = displayColor;
			tabGE.shape = "roundRectangleComplex";
			tabGE.topLeftRadius = tabLeftRadius ? tabLeftRadius : 13;
			tabGE.topRightRadius = tabRightRadius ? tabRightRadius : 13;
			tabGE.width = text.width;
			tabGE.height = text.height;
			tabGE.x = tabX;
			tabGE.fill = "gradient";
			tabGE.gradientWidth = tabGE.width;
			tabGE.gradientHeight = tabGE.height;
			tabGE.gradientRotation = 90;
			tabGE.gradientColors = tabGE.color+","+tabGE.color;
			tabGE.gradientAlphas = "1,.5";
			tabGE.addChild(text);
			addUIComponent(tabGE);	
			
			//setup panel background graphics
			display.lineStroke = standAlone ? 1.5 : 0;
			display.color = displayColor;
			display.shape = "rectangle";
			display.width = width;
			display.height = height - tabGE.height;
			display.y = tabGE.height;
			addUIComponent(display);									
		}
		
		/**
		 * A special child addition to exclude UI elements from selected state events
		 * @param	child
		 */
		private function addUIComponent(child:DisplayObject):void
		{
			super.addChild(child);
		}
		
		/**
		 * Sets visibility of children based on the selected state of the container
		 * @param	child
		 * @return
		 */
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			//child.mask = getContentMask();
			if (!isSelected) child.visible = false;
			return super.addChild(child);
		}
		
		/**
		 * Hides or displays all children depending on the selected state
		 */
		private function updateDisplayList():void
		{
			if (isSelected)
			{
				for (var i:int = 1; i < numChildren; i++)
					getChildAt(i).visible = true;
			}
			else 
			{
				for (var j:int = 1; j < numChildren; j++)
					getChildAt(j).visible = false;				
			}
		}
		
		/**
		 * Mechanism to determine if a <code>TabElement</code> belongs to a <code>TabbedContainer</code> or not.
		 * @param	e
		 */
		private function tabAdded(e:Event):void
		{
			if (e.target.parent is TabbedContainer)
			{
				standAlone = false;
				display.lineStroke = 0;
			}
		}
		
		/**
		 * @todo implement display masking option to prevent display objects from exceeding the boundaries of
		 * the container
		 * @return
		 */
		private function getContentMask():GraphicElement
		{
			var contentMask:GraphicElement = new GraphicElement();
			contentMask.alpha = 0;
			contentMask.shape = display.shape;
			contentMask.height = display.height;
			contentMask.width = display.width;
			contentMask.y = display.y;
			addUIComponent(contentMask);
			return contentMask;
		}
		
		/**
		 * Deconstructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			display = null;
			tabGE = null;
			text = null;
			
			removeEventListener(Event.ADDED, tabAdded);
		}
						
	}

}