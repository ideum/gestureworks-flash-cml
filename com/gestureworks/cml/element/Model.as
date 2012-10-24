package com.gestureworks.cml.element
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.debug.*;
	import away3d.entities.Mesh;
	import away3d.events.*;
	import away3d.library.*;
	import away3d.library.assets.*;
	import away3d.lights.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	import away3d.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.element.Image;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.*;
	
	
	/**
	 * 
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
		
	 *
	 * </codeblock>
	 * 
	 * @author Josh
	 * @see Panoramic
	 */
	public class Model extends ElementFactory
	{	
		//Infinite, 3D head model
		[Embed(source="../../../../../bin/library/assets/3d/monkey.obj", mimeType="application/octet-stream")]
		private var HeadModel:Class;
		
		//Diffuse map texture
		[Embed(source="../../../../../bin/library/assets/3d/head_diffuse.jpg")]
		private var Diffuse:Class;
		
		//Specular map texture
		[Embed(source="../../../../../bin/library/assets/3d/head_specular.jpg")]
		private var Specular:Class;
		
		//Normal map texture
		[Embed(source="../../../../../bin/library/assets/3d/head_normals.jpg")]
		private var Normal:Class;
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var cameraController:HoverController;
		
		//material objects
		private var headMaterial:TextureMaterial;
		private var subsurfaceMethod:SubsurfaceScatteringDiffuseMethod;
		private var fresnelMethod:FresnelSpecularMethod;
		private var diffuseMethod:BasicDiffuseMethod;
		private var specularMethod:BasicSpecularMethod;
		
		//scene objects
		private var light:PointLight;
		private var lightPicker:StaticLightPicker;
		private var headModel:Mesh;
		private var advancedMethod:Boolean = true;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Model()
		{
			//init();
		}
		
		override public function displayComplete():void {
			super.displayComplete();
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initLights();
			//initMaterials();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.LEFT;
			
			scene = new Scene3D();
			
			camera = new Camera3D();
			
			view = new View3D();
			view.antiAlias = 4;
			view.scene = scene;
			view.camera = camera;
			
			//setup controller to be used on the camera
			cameraController = new HoverController(camera, null, 45, 10, 800);
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
		}
		
		/**
		 * Initialise the lights in a scene
		 */
		private function initLights():void
		{
			light = new PointLight();
			light.x = 15000;
			light.z = 15000;
			light.color = 0xffddbb;
			light.ambient = 1;
			lightPicker = new StaticLightPicker([light]);
			
			scene.addChild(light);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			//setup custom bitmap material
			headMaterial = new TextureMaterial(Cast.bitmapTexture(Diffuse));
			headMaterial.normalMap = Cast.bitmapTexture(Normal);
			headMaterial.specularMap = Cast.bitmapTexture(Specular);
			headMaterial.lightPicker = lightPicker;
			headMaterial.gloss = 10;
			headMaterial.specular = 3;
			headMaterial.ambientColor = 0x303040;
			headMaterial.ambient = 1;
			
			//create subscattering diffuse method
			subsurfaceMethod = new SubsurfaceScatteringDiffuseMethod(2048, 2);
			subsurfaceMethod.scatterColor = 0xff7733;
			subsurfaceMethod.scattering = .05;
			subsurfaceMethod.translucency = 4;
			headMaterial.diffuseMethod = subsurfaceMethod;
			
			//create fresnel specular method
			fresnelMethod = new FresnelSpecularMethod(true);
			headMaterial.specularMethod = fresnelMethod;
			
			//add default diffuse method
			diffuseMethod = new BasicDiffuseMethod();
			
			//add default specular method
			specularMethod = new BasicSpecularMethod();
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//default available parsers to all
			Parsers.enableAllBundled();
			
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.loadData(new HeadModel());
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			light.x = Math.sin(getTimer()/10000)*150000;
			light.y = 1000;
			light.z = Math.cos(getTimer()/10000)*150000;
			
			view.render();
		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.MESH) {
				headModel = event.asset as Mesh;
				headModel.geometry.scale(100); //TODO scale cannot be performed on mesh when using sub-surface diffuse method
				headModel.y = -50;
				headModel.rotationY = 180;
				//headModel.material = headMaterial;
				
				scene.addChild(headModel);
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Key up listener for swapping between standard diffuse & specular shading, and sub-surface diffuse shading with fresnel specular shading
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			//advancedMethod = !advancedMethod;
			//
			//headMaterial.gloss = (advancedMethod)? 10 : 50;
			//headMaterial.specular = (advancedMethod)? 3 : 1;
			//headMaterial.diffuseMethod = (advancedMethod)? subsurfaceMethod : diffuseMethod;
			//headMaterial.specularMethod = (advancedMethod)? fresnelMethod : specularMethod;
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
		}
	}
}