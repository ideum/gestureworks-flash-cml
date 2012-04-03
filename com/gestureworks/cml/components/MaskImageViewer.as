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
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.utils.*;
	
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
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
	import com.gestureworks.cml.element.Component;

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
		// ----- interactive object settings --//
		private var count:int = 1;
		private var n:int = 0;
		private var frame:TouchSprite;
		private var info:*;
		private var menu:Menu;
		
		//private var holder:TouchContainer;
		private var base_image:TouchSprite;
		private var mask_image:Sprite;
		private var mShape:Container;
		private var shape_hit:TouchContainer;
		private var meta_data:TouchContainer;
		private var mShapeOutline:Container;
		
		private var wShape:GraphicElement;
		
		//public static var COMPLETE:String = "complete";
				 
	
		public function MaskImageViewer()
		{
			super();
			//trace("mask viewer");
		}

		override public function dispose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			//trace("mask image viewer complete")
			initUI();
			setupUI();
			updateLayout();
			
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
		}
		
			
		private function initUI():void
		{				
			n = this.childList.getCSSClass("mask_img", 0).childList.length;
			//trace("childList length------------------------------:", n);
			
			//-- bottom image --//
			width = this.childList.getCSSClass("base_img", 0).width;
			height = this.childList.getCSSClass("base_img", 0).height;
		}
			
		private function setupUI():void
		{ 
			//trace("setup");
			
			// set frame size
			this.childList.getCSSClass("touch_frame", 0).childList.getCSSClass("frame", 0).width = width;
			this.childList.getCSSClass("touch_frame", 0).childList.getCSSClass("frame", 0).height = height;
			
			//set bottom image
			base_image = this.childList.getCSSClass("base_img", 0)
				base_image.targetParent = true;  // make base capture touch points
			addChild(base_image);
			
			//top image stack
			mask_image = this.childList.getCSSClass("mask_img", 0);
				mask_image.getChildAt(0).visible = true;
			addChild(mask_image);
			
			
			////////////////////////////////////
			// image mask
			////////////////////////////////////
			mShape = this.childList.getCSSClass("mask_shape", 0);
			addChild(mShape);
			
			shape_hit = this.childList.getCSSClass("touch_mask_shape", 0);
				shape_hit.addEventListener(GWGestureEvent.DOUBLE_TAP, dTapHandler);
				shape_hit.addEventListener(GWGestureEvent.DRAG, dragHandler);
				shape_hit.addEventListener(GWGestureEvent.SCALE, scaleHandler);
				shape_hit.addEventListener(GWGestureEvent.ROTATE, rotateHandler);
			addChild(shape_hit);
			
			mask_image.mask = mShape;
			
			/////////////////////////////////////
			// mask outline
			/////////////////////////////////////
			mShapeOutline = this.childList.getCSSClass("mask_shape_outline", 0);
			addChild(mShapeOutline);
			
			wShape = this.childList.getCSSClass("window_shape", 0);
				wShape.width = width;
				wShape.height = height;
			addChild(wShape);
			
			mShapeOutline.mask = wShape;
			
			
			meta_data = this.childList.getCSSClass("info_container", 0)
				meta_data.targetParent = true;  // make base capture touch points
			addChild(meta_data);
		}
		
		private function updateLayout():void
		{
			info = childList.getCSSClass("info_container", 0);						
			menu = childList.getCSSClass("menu_container", 0);
			
			if (menu.autoHide)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);				
			}
			
			
			// update frame size
			if (childList.getCSSClass("frame_container", 0))
			{
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).width = width;
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).height = height;
			}
			// update info panel size
			if (childList.getCSSClass("info_container", 0))
			{
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_bg", 0).width = width;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_bg", 0).height = height;
			}
		
			// update info text size
			if (childList.getCSSClass("info_container", 0)) 
			{
				var textpaddingX:Number = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).paddingLeft;
				var textpaddingY:Number = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).paddingTop;
				var textSep:Number = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).paddingBottom;
				
				
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).x = textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).y = textpaddingY;
				
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).x = textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).y = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).height + textpaddingY + textSep;
				
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).width = width - 2*textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).width = width-2*textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).height = height-2*textpaddingY-textSep-childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).height;
			}
			
			// update button placement
			if (childList.getCSSClass("menu_container", 0))
			{
				var btnWidth:Number = menu.childList.getCSSClass("close_btn", 0).childList.getCSSClass("down", 0).childList.getCSSClass("btn-bg-down", 0).width;
				var btnHeight:Number = menu.childList.getCSSClass("close_btn", 0).childList.getCSSClass("down", 0).childList.getCSSClass("btn-bg-down", 0).height;
				var paddingLeft:Number = menu.paddingLeft;
				var paddingRight:Number = menu.paddingRight;
				var paddingBottom:Number = menu.paddingBottom;
				var position:String = menu.position;
				
				if(position=="bottom"){
					menu.y = height - btnHeight -paddingBottom;
					menu.childList.getCSSClass("info_btn", 0).x = paddingLeft
					menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft
				}
				else if(position=="top"){
					menu.y = paddingBottom;
					menu.childList.getCSSClass("info_btn", 0).x = paddingLeft
					menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft
				}
				
				else if(position=="topLeft"){
					menu.y = paddingBottom;
					menu.childList.getCSSClass("info_btn", 0).x = paddingLeft
					menu.childList.getCSSClass("close_btn", 0).x = btnWidth + paddingLeft +paddingRight;
				}
				else if(position=="topRight"){
					menu.y = paddingBottom;
					menu.childList.getCSSClass("info_btn", 0).x = width - 2*btnWidth - paddingLeft -paddingRight
					menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft
				}
				
				else if(position=="bottomLeft"){
					menu.y = height - btnHeight -paddingBottom;
					menu.childList.getCSSClass("info_btn", 0).x = paddingLeft;
					menu.childList.getCSSClass("close_btn", 0).x = btnWidth + paddingLeft +paddingRight;
				}
				else if(position=="bottomRight"){
					menu.y = height - btnHeight -paddingBottom;
					menu.childList.getCSSClass("info_btn", 0).x = width - 2*btnWidth - paddingLeft -paddingRight
					menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft
				}
			}	
		}
		
		private function onDown(event:*):void
		{
			menu.visible = true;
			menu.startTimer();
		}
		
		private function onStateEvent(event:StateEvent):void
		{	
			trace("StateEvent change", event.value);
			var info:* = childList.getCSSClass("info_container", 0);
			
			if (event.value == "info") {
				if (!info.visible) {
					info.visible = true;
				}
				else {
					info.visible = false;
				}
			}
			else if (event.value == "close") 	this.visible = false;
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
			if (count > n-1) count = 1;
			else count++;
			
			trace("d tap", count, n);
			
			//  turn on required image
			for (var i:int = 0; i <n; i++)
				{
				mask_image.getChildAt(i).visible = false
				if (i == count-1) mask_image.getChildAt(i).visible = true;
			}
			
		}
		
		// gesture event handlers to act on mask shape object
		private function dragHandler(event:GWGestureEvent):void 
		{
			var ang2:Number = rotation * (Math.PI / 180);
			var COS2:Number = Math.cos(ang2);
			var SIN2:Number = Math.sin(ang2);
			
			///var x_:Number = Math.abs(mShape.x + event.value.dx);
			//var y_:Number = Math.abs(mShape.y + event.value.dy);
			
			//if ((x_ > 0) && (x_ < Width))
			//{
				mShape.x += (event.value.dy * SIN2 + event.value.dx * COS2);//e.value.dx;
				mShapeOutline.x += (event.value.dy * SIN2 + event.value.dx * COS2);//e.value.dx;
				shape_hit.x += (event.value.dy * SIN2 + event.value.dx * COS2);//e.value.dx;
			//}
			//if ((y_ > 0) && (y_ < Height))
			//{
				mShape.y += (event.value.dy * COS2 - event.value.dx * SIN2);//e.value.dy;
				mShapeOutline.y += (event.value.dy * COS2 - event.value.dx * SIN2);//e.value.dy;
				shape_hit.y += (event.value.dy * COS2 - event.value.dx * SIN2);//e.value.dy;
			//}
		}
		private function scaleHandler(e:GWGestureEvent):void 
		{
			//trace("mask scale");
			mShape.scaleX += e.value.dsx;
			mShape.scaleY += e.value.dsy;
			
			mShapeOutline.scaleX += e.value.dsx;
			mShapeOutline.scaleY += e.value.dsy;
			
			shape_hit.scaleX += e.value.dsx;
			shape_hit.scaleY += e.value.dsy;
		}
		private function rotateHandler(e:GWGestureEvent):void 
		{
			//trace("mask rotation");
			mShape.rotation += e.value.dtheta;
			mShapeOutline.rotation += e.value.dtheta;
			shape_hit.rotation += e.value.dtheta;
		}
	}
}