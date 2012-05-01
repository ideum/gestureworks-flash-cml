package com.gestureworks.cml.element
{

	import com.gestureworks.core.TouchSprite;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	

	public class MagnifierElement extends Sprite
	{
		
		[Embed(source="../../../../../projects/CollectionViewerMaxwell/lib/magnify.pbj", mimeType="application/octet-stream")]
		private static var Magnifier:Class;		

		private const ZERO_POINT:Point = new Point();
		
		private var loader:URLLoader;
		private var shader:Shader;
		private var sphereFilter:ShaderFilter;	
		private var initiated:Boolean = false;
		
		
		
		public var bitmapData:BitmapData;
		
		private var canvas:BitmapData 
		private var canvasContainer:Bitmap;

		private var position:Point = new Point();

		
		
		
		public function MagnifierElement(radius:Number=100, position:Point=null, bitmapData:BitmapData=null)
		{			
			canvas = new BitmapData(radius * 2, radius * 2, false, 0x0);
		
			if (bitmapData) 
				this.bitmapData = bitmapData;
			else 
				bitmapData = new BitmapData(512, 512);
				
			//this.buttonMode = false
			//this.mouseEnabled = false
			this.mouseChildren = false;
			
			initShader();
			initMagnifyingGlass();			
		}
		
		
		
		
		
		////////////////////////////////////////////
		// Public Properties
		////////////////////////////////////////////
		
		
		/**
		 * Sets the x value
		 * @default 100
		 */
		override public function get x():Number{return super.x;}
		override public function set x(value:Number):void
		{
			super.x = value;
			position.x = value;
			update();
		}			
		
		
		/**
		 * Sets the y value
		 * @default 100
		 */
		override public function get y():Number{return super.y;}
		override public function set y(value:Number):void
		{
			super.y = value;
			position.y = value;
			update();
		}	
		
		
		private var _radius:Number = 100;
		/**
		 * Sets the radius of the magnifying glass
		 * @default 100
		 */
		public function get radius():Number{return _radius;}
		public function set radius(value:Number):void
		{
			_radius = value;
			
			/*
			if (initiated) {
				
				canvas.dispose();
				canvas = null;
				canvas = new BitmapData(value * 2, value * 2, false, 0x0);
				canvasContainer.bitmapData = canvas;
				sphereFilter = new ShaderFilter(shader);
				updateShaderParams();
				updateShader();
			}
			
			*/
		}		
		

		private var _magnification:Number = 2.5;
		/**
		 * Sets the magnification amount
		 * @default 2.5
		 */
		public function get magnification():Number{return _magnification;}
		public function set magnification(value:Number):void
		{
			_magnification = value;
			if (initiated) {
				updateShaderParams();
				updateShader();
			}
		}			
		
		
		
		////////////////////////////////////////////
		// Public Methods
		////////////////////////////////////////////
		
		
		/**
		 * re-renders magnifier
		 */
		public function update():void
		{
			if (initiated)
				updateShader();
		}		
		
		
		
		////////////////////////////////////////////
		// Private Properties
		////////////////////////////////////////////		

		
		private function initShader():void
		{
			shader = new Shader(new Magnifier)
			updateShaderParams()
		}
		
		
		private function initMagnifyingGlass():void
		{
			//Add the canvas bitmapdata to the canvasContainer bitmap
			canvasContainer = new Bitmap(canvas)
			addChild(canvasContainer)
	
			//Set the centre of the canvas container to 0,0
			canvasContainer.x = -radius
			canvasContainer.y = -radius

			sphereFilter = new ShaderFilter(shader);
			initiated = true;
			updateShader();
		}
		

		
		private function updateShaderParams():void
		{			
			shader.data.center.value = [radius, radius];
			shader.data.innerRadius.value = [radius];
			shader.data.outerRadius.value = [radius];
			shader.data.magnification.value = [magnification];			
		}
		

		private function updateShader():void
		{			
			//Copy the pixels underneath the magnifying glass
			canvas.copyPixels(bitmapData, new Rectangle(position.x - radius, position.y - radius, radius * 2, radius * 2), ZERO_POINT);
			canvasContainer.filters = [sphereFilter];
		}
		

	}
}