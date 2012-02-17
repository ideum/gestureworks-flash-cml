//commented out line 374 and 394 b/c Error undefined property View

package com.gestureworks.cml.components
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
	
	 
	public class PanoramicViewer extends ComponentKit
	{
		private var _id:int;
		private var _intialize:Boolean;
		
		//------  settings ------//
		private var _source:String;
		private var _Width:Number;
		private var _Height:Number;
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
		//private var frame_thickness:Number = 50*0.5;
		//private var frame_color:Number = 0x999999;
		//private var frame_alpha:Number = 0.3;
		//----frame gestures---//
		private var frameDragGesture:Boolean = true;
		private var frameScaleGesture:Boolean = true;
		private var frameRotateGesture:Boolean = true;
		
		//[Embed (source = "../../../../../bin/library/assets/logos/gwLogo.png")] private var myTexture:Class;
		//private var myBitmap:Bitmap = new myTexture();
	
		public function PanoramicViewer()
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
			//trace("createUI");

			//--Panoramic Settings--//
			//_source = "/library/assests/panoramic/29soothsayer_ALL-OE-75.jpg"//xml.Content.Source[id].panoramicSource;
			_source = "../../../../../bin/library/assets/panoramic/29soothsayer_ALL-OE-75.jpg"
			type = "cube"//xml.Content.Source[id].panoramicType;
			
			_Width = 400;
			_Height = 400;
			
			scale_max = 2//xml.Content.Source[id].panoramicMaxScale;
			scale_min = 0.5//xml.Content.Source[id].panoramicMinScale;
			animate = false//xml.Content.Source[id].panoramicAnimate;
			cubefaces = false//xml.Content.Source[id].cubefaces == "true"?true:false;
			
			//--Frame Style--//
			frameDraw = true;//MapParser.settings.FrameStyle.frameDraw == "true"?true:false;
			frameMargin = 50;//MapParser.settings.FrameStyle.padding;
			frameRadius = 5;//MapParser.settings.FrameStyle.cornerRadius;
			frameFillColor = 0xFFFFFF//MapParser.settings.FrameStyle.fillColor1;
			frameFillAlpha = 0.6//MapParser.settings.FrameStyle.fillAlpha;
			frameOutlineColor = 0xFFFFFF//MapParser.settings.FrameStyle.outlineColor;
			frameOutlineStroke = 2//MapParser.settings.FrameStyle.outlineStroke;
			frameOutlineAlpha = 0.5//MapParser.settings.FrameStyle.outlineAlpha;
			
			//--Frame Gestures--//
			frameDragGesture= true//MapParser.settings.FrameGestures.drag == "true" ?true:false;
			frameScaleGesture=true//MapParser.settings.FrameGestures.scale == "true" ?true:false;
			frameRotateGesture=true//MapParser.settings.FrameGestures.rotate == "true" ?true:false;
			
			// ---- item holder ----//
			_holder = new TouchSprite();
				_holder.targeting = true;
				_holder.gestureEvents = true;
				_holder.nestedTransform = true;
				_holder.disableNativeTransform = false;
				_holder.disableAffineTransform = false;
				_holder.mouseChildren = true;
				_holder.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
			addChild(_holder);
			
			
			//---------- build frame ------------------------//
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
				
			//-- center window --//
			x = -_Width/2;
			y = -_Height/2
			
			if(animate)
			{
			// will override tweening in away3d
			}
			
			///////////////////////////////////////////////////////////////
			
			// create a "hovering" camera
			cam = new HoverCamera3D();
			cam.panAngle = 0;
			cam.tiltAngle = 0;
			
			// create a viewport
			view = new View3D({camera:cam,x:_Width/2,y:_Height/2});
				view.clipping = new RectangleClipping({minX:-_Width/2,minY:-_Height/2, maxX:_Width/2,maxY:_Height/2});
			_holder.addChild(view);
			
			//----------------------------------// 

			//trace(type)
			/*if(type =="sphere"){
				// add a huge surrounding sphere
				var rad = (panoramicWidth/2)*45;//80000
				//var largeSphere:Sphere = new Sphere({radius:rad,material:texture,segmentsW:14,segmentsH:28});
					largeSphere.scaleX = -1;
				view.scene.addChild(largeSphere);
			}*/
			
			if(type=="cube"){
				//---------- build cube faces ------------------------//
				//if(cubefaces){
					//cube_net = new CubicImageDisplay();
					//cube_net.id = id;
					//cube_net.addEventListener(Event.COMPLETE, netLoadComplete);
				//}
				//else{
					texture = new BitmapFileMaterial(_source);
				//}
			}
			
			///////////////////////////////////////////////////////////////////////
			
			/*
			/////////////////////////////////////////////////////////
			cam = new HoverCamera3D({zoom:100, focus:7});
            cam.hover(true);
			
			view = new View3D({x:150,y:250,camera:cam});
			_holder.addChild(view);
			view.camera.lookAt(new Number3D(0,0,0));
			
			var myMaterial:BitmapMaterial = new BitmapMaterial(Cast.bitmap(myBitmap));
			cube = new Cube({width:120, height:120, depth:120, material:myMaterial});
			view.scene.addChild(cube);
			//////////////////////////////////////////////////////////////////////////////
			*/
			
			GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, update);
			
			screen = new TouchSprite();
				screen.graphics.beginFill(0xFFFFFF,0.3);
				screen.graphics.drawRoundRect(0,0,_Width,_Height,0,0);
				screen.graphics.endFill();
				screen.nestedTransform = true;
				screen.mouseChildren = true;
				screen.gestureEvents = true;
				screen.gestureList = {"1-finger-drag":true, "2-finger-scale":true, "2-finger-rotate":true,"double_tap":true};
				screen.disableNativeTransform = true;
				screen.disableAffineTransform = true;
				screen.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
				screen.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
				screen.addEventListener(GWGestureEvent.ROTATE, gestureRotateHandler);
				screen.addEventListener(GWGestureEvent.DOUBLE_TAP, gestureDTapHandler);
			_holder.addChild(screen);
			
			
			width=_Width+frameMargin;
			height=_Height+frameMargin;
		}
	
		/*
		override protected function commitUI():void
		{						
			x = -width/2;
			y = -height/2;
		}
		override protected function updateUI():void
		{
			if( (x-(frameMargin/2)>stageWidth) || (x+width-(frameMargin/2)<0) || (y-(frameMargin/2)>stageHeight) || (y+height-(frameMargin/2)<0) )
			{
				Dispose();
			}
		}
		*/
		
		private function netLoadComplete(e:Event):void
		{
			trace("loading bitmap");
			
			if(type=="cube"){
					var mat:BitmapMaterial
					//---------- build cube faces ------------------------//
					//if(cubefaces){
						//mat = new BitmapMaterial(Cast.bitmap(cube_net.cube_bitmap));
					//}
					//else{
						mat = new BitmapMaterial(Cast.bitmap(texture));
					//}
						mat.smooth = true;
						largeCube = new Skybox6(mat);
						largeCube.quarterFaces();
					view.scene.addChild(largeCube);
					view.render();
				}
		}
		
		public function update(e:GWEvent):void
		{
        	//trace("updating render");
			
			cam.tiltAngle = pitch;
			cam.panAngle = yaw;
			cam.zoom = scale;
		    cam.hover();
				
			//// overides any clipping that may occure when objects are placed partly on stage initall y
			//view.screenClipping.minX = -_Width/2;
			//view.screenClipping.minY = -_Height/2;
			//view.screenClipping.maxX = _Width/2;
			//view.screenClipping.maxY = _Height/2;
			
		  	view.render(); 
		}
		
		// yaw and pitch control
		private function gestureDragHandler(e:GWGestureEvent):void 
		{
			//drag_const sets the relative displacement of the touch point to the rotation of the cube/sphere
			//trace("drag")
			/*
			yaw += Math.floor(e.dx/dragConst);
			pitch += Math.floor(e.dy/dragConst);
			*/
		}
		
		// scale control
		private function gestureScaleHandler(event:GWGestureEvent):void 
		{
			var dsc:Number = event.value.dsx;
			
			/*
			var dsc:Number = e.value
			var lim:Number = 0.1;
			
			//trace("scale", scale)
			if(scale_min<scale<scale_max){
				if((Math.abs(dsc)<lim)&&(dsc<0)){
			 		scale += 4*dsc;
				}
				else{
					scale += dsc;
				}
			}
			if(scale>scale_max){
				scale = scale_max;
			}
			if(scale<scale_min){
				scale = scale_min;
			}
			*/
		}
		private function gestureRotateHandler(e:GWGestureEvent):void 
		{
		}
		private function gestureDTapHandler(e:GWGestureEvent):void 
		{
		}
	}
}