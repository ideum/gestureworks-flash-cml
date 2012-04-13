package com.gestureworks.cml.components
{
	//import com.greensock.TweenLite;
	
	import adobe.utils.CustomActions;
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.*;
	import flash.utils.*;
	
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.GraphicElement;
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.element.TextElement;
	
	//import com.gestureworks.cml.element.AvatarElement;
	//import com.gestureworks.cml.element.TimelineItem;
	//import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.cml.components.Component;

	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.core.GestureWorks;
	
	public class TimelineViewer extends Component//TouchContainer
	{		
		// component
		private var visDebug:Boolean = false;
		private var Width: Number;
		private var Height:Number;
		private var centerX:Number;
		private var centerY:Number;
		private var buffer_tween:Boolean = true;
		private var loopMode:Boolean = true;
		
		// belt
		private var belt:TouchSprite;
		private var belt_width:Number;
		private var belt_height:Number;
		private var i:int
		private var itemList:Array = new Array;
		private var masterItemList:Array = new Array;
		private var belt_marginX:int;
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
		
		//items
		private var background_tile:ImageElement;
		private var background:ImageElement;
		private var n:int;
		private var sepx:Number;
		private var box:Number ;
		private var distX:Number;
		
		//repeat blocks
		private var rn:int // repeat number
		private var centralBlockwidth:Number;
		private var repeatBlockwidth:Number;
		
		// menu text
		//private var maxDecade:Number = 1900;
		//private var minDecade:Number = 1900;
		private var decade_margin:int = 50;
		private var decade_sep:int = 130;
		private var nDecades:int = 11;
		private var menu_text_array:Array = new Array();
		
		public function TimelineViewer()
		{
			super();	
			//createUI();
			//commitUI();
			//if (buffer_tween) GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, onEnterFrame);
		}
		
		public function dipose():void
		{
			parent.removeChild(this);
		}
		/*
		override protected function displayComplete():void
		{			
			trace("timeline display viewer complete");
			
			childInfo();
			initUI();
			setupUI();
		}
			
		private function childInfo():void
		{ 
				//trace(this.childList.length);
				
				for (i=0; i<=this.childList.length; i++)
					{
						trace(this.childList[i])
						if ((childList[i] is TouchContainer)&&(childList[i].id="item"))
						{
							trace(childList[i].x, childList[i].y);
							itemList.push(childList[i])
						}
						else if ((childList[i] is ImageElement) && (childList[i].id = "background_tile")) {
							
							childList[i].visible = false
							background_tile=childList[i]
							background_tile.addEventListener(Event.COMPLETE, onAvatarComplete);
							}
							
							else if ((childList[i] is ImageElement) && (childList[i].id = "background")) background=childList[i]
						//trace(childList[i].id)
					}
					n = itemList.length;
		}
		
		

		//private function createUI():void
		//{
		
		private function initUI():void
		{
			//trace("display list:", rendererList)
			x = 0
			y = 0;
			//targeting = false;
			mouseChildren = true;
			
			Width = GestureWorks.application.stageWidth;
			Height = GestureWorks.application.stageHeight;
			centerX = Width*0.5;
			centerY = Height*0.5;
			
			// Math.round(Width/box) = min number of items based on item size and screen width
			// sets n and rn
			
			//n = 10 // min amount to show 5 items
			rn = 5; //min_n min repeating block 5 items
			box = 390; // max 385
			sepx = 0;
			belt_marginX = 0;
			belt_height = 400;//502-78-35;
			
			centralBlockwidth = 2*belt_marginX + n*box + (n-1)*sepx;
			repeatBlockwidth = 2*belt_marginX + rn*box + (rn-1)*sepx;
			
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
			
			slider_factor = (centralBlockwidth-Width) / Width;
			
			if(visDebug){
				graphics.lineStyle(4, 0x00FF00, 1);
				graphics.drawRect(0,0,Width,Height);
			}
			//trace(background_top_bar_src, background_bottom_bar_src, background_item_tile_src);
		}
		
		
		private function setupUI():void
		{ 
			//trace("TimelineDisplay class", DisplayList.array, this.childList.length, itemList.length);
				
			//////////////////////////////////////////////////////////////////////////////////////
			// creat bottom bar menu
			//////////////////////////////////////////////////////////////////////////////////////
			var ts_b_bar:TouchSprite = new TouchSprite();
				ts_b_bar.mouseChildren = false;
				ts_b_bar.touchChildren = false;
				ts_b_bar.y = belt_height + 34;
				ts_b_bar.gestureEvents = true;
				
				// touch event capture screen
				ts_b_bar.graphics.beginFill(0xFFFFFF, 0);
				ts_b_bar.graphics.drawRect(0,0,1920,68);
				ts_b_bar.graphics.endFill();
	
					if (GestureWorks.supportsTouch) ts_b_bar.addEventListener(TouchEvent.TOUCH_TAP, tweenToTarget);
					else ts_b_bar.addEventListener(MouseEvent.CLICK, tweenToClickTarget);
					
				//ts_b_bar.cluster_points.obj.stroke_color = "0xFF0000"
			addChild(ts_b_bar)
			
			//////////////////////////////////////////////////////////////////////////////////////////////
			//create menu
			//////////////////////////////////////////////////////////////////////////////////////////////
			var tfield_holder:Sprite = new Sprite();
					
				//trace(minDecade, maxDecade, nDecades);
					for (i = 0; i <= nDecades; i++) {
						
						var item_holder:Sprite = new Sprite();
							item_holder.mouseChildren = true;
						
							var item_small:TextElement = new TextElement();
							item_holder.addChild(item_small);
							
							var item_large:TextElement = new TextElement();
							item_holder.addChild(item_large);
							
						menu_text_array.push(item_holder);
						tfield_holder.addChild(item_holder);
							
							if (i == 0) 
							{
								item_small.textSize = 22;
								item_small.width = 185;
								item_small.height = 30;
								//item_small.border = true;
								item_small.x = decade_margin;
								item_small.y = 0//50//(78 - pre_decade.height) * 0.5;
								item_small.font = "OpenSansBold";
								item_small.text = "PRE-STATEHOOD";
								item_small.textAlign = "center"
								
								item_large.textSize = 30;
								item_large.width = 250;
								item_large.height = 40;
								//item_large.border = true;
								item_large.x = decade_margin;
								item_large.y = 0//50//(78 - pre_decade.height) * 0.5;
								item_large.font = "OpenSansBold";
								item_large.text = "PRE-STATEHOOD";
								item_large.textAlign = "center";
							
							}
							else{
								item_small.textSize = 22;
								item_small.width = 60;
								item_small.height = 30;
								item_small.font = "OpenSansBold";
								item_small.textAlign = "center"
								item_small.border = true;
								//decade_sep = ((Width - 2 * decade_margin - pre_decade.width) - (nDecades * (decade.width))) / (nDecades); //110
								//trace(decade_sep);
								decade_sep = ((Width - 2 * decade_margin - 185) - (nDecades * (item_small.width))) / (nDecades); //110
								//trace(decade_sep);
								//item_small.x = decade_margin + pre_decade.width + (i + 1) * decade_sep + (i) * decade.width;
								item_small.x = decade_margin + 185 + (i) * decade_sep + (i-1)*item_small.width;
								//decade.y = (78 - decade.height) * 0.5;
								//decade.y = (decade.height)*0.5;

								// set decade date
								if (i == 1) item_small.text = String(1912);
								else if (i == nDecades) item_small.text = String(2012);
								else item_small.text = String(1910 + (i-1) * 10);
							
								item_large.textSize = 30;
								item_large.width = 120;
								item_large.height = 30;
								item_large.font = "OpenSansBold";
								item_large.textAlign = "center"
								item_large.border = true;
								//decade_sep = ((Width - 2 * decade_margin - 185) - (nDecades * (item_small.width))) / (nDecades); //110
								//trace(decade_sep);
								item_large.x = decade_margin + 185 + (i) * decade_sep + (i-1)*item_small.width;
								//decade.y = (78 - decade.height) * 0.5;
								//decade.y = (decade.height)*0.5;

								// set decade date
								if (i == 1) item_large.text = String(1912);
								else if (i == nDecades) item_large.text = String(2012);
								else item_large.text = String(1910 + (i-1) * 10);
							}
						}	
				ts_b_bar.addChild(tfield_holder);	
			
			/////////////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////////////////
			// create belt object
			/////////////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////////////////
			
			belt = new TouchSprite();
				belt.name = "belt";
				belt.x = 0;
				belt.y = 35;//top_bar.height;
				belt.targeting = false;
				belt.mouseChildren = true;
				belt.gestureEvents = true;
				belt.gestureList = { "1-dragx":true, "2-dragx":true, "3-dragx":true };
				belt.disableNativeTransform = true;
				belt.disableAffineTransform = true;
				belt.addEventListener(GWGestureEvent.DRAG, checkBeltPosition);
				belt.addEventListener(TouchEvent.TOUCH_MOVE, size);
				
				if(!loopMode)	belt.addEventListener(TouchEvent.TOUCH_BEGIN, cancelTween);
				if(!loopMode)	belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
				if(!loopMode)	belt.addEventListener(GWGestureEvent.COMPLETE, onComplete);
			addChild(belt);
			
			// create belt background
				//belt.graphics.beginFill(0xFFFFFF, 0.2);
				//if (loopMode) belt.graphics.drawRect(-repeatBlockwidth,0,belt_width,belt_height);
				//else belt.graphics.drawRect(0,0,belt_width,belt_height);
				//belt.graphics.endFill();
			
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
					// create item container
				var menuObj:TouchContainer = itemList[i - 1];
						menuObj.id = String(i);
						menuObj.x = belt_marginX + (i-1)*box + (i-1)*sepx;
						menuObj.y = 0;
						menuObj.touchChildren = false;
						menuObj.targeting = false;
						//menuObj.gestureEvents = true;
						//menuObj.gestureList = {"tap":true, "double_tap":true };
					//	menuObj.addEventListener(GWGestureEvent.DOUBLE_TAP, gdtapMenuItem);
						
						if (GestureWorks.supportsTouch) menuObj.addEventListener(TouchEvent.TOUCH_TAP, tapMenuItem);
						else menuObj.addEventListener(MouseEvent.CLICK, clickMenuItem);
						
					masterItemList.push(menuObj);
					belt.addChild(menuObj);
				}
			if (loopMode) {
			
				//////////////////////////////////////////////////////////////////
				// front repeat block
				//////////////////////////////////////////////////////////////////
				
				// block debug
				if (visDebug) {
					belt.graphics.lineStyle(8, 0xFFFFFF, 1);
					belt.graphics.drawRect(centralBlockwidth, 0, repeatBlockwidth, belt_height);
				}
				
				for (i=1; i<rn+1; i++)
				{	
				// create item container
				//menuObj = new TimelineItem();
				var	menuObjf:TouchContainer = new TouchContainer()// = (itemList[i-1]);
						menuObjf = itemClone(itemList[i-1]);
						menuObjf.id = String(i - 1);
						menuObjf.x = centralBlockwidth + belt_marginX + (i-1)*box + (i-1)*sepx;
						menuObjf.y = 0;
						menuObjf.touchChildren = false;
						menuObjf.targeting = false;
						if (GestureWorks.supportsTouch) menuObjf.addEventListener(TouchEvent.TOUCH_TAP, tapMenuItem);
						else menuObjf.addEventListener(MouseEvent.CLICK, clickMenuItem);
				
				masterItemList.push(menuObjf);
				belt.addChild(menuObjf);
				}
				
				///////////////////////////////////////////////////////////////////////////////
				// back repeat block
				///////////////////////////////////////////////////////////////////////////////
				
				// block debug
				if (visDebug) {
					belt.graphics.lineStyle(8, 0xFFFF00, 1);
					belt.graphics.drawRect( -centralBlockwidth, 0, repeatBlockwidth, belt_height);
				}
				
				for (i=1; i<(rn+1); i++)
				{		
					// create item container
					//menuObj = new TimelineItem();
				var	menuObjb:TouchContainer = new TouchContainer();//= itemList[(i-1)+(n-rn)];
						menuObjb = itemClone(itemList[(i-1)+(n-rn)]);		
						menuObjb.id =String( i + (n - rn));
						menuObjb.x = -repeatBlockwidth + belt_marginX + (i-1)*box + (i-1)*sepx;
						menuObjb.y = 0;
						
						menuObjb.touchChildren = false;
						menuObjb.targeting = false;
						
						if (GestureWorks.supportsTouch) menuObjb.addEventListener(TouchEvent.TOUCH_TAP, tapMenuItem);
						else menuObjb.addEventListener(MouseEvent.CLICK, clickMenuItem);
						
					masterItemList.push(menuObjb);	
					belt.addChild(menuObjb);
				}	
			}
			
	}
	public function size(event:TouchEvent):void {
		
		var area:Number = event.sizeX * event.sizeY;
			trace("touch data",event.sizeX, event.sizeY, area, event.pressure)
	}
		
	public function onAvatarComplete(event:Event):void
	{
		trace("avatar complete");
		
		for (i=0; i<masterItemList.length; i++)
			{	
			var bitmapDataClone:BitmapData = background_tile.bitmapData.clone();
			var bgclone:Bitmap = new Bitmap(bitmapDataClone);
				masterItemList[i].addChildAt(bgclone, 0);
			}
	}
	
	public function itemClone(origin:*):TouchContainer {
		
		var clone:TouchContainer = new TouchContainer();
			clone.alpha = 1;
						
						for (var j:int=0; j<origin.numChildren; j++)
							{
								if (origin.getChildAt(j) is TextElement) 
								{
									var txt:TextElement = new TextElement();
										txt.x = origin.getChildAt(j).x;
										txt.y = origin.getChildAt(j).y;
										txt.width = origin.getChildAt(j).width;
										txt.height = origin.getChildAt(j).height;
										txt.multiline = true//origin.getChildAt(j).multiline;
										txt.wordWrap = true;// origin.getChildAt(j).wordWrap;
										txt.textAlign = origin.getChildAt(j).textAlign;
										txt.font = origin.getChildAt(j).font;
										txt.textFormatColor = origin.getChildAt(j).textFormatColor;
										txt.textSize = origin.getChildAt(j).textSize;
										txt.alpha = origin.getChildAt(j).alpha;
										txt.text = origin.getChildAt(j).text;
									clone.addChild(txt);
								}
								
								if (origin.getChildAt(j) is ImageElement) 
								{
									var img:ImageElement = new ImageElement();
										img.src = origin.getChildAt(j).src;
										img.x = origin.getChildAt(j).x;
										img.y = origin.getChildAt(j).y;
									clone.addChild(img);
								}
					}
					
		return clone;
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
		
		if ((belt.x > 0) && (abs_beltx > belt_minValue))
		{
			//trace("tween left to:",belt.$x, belt_minValue);
			belt_buffer_tweenOn = true;
			belt_tween_factor = -1;
			belt_speed = 0.4;
			belt_tween_target = belt_minValue;
		}
		else if ((belt.x <= 0 )&&(abs_beltx > belt_maxValue))
		{
			//trace("tween right to:",belt.$x, belt_maxValue);
			belt_buffer_tweenOn = true;
			belt_tween_factor = 1;
			belt_speed = 0.4;
			belt_tween_target = -belt_maxValue;
		}
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
		
		//belt.x = -event.stageX * factor;
		if (event.stageX <= decade_margin + 100) 
		{
			trace("start");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = belt_minValue;// return start of timeline
			belt_tween_factor = 1;
		}
		
		if (event.stageX > Width - decade_margin - 100) 
		{	
			trace("end");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = -belt_maxValue;// return start end of timeline
			belt_tween_factor = 1;
		}
		
		
		if ((event.stageX > decade_margin + 100) && (event.stageX < Width - decade_margin - 100))
		{
			trace("target");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = -event.stageX * slider_factor//+belt_buffer;
			belt_tween_factor = 1;
		}
		//trace("tweening to target", event.stageX, belt_tween_target, belt.x, slider_factor);
		
		for (i = 0; i < nDecades; i++) {
				menu_text_array[i].textSize = 10;
				menu_text_array[i].font = "OpenSansBold";
				//if (i == 1)
				menu_text_array[i].text = String(1912);
				trace("resize");
			}
	}
	
	public function tweenToClickTarget(event:MouseEvent):void
	{
		trace(event.stageX)
		var hit_margin:int = 200;
		
		// reset text menu item
		for (i = 0; i < nDecades; i++) 
		{
			menu_text_array[i].getChildAt(0).visible = true;
			menu_text_array[i].getChildAt(1).visible = false;
		}
		
		
		//belt.x = -event.stageX * factor;
		if (event.stageX <= decade_margin + hit_margin) 
		{
			trace("start");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = belt_minValue;// return start of timeline
			belt_tween_factor = 1;
			
			// set pre statehood
			menu_text_array[0].getChildAt(0).visible = false;
			menu_text_array[0].getChildAt(1).visible = true;
		}
		
		if (event.stageX > Width - decade_margin - hit_margin) 
		{	
			trace("end");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = -belt_maxValue;// return start end of timeline
			belt_tween_factor = 1;
			
			// set 2012
			menu_text_array[nDecades].getChildAt(0).visible = false;
			menu_text_array[nDecades].getChildAt(1).visible = true;
		}
		
		
		if ((event.stageX > decade_margin + hit_margin) && (event.stageX < Width - decade_margin - hit_margin))
		{
			trace("target");
			belt_target_tweenOn = true;
			belt_speed = 0.1;
			belt_tween_target = -event.stageX * slider_factor//+belt_buffer;
			belt_tween_factor = 1;
			
			//decade_sep = 110;
			
			var item_num:int = Math.floor((event.stageX - (decade_margin + hit_margin)) / decade_sep);
			
			trace("item num", decade_margin, hit_margin,decade_sep,item_num, decade_sep)
			// set division
			menu_text_array[item_num].getChildAt(0).visible = false;
			menu_text_array[item_num].getChildAt(1).visible = true;
			
		}
		//trace("tweening to target", event.stageX, belt_tween_target, belt.x, slider_factor);
	}
	
	public function tapMenuItem(event:TouchEvent):void{
		trace("tap menu item", event.target.id)
	}
	public function clickMenuItem(event:MouseEvent):void{
		trace("click menu item", event.target.id)
	}
	public function gtapMenuItem(event:GWGestureEvent):void{
		trace("gtap menu item", event.target.id)
	}
	public function gdtapMenuItem(event:GWGestureEvent):void{
		trace("gdtap menu item", event.target.id)
	}
		
		//override protected function createUI():void{}
		//override protected function commitUI():void{}
		//override protected function layoutUI():void{}
		
		private function updateHandler(event:Event):void{}
		*/
	}
}