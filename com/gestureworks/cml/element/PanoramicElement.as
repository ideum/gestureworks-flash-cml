package com.gestureworks.cml.element
{
	//----------------adobe--------------//
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.controllers.HoverController;
	import away3d.textures.CubeTextureBase;
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
    import away3d.primitives.SphereGeometry;
	import away3d.primitives.SkyBox
    import away3d.core.utils.Cast;
    import away3d.materials.BitmapMaterial;
	//import away3d.materials.BitmapFileMaterial;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.math.Number3D;
	import away3d.primitives.Cube;
	import away3d.materials.BitmapMaterial;
	import away3d.core.utils.Cast;
	
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;		
	
	/**
	 * PanoramicElement provides a touch-enabled, 3-Dimensional panorama using the Away3D library.
	 * The PanoramicElement has two projection types: sphere, or cube, which may be set using the projectionType attribute/property.
	 * 
	 * For a sphere projectionType, a single, spherical panoramic image needs to be provided in an ImageElement. The maximum with of the image can be up to 80,000 pixels wide. 
	 * If using CML, this ImageElement should be added between the open and close tags of the PanoramicElement to make it a child of the PanoramicElement; 
	 * in AS3 the ImageElement should be added to the PanoramicElement object as a child, and the object should be initialized after the image's Event.Complete is called.
	 * 
	 * For a cube projectionType, six cubic panorama images need to be provided in CML or AS3 in the same way as the sphere. In AS3 each image should have its Event.Complete called and
	 * added to the PanoramicElement's display list before the init() method is called. The maximum size for cubic faces is 1,670 pixels wide, and 1,670 tall. Cubic faces
	 * should be perfectly square.
	 * 
	 * The PanoramicElement will actually consist of two objects, the Away3D projection/view, and a TouchContainer which holds the projection and provides the enabled touch interaction.
	 * 
	 * The PanoramicElement has the following parameters: cubeFace, projectionType, zoomMax, zoomMin
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   pano = new PanoramicElement();
		pano.projectionType = "cube";
		pano.cubeFace = true;
		pano.width = 700;
		pano.height = 500;
		pano.x = 500;
		pano.zoomMin = 30;
		pano.zoomMax = 200;
		pano.mouseChildren = true;
		
		var touchC:TouchContainer = new TouchContainer();
		touchC.nestedTransform = false;
		touchC.gestureEvents = true;
		touchC.mouseChildren = false;
		touchC.disableAffineTransform = true;
		touchC.disableNativeTransform = true;
		touchC.gestureList = { "n-drag":true, "n-scale":true };
		touchC.init();
		
		var imageBack:ImageElement = new ImageElement();
		imageBack.open("../../../../assets/panoramic/30kabah_b.jpg");
		imageBack.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageLeft:ImageElement = new ImageElement();
		imageLeft.open("../../../../assets/panoramic/30kabah_l.jpg");
		imageLeft.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageFront:ImageElement = new ImageElement();
		imageFront.open("../../../../assets/panoramic/30kabah_f.jpg");
		imageFront.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageRight:ImageElement = new ImageElement();
		imageRight.open("../../../../assets/panoramic/30kabah_r.jpg");
		imageRight.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageUp:ImageElement = new ImageElement();
		imageUp.open("../../../../assets/panoramic/30kabah_u.jpg");
		imageUp.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageDown:ImageElement = new ImageElement();
		imageDown.open("../../../../assets/panoramic/30kabah_d.jpg");
		imageDown.addEventListener(Event.COMPLETE, imageComplete);
		
		function imageComplete(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, imageComplete);
			e.target.init();
			
			if ( counter == 5 ) {
				
				pano.addChild(imageBack);
				pano.addChild(imageLeft);
				pano.addChild(imageFront);
				pano.addChild(imageRight);
				pano.addChild(imageUp);
				pano.addChild(imageDown);
				
				pano.addChild(touchC);
				
				pano.init();
				
				addChild(pano);
			}
			else { counter++; }
		}
	 *
	 * </codeblock>
	 * @author Josh
	 */
	public class PanoramicElement extends Container
	{	
		private var panoramic:TouchContainer;
		private var faceNum:int = 0;
		
		private var cam:Camera3D;
		private var view:View3D;
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
			
			//cam = new HoverCamera3D({zoom:100, focus:7});
			cam = new Camera3D()
			var camController:HoverController = new HoverController(cam);
            //cam.hover(true);
			
			// create a viewport
			//view = new View3D({x:width/2,y:height/2,camera:cam});
				//view.camera.lookAt(new Number3D(0, 0, 0));
				//view.clipping = new RectangleClipping({minX:-width/2,minY:-height/2, maxX:width/2,maxY:height/2});
			//panoramic.addChild(view);
			
			view = new View3D();
			view.camera = cam;
			view.camera.lens = new PerspectiveLens(90);
			
			//----------------------------------// 
			
			// add a huge surrounding sphere
			if(_projectionType =="sphere"){
				
				var rad:Number = (width / 2) * 45;//80000
				mat = new BitmapMaterial(Cast.bitmap(shape_net));
				//var largeSphere:SphereGeometry = new SphereGeometry(rad, 16, 28);
				
				//var largeSphere:SphereGeometry = new Sphere({radius:rad,material:mat,segmentsW:14,segmentsH:28});
					largeSphere.scaleX = -1;
				view.scene.addChild(largeSphere);
			}
			
			if(_projectionType=="cube"){
					//mat = new BitmapMaterial(Cast.bitmap(shape_net));
					//mat.smooth = true;
					//largeCube = new Skybox6(mat);
					//largeCube.quarterFaces();
				
				var skyboxCubeMap:CubeTextureBase = new CubeTextureBase();
					
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
			//trace("drag", e.value.drag_dx, e.value.drag_dy);
			_yaw += e.value.drag_dx * DRAG_LIMITER;
			_pitch += e.value.drag_dy * DRAG_LIMITER;
		}
		
		// scale control
		private function gestureScaleHandler(event:GWGestureEvent):void 
		{
			//trace("zoom", _zoom)
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