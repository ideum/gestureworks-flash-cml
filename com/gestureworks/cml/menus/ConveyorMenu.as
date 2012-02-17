package com.gestureworks.cml.menus
{
	
	/*import flash.events.Event;
	import id.core.ApplicationGlobals;
	import id.core.TouchSprite;
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	import flash.display.DisplayObject;
	import id.component.AvatarDisplay;
	import id.element.ImageParser;*/

	public class ConveyorMenu /*extends TouchSprite*/
	{
		/*private var n:int;
		private var X:Number;
		private var Y:Number;
		private var scale:Number;
		private var angle:Number;
		
		private var dx:Number;
		private var dy:Number;
		private var dtheta:Number = 0.005; 
		private var k:Number = 180/Math.PI
		private var p:Number = 1;
		private var q:Number = 2;
		
		private var centerX: Number;
		private var centerY:Number;
		private var speed:Number= 0;
		private var distX:Number;
		private var marginX:Number = 100;
		private var box:Number = 200;
		private var sepx:Number = 10;
		private var Width: Number = 1000;
		private var Height:Number = 300;
			
		private var displayList:Array;
		private var menuObj:TouchSprite;
		
		public static var COMPLETE:String = "complete";*/
		
		public function ConveyorMenu()
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
			
			init();
			addEventListener(GestureEvent.GESTURE_DRAG, updateMenu);
			//addEventListener(TouchEvent.TOUCH_MOVE, updateMenu);
		}
		
		//----------------------------------------------------------//
		
		function sortBySize():void {
			displayList.sortOn("scaleX", Array.DESCENDING | Array.NUMERIC);
			displayList.reverse();
			for(var i:uint = 0; i < displayList.length; i++) {
				var obj = displayList[i];
				setChildIndex(obj, i);
			}
		}
	
		//----------------------------------------------------------//
		
		public function updateMenu(e:GestureEvent){
			trace("updating menu in caraselle")
				speed = -e.dx/5000;
				updateCoverFlow()
		}
			
		private function init(){ 
		
			for (var i=0; i<n; i++)
			{
				menuObj = new TouchSprite();
				addChild(menuObj);
				displayList[i] = menuObj;
				
				
				var avatarObj = new AvatarDisplay();
					avatarObj.id=i;
					avatarObj.moduleName="AvatarMenu";
				menuObj.addChild(avatarObj);
				
				var avatarRef = avatarObj;
					avatarRef.y = avatarObj.height + dist;
					avatarRef.rotation = 180;
				menuObj.addChild(avatarRef);
			}
			initCoverFlow()
			
			graphics.beginFill(0xFFFFFF,0.2);
			graphics.drawRect(0,0,Width,Height);
			graphics.endFill()
			
			blobContainerEnabled=true;
	}
	
		private function initCoverFlow(){ 
				
				
				for (var i=0; i<n; i++)
				{
					X = marginX + i*box + (i-1)*sepx;
					Y = centerY;
					angle = i*(2*Math.PI/n)-90;		
					//scale = p*Math.abs(1-q*Math.abs(centerX-(marginX+i*distX))/(Width));
					trace(scale)
					
					displayList[i].x = X;
					displayList[i].y = Y;
					displayList[i].x += speed*10;
				}
				sortBySize()
			}
			
		//------------------------------------------------------------//
		public function updateCoverFlow(){ //e:GestureEvent
				
				for (var i=0; i<n; i++)
				{
					X = marginX + i*box;
					Y = centerY;
					//angle = i*(2*Math.PI/n) + dtheta					
					scale = p*Math.abs(1-Math.abs(centerX-(marginX+i*distX))/(Width));
					
					displayList[i].x = X;
					displayList[i].y = Y;
					displayList[i].x += speed*10;
				}
				//sortBySize()
			}*/
		//------------------------------------------------------------//
	}
}