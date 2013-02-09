package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.utils.DisplayUtils;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	
	/**
	 * The TabbedContainer element is a container that allows switching between a group of containers by selecting their associated tabs. 
	 * 
 	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 	
		var tabC:TabbedContainer = new TabbedContainer();	
		tabC.x = 100;
		tabC.y = 100;
		tabC.init();
		addChild(tabC);
		
		var tab:Tab = new Tab();
		tab.title = "tab1";
		tab.init();
		tabC.addTab(tab);		
		
		var tab1:Tab = new Tab();
		tab1.title = "tab2";
		tab1.init();
		tabC.addTab(tab1);	
		
		var circle:Graphic = new Graphic();
		circle.color = 0xFF0000;
		circle.shape = "circle";
		circle.radius = 100;
		circle.y = 100;
		tab.addChild(circle);
		
		var square:Graphic = new Graphic();
		square.color = 0x00FF00;
		square.shape = "rectangle";
		square.width = 200;
		square.height = 200;
		square.y = 100;
		tab1.addChild(square);
	 * 
	 * </codeblock>
	 * 
	 * @author Shaun 
	 * @see Tab
	 * @see Container
	 */
	public class TabbedContainer extends Container
	{
		private var _selectedIndex:int = -1;
		private var _backgroundColor:uint = 0x424141;
		private var _spacing:Number = 5;
		
		private var background:Graphic;
		private var tabs:Array;	
		
		/**
		 * Constructor
		 */
		public function TabbedContainer() 
		{
			super();
			tabs = new Array();
			width = 500;
			height = 420;
		}
		
		/**
		 * Initialization call
		 */
		public function init():void
		{					
			setupUI();
		}
		
		/**
		 * CML initialization. 
		 */
		override public function displayComplete():void 
		{			
			init();	
		}
		
		/**
		 * The index of the currently selected tab. 
		 */
		public function get selectedIndex():int { return _selectedIndex; }
		public function set selectedIndex(i:int):void
		{
			if (i < tabs.length)
				_selectedIndex = i;
		}
		
		/**
		 * The width of the container 
		 * @default 500
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			if(background) background.width = value;
		}		
		
		/**
		 * The height of the container 
		 * @default 420
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (background) background.height = value;
		}
		
		/**
		 * The color of the background graphic element
		 * @default 0x424141
		 */
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(c:uint):void
		{
			_backgroundColor = c;
			if (background)
			{
				var ct:ColorTransform = new ColorTransform();
				ct.color = _backgroundColor;
				background.transform.colorTransform = ct;
			}
		}
		
		/**
		 * The spacing between each tab
		 * @default 5
		 */
		public function get spacing():Number { return _spacing; }
		public function set spacing(s:Number):void
		{
			_spacing = s;
		}
		
		/**
		 * Renders and adds the UI graphic to the container
		 */
		private function setupUI():void
		{
			background = new Graphic();
			background.lineStroke = 0;
			background.color = backgroundColor;
			background.shape = "rectangle";
			background.width = width;
			background.height = height;
			addChild(background);	
			
			for (var i:int = this.numChildren - 1; i >= 0; i--)
			{
				var child:* = getChildAt(i);
				if (child is Tab)
				{
					child.init();
					addTab(child);
				}
			}
		}
		
		/**
		 * Updates the selected state of the target tab element
		 * @param	e the touch event
		 */
		private function selectTab(e:TouchEvent):void
		{
			addTab(DisplayUtils.getParentType(Tab, e.target));
		}	
		
		/**
		 * Adds a new tab to the container and/or gives focus to the selected tab.
		 * @param	tab
		 */
		private function addTab(tab:Tab):void
		{
			var previousTab:Tab = tabs.length > 0 ? tabs[selectedIndex] : null;
				
			//if tab is new, set dimensions and location relative to container, listen
			//for tab selection and add to tab array
			if (!hasTab(tab))
			{		
				tab.x = 2;
				tab.y = 5;
				tab.width = width - 4;
				tab.height = height - 7;
				tab.tabX = nextTabX();
				tab.addEventListener(TouchEvent.TOUCH_BEGIN, selectTab, false, 0, true);					
				tabs.push(tab);
			}
			
			//update selected state of previously selected tab
			if (previousTab != null && tab != previousTab)
				previousTab.isSelected = false;
			
			//update slected state of current tab	
			tab.isSelected = true;
			selectedIndex = tabs.indexOf(tab);
			
			//places tab element on top
			addChild(tab);
		}
		
		/**
		 * Calculates the x location of the next tab depending on the previous tab location
		 * and the spacing
		 * @return  the x location of the next tab
		 */
		private function nextTabX():Number
		{
			var lastTab:Tab = lastTab();
			if (lastTab)
				return lastTab.tabX + lastTab.tabWidth + spacing;
			return spacing;
		}
		
		/**
		 * Checks to see if tab exists in the tab array
		 * @param	tab1  the tab to search for
		 * @return  true if the tab exists, false otherwise
		 */
		private function hasTab(tab1:Tab):Boolean
		{
			for each(var tab2:Tab in tabs)
				if (tab1 == tab2) return true;
			return false;
		}
		
		/**
		 * Returns the most recently added tab
		 * @return  the furthest tab to the right
		 */
		private function lastTab():Tab
		{
			if (tabs.length > 0)
				return tabs[tabs.length - 1];
			return null;
		}
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			background = null;
			tabs = null;			
		}
		
	}

}