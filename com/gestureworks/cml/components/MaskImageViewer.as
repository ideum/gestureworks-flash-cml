////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2010-2011 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:     MaskImageDisplay.as
//
//  Author:  Paul Lacey (paul(at)ideum(dot)com)		 
//
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.

////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.element.FrameElement;
	import com.gestureworks.cml.element.GraphicElement;
	import flash.events.Event;
	import adobe.utils.CustomActions;
	import com.gestureworks.cml.factories.TouchContainerFactory;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.utils.*;
	
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.element.Container;	
	import com.gestureworks.cml.kits.ComponentKit;	
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.core.GestureWorks;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks	

	 /**
	 * <p>The MaskImageDisplay component is the main component for the MaskImageViewer module.  It contains all the neccessary display objects for the module.</p>
	 *
	 * <p>
     * The MaskImageViewer is a module that uses the Flash Drawing API to create a window based interactive dynamic image mask.  
	 * Multiple touch object windows can independently display individual masked images pairs with different sizes and orientations.  
	 * The maskimage windows can be interactively moved around stage, scaled and rotated using multitouch gestures additionaly the 
	 * mask can be panned, zoomed and rotated using multitouch gestures inside the masked image window. Multitouch frame gestures 
	 * can be activated and deactivated using the module XML settings.</p>
	 *
	**/
	 
	public class MaskImageViewer extends Component//ComponentKit
	{
		private var textFields:Array;
	
		public function MaskImageViewer()
		{
			super();
			//trace("mask viewer");
		}
		
		private var _maskCon:*;
		/**
		 * Sets the image mask element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get maskCon():* {return _maskCon}
		public function set maskCon(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_maskCon = value;
			else 
				_maskCon = searchChildren(value);					
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
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!maskCon){
				maskCon = searchChildren(".mask_element");
			}
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".mask_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!maskCon){
				maskCon = searchChildren(MaskContainer);
			}
			if (!menu)
				menu = searchChildren(Menu);
			if (!frame)
				frame = searchChildren(FrameElement);
			if (!backBackground && back && back.hasOwnProperty("searchChildren"))
				backBackground = back.searchChildren(GraphicElement);	
			
			// this is the v2.0-v2.1 implementation
			if (autoTextLayout)
				textFields = searchChildren(TextElement, Array);
			
				
				maskCon.addEventListener(StateEvent.CHANGE, onStateEvent);
			updateLayout();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{			
			init();
		}
		
		public function updateLayout():void
		{
			// update width and height to the size of the image, if not already specified
			if (!width && maskCon)
				width = maskCon.width;
			if (!height && maskCon)
				height = maskCon.height;
							
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
			else if (event.value == "LOADED") {
				maskCon.removeEventListener(StateEvent.CHANGE, onStateEvent);
				updateLayout();
			}
		}
		
		private function downHandler(e:TouchEvent):void
		{
			trace("t down");
		}
		
		private function tapHandler(e:GWGestureEvent):void
		{
			trace("tap");
		}
		
		private function dTapHandler(e:GWGestureEvent):void
		{
			
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			textFields = null;
			maskCon = null;
			front = null;
			back = null;
			backBackground = null;
			menu = null;
			frame = null;
			
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