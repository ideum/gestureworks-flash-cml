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
	import flash.events.Event;
	
	import adobe.utils.CustomActions;
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	//import flash.text.*;
	import flash.utils.*;
	
	import flash.events.Event;
	
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.element.Container;	
	import com.gestureworks.cml.kits.ComponentKit;	
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	//import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	
	import com.gestureworks.core.GestureWorks;

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
	 
	public class MaskImageViewer extends ComponentKit
	{
		private var itemList:Array = new Array;

		// ----- interactive object settings --//
		private var stageWidth:Number;
		private var stageHeight:Number;
		
		private var imagesNormalize:Number;
		private var globalScale:Number;
		
		private var Width:Number = 0;
		private var Height:Number = 0;
		private var count:int = 0;
		private var n:int = 0;
		private var holder:TouchSprite;
		private var base_image:TouchSprite;
		private var mask_image:Sprite;
		
		
		//-- mask settings ---//
		private var maskSize:Number = 200;
		private var maskShape:String = "square";
		private var mShape:TouchSprite;
		private var shape_hit:TouchSprite;
		private var mapShape:Sprite;
		private var mShapeOutline:Sprite;
		
		//---------frame settings--//
		private var frame:TouchSprite;
		private var frameDraw:Boolean = true;
		private var frameMargin:Number = 100;
		private var frameRadius:Number = 20;
		private var frameFillColor:Number = 0xFFFFFF;
		private var frameFillAlpha:Number = 0.5;
		private var frameOutlineColor:Number = 0xFFFFFF;
		private var frameOutlineStroke:Number = 2;
		private var frameOutlineAlpha:Number = 1;
		//----maskimage gestures---//
		private var dragGesture:Boolean = true;
		private var scaleGesture:Boolean = true;
		private var rotateGesture:Boolean = true;
		//----frame gestures---//
		private var frameDragGesture:Boolean = true;
		private var frameScaleGesture:Boolean = true;
		private var frameRotateGesture:Boolean = true;
		
		//public static var COMPLETE:String = "complete";
				 
	
		public function MaskImageViewer()
		{
			super();
			//visible=false;
			
			//trace("__________________________________________________________mask viewer_____________________________________________________________");
			
		}

		override public function dispose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			childInfo();
			
			initUI();
			setupUI();
		}
		
		private function childInfo():void
		{ 
				trace(this.childList.length);
				
				for (var i:int = 0; i < this.childList.length; i++)
				{
					trace(childList.getIndex(i),childList.getIndex(i).id);
					//if ((childList.getIndex(i) is TouchContainer))
					//if ((childList.getIndex(i) is ImageElement))
					{
						trace(childList.getIndex(i).id);
						itemList.push(childList.getIndex(i));
					}
				}
				n = itemList.length;				
		}
		
		private function initUI():void
		{
			/*
			var xml:XML = ImageParser.settings;
			stageWidth=ApplicationGlobals.application.stage.stageWidth;
			stageHeight=ApplicationGlobals.application.stage.stageHeight;
			
			//-- Style
			globalScale=ImageParser.settings.GlobalSettings.globalScale;
			scale=ImageParser.settings.GlobalSettings.scale;
			imagesNormalize=ImageParser.settings.GlobalSettings.imagesNormalize;
			maxScale=ImageParser.settings.GlobalSettings.maxScale;
			minScale=ImageParser.settings.GlobalSettings.minScale;
			stageWidth=ApplicationGlobals.application.stage.stageWidth;
			stageHeight=ApplicationGlobals.application.stage.stageHeight;

			//-- mask Properties --//
			maskSize=ImageParser.settings.GlobalSettings.maskSize;
			maskShape=ImageParser.settings.GlobalSettings.maskShape;
			
			//--Frame Style--//
			frameDraw = xml.FrameStyle.frameDraw == "true"?true:false;
			frameMargin = xml.FrameStyle.padding;
			frameRadius = xml.FrameStyle.cornerRadius;
			frameFillColor = xml.FrameStyle.fillColor1;
			frameFillAlpha = xml.FrameStyle.fillAlpha;
			frameOutlineColor = xml.FrameStyle.outlineColor;
			frameOutlineStroke = xml.FrameStyle.outlineStroke;
			frameOutlineAlpha = xml.FrameStyle.outlineAlpha;
			
			//--Frame Gestures--//
			frameDragGesture=xml.FrameGestures.drag == "true" ?true:false;
			frameScaleGesture=xml.FrameGestures.scale == "true" ?true:false;
			frameRotateGesture=xml.FrameGestures.rotate == "true" ?true:false;
			*/
			
			//Width = base_image.width//401//499//image1.width;
			//Height = base_image.height//401//321//image1.height;
			
			//Width = itemList[0].width;
			//Height = itemList[0].height;
			
			//trace(itemList[0].width,itemList[0].width)
						
			if(frameDraw)
			{	
				//width=Width+frameMargin;
				//height=Height+frameMargin;
			}
			
		}
			
		private function setupUI():void
		{ 
			trace("setup");
			holder = new TouchSprite();
				holder.targeting = true;
				holder.gestureEvents = true;
				holder.nestedTransform = true;
				holder.disableNativeTransform = false;
				holder.disableAffineTransform = false;
				holder.mouseChildren = true;
				holder.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
			addChild(holder);
				
			//---------- build frame ------------------------//
			if(frameDraw)
			{							
				frame = new TouchSprite();
					
					var frame_thickness:Number = 50*0.5;
					var frame_color:Number = 0x999999;
					var frame_alpha:Number = 0.3;
					
					frame.targetParent = true;
					frame.graphics.lineStyle(2*frame_thickness, frame_color, frame_alpha);
					frame.graphics.drawRect( -frame_thickness, -frame_thickness, Width + 2 * frame_thickness, Height + 2 * frame_thickness);
					frame.graphics.lineStyle(2, frame_color,frame_alpha+0.5);
					frame.graphics.drawRoundRect( -2 * frame_thickness, -2 * frame_thickness, Width + 4 * frame_thickness, Height + 4 * frame_thickness, 2 * frame_thickness, 2 * frame_thickness);
					frame.graphics.lineStyle(4, frame_color,0.8);
					frame.graphics.drawRect(-2, -2, Width + 4, Height + 4);
					
				holder.addChild(frame);
			}
			else frameMargin=0;
			
			
			//-- bottom image --//
			base_image = itemList[0];
			base_image.targetParent = true;  // make base capture touch points
			holder.addChild(base_image);
			
			//-- top image --//
			mask_image = new Sprite();
			
			for (var i:int = 1; i <n; i++)
				{
				mask_image.addChild(itemList[i]);
				if(i!=1)itemList[i].visible = false;
				}
			
			holder.addChild(mask_image);
			
			//-- create mask shape --//
			mShape = new TouchSprite();
				mShape.graphics.beginFill(0xFFFFFF,1);
				mShape.graphics.drawRect(-maskSize/2,-maskSize/2,maskSize,maskSize);
				mShape.graphics.endFill();
				mShape.x = maskSize/2;
				mShape.y = maskSize / 2;
			holder.addChild(mShape);	
				
			shape_hit = new TouchSprite();
				shape_hit.graphics.beginFill(0xFFFFFF,0);
				shape_hit.graphics.drawRect( -maskSize / 2, -maskSize / 2, maskSize, maskSize);
				shape_hit.graphics.endFill();
				shape_hit.x = maskSize/2;
				shape_hit.y = maskSize / 2;
				shape_hit.mouseChildren = false;
				shape_hit.gestureEvents = true;
				shape_hit.disableNativeTransform = true;
				shape_hit.disableAffineTransform = true;
				shape_hit.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true, "double_tap":true };
				shape_hit.addEventListener(GWGestureEvent.DOUBLE_TAP, dTapHandler);
				shape_hit.addEventListener(GWGestureEvent.DRAG, dragHandler);
				shape_hit.addEventListener(GWGestureEvent.SCALE, scaleHandler);
				shape_hit.addEventListener(GWGestureEvent.ROTATE, rotateHandler);
			holder.addChild(shape_hit);
			
			//-- apply mask to images --//
			mask_image.mask = mShape;
			
			
			mShapeOutline = new Sprite();
				mShapeOutline.graphics.lineStyle(3,0xFFFFFF,1);
				//mShapeOutline.graphics.beginFill(0xFFFFFF,0);
				mShapeOutline.graphics.drawRect(-maskSize/2,-maskSize/2,maskSize,maskSize);
				//mShapeOutline.graphics.endFill();
				mShapeOutline.x = maskSize/2;
				mShapeOutline.y = maskSize / 2;
			holder.addChild(mShapeOutline);
			
			var wShape:Sprite = new Sprite();
				wShape.graphics.beginFill(0xFFFFFF, 1);
				wShape.graphics.drawRect(0,0,Width,Height);
				wShape.graphics.endFill();
			holder.addChild(wShape);
			
			mShapeOutline.mask = wShape;
			
		}
		
		private function dTapHandler(e:GWGestureEvent):void
		{
			trace("d tap", count);
			
			//  turn on required image
			for (var i:int = 0; i <n-1; i++)
				{
				//trace(this.childList[i])
				mask_image.getChildAt(i).visible = false
				if (i == count) mask_image.getChildAt(i).visible = true;
			}
			
			if (count >= n-2) count = 0;
			else count++;
		}
		
		// gesture event handlers to act on mask shape object
		private function dragHandler(e:GWGestureEvent):void 
		{
			var x_:Number = mShape.x + e.value.dx;
			var y_:Number = mShape.y + e.value.dy;
			
			if ((x_ > 0) && (x_ < Width))
			{
				mShape.x += e.value.dx;
				mShapeOutline.x += e.value.dx;
				shape_hit.x += e.value.dx;
			}
			if ((y_ > 0) && (y_ < Height))
			{
				mShape.y += e.value.dy;
				mShapeOutline.y += e.value.dy;
				shape_hit.y += e.value.dy;
			}
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