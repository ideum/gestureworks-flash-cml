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
	
	public class AlbumViewerNew extends ComponentKit//TouchContainer
	{		
		// component
		private var visDebug:Boolean =false;
		private var Width:Number;
		private var Height:Number;
		private var centerX:Number;
		private var centerY:Number;
		private var buffer_tween:Boolean = true;
		private var loopMode:Boolean = false;
		
		private var frame:TouchSprite;
		public var album:TouchSprite = new TouchSprite();
		private var metadata:Sprite;
		
		// bar
		private var bar_height:Number;
		private var bar:TouchSprite;
		private var ibtn:TouchSprite;
		private var cbtn:TouchSprite;
		
		private var btn_rad:int = 15;
		private var btn_pad:int = 10;
		
		// belt
		private var belt:TouchSprite;
		private var belt_width:Number;
		private var belt_height:Number;
		private var i:int
		public var itemList:Array = new Array;
		private var masterItemList:Array = new Array;
		private var belt_marginX:Number;
		private var belt_marginY:Number;
		private var belt_maxValue:Number;
		private var belt_minValue:Number;
		private var belt_buffer:int;
		// belt tween
		private var belt_buffer_tweenOn:Boolean = false;
		private var belt_target_tweenOn:Boolean = false;
		private var belt_tween_target:Number
		private var belt_minDelta:Number = 0.5;
		private var belt_tween_factor:Number = 1;
		private var belt_gcomplete:Boolean =false;
		private var belt_speed:Number = 0.4;
		
		// slider
		private var slider_factor:Number;

		private var n:int;
		private var sepx:Number;
		private var box:Number ;
		private var distX:Number;
		
		//repeat blocks
		private var rn:int // repeat number
		private var centralBlockwidth:Number;
		private var repeatBlockwidth:Number;
		
		// meta data
		private var album_description:TextElement
		private var text_pad:Number;
		private var scroll_bar_pad:Number;
		private var scroll_bar_width:Number;
		private var scroll_bar_height:Number;
		
		private var itemListObject:Object = new Object;
		
		private var mShape:GraphicElement
		
		public static var ALBUM_UPDATE:String = "album update";
		
		public function AlbumViewerNew()
		{
			super();	
			//createUI();
			//commitUI();
			if (buffer_tween) GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, onEnterFrame);
		}
		
		public function dipose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			trace("album display viewer complete");
			//childrenParse();
			childListParse();
			childListParse2();
			initUI();
			setupUI();			
		}
		
		private function childListParse():void
		{ 
				trace("album, items",this.childList.length);
				
				for (i=0; i<=this.childList.length; i++)
					{

						//trace(this.childList[i])
						//if (childList[i] is TouchContainer)

						trace(this.childList.getIndex(i))
						if ((childList.getIndex(i) is TouchContainer))

						{
						//trace(this.childList[i].id)
						//itemList.push(childList[i]);
					
						//trace(childList.getIndex(i).x, childList.getIndex(i).y,childList.getIndex(i).width,childList.getIndex(i).getChildAt(0).width);
						itemList.push(childList.getIndex(i))
						}
					}
					n = itemList.length;

			//if(childList[0])childList[0].getChildAt(0).addEventListener(Event.COMPLETE, updateDisplay);				
			//childList[0].getChildAt(0).addEventListener(Event.COMPLETE, updateDisplay);
		}
		
		
		private function childListParse2():void
		{
			for (var j:int = 0; j < this.childList.length; j++)
					{	
						//trace("inside 1---------------- ", this.childList.getIndex(j), this.childList.getIndex(j).id)
						itemListObject[this.childList.getIndex(j).id] = this.childList.getIndex(j);
					
						for (var i:int = 0; i < this.childList.getIndex(j).childList.length; i++)
						{
						//trace("inside 2-----------------------------------",this.childList.getIndex(j).childList.getIndex(i), this.childList.getIndex(j).childList.getIndex(i).id);
						itemListObject[this.childList.getIndex(j).childList.getIndex(i).id] = this.childList.getIndex(j).childList.getIndex(i)
						
						if ( this.childList.getIndex(j).childList.getIndex(i) is TouchContainer) {
								for (var k:int = 0; k < this.childList.getIndex(j).childList.getIndex(i).childList.length; k++)
								{
									//trace("inside 3--------------------------------------------------", this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k),this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k).id);
									itemListObject[this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k).id] = this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k);	
								}
						}
					}
				}
				
			//trace("---------------------------------------------------", this.childList.getKey("a1").childList);
			//trace("---------------------------------------------------", this.childList.getKey("a1").childList.getKey("c1"));
			//trace("---------------------------------------------------",this.childList.getKey("a1").getKey("c1"));
			trace("-------------------\\", this.childList.getKey("holder1").childList.getKey("metadata1"));//.getChildAt(0).id
			trace("-------------------\\", this.childList.getKey("al"))
			trace("-------------------\\", this.childList.getKey("holder1").class_)
			
			//trace("-------------------\\", this.childList.getCSSClass("holder"))
			
			//var s:String;
			//for (s in itemListObject) trace("chilist objects",itemListObject[s].id);
				
		}
		
		private function initUI():void
		{

			mouseChildren = true;
			
			trace("initUI album");
			//Width = 400//childList[0].width;
			//Height = 220//childList[0].height;
			//x = 0
			//y = 0;
			//targeting = false;
			
			
			//Width = 400//GestureWorks.application.stageWidth;//width//
			Height += 50//GestureWorks.application.stageHeight;//height//
			centerX = Width*0.5;
			centerY = Height*0.5;
			box = 455//Width; //400// max 385
			sepx = 10;
			belt_marginY = 0;
			belt_marginX = 0;
			belt_height = Height;//502-78-35;
			centralBlockwidth = 2 * belt_marginX + n * box + (n - 1) * sepx;
			
			bar_height = 50;
			
			if (!loopMode) {
				belt_width = 2*belt_marginX + n*box + (n-1)*sepx;
				belt_maxValue = belt_width - Width;
				belt_minValue = 0;
				belt_buffer = 200;
			}
			else {
				belt_width = 2*belt_marginX + n*box + (n-1)*sepx + 2*repeatBlockwidth;
				belt_maxValue = centralBlockwidth;
				belt_minValue = repeatBlockwidth;
				belt_buffer = 0;
			}
			
			slider_factor = (centralBlockwidth - Width) / Width;
			
			text_pad = 20;
			scroll_bar_pad = 30;
			scroll_bar_width = 10;
			scroll_bar_height = 60;
		}
		
		
		private function setupUI():void
		{ 
			trace("setupUI album");
			
			// assign album holder////////////////////////////////////////////////////////////////////
			album = this.childList.getKey("holder1");
				album.targeting = true;
				album.gestureEvents = true;
				album.nestedTransform = true;
				album.disableNativeTransform = false;
				album.disableAffineTransform = false;
				album.mouseChildren = true;
				album.gestureList = { "n-drag":true };
				album.x = 0;
				album.y = 0;
				album.name = "album";
				album.transformEvents = true;
				album.width = Width;
				album.addEventListener(GWTransformEvent.T_TRANSLATE, translateHandler);
			addChild(album);
			
			// assign bar ////////////////////////////////////////////////////////////////////////////
			bar = this.childList.getKey("holder1").childList.getKey("menu1");
				//bar.targetParent = true;
			album.addChild(bar);
			
			// assign close button behaviors ///////////////////////////////////////////////////////////////////
			cbtn = this.childList.getKey("holder1").childList.getKey("menu1").childList.getKey("cbtn1");
				//cbtn.gestureEvents = true;
				//cbtn.mouseChildren = false;
				cbtn.gestureList = { "tap":true, "n-drag":true };
				cbtn.addEventListener(GWGestureEvent.TAP, onClose);
			album.addChild(cbtn);
			
			// assign info button behaviors
			ibtn = this.childList.getKey("holder1").childList.getKey("menu1").childList.getKey("ibtn1");
				//ibtn.gestureEvents = true;
				//ibtn.mouseChildren = false;
				ibtn.gestureList = { "tap":true, "n-drag":true };
				ibtn.addEventListener(GWGestureEvent.TAP, onInfo);
			album.addChild(ibtn);
			
			// assign belt///////////////////////////////////////////////////////////////////////////
			//belt = itemListObject["belt1"];
			belt = this.childList.getKey("holder1").childList.getKey("belt1");
				//belt.name = "belt";
				//belt.x = 0;
				//belt.y = belt_marginY + bar_height;//top_bar.height;
				//belt.nestedTransform = true;
				//belt.mouseChildren = true;
				//belt.gestureEvents = true;
				//belt.disableNativeTransform = true;
				//belt.disableAffineTransform = true;
				belt.gestureList = { "tap":true,"double_tap":true,"1-dragx":true, "2-dragx":true, "3-dragx":true };
				belt.addEventListener(GWGestureEvent.DRAG, checkBeltPosition);
				belt.addEventListener(GWGestureEvent.DOUBLE_TAP, gtapMenuItem);
				
				if(!loopMode)	belt.addEventListener(TouchEvent.TOUCH_BEGIN, cancelTween);
				if(!loopMode)	belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
				if (!loopMode)	belt.addEventListener(GWGestureEvent.COMPLETE, onComplete);
				
				belt.getChildAt(0).width = 1800;
			album.addChild(belt);
			
			//assign mask shape////////////////////////////////////////////////////////////////////////
			//mShape = itemListObject["mask_shape"];
			mShape = this.childList.getKey("holder1").childList.getKey("mask_shape1");
			album.addChild(mShape);
			//apply mask//
			//belt.mask = mShape;
	}
	
	public function onScroll(event:GWGestureEvent):void
	{
		//trace("scroll",album_description.maxScrollH,10*event.value.dx);
		album_description.scrollV += 0.2*event.value.dx;
	}
	
	public function onClose(event:GWGestureEvent):void
	{
		trace("close");
		//dispose();
		
		//reset album //faux dispose
		//album.visible = false;
		//reset position
		album.x = 0;
		album.y = 0;
		
		x = 0;
		y = 0;
		
		// reset meta data 
		metadata.visible = false; // reset meta data
		// reset scroll text
		
		// reset belt
		belt.x = 0;
	}
	public function onInfo(event:GWGestureEvent):void
	{
		trace("info");
		if (!metadata.visible) metadata.visible = true;
		else metadata.visible = false;
	}
	
	
	public function onComplete(event:GWGestureEvent):void
	{
		//trace("complete");
		belt_gcomplete = true;
		checkTween();
	}
	
	public function onRelease(event:GWGestureEvent):void
	{
		//trace("release");
		checkTween();
	}
	
	public function checkTween():void
	{
		var abs_beltx:Number = Math.abs(belt.x)
		//trace("check tween");
		
		if ((belt.x > 0) && (abs_beltx > belt_minValue))
		{
			trace("tween left to:",belt.$x, belt_minValue);
			belt_buffer_tweenOn = true;
			belt_tween_factor = -1;
			belt_speed = 0.4;
			belt_tween_target = belt_minValue;
		}
		else if ((belt.x <= 0 )&&(abs_beltx > belt_maxValue))
		{
			trace("tween right to:",belt.$x, belt_maxValue);
			belt_buffer_tweenOn = true;
			belt_tween_factor = 1;
			belt_speed = 0.4;
			belt_tween_target = -belt_maxValue;
		}
		else belt_buffer_tweenOn = false;
	}
	
	public function checkBeltPosition(event:GWGestureEvent):void
	{
		var abs_beltx:Number = Math.abs(belt.x);
		belt.x += event.value.dx;
		
		//trace("belt_pos",belt.x)
		
			//////////////////////////////////////////////////////////////////////////////
			// buffer mode
			//////////////////////////////////////////////////////////////////////////////
			if (!loopMode) {
			
				if (buffer_tween) {
					
				
					if(event.value.n!=0){
						
						if (belt.x > 0) // positive
						{
							if (abs_beltx > (belt_minValue+belt_buffer))
							{
								//trace(" left limit hard, zero motion towards left",belt.$x);
								belt.x = belt_minValue + belt_buffer;
							}
							else if (abs_beltx > belt_minValue){
								var lbuff_perc:Number = ((belt_minValue+belt_buffer)-abs_beltx)/belt_buffer
								//trace(" left limit soft, take over gesture control",belt.$x, event.value.n);
								belt.x += lbuff_perc * event.value.dx;
							}
						}
						else if (belt.x <= 0 ) //negative
						{	
							if (abs_beltx > belt_maxValue+belt_buffer){
									//trace("right limit hard, zero motion towards right",belt.$x);
									belt.x = -(belt_maxValue+belt_buffer);
							}
							else if (abs_beltx > belt_maxValue) {
								var rbuff_perc:Number = ((belt_maxValue+belt_buffer)-abs_beltx)/belt_buffer
								//trace("right limit soft, take over gesture control",belt.$x,event.value.n);
								belt.x += rbuff_perc * event.value.dx;
							}
						}
					}
				
					else if ((event.value.n == 0) && (!belt_buffer_tweenOn)) 
					{
						// when gesture tween check to see if break buffer
						checkTween();
					}
				}
				//limit check when not buffer anim or loop
				else {
					// when gesture tween check to see if break buffer
					checkTween();
					}
		}
		
		//////////////////////////////////////////////////////////////////////////////
		// loop belt content
		//////////////////////////////////////////////////////////////////////////////
		
		else {
			if ((belt.x > 0) && (abs_beltx >= belt_minValue)) {
						//trace("loopmmin", belt.$x);
						belt.x = -(centralBlockwidth-repeatBlockwidth);
					}
				
			else if ((belt.x < 0 )&&(abs_beltx >= belt_maxValue)){
						//trace("loopmax",belt.$x);
						belt.x = 0;
			}	
		}
		///////////////////////////////////////////////////////////////////////////
			
	}
	
	public function onEnterFrame(event:GWEvent):void
	{
		
		//trace(belt_buffer_tweenOn,belt_target_tweenOn)
		
		if (belt_buffer_tweenOn) {
				
			var buffer_dist:Number = Math.abs(belt.x) - Math.abs(belt_tween_target);

				if (Math.abs(buffer_dist) <= belt_minDelta)
				{
				//trace("buffer ease complete",buffer_dist,belt.x, belt_tween_target,belt_minDelta)
				belt_buffer_tweenOn = false;
				belt.x = belt_tween_target;
				}
			else {
				//trace("easing to buffer target x", buffer_dist, belt_tween_factor, belt.x, belt_tween_target,belt_minDelta);
				belt_buffer_tweenOn = true;
				belt.x += buffer_dist * belt_tween_factor * belt_speed;
				}
		}
		else if (belt_target_tweenOn) {
			var target_dist:Number = Math.abs(belt.x) - Math.abs(belt_tween_target);
			
			if (Math.abs(target_dist) <= belt_minDelta)
				{
				//trace("ease complete",belt.x,target_dist,belt_tween_target,belt_minDelta)
				belt_target_tweenOn = false;
				belt.x = belt_tween_target;
				}
			else {
				//trace("easing to target x", belt.x,target_dist, belt_tween_factor,belt_tween_target,belt_minDelta);
				belt_target_tweenOn = true;
				belt.x += target_dist * belt_tween_factor * belt_speed;
				}
		}
		
	}
	
	public function cancelTween(event:TouchEvent):void
	{
		//trace("tween cancel");
		belt_buffer_tweenOn = false;
		belt_target_tweenOn = false;
		belt_gcomplete = false;
	}
	
	public function tweenToTarget(event:TouchEvent):void
	{
			//trace("target");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = -event.stageX * slider_factor//+belt_buffer;
			belt_tween_factor = 1;
	}
	
	public function tweenToClickTarget(event:MouseEvent):void
	{
			//trace("target");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = -event.stageX * slider_factor//+belt_buffer;
			belt_tween_factor = 1;
	}
	
	public function tapMenuItem(event:TouchEvent):void{
		//trace("tap menu item", event.target.id);
		
		if (itemList[event.target.id - 1].getChildAt(1).visible)
		{
			itemList[event.target.id - 1].getChildAt(1).visible = false;
			itemList[event.target.id - 1].getChildAt(2).visible = true;
		}
		else {
			itemList[event.target.id - 1].getChildAt(1).visible = true;
			itemList[event.target.id - 1].getChildAt(2).visible = false;
		}
	}
	public function clickMenuItem(event:MouseEvent):void{
		trace("click menu item", event.target.id)
	}
	public function gtapMenuItem(event:GWGestureEvent):void{
		//trace("gtap menu item"event.target.id)
		trace("gtap menu item"); 
		/*
		if (itemList[event.target.id - 1].getChildAt(1).visible)
		{
			itemList[event.target.id - 1].getChildAt(1).visible = false;
			itemList[event.target.id - 1].getChildAt(2).visible = true;
		}
		else {
			itemList[event.target.id - 1].getChildAt(1).visible = true;
			itemList[event.target.id - 1].getChildAt(2).visible = false;
		}
		*/
	}
	public function gdtapMenuItem(event:GWGestureEvent):void{
		//trace("gdtap menu item", event.target.id)
		trace("gdtap menu item");
		/*
		if (itemList[event.target.id - 1].getChildAt(1).visible)
		{
			itemList[event.target.id - 1].getChildAt(1).visible = false;
			itemList[event.target.id - 1].getChildAt(2).visible = true;
		}
		else {
			itemList[event.target.id - 1].getChildAt(1).visible = true;
			itemList[event.target.id - 1].getChildAt(2).visible = false;
		}
		*/
	}
		
		//override protected function createUI():void{}
		//override protected function commitUI():void{}
		//override protected function layoutUI():void{}
		
		public function translateHandler(event:GWTransformEvent):void
		{
			trace("translate album");
			this.dispatchEvent(new DisplayEvent(DisplayEvent.CHANGE));
		}
		
		private function updateHandler(event:Event):void 
		{
		trace("album update");	
		}

	}
}