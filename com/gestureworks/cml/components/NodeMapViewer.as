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
	import com.gestureworks.cml.kits.ComponentKit;	
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	
	import com.gestureworks.core.GestureWorks;
	 
	public class NodeMapViewer extends ComponentKit
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
				 
	
		public function NodeMapViewer()
		{
			super();
			//visible=false;
		}

		override public function dispose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			trace("node viewer complete");
			childListParse();
			
			trace("update");
			//initUI();
			//setupUI();
		}
		/*
		private function childListParse():void
		{ 
				//trace(this.childList.length);
				
				for (var i:int = 0; i <= this.childList.length; i++)
					{
						//trace(this.childList[i])
						if (childList[i] is TouchContainer)//&&(childList[i].id=="item"))
						{
							trace("childList",this.childList[i].id)
							//trace(childList[i].x, childList[i].y,childList[i].getChildAt(0).width,childList[i],childList[i].getChildAt(0));
							itemList.push(childList[i])
						}
					}
					n = itemList.length;
				
				//childList[0].getChildAt(0).addEventListener(Event.COMPLETE, updateDisplay);
		}*/
		
		private function childListParse():void
		{ 
			trace(this.childList.length);
				for (var i:int=0; i<this.childList.length; i++)
					{
						trace(this.childList.getIndex(i),this.childList.getIndex(i).id)
						if ((childList.getIndex(i) is TouchContainer))

						{
						trace("touch container", this.childList[i].id)
						itemList.push(childList.getIndex(i))
						}
					}
				n = itemList.length;
		}
		
		
		private function initUI():void
		{
			//Width = childList[0].width;
			//Height = childList[0].height;
			
			for (var j:int = 0; j < itemList.length; j++)
					{
			for (var i:int = 0; i < itemList[j].childList.length; i++)
					{
					
				if(itemList[j].getChildAt(i))	trace("node children", i, itemList[j].getChildAt(i).id, itemList[j].getChildAt(i));
				if (itemList[j].getChildAt(i).id == "0.album1") trace("album children", itemList[j].getChildAt(i).itemList.length); // not loaded yet
					}
				}
			
			//itemList[0].transformEvents = true;
			//itemList[0].addEventListener(GWTransformEvent.T_TRANSLATE, dragHandler);
			
			//itemList[0].getChildAt(5).getChildAt(0).transformEvents = true;
			//itemList[0].getChildAt(5).getChildAt(0).addEventListener(GWTransformEvent.T_TRANSLATE, dragHandler);
	
		}
		private function setupUI():void
		{ 	
			
			
		}
		
		private function dTapHandler(event:GWGestureEvent):void
		{
			trace("d tap", count);
		}
		
		private function dragHandler(event:GWTransformEvent):void 
		{
			trace("album translate",itemList[0].getChildAt(5).x,itemList[0].getChildAt(5).y);
			//event.target.getChildAt(2).width = 500;
			//event.target.getChildAt(2).Height = 10;
			
			itemList[0].getChildAt(2).width = itemList[0].getChildAt(5).x;
			itemList[0].getChildAt(2).height = itemList[0].getChildAt(5).y;
			
			//trace("album children", itemList[0].getChildAt(5).itemList.length)
			//trace("album children", itemList[0].getChildAt(5).childList.length)
		}
	}
}