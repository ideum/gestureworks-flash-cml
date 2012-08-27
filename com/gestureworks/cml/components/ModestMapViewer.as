package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.GWGestureEvent;
	
	/**
	 * The ModestMapViewer is a component that is meant to display a map generated from ModestMaps on the front side and meta-data on the back side.
	 * It is composed of the following elements: map, front, back, menu, and frame. The image and front may be the same thing. 
	 * The map is required. The width and height of the component is automatically set to the dimensions of the map unless it is 
	 * previously specifed by the component.
	 */
	public class ModestMapViewer extends Component 
	{
		private var textFields:Array;	
		
		public function ModestMapViewer() 
		{
			super();
			mouseChildren = true;
			//_map = new ModestMapElement();
			disableNativeTransform = false;
			disableAffineTransform = false;			
		}
		
		
		private var _map:*;
		/**
		 * Sets the map element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get map():* {return _map}
		public function set map(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_map = value;
			else 
				_map = searchChildren(value);					
		}			
		
		
		private var _front:*;
		/**
		 * Sets the front element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get front():* {return _front}
		public function set front(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_front = value;
			else 
				_front = searchChildren(value);			
		}				
		
		
		private var _back:*;
		/**
		 * Sets the back element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get back():* {return _back}
		public function set back(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_back = value;
			else
				_back = searchChildren(value);
		}		
		
		
		private var _backBackground:*;
		/**
		 * Sets the back background element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get backBackground():* {return _backBackground}
		public function set backBackground(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_backBackground = value;
			else
				_backBackground = searchChildren(value);				
		}
		
		
		private var _menu:*;
		/**
		 * Sets the menu element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get menu():* {return _menu}
		public function set menu(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_menu = value;
			else
				_menu = searchChildren(value);
		}			
		
		
		private var _frame:*;
		/**
		 * Sets the frame element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get frame():* {return _frame}
		public function set frame(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_frame = value;
			else
				_frame = searchChildren(value);				
		}			
		
		
		private var _hideFrontOnFlip:Boolean = false;
		/**
		 * Specifies whether the front is hidden when the the back is shown
		 * @default false
		 */		
		public function get hideFrontOnFlip():* {return _hideFrontOnFlip}
		public function set hideFrontOnFlip(value:*):void 
		{	
			_hideFrontOnFlip = value;			
		}				
		
		
		private var _autoTextLayout:Boolean = true;
		/**
		 * Specifies whether text fields will be automatically adjusted to the component's width
		 * @default true
		 */		
		public function get autoTextLayout():Boolean {return _autoTextLayout}
		public function set autoTextLayout(value:Boolean):void 
		{	
			_autoTextLayout = value;			
		}		
		
		
		// public methods // 
	
		
		/**
		 * This is part of the CML parsing process.
		 */
		override public function displayComplete():void
		{
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!map){
				map = searchChildren(".map_element");
				trace("Adding map event listener.");
				map.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".map_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");
			
			// automatically try to find elements based on AS3 class
			if (!map){
				map = searchChildren(ModestMapElement);
				trace("Adding map event listener.");
				map.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			if (!menu)
				menu = searchChildren(Menu);
			if (!frame){
				frame = searchChildren(FrameElement);
			}
			if (!backBackground && back && back.hasOwnProperty("searchChildren"))
				backBackground = back.searchChildren(GraphicElement);	
			
			// this is the v2.0-v2.1 implementation
			if (autoTextLayout)
				textFields = searchChildren(TextElement, Array);
			
			//updateLayout();		
		}		
			
		
		///////////////////////////////////////////////////////////////////////
		// Private Methods
		//////////////////////////////////////////////////////////////////////		
		
		private function updateLayout():void
		{			
			// update width and height to the size of the image, if not already specified
			if (!width && map)
				width = map.width;
			if (!height && map)
				height = map.height;
							
			if (front)
			{
				front.width = width;
				front.height = height;				
			}			
			
			if (back)
			{
				back.width = width;
				back.height = height;				
			}
			
			if (backBackground)
			{
				backBackground.width = width;
				backBackground.height = height;
			}
				
			if (frame)
			{
				frame.width = width;
				frame.height = height;
			}			
			
			if (menu)
			{				
				menu.updateLayout(width, height);
				
				if (menu.autoHide) {
					if (GestureWorks.activeTUIO)
						this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
					else if	(GestureWorks.supportsTouch)
						this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					else	
						this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
						
					if (GestureWorks.activeTUIO)
						this.addEventListener(TuioTouchEvent.TOUCH_UP, onUp);
					else if	(GestureWorks.supportsTouch)
						this.addEventListener(TouchEvent.TOUCH_END, onUp);
					else	
						this.addEventListener(MouseEvent.MOUSE_UP, onUp);						
				}					
			}
			
			if (textFields && autoTextLayout)
			{
				for (var i:int = 0; i < textFields.length; i++) 
				{
					textFields[i].x = textFields[i].x + textFields[i].paddingLeft;
					
					textFields[i].autoSize = "left";
					textFields[i].width = width - textFields[i].paddingLeft - textFields[i].paddingRight;
										
					if (i == 0)
						textFields[i].y = textFields[i].paddingTop;
					else
						textFields[i].y = textFields[i].paddingTop + textFields[i-1].paddingBottom + textFields[i-1].height;
				}
			}
							
		}
		
		public function onDown(event:*):void
		{
			if (menu)
			{
				menu.visible = true;
				menu.startTimer();
			}
		}			

		public function onUp(event:*):void
		{
			if (menu)
				menu.mouseChildren = true;
		}		
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			if (event.value == "info") 
			{
				if (back)
				{
					if (!back.visible) { 
						back.visible = true;
					}
					else { 
						back.visible = false;
					}
				}
				if (front && hideFrontOnFlip)
				{
					if (!front.visible) { 
						front.visible = true;
					}
					else { 
						front.visible = false;
					}
				}
			}
			else if (event.value == "close")
			{
				this.visible = false;
			}
			else if (event.value == "loaded") {
				//map.removeEventListener(StateEvent.CHANGE, onStateEvent);
				trace("Traced mapElement loaded.");
				map.updateFrame();
				updateLayout();
			}
		}
		
		private function onDouble(e:*):void {
			map.switchMapProvider();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			textFields = null;
			map = null;
			front = null;
			back = null;
			backBackground = null;
			menu = null;
			frame = null;
			
			if (GestureWorks.activeTUIO)
				this.removeEventListener(TuioTouchEvent.DOUBLE_TAP, onDouble);
			else if	(GestureWorks.supportsTouch)
				this.removeEventListener(GWGestureEvent.DOUBLE_TAP, onDouble);
			else	
				this.removeEventListener(MouseEvent.DOUBLE_CLICK, onDouble);
			
			this.removeEventListener(StateEvent.CHANGE, onStateEvent);			
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);		
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);		
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
	}
	
}