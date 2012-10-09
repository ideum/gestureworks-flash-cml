package com.gestureworks.cml.element
{
	//----------------adobe--------------//
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
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
	import away3d.cameras.Camera3D;
    import away3d.containers.View3D;
    import away3d.primitives.SphereGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;
	import away3d.tools.helpers.MeshHelper;
	
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;		
	
	/**
	 * PanoramicElement provides a touch-enabled, 3-Dimensional panorama using the Away3D library.
	 * The PanoramicElement has two projection types: sphere, or cube, which may be set using the projectionType attribute/property.
	 * 
	 * For a sphere projectionType, a single, spherical panoramic image needs to be provided in an ImageElement. The maximum size of the panorama's longest edge can be no greater than 2048, and
	 * this may be set in the CML or Actionscript rather than resizing the actual image file itself.
	 * If using CML, this ImageElement should be added between the open and close tags of the PanoramicElement to make it a child of the PanoramicElement; 
	 * in AS3 the ImageElement should be added to the PanoramicElement object as a child, and the object should be initialized after the image's Event.Complete is called.
	 * 
	 * For a cube projectionType, six cubic panorama images need to be provided in CML or AS3 in the same way as the sphere. In AS3 each image should have its Event.Complete called and
	 * added to the PanoramicElement's display list before the init() method is called. Cubic faces must be sized in powers of 2. The maximum size for cubic faces is 2,048 pixels wide, and 2,048 tall. Cubic faces
	 * should be perfectly square.
	 * 
	 * The PanoramicElement will actually consist of two objects, the Away3D projection/view, and a TouchContainer which holds the projection and provides the enabled touch interaction.
	 * 
	 * The PanoramicElement has the following parameters: cubeFace, projectionType, fovMax, fovMin, src
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   pano = new PanoramicElement();
		pano.projectionType = "cube";
		pano.cubeFace = true;
		pano.width = 700;
		pano.height = 500;
		pano.x = 500;
		pano.fovMin = 30;
		pano.fovMax = 200;
		pano.mouseChildren = true;
		
		var touchC:TouchContainer = new TouchContainer();
		touchC.nestedTransform = false;
		touchC.gestureEvents = true;
		touchC.mouseChildren = false;
		touchC.disableAffineTransform = true;
		touchC.disableNativeTransform = true;
		touchC.gestureList = { "n-drag":true, "n-scale":true };
		touchC.init();
		
		var imageRight:ImageElement = new ImageElement();
		imageRight.width = 1024;
		imageRight.open("../../../../assets/panoramic/30kabah_r.jpg");
		imageRight.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageLeft:ImageElement = new ImageElement();
		imageLeft.width = 1024;
		imageLeft.open("../../../../assets/panoramic/30kabah_l.jpg");
		imageLeft.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageUp:ImageElement = new ImageElement();
		imageUp.width = 1024;
		imageUp.open("../../../../assets/panoramic/30kabah_u.jpg");
		imageUp.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageDown:ImageElement = new ImageElement();
		imageDown.width = 1024;
		imageDown.open("../../../../assets/panoramic/30kabah_d.jpg");
		imageDown.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageFront:ImageElement = new ImageElement();
		imageFront.width = 1024;
		imageFront.open("../../../../assets/panoramic/30kabah_f.jpg");
		imageFront.addEventListener(Event.COMPLETE, imageComplete);
		
		var imageBack:ImageElement = new ImageElement();
		imageBack.width = 1024;
		imageBack.open("../../../../assets/panoramic/30kabah_b.jpg");
		imageBack.addEventListener(Event.COMPLETE, imageComplete);
		
		function imageComplete(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, imageComplete);
			e.target.init();
			
			if ( counter == 5 ) {
				
				pano.addChild(imageRight);
				pano.addChild(imageLeft);
				pano.addChild(imageUp);
				pano.addChild(imageDown);
				pano.addChild(imageFront);
				pano.addChild(imageBack);
				
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
		
		private var camController:HoverController;
		private var _skyBox:SkyBox;
		private var _lens:PerspectiveLens;
		
		private var cam:Camera3D;
		private var view:View3D;
		private var cube_face:Array = new Array();
		private var shape_net:TextureMaterial;
		
		private var _fov:Number = 90; 
		private var _yaw:Number = 45;
		private var _roll:Number = 0;
		private var _pitch:Number = 8; 
		
		private const DRAG_LIMITER:Number = 0.25;
		private const SCALE_MULTIPLIER:Number = 50;
	
		/**
		 * constructor
		 */
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
		
		private var _fovMax:Number = 150;
		/**
		 * Sets maximum spread of the field of view. This is how wide the viewing angle can be. Larger means more of the panorama is seen at once,
		 * but too large can mean things can look skewed or warped, or even get turned inside out.
		 * @default 150
		 */		
		public function get fovMax():Number{return _fovMax;}
		public function set fovMax(value:Number):void
		{			
			_fovMax = value;
		}
		
		private var _fovMin:Number = 50;
		private var largeSphere:Mesh;
		/**
		 * Sets the minimum spread of the field of view. This is how narrow the viewing angle can be. Smaller means less total area of the panorama can be
		 * seen, but the viewing area that is available is in much greater detail, and appears "foved" in.
		 * @default 50
		 */		
		public function get fovMin():Number{return _fovMin;}
		public function set fovMin(value:Number):void
		{			
			_fovMin = value;
		}
		
		/**
		 * CML callback initialisation
		 */
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
				
				//createCubeNet();
			}
			else if (projectionType == "sphere") {
				while (this.numChildren > 0) {
					if (this.getChildAt(0) is TouchContainer) {
						panoramic = TouchContainer(this.getChildAt(0));
					}
					
					if (this.getChildAt(0) is ImageElement) {
						shape_net = new TextureMaterial(Cast.bitmapTexture(this.getChildAt(0)))
					}
					
					this.removeChildAt(0);
				}
			}

			setupUI();
		}
		
		/**
		 * initialisation method
		 */
		public function init():void
		{
			displayComplete();
		}
		
		private function setupUI():void
		{ 
			addChild(panoramic);
			// create a "hovering" camera
			
			cam = new Camera3D();
			camController = new HoverController(cam);
			
			// create a viewport
			_lens = new PerspectiveLens(90);
			view = new View3D();
			view.width = width;
			view.height = height;
			view.camera = cam;
			cam.lens = _lens;
			
			panoramic.addChild(view);
			
			//----------------------------------// 
			
			// add a huge surrounding sphere
			if(_projectionType =="sphere"){
				
				largeSphere = new Mesh(new SphereGeometry(this.width, 32, 32), shape_net);
				largeSphere.scaleX = -1;
				largeSphere.position = cam.position;
				
				//largeSphere.z = rad * 3 * -1;
				
				view.backgroundColor = 0x00ff00;
				
				trace("Making sphere");
				trace(view.x, view.y);
				trace(this.x, this.y);
				
				camController = null;
				
				view.scene.addChild(largeSphere);
				view.render();
			}
			
			if (_projectionType == "cube") {
				
				trace("Making cubeTexture");
				var bmCubeText:BitmapCubeTexture = new BitmapCubeTexture(Cast.bitmapData(cube_face[0]), Cast.bitmapData(cube_face[1]), Cast.bitmapData(cube_face[2]), Cast.bitmapData(cube_face[3]), Cast.bitmapData(cube_face[4]), Cast.bitmapData(cube_face[5]));
				//															right							left							up							down							front							back
				_skyBox = new SkyBox(bmCubeText);
				view.scene.addChild(_skyBox);
				view.render();
			}
			
			panoramic.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			panoramic.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
			GestureWorks.application.addEventListener(GWEvent.ENTER_FRAME, update);
		}
		
		/**
		 * updates camera angle
		 * @param	e
		 */
		public function update(e:GWEvent):void
		{
        	//trace("updating render");
			if(_skyBox){
				camController.tiltAngle = _pitch;
				camController.panAngle = _yaw;
				_lens.fieldOfView = _fov;
				camController.update();
			}
			
			if (largeSphere) {
				cam.rotateTo(_pitch, _yaw, 0);
				//cam.pitch(_pitch);
				_lens.fieldOfView = _fov;
			}
			
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
			//trace("fov", _fov)
			if (_fovMin < _fov < _fovMax) _fov -= event.value.scale_dsx * SCALE_MULTIPLIER;
			if (_fov > _fovMax) _fov = _fovMax;
			if (_fov < _fovMin) _fov = _fovMin;
		}	
		
		/**
		 * dispose methods to nullify children
		 */
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
			
			if (largeSphere)
				largeSphere = null;
			if (_skyBox)
				_skyBox = null;
			panoramic = null;
			cam = null;
			view = null;
			camController = null;
		}
	}
}