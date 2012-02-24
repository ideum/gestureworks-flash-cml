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
		// objects
		public var album:TouchSprite = new TouchSprite();
		private var bar:TouchSprite;
		private var ibtn:TouchSprite;
		private var cbtn:TouchSprite;
		private var belt:TouchSprite;
		private var mShape:GraphicElement
		private var metadata:TouchSprite;
		//private var frame:TouchSprite;
		//private var itemListObject:Object = new Object;
		
		// component
		private var i:int
		private var visDebug:Boolean =false;
		private var buffer_tween:Boolean = true;
		private var loopMode:Boolean = false;
		
		// belt
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
		
		//repeat blocks
		//private var rn:int // repeat number
		//private var centralBlockwidth:Number;
		//private var repeatBlockwidth:Number;
		
		// meta data
		private var album_description:TextElement
		//private var text_pad:Number;
		//private var scroll_bar_pad:Number;
		//private var scroll_bar_width:Number;
		//private var scroll_bar_height:Number;
		
		public static var ALBUM_UPDATE:String = "album update";
		
		public function AlbumViewerNew()
		{
			super();	
			if (buffer_tween) GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, onEnterFrame);
		}
		
		public function dipose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			trace("album display viewer complete");
			childListParse();
			initUI();	
			setupUI();	
		}
	
		
		private function childListParse():void
		{
			trace("-------", this.childList.getCSSClass("holder", 0).id);
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("menu", 0).id);
			trace("-------", this.childList.getCSSClass("holder",0).childList.getCSSClass("belt",0).id);
			trace("-------", this.childList.getCSSClass("holder",0).childList.getCSSClass("menu",0).childList.getCSSClass("cbtn",0).id);
			trace("-------", this.childList.getCSSClass("holder",0).childList.getCSSClass("menu",0).childList.getCSSClass("ibtn",0).id);
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("mask_shape", 0).id);
			trace("-------", this.childList.getCSSClass("holder", 0).childList.getCSSClass("metadata", 0).id);
		}
		
		private function initUI():void
		{
			trace("initUI album");
			
			mouseChildren = true;
			belt_buffer = 200;
			//slider_factor = (centralBlockwidth - width) / width;
			//text_pad = 20;
			//scroll_bar_pad = 30;
			//scroll_bar_width = 10;
			//scroll_bar_height = 60;
		}
		
		
		private function setupUI():void
		{ 
			trace("setupUI album");
			
			//////////////////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////////////////
			
				album = this.childList.getCSSClass("holder", 0);
					album.gestureList = { "n-drag":true };
					album.transformEvents = true;
					album.addEventListener(GWTransformEvent.T_TRANSLATE, translateHandler);
				addChild(album);
			 
				bar = this.childList.getCSSClass("holder", 0).childList.getCSSClass("menu", 0);
				//bar = album.childList.getCSSClass("menu", 0);
					//bar.targetParent = true;
				album.addChild(bar);
						
				cbtn = this.childList.getCSSClass("holder", 0).childList.getCSSClass("menu", 0).childList.getCSSClass("cbtn",0);
				//cbtn = bar.childList.getCSSClass("cbtn",0);
					cbtn.gestureList = { "tap":true, "n-drag":true };
					//cbtn.addEventListener(GWGestureEvent.TAP, onClose);
					cbtn.addEventListener(GWGestureEvent.DRAG, onClose);
					//cbtn.addEventListener(TouchEvent.TOUCH_BEGIN, onClose);
				album.addChild(cbtn);
							
				ibtn = this.childList.getCSSClass("holder", 0).childList.getCSSClass("menu", 0).childList.getCSSClass("ibtn",0);
				//ibtn = bar.childList.getCSSClass("ibtn",0);
					ibtn.gestureList = { "tap":true, "n-drag":true };
					//ibtn.addEventListener(GWGestureEvent.TAP, onInfo);
					ibtn.addEventListener(GWGestureEvent.DRAG, onInfo);
					//ibtn.addEventListener(TouchEvent.TOUCH_BEGIN, onInfo);
				album.addChild(ibtn);
								
				belt = this.childList.getCSSClass("holder", 0).childList.getCSSClass("belt", 0);
				//belt = album.childList.getCSSClass("belt", 0);
					belt.gestureList = {"1-dragx":true, "2-dragx":true, "3-dragx":true };
					belt.addEventListener(GWGestureEvent.DRAG, checkBeltPosition);
					//belt.addEventListener(GWGestureEvent.DOUBLE_TAP, gtapMenuItem);
					if(!loopMode)	belt.addEventListener(TouchEvent.TOUCH_BEGIN, cancelTween);
					if(!loopMode)	belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
					if (!loopMode)	belt.addEventListener(GWGestureEvent.COMPLETE, onComplete);
				album.addChild(belt);
			 
				//apply mask//
				mShape = this.childList.getCSSClass("holder", 0).childList.getCSSClass("mask_shape", 0);
				//mShape = album.childList.getCSSClass("mask_shape", 0);
				album.addChild(mShape);
				belt.mask = mShape;
				
				// meta data text display
				metadata = this.childList.getCSSClass("holder", 0).childList.getCSSClass("metadata", 0);
				album.addChild(metadata);
			/////////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////////
			
			// set anim params
			belt_maxValue = belt.width - width;
			belt_minValue = 0;
			
			//trace("belt........",belt.width,belt_maxValue, width);
			
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
		trace("info",metadata.visible);
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
		/*
		else {
			if ((belt.x > 0) && (abs_beltx >= belt_minValue)) {
						//trace("loopmmin", belt.$x);
						belt.x = -(centralBlockwidth-repeatBlockwidth);
					}
				
			else if ((belt.x < 0 )&&(abs_beltx >= belt_maxValue)){
						//trace("loopmax",belt.$x);
						belt.x = 0;
			}	
		}*/
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
		
	public function translateHandler(event:GWTransformEvent):void
	{
		//trace("translate album");
		this.dispatchEvent(new DisplayEvent(DisplayEvent.CHANGE));
	}
		
	private function updateHandler(event:Event):void 
	{
	trace("album update");	
	}

	}
}