﻿//commented out line 374 and 394 b/c Error undefined property View

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
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.events.*;
	
	//---------- gestureworks ------------//
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.element.Component;
	
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
	import away3d.core.clip.RectangleClipping;
	import away3d.core.math.Number3D;
	import away3d.primitives.Cube;
	import away3d.materials.BitmapMaterial;
	import away3d.core.utils.Cast;
	
	 
	public class PanoramicViewer extends Component
	{
		private var frame:TouchSprite;
		private var panoramic:TouchSprite;
		
		private var faceNum:int = 0;
		
		private var cam:HoverCamera3D;
		private var view:View3D;
		private var largeCube:Skybox6;
		private var cube:Cube;
		private var shape_net:Bitmap;
		private var cube_face:Array = new Array();
		private var mat:BitmapMaterial;
		
		private var _zoom:Number = 100; 
		private var _yaw:Number = 45;
		private var _roll:Number = 0;
		private var _pitch:Number = 8; 
	
		public function PanoramicViewer()
		{
			super();
		}

		override public function dispose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			//trace("panoramicViewer complete")
			initUI();
			setupUI();
		}

	
		private function initUI():void
		{
			trace("initUI");
			// check for net
			// check for faces
			
			if (_projectionType == "sphere") {
			
				shape_net = this.childList.getCSSClass("panoramic", 0).childList.getCSSClass("sphere_net", 0).bitmap;
			}
			
			if (_projectionType == "cube") {
				
				if (!cubeFace)
				{
					// build net
					shape_net = this.childList.getCSSClass("panoramic", 0).childList.getCSSClass("cube_net", 0).bitmap;
				}
				if (cubeFace)
				{
					//---------- build cube faces ------------------------//
					faceNum = this.childList.getCSSClass("panoramic", 0).childList.getCSSClass("cube_face").length
					
					if (faceNum == 6){
					
						for (var i:int = 0; i < faceNum; i++)
						{
							cube_face[i] = this.childList.getCSSClass("panoramic", 0).childList.getCSSClass("cube_face", i).bitmapData;
						}
					createCubeNet();
					}
					else trace("incorrect number of cube faces");
					
				}
			}
		}
		
		private function setupUI():void
		{ 
			trace("setupUI");
			
			// update 
			GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, update);
			
			// set frame size
			this.childList.getCSSClass("touch_frame", 0).childList.getCSSClass("frame", 0).width = width;
			this.childList.getCSSClass("touch_frame", 0).childList.getCSSClass("frame", 0).height = height;
			
			//touch container
			panoramic = this.childList.getCSSClass("panoramic", 0)
				panoramic.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
				panoramic.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
			addChild(panoramic);
			
			// create a "hovering" camera
			cam = new HoverCamera3D({zoom:100, focus:7});
            cam.hover(true);
			
			// create a viewport
			view = new View3D({x:width/2,y:height/2,camera:cam});
				view.camera.lookAt(new Number3D(0, 0, 0));
				view.clipping = new RectangleClipping({minX:-width/2,minY:-height/2, maxX:width/2,maxY:height/2});
			panoramic.addChild(view);
			
			//----------------------------------// 
			//trace(type)
			
			
			// add a huge surrounding sphere
			if(_projectionType =="sphere"){
				
				var rad:Number = (width / 2) * 45;//80000
				mat = new BitmapMaterial(Cast.bitmap(shape_net));
				var largeSphere:Sphere = new Sphere({radius:rad,material:mat,segmentsW:14,segmentsH:28});
					largeSphere.scaleX = -1;
				view.scene.addChild(largeSphere);
			}
			
			if(_projectionType=="cube"){
					mat = new BitmapMaterial(Cast.bitmap(shape_net));
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
			cam.tiltAngle = _pitch;
			cam.panAngle = _yaw;
			cam.zoom = _zoom;
			cam.hover();
				
			//// overides any clipping that may occure when objects are placed partly on stage initall y
		  	view.render(); 
		}
		
		// yaw and pitch control
		private function gestureDragHandler(e:GWGestureEvent):void 
		{
			//trace("drag")
			_yaw += e.value.dx;
			_pitch += e.value.dy;
		}
		
		// scale control
		private function gestureScaleHandler(event:GWGestureEvent):void 
		{
			//trace("zoom", _zoom)
			if (_zoomMin < _zoom < _zoomMax) _zoom += event.value.dsx;
			if (_zoom > _zoomMax) _zoom = _zoomMax;
			if (_zoom < _zoomMin) _zoom = _zoomMin;
		}
		
		private var _cubeFace:Boolean = true;
		
		/**
		 * Sets default projection geometry
		 * @default false
		 */		
		public function get cubeFace():Boolean{return _cubeFace;}
		public function set cubeFace(value:Boolean):void
		{			
			_cubeFace = value;
		}
		
		private var _projectionType:String = "cube";
		/**
		 * Sets default projection geometry
		 * @default "cube"
		 */		
		public function get projectionType():String{return _projectionType;}
		public function set projectionType(value:String):void
		{			
			_projectionType = value;
		}
		
		private var _zoomMax:Number = 150;
		/**
		 * Sets maximum zoom value of view
		 * @default 150
		 */		
		public function get zoomMax():Number{return _zoomMax;}
		public function set zoomMax(value:Number):void
		{			
			_zoomMax = value;
		}
		
		private var _zoomMin:Number = 50;
		/**
		 * Sets minumum zoom value of zoom
		 * @default 50
		 */		
		public function get zoomMin():Number{return _zoomMin;}
		public function set zoomMin(value:Number):void
		{			
			_zoomMin = value;
		}	
		
		private function createCubeNet():void {
			
			// max width = 1670
			
			var cubeWidth:Number = cube_face[0].width
			var bitmapData:BitmapData=new BitmapData(3*cubeWidth,2*cubeWidth, false, 0xFFFFFF);
			var tMatrix:Matrix;
				
				tMatrix = new Matrix(1,0,0,1,0,0);
				bitmapData.draw(cube_face[0], tMatrix);
				cube_face[0] = null;
					
				tMatrix = new Matrix(1,0,0,1,cubeWidth,0);
				bitmapData.draw(cube_face[1], tMatrix);
				cube_face[1] = null;
				
				tMatrix = new Matrix(1,0,0,1,2*cubeWidth,0);
				bitmapData.draw(cube_face[2], tMatrix);
				cube_face[2] = null;
					
				tMatrix= new Matrix(1,0,0,1,0,cubeWidth);
				bitmapData.draw(cube_face[3], tMatrix);
				cube_face[3] = null;
					
				tMatrix= new Matrix(-1,0,0,-1,2*cubeWidth,2*cubeWidth);
				bitmapData.draw(cube_face[4], tMatrix);
				cube_face[4] = null;
					
				tMatrix= new Matrix(-1,0,0,-1,3*cubeWidth,2*cubeWidth);
				bitmapData.draw(cube_face[5], tMatrix);
				cube_face[5] = null;
					
				shape_net = new Bitmap(bitmapData,PixelSnapping.NEVER,true);
				cube_face = null;				
		}
		
	}
}