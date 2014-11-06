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
	 * Popup menu is used to create a simple menu from a text string of items.
	 * The menuItems are a comma separated list of items to populate the menu.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
		var ppMenu:PopupMenu = new PopupMenu();
		ppMenu.x = 500;
		ppMenu.y = 150;
		ppMenu.fill = 0xf2d4c2;
		ppMenu.color = 0xA66874;
		ppMenu.fontSize = 36;
		ppMenu.menuTitle = "Images";
		ppMenu.menuItems = "Image1,Image2,Image3,Image4,Image5";
		addChild(ppMenu);
		ppMenu.init();
				
					
		// This is the event listener for when a menu item has been selected.
		ddMenu.addEventListener(StateEvent.CHANGE, onItemSelected);
		
		
		function onItemSelected(e:StateEvent):void {
			trace("OnItemSelected", e.value);
		}

	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see DropDownMenu
	 * @see OrbMenu
	 */
	public class PopupMenu extends DropDownMenu
	{
		/**
		 * Constructor
		 */
		public function PopupMenu():void {
			super();
			mouseChildren = true;
		}
		
		/**
		 * inialization method 
		 */
		override public function init():void {
			super.init();
		}

		override public function onDownHit(event:*=null):void {
			if (!_open) {
				showMenu();
			}
			else if(_open) {
				hideMenu();
			}
		}
		
		override protected function onItemSelected(event:*):void {
			_currentSelection = event.target.text;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "itemSelected", event.target.text, true));
			hideMenu();
			_menuTitle.text = _currentSelection;
		}
	}
	
}