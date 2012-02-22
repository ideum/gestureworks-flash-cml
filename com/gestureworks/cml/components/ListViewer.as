package com.gestureworks.cml.components
{
	
	import adobe.utils.CustomActions;
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.cml.element.ButtonElement;
	import com.gestureworks.cml.element.GraphicElement;
	import com.gestureworks.cml.element.FrameElement;
	import com.gestureworks.cml.element.TextElement;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	//import flash.text.*;
	import flash.utils.*;
	
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.element.GraphicElement;
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.cml.kits.ComponentKit;
	
	import com.gestureworks.core.GestureWorks;
	
	public class ListViewer extends ComponentKit//TouchContainer
	{		
		// component
		private var visDebug:Boolean =false;
		private var Width:Number;
		private var Height:Number;
		private var centerX:Number;
		private var centerY:Number;
		private var buffer_tween:Boolean = true;	
		public var album:TouchSprite = new TouchSprite();
		
		// belt
		private var belt:TouchSprite;
		private var belt_width:Number;
		private var belt_height:Number;
		private var i:int
		public var itemList:Array = new Array;
		private var masterItemList:Array = new Array;
		
		private var belt_marginY;
		private var belt_marginX;

		private var n:int;
		private var sepx:Number;
		private var box:Number ;
		private var distX:Number;
		
		//repeat blocks
		private var rn:int // repeat number
		private var centralBlockwidth:Number;
		private var repeatBlockwidth:Number;
		
		public function ListViewer()
		{
			super();
		}
		
		public function dipose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			trace("list display viewer complete");
			childListParse();
			initUI();
			setupUI();			
		}
		
		private function childListParse():void
		{ 
				//trace("album, items",this.childList.length);
				for (i=0; i<=this.childList.length; i++)
					{
						//trace(this.childList.getIndex(i))
						if ((childList.getIndex(i) is TouchContainer))
						{
						itemList.push(childList.getIndex(i))
						}
					}
				n = itemList.length;
				
				//this.childList.getKey("holder1")
				
				//var s:String;
				//for (s in childList.getKey) trace("chilist objects",childList.getKey[s].id);
		}
		
		
		private function initUI():void
		{
			//mouseChildren = true;
			centerX = Width*0.5;
			centerY = Height*0.5;
			box = 255//Width; //400// max 385
			sepx = 10;
			belt_marginY = 25;
			belt_marginX = 0;
		}
		
		private function setupUI():void
		{ 
			// create menu elements
				for (i=1; i<n+1; i++)
				{	
					//trace("menu item",i);
					// create item container
				var menuObj:TouchContainer = itemList[i - 1];
						menuObj.id = String(i);
						menuObj.name = "meni item";
						//menuObj.visible = true;
						menuObj.x = belt_marginX + (i-1)*box + (i-1)*sepx;
						menuObj.y = belt_marginY;
						menuObj.touchChildren = false;
						menuObj.mouseChildren = false;
						menuObj.targeting = true;
						menuObj.targetParent = true;
						menuObj.gestureEvents = true;
						menuObj.gestureList = { "tap":true, "double_tap":true };
					addChild(menuObj);
				}
	}
	
	private function updateHandler(event:Event):void 
	{
		trace("list update");	
	}

	}
}