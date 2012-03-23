package com.gestureworks.cml.components
{
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.*;
	import flash.ui.Mouse;
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.cml.element.Component;
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	
	import com.gestureworks.core.GestureWorks;

	import com.google.maps.LatLng;
	import com.google.maps.Map;
  	import com.google.maps.Map3D;
 	import com.google.maps.MapEvent;
 	import com.google.maps.MapOptions;
 	import com.google.maps.MapType;
 	import com.google.maps.View;
	import com.google.maps.geom.Attitude;
	 
	public class MediaViewer extends Component
	{
		private var _id:int;
		private var _intialize:Boolean;
		
		private var _holder:TouchSprite;
		private var frame:TouchSprite;
		private var screen:TouchSprite;
		
		public var src:String = "";
		
		//---------frame settings--//
		private var frameDraw:Boolean = true;
		private var frameMargin:Number = 25;
		private var frameRadius:Number = 20;
		private var frameFillColor:Number = 0x999999;
		private var frameFillAlpha:Number = 0.5;
		private var frameOutlineColor:Number = 0x999999;
		private var frameOutlineStroke:Number = 2;
		private var frameOutlineAlpha:Number = 0.3;
		
		private var screenDraw:Boolean = true;
		
		private var _Width:Number = 0;
		private var _Height:Number = 0;
		
		//----frame gestures---//
		//private var frameDragGesture:Boolean = true;
		//private var frameScaleGesture:Boolean = true;
		//private var frameRotateGesture:Boolean = true;
		
		private var media:ImageElement;
				 
	
		public function MediaViewer()
		{
			super();
			//blobContainerEnabled=true;
			//visible=false;
			//displayComplete();
		}

		public function dipose():void
		{
			parent.removeChild(this);
		}
		/*

		override protected function displayComplete():void
		{			
			trace("media display viewer complete");
			
			childInfo();
			
		}
		
		//override public function set childToList(child:*):void
		//{
			//trace("y");
			//childInfo();
			//createUI();
			//commitUI();
			//trace("childList",childList[0])
		//}
		
			
		private function childInfo():void
		{ 
				trace(this.childList.length);
				
				//media = this.childList[0];
				
				/*
				for (var i:int=0; i<=this.childList.length; i++)
					{
						trace(this.childList[i])
						if ((childList[i] is ImageElement)&&(childList[i].id="image"))
						{
							//trace(childList[i].x, childList[i].y,childList[i].width,childList[i].getChildAt(0).width);
							media=childList[i]
						}
					}
					
					//n = itemList.length;
					
			//childList[0].getChildAt(0).addEventListener(Event.COMPLETE, updateDisplay);
			*/
		//}
/*
		override protected function createUI():void
		{
			
			_Width = 500;
			_Height = 500;
			//trace("createUI");
			//stageWidth = 500//ApplicationGlobals.application.stage.stageWidth;
			//stageHeight = 500//ApplicationGlobals.application.stage.stageHeight;
		
			//--Frame Style--//
			frameDraw = true//MapParser.settings.FrameStyle.frameDraw == "true"?true:false;
			frameMargin = 50//MapParser.settings.FrameStyle.padding;
			frameRadius = 5//MapParser.settings.FrameStyle.cornerRadius;
			frameFillColor = 0xFFFFFF//MapParser.settings.FrameStyle.fillColor1;
			frameFillAlpha = 0.6//MapParser.settings.FrameStyle.fillAlpha;
			frameOutlineColor = 0xFFFFFF//MapParser.settings.FrameStyle.outlineColor;
			frameOutlineStroke = 4//MapParser.settings.FrameStyle.outlineStroke;
			frameOutlineAlpha = 0.8//MapParser.settings.FrameStyle.outlineAlpha;
			
			//--Frame Gestures--//
			//frameDragGesture= true//MapParser.settings.FrameGestures.drag == "true" ?true:false;
			//frameScaleGesture=true//MapParser.settings.FrameGestures.scale == "true" ?true:false;
			//frameRotateGesture=true//MapParser.settings.FrameGestures.rotate == "true" ?true:false;
			
			//----------------------------//
			_holder = new TouchSprite();
				_holder.targeting = true;
				_holder.gestureEvents = true;
				_holder.nestedTransform = true;
				_holder.disableNativeTransform = false;
				_holder.disableAffineTransform = false;
				_holder.mouseChildren = true;
				_holder.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
			addChild(_holder);
			
			//-----------media -------------------------------//
			
			//var media:ImageElement = new ImageElement();
			//	media.src = this.src;
				//media.src = "../../../bin/library/assets/USS_Macon_over_Manhattan.png"
			
				//media = this.childList[0];
				//media.x = 400;
				//_holder.addChild(media);
				
				//this.x = 800;
			
			
			//---------- build frame ------------------------//
			if(frameDraw)
			{							
				frame = new TouchSprite();
					frame.targetParent = true;
				_holder.addChild(frame);
			}
			
			
			//-- center map --//
			x = -_Width/2;
			y = -_Height/2
			
			if (screenDraw)
			{
			screen = new TouchSprite();
				screen.nestedTransform = true;
				screen.mouseChildren = true;
				screen.gestureEvents = true;
				screen.gestureList = {"n-drag":true, "n-scale":true,"4-finger-scale":true, "n-rotate":true,"double_tap":true};
				screen.disableNativeTransform = true;
				screen.disableAffineTransform = true;
				screen.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
				screen.addEventListener(GWGestureEvent.DOUBLE_TAP, doubleTapHandler);
			_holder.addChild(screen);
			}
			
		}

		override protected function commitUI():void
		{	
			trace("commit");
			
			width=_Width;
			height=_Height;
			
			if(!frameMargin)
			{
				frameMargin=0;
			}
			
			if(frameDraw)
			{		
				frame.graphics.lineStyle(2*frameMargin, frameFillColor, frameFillAlpha);
				frame.graphics.drawRect( -frameMargin, -frameMargin, _Width + 2 * frameMargin, _Height + 2 * frameMargin);
				frame.graphics.lineStyle(2, frameFillColor,frameFillAlpha+0.5);
				frame.graphics.drawRoundRect( -2 * frameMargin, -2 * frameMargin, _Width + 4 * frameMargin, _Height + 4 * frameMargin, 2 * frameMargin, 2 * frameMargin);
				frame.graphics.lineStyle(frameOutlineStroke, frameOutlineColor,frameOutlineAlpha);
				frame.graphics.drawRect(-2, -2, _Width + 4, _Height + 4);

				width=_Width+frameMargin;
				height=_Height+frameMargin;
			}
			
			if (screenDraw)
			{
			screen.graphics.beginFill(0xFFFFFF,0);
			screen.graphics.drawRoundRect(0,0,_Width,_Height,0,0);
			screen.graphics.endFill();
			}
			
			if (! _intialize)
			{
				_intialize=true;
				visible=true;
			}
		}
		
		/*
		override protected function updateUI():void
		{
			if( (x-(frameMargin/2)>stageWidth) || (x+width-(frameMargin/2)<0) || (y-(frameMargin/2)>stageHeight) || (y+height-(frameMargin/2)<0) )
			{
				Dispose();
			}
		}
		*/
		/*
		private function objectDragHandler(event:GWGestureEvent):void
		{
			x += event.value.dx;
			y += event.value.dy;
		}
		
		private function objectScaleHandler(event:GWGestureEvent):void
		{
			scaleX += event.value.dsx;
			scaleY += event.value.dsy;
		}
		
		private function objectRotateHandler(event:GWGestureEvent):void
		{
			rotation += event.value.dtheta;
		}
		
		private function gestureDragHandler(event:GWGestureEvent):void 
		{	
		}
		
		private function doubleTapHandler(event:GWGestureEvent):void
		{
		}

		private function gestureScaleHandler(event:GWGestureEvent):void
		{
		}
		
		private function gestureRotateHandler(event:GWGestureEvent):void
		{
		}
		
		*/
	}
}