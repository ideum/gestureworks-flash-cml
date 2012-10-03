package com.gestureworks.cml.components
{
	//----------------adobe--------------//
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.core.*;
	import flash.display.*;
	import flash.events.*;
	import org.openzoom.flash.components.*;
	import org.openzoom.flash.viewport.constraints.*;
	import org.tuio.*;
	//---------- gestureworks ------------//
	//---------------open zoom-------------//
	
	 /**
	 * <p>The GigaPixelDisplay component is the main component for the GigaPixelViewer module.  It contains all the neccessary display objects for the module.</p>
	 *
	 * <p>
	 * The GigaPixelViewer is a module that uses the GigapixelElement to create interactive high resolution zoomable image windows.  
	 * Multiple windows can independently display individual images with different sizes and orientations. The Gigapixel Elements are already touch enabled and should not be placed in touchContainers.  
	 * The image windows can be interactively moved around stage, scaled and rotated using multitouch gestures additionaly the image can be panned and zoomed using multitouch gesture inside the image window.
	 * Multitouch frame gestures can be activated and deactivated using the module XML settings.</p>
	 *
	 * <strong>Import Components :</strong>
	 * <pre>
	 * GigaPixelParser
	 * </pre>
	 *
	 * <listing version="3.0">
	 * var gpDisplay:GigaPixelDisplay = new GigaPixelDisplay();
	 *
	 * 		gpDisplay.id = Number;
	 *
	 * addChild(gpDisplay);</listing>
	 *
	 * @see id.module.GigaPixelViewer
	 * 
	 * @includeExample GigaPixelDisplay.as
	 * 
	 * @langversion 3.0
	 * @playerversion AIR 2
	 * @playerversion Flash 10.1
	 * @playerversion Flash Lite 4
	 * @productversion GestureWorks 2.0
	 */
	
	 
	public class GigaPixelViewer extends Component
	{
		//private var frame:TouchSprite;
		private var info:*;
		//private var menu:Menu;
		private var textFields:Array;

		//------ image settings ------//
		private var _clickZoomInFactor:Number = 1.7
		private var _scaleZoomFactor:Number = 1.4
    	public var smoothPanning:Boolean = true;
    	private var sceneNavigator:SceneNavigator;
    	private var scaleConstraint:ScaleConstraint;
	
	
		public function GigaPixelViewer()
		{
			super();
		}
		
		private var _gigapixel:*;
		/**
		 * Sets the gigapixel element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get gigapixel():* {return _gigapixel}
		public function set gigapixel(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_gigapixel = value;
			else 
				_gigapixel = searchChildren(value);					
		}
		
		private var _minScaleConstraint:Number = 0.001;
		public function get minScaleConstraint():Number { return _minScaleConstraint; }
		public function set minScaleConstraint(value:Number):void {
			if(!isNaN(value) && value >=0){
				_minScaleConstraint = value;
			}
		}

		private var _front:*;
		/**
		 * Sets the front element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get front():* { return _front; }
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
		public function get back():* { return _back; }
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
		public function get backBackground():* { return _backBackground; }
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
		public function get menu():* { return _menu; }
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
		public function get frame():* { return _frame; }
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
		public function get hideFrontOnFlip():* { return _hideFrontOnFlip; }
		public function set hideFrontOnFlip(value:*):void 
		{	
			_hideFrontOnFlip = value;			
		}
		
		private var _autoTextLayout:Boolean = true;
		/**
		 * Specifies whether text fields will be automatically adjusted to the component's width
		 * @default true
		 */		
		public function get autoTextLayout():Boolean { return _autoTextLayout; }
		public function set autoTextLayout(value:Boolean):void 
		{	
			_autoTextLayout = value;			
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{
			setupUI();
			updateLayout();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{			
			init();
		}
		
		private function setupUI():void
		{ 
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!gigapixel)
				gigapixel = searchChildren(".gigapixel_element");
				gigapixel.addEventListener(StateEvent.CHANGE, onStateEvent);
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".gigapixel_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!gigapixel)
				gigapixel = searchChildren(GigapixelElement);
				gigapixel.addEventListener(StateEvent.CHANGE, onStateEvent);
			if (!menu)
				menu = searchChildren(Menu);
			if (!frame)
				frame = searchChildren(FrameElement);
			if (!backBackground && back && back.hasOwnProperty("searchChildren"))
				backBackground = back.searchChildren(GraphicElement);	
			
			// this is the v2.0-v2.1 implementation
			if (autoTextLayout)
				textFields = searchChildren(TextElement, Array);
				
			updateLayout();
		}
		
		private function updateLayout():void
		{
			// update width and height to the size of the image, if not already specified
			if (!width && gigapixel)
				width = gigapixel.width;
				trace("Gigapixel width: " + gigapixel.width);
			if (!height && gigapixel)
				height = gigapixel.height;
				trace("Gigapixel height: " + gigapixel.height);
							
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
		
		private function onDown(event:*):void
		{
			menu.visible = true;
			menu.startTimer();
		}
		
		public function onUp(event:*):void
		{
			if (menu)
				menu.mouseChildren = true;
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			//trace("StateEvent change", event.value);
			var info:* = childList.getCSSClass("info_container", 0)
			
			if (event.value == "info") {
				if (!info.visible) {
					info.visible = true;
					gigapixel.visible = false;
				}
				else {
					info.visible = false;
					gigapixel.visible = true;
				}
			}
			else if (event.value == "close") 	this.visible = false;
			else if (event.value == "loaded") {
				height = gigapixel.height;
				width = gigapixel.width;
				gigapixel.removeEventListener(StateEvent.CHANGE, onStateEvent);
				
				updateLayout();
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			frame = null;
			info = null;
			menu = null;
			sceneNavigator = null;
			scaleConstraint = null;
			textFields = null;
			
			if (gigapixel)
			{
				gigapixel.removeEventListener(StateEvent.CHANGE, onStateEvent);
				gigapixel = null;
			}	
			
			this.removeEventListener(StateEvent.CHANGE, onStateEvent);
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);			
			this.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
			this.removeEventListener(TouchEvent.TOUCH_END, onUp);
			this.removeEventListener(MouseEvent.MOUSE_UP, onUp);	
		}
	}
}