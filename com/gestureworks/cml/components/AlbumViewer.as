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
	
	public class AlbumViewer extends ComponentKit//TouchContainer
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
		
		public static var ALBUM_UPDATE:String = "album update";
		
		public function AlbumViewer()
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
			preInit();
			initUI();
			setupUI();			
		}
		
		/*
		private function childrenParse():void
		{
			var key:String
			for (key in children){
				//trace("children", children[key].id);
				itemList.push(children[key]);
			}	
		}
		*/
		
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
			//Width = childList[0].width;
			//Height = childList[0].height;
			
			for (var j:int = 0; j < this.childList.length; j++)
					{	
						trace("inside 1---------------- ",this.childList.getIndex(j), this.childList.getIndex(j).id)
					
						for (var i:int = 0; i < this.childList.getIndex(j).childList.length; i++)
					{
						trace("inside 2-----------------------------------",this.childList.getIndex(j).childList.getIndex(i), this.childList.getIndex(j).childList.getIndex(i).id);
						
							if ( this.childList.getIndex(j).childList.getIndex(i) is TouchContainer) {
								
								//trace("length",this.childList.getIndex(j).childList.getIndex(i).childList.length)
								for (var k:int = 0; k < this.childList.getIndex(j).childList.getIndex(i).childList.length; k++)
								{
									trace("inside 3--------------------------------------------------", this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k),this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k).id);	
									var item = this.childList.getIndex(j).childList.getIndex(i).childList.getIndex(k);
									if (item is ComponentKit) {
										if (item.childList) {
											//trace(item.childList.length, item.childList.getIndex(0), item.childList.getIndex(0).id);
											//item.childList.getIndex(0).addEventListener(DisplayEvent.CHANGE, displayHandler);
										}
									}
								}
							}
					}
				}
		}
		
		
		
		private function preInit(): void {
			
			album = new TouchSprite();
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
		}
		
		
		private function initUI():void
		{

			trace("initUI album");

			//Width = childList.getIndex(0).width;
			//Height = childList.getIndex(0).height;

			
			Width = 400//childList[0].width;
			Height = 220//childList[0].height;
			
			//trace("display list:", rendererList)
			//x = 0
			//y = 0;
			//targeting = false;
			mouseChildren = true;
			
			//Width = 400//GestureWorks.application.stageWidth;//width//
			Height += 50//GestureWorks.application.stageHeight;//height//
			centerX = Width*0.5;
			centerY = Height*0.5;
			box = 255//Width; //400// max 385
			sepx = 10;
			belt_marginY = 25;
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
			
			/////////////////////////////
			//
			/////////////////////////////
			// create track list for objects based on item size and sep
			// can snap to track / nearest item
			// jump to next or previouos item
			// jump to specific item
			// flick to nearest 
			// calculate end point of flick tween
			/////////////////////////////
		
			
			//trace(background_top_bar_src, background_bottom_bar_src, background_item_tile_src);
		}
		
		
		private function setupUI():void
		{ 
			trace("setupUI album");
			
			/////////////////////////////////////////////////////////////////////////////////////
			// create album object
			/////////////////////////////////////////////////////////////////////////////////////
			
			/*
			//album = new TouchSprite();
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
			addChild(album);
			*/
			
			var bg:GraphicElement = new GraphicElement();
				bg.lineColor = 0x000000;
				bg.lineAlpha = 1;
				bg.color = 0x000000;
				bg.fillAlpha = 1;
				bg.shape="rectangle"
				bg.width = Width;
				bg.height = Height;
				bg.y = bar_height;
			album.addChild(bg);
			
			//if(visDebug){
				//album.graphics.lineStyle(4, 0x00FF00, 1);
				//album.graphics.drawRect(0,0,Width,Height);
			//}
			
			/////////////////////////////////////////////////////////////////////////////////////
			// create frame object
			/////////////////////////////////////////////////////////////////////////////////////
			
			var frame:TouchSprite = new TouchSprite();
				frame.targetParent = true;
				
				//frame.gestureEvents = true;
				//frame.disableNativeTransform = false;
				//frame.disableAffineTransform = false;
				//frame.gestureList = {"n-drag":true, "n-scale":true, "n-rotate":true};
			album.addChild(frame);
			
			// general frame
			/*
			var f:FrameElement = new FrameElement();
				f.shape = "bar";
				f.frameThickness = 50*0.5;
				f.frameColor= 0x999999;
				f.frameAlpha = 0.3;
				f.width = Width;
				f.height = Height;
			frame.addChild(f);
			*/
			
			var bar:GraphicElement = new GraphicElement();
				bar.lineColor = 0x000000;
				bar.lineAlpha = 1;
				bar.lineStroke = 2;
				bar.color = 0x666666;
				bar.shape="rectangle"
				bar.width = Width;
				bar.height = bar_height;
				bar.y = 0// -bar_height
				//bar.x = 0
			frame.addChild(bar);
			
			
			var album_title:TextElement = new TextElement();
					album_title.text = "Title 123456789....";
					album_title.x = text_pad + 2*btn_rad + 2*btn_pad;
					album_title.y = text_pad;
					album_title.textColor = 0xFFFFFF;
					album_title.width = Width - 4 * btn_rad - 4 * btn_pad;
					album_title.height = bar_height; 
			bar.addChild(album_title);	
			
			
			// close button 
			var cbtn:TouchSprite = new TouchSprite();
				cbtn.addEventListener(GWGestureEvent.TAP, onClose);
				cbtn.gestureEvents = true;
				cbtn.mouseChildren = false;
				cbtn.gestureList = { "tap":true };
				cbtn.x = Width - btn_rad-btn_pad;
				cbtn.y = btn_rad+btn_pad;
			album.addChild(cbtn);
			
			//var close_btn:ButtonElement = new ButtonElement();
			var close_btn:GraphicElement = new GraphicElement();
				close_btn.shape = "circle";
				close_btn.radius = btn_rad;
				close_btn.lineStroke = 2;
				close_btn.x = -btn_rad;
				close_btn.y = -btn_rad;
				//close_btn.width = 30;
				//close_btn.height = 30;
				//close_btn.text = "x........";
			cbtn.addChild(close_btn);
			
			// info button 
			var ibtn:TouchSprite = new TouchSprite();
				ibtn.addEventListener(GWGestureEvent.TAP, onInfo);
				ibtn.gestureEvents = true;
				ibtn.mouseChildren = false;
				ibtn.gestureList = { "tap":true };
				ibtn.x = btn_rad+btn_pad;
				ibtn.y = btn_rad+btn_pad;
			album.addChild(ibtn);
			
			
			var info_btn:GraphicElement = new GraphicElement();
			//var info_btn:ButtonElement = new ButtonElement();
				info_btn.shape = "circle";	
				info_btn.lineStroke = 2;
				info_btn.radius = btn_rad;
				info_btn.x = -btn_rad;
				info_btn.y = -btn_rad;
				//info_btn.width = 25;
				//info_btn.height = 25;
				//info_btn.text = "i........";
			ibtn.addChild(info_btn);
			
			//outline
			/*
			var ol:GraphicElement = new GraphicElement();
				ol.fillAlpha = 0;
				ol.lineColor = 0x000000;
				ol.lineStroke = 3;
				ol.shape = "rectangle";
				ol.width = Width;
				ol.height = Height;
				ol.y = bar_height;
				ol.mouseChildren = true;
			album.addChild(ol);
			*/
			
			/////////////////////////////////////////////////////////////////////////////////////
			// create belt object
			/////////////////////////////////////////////////////////////////////////////////////
			
			belt = new TouchSprite();
			
				belt.name = "belt";
				belt.x = 0;
				belt.y = belt_marginY + bar_height;//top_bar.height;
				
				belt.nestedTransform = true;
				//belt.targeting = false;
				belt.mouseChildren = true;
				belt.gestureEvents = true;
				belt.gestureList = { "tap":true,"double_tap":true,"1-dragx":true, "2-dragx":true, "3-dragx":true };
				belt.disableNativeTransform = true;
				belt.disableAffineTransform = true;
				belt.addEventListener(GWGestureEvent.DRAG, checkBeltPosition);
				belt.addEventListener(GWGestureEvent.DOUBLE_TAP, gtapMenuItem);
				
				if(!loopMode)	belt.addEventListener(TouchEvent.TOUCH_BEGIN, cancelTween);
				if(!loopMode)	belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
				if(!loopMode)	belt.addEventListener(GWGestureEvent.COMPLETE, onComplete);
			album.addChild(belt);
			
			 //create belt background
				belt.graphics.beginFill(0x777777, 0);
				belt.graphics.drawRect(0,0,belt_width,belt_height);
				belt.graphics.endFill();
			
			if (visDebug) {
				belt.graphics.lineStyle(4, 0x0000FF, 1);
				if (loopMode) belt.graphics.drawRect(-repeatBlockwidth,0,belt_width,belt_height);
				else belt.graphics.drawRect(0,0,belt_width,belt_height);
			}
			
			///////////////////////////////////////////////////////////////////////////
			// main block of elements
			///////////////////////////////////////////////////////////////////////////
			
			// block debug
			if (visDebug) {
				belt.graphics.lineStyle(1, 0x00FFFF, 1);
				belt.graphics.drawRect(0, 0, centralBlockwidth, belt_height);
			}
			
			// create menu elements
				for (i=1; i<n+1; i++)
				{	
					trace("menu item",i);
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
						//menuObj.addEventListener(GWGestureEvent.TAP, gtapMenuItem);
						menuObj.addEventListener(GWGestureEvent.DOUBLE_TAP, gtapMenuItem);
						//addEventListener(GWGestureEvent.HOLD, gestureHoldHandler);
						//addEventListener(GWGestureEvent.TAP, gestureTapHandler);
						//addEventListener(GWGestureEvent.DOUBLE_TAP, gestureDTapHandler);
						
						//if (GestureWorks.supportsTouch) menuObj.addEventListener(TouchEvent.TOUCH_TAP, tapMenuItem);
						//else menuObj.addEventListener(MouseEvent.CLICK, clickMenuItem);
						
					masterItemList.push(menuObj);
					belt.addChild(menuObj);
				}
				
			/////////////////////////////////////////////////////////////////////////////////////
			// create mask object
			/////////////////////////////////////////////////////////////////////////////////////
			var mShape:GraphicElement = new GraphicElement();
				mShape.fill = "0xFFFFFF";
				mShape.fillAlpha = 1;
				mShape.lineColor = 0xFFFFFF;
				mShape.lineStroke = 2;
				mShape.shape = "rectangle";
				mShape.width = Width;
				mShape.height = Height;
				mShape.y = bar_height;
			album.addChild(mShape);
			
			//apply mask
			belt.mask = mShape;
			
			//////////////////////////////////////////////////////////////////
			// create album metadata
			//////////////////////////////////////////////////////////////////
			
			// metadata holder
			metadata = new Sprite();
				metadata.name = "metadata";
				metadata.x = 0;
				metadata.y = bar_height;
				metadata.visible = false;
			album.addChild(metadata);
				
			// meta text background
			var meta_bg:GraphicElement = new GraphicElement();
				meta_bg.fill = "0xFFFFFF";
				meta_bg.fillAlpha = 1;
				meta_bg.shape = "rectangle";
				meta_bg.width = Width;
				meta_bg.height = Height;
			metadata.addChild(meta_bg);
				
			// scrolable text field
			var scrolltxt:TouchSprite = new TouchSprite();
				scrolltxt.touchChildren = false;
				scrolltxt.targeting = true;
				scrolltxt.gestureEvents = true;
				//scrolltxt.gestureList = { "2-finger-drag":true };
				scrolltxt.disableNativeTransform = true;
				scrolltxt.disableAffineTransform = true;
				scrolltxt.gestureList = { "n-drag":true };
				scrolltxt.addEventListener(GWGestureEvent.DRAG, onScroll);
				metadata.addChild(scrolltxt);
				
			album_description = new TextElement();
				album_description.text = " 1 Description --Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. 2 Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.0000";
				album_description.textSize = 24;
				album_description.x = text_pad;
				album_description.y = text_pad;
				album_description.width = Width-2*text_pad-scroll_bar_width;
				album_description.height = Height-text_pad;
				album_description.wordWrap = true;
				album_description.multiline = true;
				album_description.selectable = false;
			scrolltxt.addChild(album_description);	
			
			width = Width;
			//heith = Height;
			
			
			// childList["meta_bg"].x = 500;
			trace("---------------------------------------------------",this.childList.getKey("belt1"));
			//childList.getKey("meta_bg").x = 500
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
			//trace("translate album");
			this.dispatchEvent(new DisplayEvent(DisplayEvent.CHANGE));
		}
		
		private function updateHandler(event:Event):void 
		{
		trace("album update");	
		}

	}
}