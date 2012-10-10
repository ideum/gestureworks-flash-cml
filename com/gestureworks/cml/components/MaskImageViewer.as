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
		/**
		 * constructor
		 */
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
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!maskCon){
				_maskCon = searchChildren(".mask_element");
				addEventListener(GWGestureEvent.ROTATE, onRotate);
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
				_maskCon = searchChildren(MaskContainer);
				addEventListener(GWGestureEvent.ROTATE, onRotate);
			}							
			maskCon.addEventListener(StateEvent.CHANGE, onStateEvent);
			super.init();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{			
			init();
		}
		
		override protected function updateLayout(event:* = null):void 
		{
			// update width and height to the size of the image, if not already specified
			if (!width && maskCon)
				width = maskCon.width;
			if (!height && maskCon)
				height = maskCon.height;
				
			super.updateLayout(event);
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	

			super.onStateEvent(event);
			if (event.value == "LOADED") {
				maskCon.removeEventListener(StateEvent.CHANGE, onStateEvent);
				updateLayout();
			}
		}
		
		private function onRotate(e:GWGestureEvent):void {
			_maskCon.dragAngle = this.rotation;
		}
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void
		{
			super.dispose();
			maskCon = null;
		}
	}
}