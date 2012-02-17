﻿package com.gestureworks.cml.components
{
	//----------------adobe--------------//
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.*;
	import flash.ui.Mouse;
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	//---------- gestureworks ------------//
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.core.GestureWorks;
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
	
	//----------------away3d--------------//
	import away3d.cameras.HoverCamera3D;
	import away3d.cameras.Camera3D;
    import away3d.containers.View3D;
    import away3d.primitives.Sphere;
	import away3d.primitives.Skybox6;
    import away3d.core.utils.Cast;
    import away3d.materials.BitmapMaterial;
	import away3d.materials.BitmapFileMaterial;
	import away3d.core.clip.Clipping;
	import away3d.core.clip.FrustumClipping;
	import away3d.core.clip.RectangleClipping;
	
	import away3d.core.math.Number3D;
	import away3d.primitives.Cube;
	import away3d.materials.BitmapMaterial;
	import away3d.core.utils.Cast;
	
	import away3d.materials.utils.SimpleShadow 
	
	 
	public class TestViewer extends ComponentKit
	{
		private var _id:int;
		private var _intialize:Boolean;
		
		//------  settings ------//
		private var _source:String;
		// ----- interactive object settings --//
		private var _holder:TouchSprite;
		private var frame:TouchSprite;
		private var screen:TouchSprite;
		private var cam:HoverCamera3D;
		private var view:View3D;
		private var largeCube:Skybox6;
		private var type:String = "cube";
		private var animate:Boolean = false;
		private var cubefaces:Boolean = false;
		//private var cube_net;
		private var texture:BitmapFileMaterial;
		
		private var cube:Cube;
		
		//-----//
		private var scale_min:Number = 1;
		private var scale_max:Number = 5;
		//private var scale:Number = 4; 
		private var yaw:Number = 45;
		private var roll:Number = 0;
		private var pitch:Number = 8; 
		
		//---------frame settings--//
		private var frameDraw:Boolean = true;
		private var frameMargin:Number = 25;
		private var frameRadius:Number = 20;
		private var frameFillColor:Number = 0xFFFFFF;
		private var frameFillAlpha:Number = 0.5;
		private var frameOutlineColor:Number = 0xFFFFFF;
		private var frameOutlineStroke:Number = 2;
		private var frameOutlineAlpha:Number = 1;
		
		
		private var pitch_min:Number = -4;
		private var pitch_max:Number = 15;
		private var simpleShadow:SimpleShadow;
		private var color:uint = 0x44444444; 
		private var blur:Number = 20; 
		private var base:Number = -100; 
		private var distance:Number = 0; 
		
		private var _Width:Number = 400;
		private var _Height:Number = 400;
		
		[Embed (source="../../../../../bin/library/assets/logos/gwLogo.png")] private var myTexture:Class;
		private var myBitmap:Bitmap = new myTexture();
	
		public function TestViewer()
		{
			super();
			//blobContainerEnabled=true;
			//visible=false;
			displayComplete();
		}

		public function dipose():void
		{
			parent.removeChild(this);
		}

		override protected function displayComplete():void
		{			
			//trace("google map viewer complete");
			createUI();
			//commitUI();
		}

		override protected function createUI():void
		{
			addEventListener(Event.ENTER_FRAME,update);
			
			var _holder:TouchSprite = new TouchSprite();
				_holder.x = 500;
				_holder.y = 100;
				_holder.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
				_holder.targeting = true;
				_holder.gestureEvents = true;
				_holder.nestedTransform = true;
				_holder.disableNativeTransform = false;
				_holder.disableAffineTransform = false;
				_holder.mouseChildren = true;
			addChild(_holder);
			
			if(frameDraw)
			{							
				frame = new TouchSprite();
				frame.graphics.lineStyle(2*frameMargin, frameFillColor, frameFillAlpha);
				frame.graphics.drawRect( -frameMargin, -frameMargin, _Width + 2 * frameMargin, _Height + 2 * frameMargin);
				frame.graphics.lineStyle(2, frameFillColor,frameFillAlpha+0.5);
				frame.graphics.drawRoundRect( -2 * frameMargin, -2 * frameMargin, _Width + 4 * frameMargin, _Height + 4 * frameMargin, 2 * frameMargin, 2 * frameMargin);
				frame.graphics.lineStyle(frameOutlineStroke, frameOutlineColor,frameOutlineAlpha);
				frame.graphics.drawRect(-2, -2, _Width + 4, _Height + 4);
				frame.targetParent = true;
			_holder.addChild(frame);
			}
			
			///////////////////////////////////////////////////////////
			cam = new HoverCamera3D({zoom:100, focus:7});
            cam.hover(true);
			
			view = new View3D({x:150,y:250,camera:cam});
			//_holder.addChild(view);
			addChild(view);
			view.camera.lookAt(new Number3D(0,0,0));
			
			var myMaterial:BitmapMaterial = new BitmapMaterial(Cast.bitmap(myBitmap));
			cube = new Cube({width:120, height:120, depth:120, material:myMaterial});
			view.scene.addChild(cube);
			
			simpleShadow = new SimpleShadow(cube, color, blur, base, distance);
			simpleShadow.apply(view.scene)
			///////////////////////////////////////////////////////////

			var screen:TouchSprite = new TouchSprite();
				screen.graphics.beginFill(0xFFFFFF,0.3);
				screen.graphics.drawRoundRect(0,0,_Width,_Height,0,0);
				screen.graphics.endFill();
				//screen.nestedTransform = true;
				screen.gestureEvents = true;
				screen.gestureList = {"n-drag":true};
				screen.disableNativeTransform = true;
				screen.disableAffineTransform = true;
				screen.addEventListener(GWGestureEvent.DRAG, tilt);
				//screen.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
				//screen.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
				//screen.addEventListener(GWGestureEvent.ROTATE, gestureRotateHandler);
				//screen.addEventListener(GWGestureEvent.DOUBLE_TAP, gestureDTapHandler);
			_holder.addChild(screen);
		}
		private function update(e:Event):void
		{
			cam.tiltAngle = pitch;
			cam.panAngle = yaw;
            cam.hover();
			simpleShadow.plane;
            view.render();
		}
		
		private function tilt(e:GWGestureEvent):void 
		{
			 yaw += e.value.dx;
			 pitch += e.value.dy;
			 //trace(pitch);
			 
			 if(pitch_min<pitch<pitch_max){
			 	pitch += e.value.dy;
			}
			if(pitch<=pitch_min){
				pitch = pitch_min;
			}
			if(pitch>=pitch_max){
				pitch = pitch_max;
			}
		}
	}
}