package com.gestureworks.cml.components
{
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.cml.element.ButtonElement;
	import com.gestureworks.cml.element.GraphicElement;
	import com.gestureworks.cml.element.FrameElement;
	import com.gestureworks.cml.element.TextElement;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.utils.*;
	import adobe.utils.CustomActions;
	
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.Component;
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

	
	public class AlbumViewer extends Component
	{		
		// objects
		private var menu:TouchSprite;
		private var bar:GraphicElement;
		private var ibtn:TouchContainer;;
		private var cbtn:TouchContainer;
		private var album_title:TextElement;
		
		private var album_bg:GraphicElement;
		private var content_holder:TouchSprite;
		private var belt:TouchSprite;
		private var belt_bg:GraphicElement;
		private var list:ComponentKit;
		private var mShape0:GraphicElement
		private var mShape:GraphicElement
		
		private var metadata:TouchSprite;
		private var text_scroll_box:TouchSprite;
		private var meta_bg:GraphicElement;
		private var meta_desc:TextElement;

		private var _x:Number;
		private var _y:Number;
		public var bar_height:Number;
		private var text_padding:Number = 20;
		
		// component
		private var i:int
		private var visDebug:Boolean =false;
		private var buffer_tween:Boolean = true;
		private var loopMode:Boolean = false;
		
		// belt
		private var belt_marginX:Number;
		private var belt_marginY:Number;
		public var belt_maxValue:Number;
		public var belt_minValue:Number;
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
		
		// meta data
		private var album_description:TextElement
		//private var text_pad:Number;
		//private var scroll_bar_pad:Number;
		//private var scroll_bar_width:Number;
		//private var scroll_bar_height:Number;
		
		private var scroll_minValue:int;
		private var scroll_maxValue:int;
		
		// interation
		public var Icount:int = 0;
		private var timeOut:int = 1200;
		
		public static var ALBUM_UPDATE:String = "album update";
		
		public function AlbumViewer()
		{
			super();	
			mouseChildren = true;
			if (buffer_tween) GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, onEnterFrameGW);
		}
		
		public function dipose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			//trace("album display viewer complete");
			initUI();	
			setupUI();	
		}
	
		private function initUI():void
		{
			//trace("initUI album");
			belt_buffer = 200;
			//slider_factor = (centralBlockwidth - width) / width;
			//text_pad = 20;
			//scroll_bar_pad = 30;
			//scroll_bar_width = 10;
			//scroll_bar_height = 60;
		}
		
		
		private function setupUI():void
		{ 
			//trace(" start setupUI album");
			
				this.gestureEvents = true;
				this.gestureList = { "n-drag-lim":true };
				this.transformEvents = true;
				this.addEventListener(GWTransformEvent.T_TRANSLATE, translateHandler);
				
				this.filters = [new DropShadowFilter(6, 45, 0x000000, .5, 6, 6, 1, 3)];
				
				//set init placement
				_x = this.x;
				_y = this.y;
				
				// album background
				album_bg = this.childList.getCSSClass("album_bg", 0)
				this.addChild(album_bg);
				
				
				////////////////////////////////////////////////
				// menu
				////////////////////////////////////////////////
				menu = this.childList.getCSSClass("menu", 0);
					menu.targetParent = true;
				this.addChild(menu);
				
				bar = this.childList.getCSSClass("menu", 0).childList.getCSSClass("bar", 0);
				//bar = album.childList.getCSSClass("menu", 0);
					//bar.y -= 10;
				menu.addChild(bar);
				
				bar_height = bar.height;
				
				album_title = this.childList.getCSSClass("menu", 0).childList.getCSSClass("title", 0);
				menu.addChild(album_title);
						
				// close button 
				cbtn = new TouchContainer();
				//cbtn = this.childList.getCSSClass("menu", 0).childList.getCSSClass("cbtn",0);
					cbtn.mouseChildren = false;
					cbtn.gestureEvents = true;
					cbtn.gestureList = { "tap":true};//"n-drag":true 
					cbtn.addEventListener(GWGestureEvent.TAP, onClose);
				//menu.addChild(cbtn);
				this.addChild(cbtn);
				
				var cml_cbtn:* = this.childList.getCSSClass("menu", 0).childList.getCSSClass("cbtn",0);
				cbtn.addChild(cml_cbtn);

				// info button
				ibtn = new TouchContainer();
				//ibtn = this.childList.getCSSClass("menu", 0).childList.getCSSClass("ibtn", 0);
					ibtn.mouseChildren = false;
					ibtn.gestureEvents = true;
					ibtn.gestureList = {"tap":true};//, "n-drag":true 
					ibtn.addEventListener(GWGestureEvent.TAP, onInfo);
				//menu.addChild(ibtn);
				this.addChild(ibtn);
				
				var cml_ibtn:* = this.childList.getCSSClass("menu", 0).childList.getCSSClass("ibtn",0);
				ibtn.addChild(cml_ibtn);
				
				
				/// belt and metadata holder 
				content_holder = this.childList.getCSSClass("content", 0);
				this.addChild(content_holder);
				
			
				/////////////////////////////////////////////////
				// item belt
				/////////////////////////////////////////////////
				belt = this.childList.getCSSClass("content", 0).childList.getCSSClass("belt", 0);
					belt.gestureList = {"1-dragx":true};//, "2-dragx":true, "3-dragx":true 
					belt.gestureEvents = true;
					belt.addEventListener(GWGestureEvent.DRAG, checkBeltPosition);
					belt.transformEvents = true;
				content_holder.addChild(belt);
				
					
				belt_bg = this.childList.getCSSClass("content", 0).childList.getCSSClass("belt", 0).childList.getCSSClass("belt_bg", 0);
				belt.addChild(belt_bg);
				
				list = this.childList.getCSSClass("content", 0).childList.getCSSClass("belt", 0).childList.getCSSClass("list", 0);
				belt.addChild(list);
			
				
				//////////////////////////////////////////////////////////
				// meta data text display 
				//////////////////////////////////////////////////////////
				metadata = this.childList.getCSSClass("content", 0).childList.getCSSClass("metadata", 0);
				content_holder.addChild(metadata);
				
					
				meta_bg = this.childList.getCSSClass("content", 0).childList.getCSSClass("metadata", 0).childList.getCSSClass("vscroll_box", 0).childList.getCSSClass("meta_bg", 0)
				metadata.addChild(meta_bg);
				
				text_scroll_box = this.childList.getCSSClass("content", 0).childList.getCSSClass("metadata", 0).childList.getCSSClass("vscroll_box", 0);
					text_scroll_box.mouseChildren = false;
					text_scroll_box.gestureEvents = true;
					text_scroll_box.gestureList = { "n-dragy":true };  
					text_scroll_box.addEventListener(GWGestureEvent.DRAG, checkScrollPosition);
				metadata.addChild(text_scroll_box);
				
					meta_desc =  this.childList.getCSSClass("content", 0).childList.getCSSClass("metadata", 0).childList.getCSSClass("vscroll_box", 0).childList.getCSSClass("meta_description", 0);
					text_scroll_box.addChild(meta_desc);
				
					
				/////////////////////////////////////////////////////////
				//apply metadata mask
				/////////////////////////////////////////////
				mShape = this.childList.getCSSClass("mask_shape", 0);
				this.addChild(mShape);
				content_holder.mask = mShape;

				//trace("Album setup complete");
		
	}
	
	public function update():void
	{	
		// update height
		
		//trace("*******height", height);
		
		album_bg.height = height;
		belt.height = height;
		belt_bg.height = height;
		mShape.height = height;
		metadata.height = height;
		meta_bg.height = height;
		
		
		//update width
		album_bg.width = width;
		mShape.width = width;
		metadata.width = width;
		meta_bg.width = width;
		text_scroll_box.width = width;
		meta_desc.width = width - 2 * text_padding;
		
		// update limits
		belt_minValue = 0
		belt_maxValue = belt_bg.width - width;
		
		///////////////////////////////////////////
		
		//meta_desc.height = 800// height - 2*text_padding;
		meta_desc.wordWrap = true;
		meta_desc.autoSize = "left"
		
		text_scroll_box.height = meta_desc.height;
		
		scroll_minValue = 0;
		scroll_maxValue = meta_desc.height - height + bar_height;
		
		//trace("==============================================",meta_desc.height,meta_desc.textHeight)
	}
	
	
	///////////////////////////////////////////////////////////////

		private function resetInteractionCount():void
		{
			Icount = 0;
		}
		
		private function interactionCount():void
		{
			if (visible)
			{ 
				Icount++;
				//trace(Icount);
			}
		}
		
		private function interactionMonitor():void 
		{
			if (Icount > timeOut) 
			{
				//trace("close album");
				closeAlbum();
				resetInteractionCount();
			}
			else interactionCount();
		}
	
	///////////////////////////////////////////////////////////////
	
	
	public function onClose(event:GWGestureEvent):void
	{
		closeAlbum();
	}
	
	public function closeAlbum():void
	{
		//trace("close album");
		//dispose();
		
		//reset album //faux dispose
		this.visible = false;
		//reset position
		this.x = _x;
		this.y = _y;
		// reset meta data 
		metadata.visible = false; // reset meta data
		// reset scroll text
		
		// reset belt
		belt.x = 0;
		
		// reset meta data
		text_scroll_box.y = 0;

		// reset link line
		this.dispatchEvent(new DisplayEvent(DisplayEvent.CHANGE));
		
		resetInteractionCount();
	}
	
	
	public function onInfo(event:GWGestureEvent):void
	{
		showInfo();
	}
	
	public function showInfo():void
	{
		//trace("info",metadata.visible);
		if (!metadata.visible) metadata.visible = true;
		else metadata.visible = false;
		
		this.dispatchEvent(new DisplayEvent(DisplayEvent.CHANGE));
		resetInteractionCount();
		
		// reset belt
		belt.x = 0;
		// reset meta data
		text_scroll_box.y = 0;
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
	
	public function checkScrollPosition(event:GWGestureEvent):void
	{
		//trace("checkscroll position",text_scroll_box.y );
		// update interaction on drag belt
		resetInteractionCount(); 
		
		var abs_scrolly:Number = Math.abs(text_scroll_box.y);
		
		text_scroll_box.y += event.value.dy;
		
		if (text_scroll_box.y > 0){
			if (abs_scrolly > scroll_minValue) text_scroll_box.y = scroll_minValue;
		}
		if (text_scroll_box.y < 0){
			if (abs_scrolly > scroll_maxValue) text_scroll_box.y = -scroll_maxValue;
		}

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
		
		trace(belt.x);
	}
	
	public function checkBeltPosition(event:GWGestureEvent):void
	{
		// update interaction on drag belt
		resetInteractionCount(); 
		
		var abs_beltx:Number = Math.abs(belt.x);
		belt.x += event.value.dx;
		//trace("belt_pos",belt.x)
		
		checkTween();	
	}
	
	public function onEnterFrameGW(event:GWEvent):void
	{
		interactionMonitor();
		//trace(belt_buffer_tweenOn,belt_target_tweenOn)
		
		beltbuffer();
	}
	
	public function beltbuffer():void
	{
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
		resetInteractionCount();
	}
		
	private function updateHandler(event:Event):void 
	{
		trace("album update");	
	}
	
	

	}
}