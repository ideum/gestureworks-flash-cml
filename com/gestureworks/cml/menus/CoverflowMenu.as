﻿package com.gestureworks.cml.menus
{
	
	/*import flash.events.Event;
	import id.core.ApplicationGlobals;
	import id.core.TouchSprite;
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import flash.display.DisplayObject;
	import id.component.AvatarDisplay;
	import id.element.ImageParser;
	
	import id.component.AvatarDisplay;
	import id.element.ImageParser;
	
	import flash.display.*;
	import flash.geom.*;
	
	import id.utils.shapes.drawRecLF;
	import com.pixelfumes.Reflect;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;*/

	public class CoverflowMenu /*extends TouchSprite*/
	{
		/*private var n:int;
		private var X:Number;
		private var Y:Number;
		private var scale:Number;
		private var angle:Number;
		
		private var dx:Number = 0;
		//private var dy:Number;
		private var dtheta:Number = 0.005; 
		private var k:Number = 180/Math.PI
		private var p:Number = 1;
		private var q:Number = 2;
		
		private var centerX: Number = 500;
		private var centerY:Number = 400;
		private var speed:Number= 0;
		private var distX:Number;
		private var marginX:Number = 0;
		private var box:Number = 100;
		private var sepx:Number = 10;
		private var Width: Number = 1000;
		private var Height:Number = 300;
			
		private var displayList:Array;
		private var objectList:Array;
		private var menuObj:TouchSprite;
		private var menu:TouchSprite;
		
		private var dist:Number;
		private var perspective:Number = 80;
		private var drag_const;
		
		private var reflection:Boolean = true;
		private var outline:Boolean = false;
		private var tweenMenu:Boolean = true;
		private var avWrapperCalled:Boolean = false;
		private var angVelMin = 0.000002;
		
		public static var COMPLETE:String = "complete";*/
		
		public function CoverflowMenu()
		{
			super();
			/*ImageParser.settingsPath="ImageViewer.xml";
			ImageParser.addEventListener(Event.COMPLETE,onParseComplete);*/
		}
		
		/*private function onParseComplete(event:Event):void
		{
			n = ImageParser.amountToShow
			centerX = Width/2;
			centerY = Height/2;
			distX = (Width-2*marginX)/n
			dtheta = (180/n)
			displayList = new Array();
			objectList = new Array();
			init();
		}
		
		//----------------------------------------------------------//
			
		private function init(){ 
				
				drag_const = 0.85*n*Width
				x = -Width/2;
				y = -Height/2;
				
				var bground = new Sprite();
					bground.graphics.beginFill(0x000000,0);
					bground.graphics.lineStyle(3,0xFFFFFF,1);
					bground.graphics.drawRect(0,0,Width,Height);
					bground.graphics.endFill()
				addChild(bground);
		
				menu = new TouchSprite();
				addChild(menu);
		
			for (var i=0; i<n; i++)
			{
				var menuObj = new TouchSprite();
						menuObj.name="menu object";
					menu.addChild(menuObj);
					
					displayList[i] = menuObj;
					objectList[i] = menuObj;

					var avatarObj = new AvatarDisplay();
						avatarObj.id=i;
						avatarObj.moduleName="AvatarMenu";
						avatarObj.name="Avatarohh";
						avatarObj.addEventListener( AvatarDisplay.COMPLETE, avWrapper);
					menuObj.addChild(avatarObj);
				
			}
			var capture = new TouchSprite();
				capture.graphics.beginFill(0xFFFFFF,0);
				capture.graphics.drawRect(0,0,Width,Height);
				capture.graphics.endFill()
				capture.blobContainerEnabled=true;
				capture.addEventListener(GestureEvent.GESTURE_DRAG, moveMenu);
				capture.addEventListener(GestureEvent.RELEASE, gestureRelease);
			addChild(capture);
	}
	
	private function avWrapper(e:Event):void
		{
			avWrapperCalled = true;
			//trace("av wrapper called");
					var obj = e.target
		 			var avWidth = obj.width//150;
					var avHeight = obj.height;
					
					dist = 30
					
					if (outline)
					{
						//trace("outline")
						var outline = new Sprite();
							outline.graphics.lineStyle(3,0xFFFFFF,1);
							outline.graphics.drawRect(-avWidth/2,-avHeight/2,avWidth,avHeight);
						obj.parent.addChild(outline);
					}
					
					if (reflection)
					{
						//trace("reflection")
						var avatarRef = new Sprite;
							avatarRef.addChild(obj.avBitmap)
							avatarRef.y = avHeight+dist;
							avatarRef.scaleY = -1;
							avatarRef.name = "avRef";
						obj.parent.addChild(avatarRef);
						
						var avMask = new drawRecLF(avWidth, avHeight, 0, 0xFFFFFF, 0, 0xFFFFFF, 0x000000,1,0, Math.PI/2,100,-40);
							avMask.y = avHeight + dist;
						obj.parent.addChild(avMask);
						
						avMask.cacheAsBitmap = true;
						avatarRef.cacheAsBitmap = true;
						avatarRef.mask = avMask;
					}
		}
	
		function sortBySize():void {
			displayList.sortOn("scaleX", Array.DESCENDING | Array.NUMERIC);
			displayList.reverse();
			for(var i:uint = 0; i < displayList.length; i++) {
				var obj = displayList[i];
				menu.setChildIndex(obj, i);
			}
		}
	
		public function updateMenu()
		{
			trace("updating menu in caraselle",speed)
			layoutCoverFlow()
		}
		
		public function moveMenu(e:GestureEvent)
		{
			trace("moving menu in caraselle",speed)
			speed = -e.dx/drag_const;
			layoutCoverFlow()
		}
		
		private  function gestureRelease(e:GestureEvent)
		{
			trace("release");
			if(tweenMenu){
				addEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		private function enterFrame(e:Event):void
		{
			if(Math.abs(speed)>angVelMin){
				trace("animation",speed)
				speed *= 0.92;
				updateMenu()
			}
			else if (Math.abs(speed)<angVelMin){
				trace("stopped");
				speed = 0;
				removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		private function initCoverFlow()
		{
				layoutCoverFlow();
				dispatchEvent(new Event(coverflowMenu.COMPLETE));
		}
		//------------------------------------------------------------//
		public function layoutCoverFlow(){
				
				for (var j=0; j<n; j++)
				{
					X = marginX +  j*distX + dx;
					Y = centerY;
					angle = j*(2*Math.PI/n) + dtheta					
					scale = p*Math.abs(1-q*Math.abs(centerX-X)/Width);
					dtheta += speed*10;
					dx += -speed*360;
					
					if (scale<1){
						//scale =0;
					}
					if((X>Width)||(X<0)){
						//objectList[j].visible = false;
					}
					
					objectList[j].x = X;
					objectList[j].y = Y;
					objectList[j].scaleX = scale;
					objectList[j].scaleY = scale;
					//objectList[j].rotationY = angle;
					
					if(avWrapperCalled){
						objectList[j].getChildAt(1).alpha = 0.85*Math.pow(scale,4);
					}
				}
				sortBySize()
			}
		//------------------------------------------------------------//*/
	}
}