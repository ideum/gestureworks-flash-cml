////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File: BitmapFactory.as
//  Authors: Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.factories 
{	
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	/** 
	 * The BitmapFactory class load and stores bitmap data, usually in the form an external image file
	 * 
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * @langversion 3.0
	 *
	 * @see com.gestureworks.cml.factories.ElementFactory
	 * @see com.gestureworks.cml.factories.ObjectFactory
	 */	 	
	public class BitmapFactory extends ElementFactory
	{		
		// image file loader
		private var img:IMG;
		
		// loaded bitmap data from file
		private var fileData:*;
		
		public function BitmapFactory() 
		{
			super();	
			mouseChildren = false;
		}
			
		
		private var _width:Number = 0;
		/**
		 * Sets width of the display object in pixels
		 * @default 0
		 */
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			super.width = value;
		}
		
		
		private var _height:Number = 0;
		/**
		 * Sets width of the display object in pixels
		 * @default 0
		 */		
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{			
			_height = value;
			super.height = value;
		}			
		
		
		private var _src:String;
		/**
		 * Sets the file source path
		 * @default null
		 */
		public function get src():String{return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;
				_src = value;
		}

		
		private var _bitmap:Bitmap;
		/**
		 * Stores a reference to the currently loaded bitmap
		 * @default null
		 */			
		public function get bitmap():Bitmap { return _bitmap; }
		
	
		private var _bitmapData:BitmapData;
		/**
		 * Stores a reference to the currently loaded bitmapData
		 * @default null
		 */				
		public function get bitmapData():BitmapData { return _bitmapData; }
		
	
		private var _bitmapDataCache:Boolean = false;
		/**
		 * Specifies whether the bitmapData is cached or not
		 * @default false
		 */				
		public function get bitmapDataCache():Boolean  { return _bitmapDataCache; }
		public function set bitmapDataCache(value:Boolean):void
		{
			_bitmapDataCache = value;
		}			
		
		
		private var _resample:Boolean = false;
		/**
		 * Specifies whether a loaded image is resampled to the provided width and/or height.
		 * In order for resampling to work, this must be set to true, and a width and/or height 
		 * must be set prior to calling open.
		 * @default false
		 */
		public function get resample():Boolean{return _resample;}
		public function set resample(value:Boolean):void
		{
			_resample = value;
		}		
			
	
		private var _normalize:Boolean = false;
		public function get normalize():Boolean{return _normalize;}
		public function set normalize(value:Boolean):void
		{
			_normalize = value;
		}
		
		
		private var _avatar:Boolean = false;
		public function get avatar():Boolean{return _avatar;}
		public function set avatar(value:Boolean):void
		{
			_avatar = value;
		}
		
		
		private var _portrait:Boolean = false;
		public function get portrait():Boolean{return _portrait;}
		
		
		private var _landscape:Boolean = false;
		public function get landscape():Boolean{return _landscape;}
	
		
		private function resampleBitmapData():void {}
	
		
		private var _bitmapArray:Array = new Array();
		public function get bitmapArray():Array {return _bitmapArray;}
		
		//private var _sizeArray:Array = new Array(20, 50, 100, 200, 400, 800, 1200, 1600); // default size array list
		private var _sizeArray:Array = new Array(20, 50, 100, 200); // default size array list
		
		
		public function get sizeArray():Array {return _sizeArray;}
		public function set sizeArray(value:Array):void
		{
			_sizeArray = value;
		}
		
		private var _bitmapDataArray:Array;
		public function get bitmapDataArray():Array { return _bitmapDataArray; }
		
		
		
		private var _aspectRatio:Number = 0;
		/**
		 * Stores the aspectRatio of the currently loaded image
		 * @default 0
		 */
		public function get aspectRatio():Number{return _aspectRatio; }
		
		
		////////////////////////////////////////////////////////////////////////////////
		// Public Methods
		////////////////////////////////////////////////////////////////////////////////
		
		
		/**
		 * Opens an external image file
		 * @param	file
		 */
		public function open(file:String):void
		{
			src = file;
			img = new IMG;
			img.load(file);
			img.addEventListener(Event.COMPLETE, loadComplete);
		}	
		
		
		[Deprecated(replacement="open()")] 
		public function load(file:String):void
		{
			open(file);
		}
		
		
		/**
		 * Closes the currently open image file
		 */
		public function close():void
		{
			_src = null;
			_aspectRatio = 0;
			_landscape = false;
			_portrait = false;
			
			if (_bitmapData && !_bitmapDataCache)
			{
				_bitmapData.dispose();
				_bitmapData = null;
			}
			
			if (_bitmap) {
				if (contains(_bitmap))
					removeChild(_bitmap)
				_bitmap = null;
			}
				
		}		
		
		
		/**
		 * This is called by the CML parser. Do not override this method.
		 */		
		override public function postparseCML(cml:XMLList):void 
		{
			if (this.propertyStates[0]["src"])
				preloadFile(this.propertyStates[0]["src"]);
		}
		
		
		/**
		 * This is called when the image is loaded. Do not override this method.
		 */		
		public function loadComplete(event:Event=null):void
		{
			if (img)
			{
				fileData = img.loader;
			}
			else
			{
				var imageSrc:String;
				if (src.length < 3)
					imageSrc = propertyStates[0]["src"];
				else
					imageSrc = src;				
				fileData = FileManager.instance.fileList.getKey(imageSrc).loader;				
			}

			
			// scale percentages needed to achieve desired diemensions
			var percentX:Number = 1; 
			var percentY:Number = 1;
			
			
			// Commenting out this below - I'm not sure why we were resetting the scale to one here,
			// and thus nullifying the user scaling
			
			//scaleX = 1;
			//scaleY = 1;

			
			if (_resample)
			{
				if (width && height)
				{
					// skip resampling if not needed to avoid image degradation
					if ((width != fileData.width) && (height != fileData.height))
					{
						percentX = width / fileData.width;
						percentY = height / fileData.height;
					}
				}
				
				else if (width)
				{
					// skip resampling if not needed to avoid image degradation
					if (width != fileData.width)
					{
						percentX = width / fileData.width;
						percentY = percentX;
					}
				}
				
				else if (height)
				{
					// skip resampling if not needed to avoid image degradation
					if (height != fileData.height)
					{
						percentY = height / fileData.height; 										
						percentX = percentY;
					}
				}	
			}			
			
			if ((percentX != 1) && (percentY != 1))
			{
				var resizeMatrix:Matrix = new Matrix();		
				resizeMatrix.scale(percentX, percentY);				
				_bitmapData = new BitmapData(fileData.width * percentX, fileData.height * percentY, true, 0x000000);
				_bitmapData.draw(fileData.content, resizeMatrix);
				_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);
				resizeMatrix = null;
			}
			
			// this used to contain a clause for scale, but it was counter-acting and the result was no scale
			else
			{
				_bitmapData = new BitmapData(fileData.width, fileData.height, true, 0x000000);
				_bitmapData.draw(fileData.content);
				_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);
			}
			
			_bitmap.smoothing = true;
			
			
			
			// very important to set width and height!
			width = _bitmap.width * scaleX;
			height = _bitmap.height * scaleY;
		
			
			// establish orientation			
			_aspectRatio = width / height;
			
			
			if (_aspectRatio > 1) 
			{
				_portrait = true;
				_landscape = false;
			}
			else 
			{
				_portrait = false;
				_landscape = true; 
			}
			
			addChild(_bitmap);
				
			
			
			
			// Do this if it loaded itself. If using the preloader, the preloader handles unloading
			if (img &&  !_bitmapDataCache) 
			{
				fileData.unload();
				fileData.unloadAndStop();
				fileData = null;
			}
			
			
			// send complete event
			
			// resample base bitmap
			if ((resample) || (normalize)) 
			{
				//resampleBitmapData();
			}
			
			//process avatar images
			if (avatar) 
			{
				createBitmapDataArray(); // may need to call once resample is complete // may need to send out complete when done
			}
			
			bitmapComplete();			
		}		
		
		/**
		 * This is called by the CML parser. Do not override this method.
		 */
		override public function displayComplete():void {}		
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		// Protected Methods
		////////////////////////////////////////////////////////////////////////////////
	
		protected function bitmapComplete():void 
		{
			// listen like this: imageElement.addEventListener(Event.COMPLETE, onComplete);		
			dispatchEvent(new Event(Event.COMPLETE, true, true));
		}
	
		

		////////////////////////////////////////////////////////////////////////////////
		// Private Methods
		////////////////////////////////////////////////////////////////////////////////		
		
		public function preloadFile(file:String):void
		{
			src = file;
			FileManager.instance.addToQueue(file, "img");
		}
		
		
	
			
		private function createBitmapDataArray():void
		{
			var avatarNum:int = _sizeArray.length;
			var resizeMatrix:Matrix;
			var bitmapData:BitmapData;
			var reduceX:Number = 1;
			var reduceY:Number = 1;
			
			// loop thru standard sizeArray
			for (var i:int=0; i<avatarNum; i++)
			{	
				//trace("sizeArray:",i,_sizeArray[i])
				
				if((width)&&(height)){
			
				var	pixelSize:Number = sizeArray[i];
					
				//	if(force_height_normalize){
				//		reduceY = pixelSize/height;
				//		reduceX = reduceY;
				//	}
				//	if(force_width_normalize){
				//		reduceX = pixelSize/width;
				//		reduceY = reduceX;
				//	}
				
					//if((!force_width_normalize)&&(!force_height_normalize)){
					if(width>height){ //landscape
							reduceX = pixelSize/width;
							reduceY = reduceX;
						}
						else if(width<=height){ //portrait or square
							reduceY = pixelSize/height;
							reduceX = reduceY;
						}
					//generate multitple resize matrixces
					resizeMatrix = new Matrix();
					resizeMatrix.scale(reduceX, reduceY);
					// resize bitmap data
					bitmapData = new BitmapData(width * reduceX, height * reduceY);
					bitmapData.draw(fileData.content, resizeMatrix);
						
					_bitmap = new Bitmap(bitmapData,PixelSnapping.NEVER,true);
					_bitmap.smoothing=true;
					
					bitmapData = null;
					// add the bitmap objects to a list 
					bitmapArray[i] = _bitmap;
					//bitmapArray[i].visible = false
					bitmapArray[i].y = 50 * i;
					addChild(bitmapArray[i]);
				}
			}
		}
		
	}
}