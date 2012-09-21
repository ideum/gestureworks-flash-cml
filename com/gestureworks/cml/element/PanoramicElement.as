package com.gestureworks.cml.element
{
	//----------------adobe--------------//
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
	import com.gestureworks.cml.factories.TouchContainerFactory;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.kits.*;
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
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;		
	
	 
	public class PanoramicElement extends Container
	{	
		private var panoramic:TouchContainer;
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
		
		private const DRAG_LIMITER:Number = 0.25;
		private const SCALE_MULTIPLIER:Number = 50;
	
		public function PanoramicElement()
		{
			super();
			panoramic = new TouchContainer();
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
		
		override public function displayComplete():void
		{
			if (projectionType == "cube"){
				var counter:Number = 0;
				while (this.numChildren > 0) {
					
					if (this.getChildAt(0) is TouchContainer) {
						panoramic = TouchContainer(this.getChildAt(0));
					}
					
					if (this.getChildAt(0) is ImageElement && counter < 6) {
						cube_face.push(this.getChildAt(0));
						counter++;
					}
					this.removeChildAt(0);
				}
				
				createCubeNet();
			}
			else if (projectionType == "sphere") {
				while (this.numChildren > 0) {
					if (this.getChildAt(0) is TouchContainer) {
						panoramic = TouchContainer(this.getChildAt(0));
					}
					
					if (this.getChildAt(0) is ImageElement) {
						shape_net = Bitmap(this.getChildAt(0));
					}
					
					this.removeChildAt(0);
				}
			}

			setupUI();
		}
		
		public function init():void
		{
			displayComplete();
		}
		private function setupUI():void
		{ 
			// create a "hovering" camera
			addChild(panoramic);
			
			cam = new HoverCamera3D({zoom:100, focus:7});
            cam.hover(true);
			
			// create a viewport
			view = new View3D({x:width/2,y:height/2,camera:cam});
				view.camera.lookAt(new Number3D(0, 0, 0));
				view.clipping = new RectangleClipping({minX:-width/2,minY:-height/2, maxX:width/2,maxY:height/2});
			panoramic.addChild(view);
			
			//----------------------------------// 
			
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
			
			panoramic.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			panoramic.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
			GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, update);
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
			trace("drag", e.value.drag_dx, e.value.drag_dy);
			_yaw += e.value.drag_dx * DRAG_LIMITER;
			_pitch += e.value.drag_dy * DRAG_LIMITER;
		}
		
		// scale control
		private function gestureScaleHandler(event:GWGestureEvent):void 
		{
			trace("zoom", _zoom)
			if (_zoomMin < _zoom < _zoomMax) _zoom += event.value.scale_dsx * SCALE_MULTIPLIER;
			if (_zoom > _zoomMax) _zoom = _zoomMax;
			if (_zoom < _zoomMin) _zoom = _zoomMin;
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
		
		override public function dispose():void {
			super.dispose();
			
			GestureWorks.application.removeEventListener(GWEvent.ENTER_FRAME, update);
			panoramic.removeEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			panoramic.removeEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
			
			while (panoramic.numChildren > 0 ) {
				panoramic.removeChildAt(0);
			}
			
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			panoramic = null;
			cam = null;
			view = null;
			largeCube = null;
			cube = null;
		}
	}
}