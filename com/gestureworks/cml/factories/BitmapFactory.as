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
	
	public class BitmapFactory extends ElementFactory
	{
		public static var COMPLETE:String = "complete";	
		
		protected var loader:Loader;
		private var file:*;
		
		
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
		
		
		private var _src:String = "";
		/**
		 * Sets the file source path
		 * @default ""
		 */
		public function get src():String{return _src;}
		public function set src(value:String):void
		{
			if (src == value) return;
				_src = value;
		}
		
		
		private var img:IMG;
		public function load(url:String):void
		{
			src = url;
			img = new IMG;
			img.load(url);
			img.addEventListener(Event.COMPLETE, loadComplete)
		}
		
		private function loadBitmap(url:String):void
		{
			src = url;
			FileManager.instance.addToQueue(url, "img");
		}
				
		override public function postparseCML(cml:XMLList):void 
		{
			if (this.propertyStates[0]["src"])
				loadBitmap(this.propertyStates[0]["src"]);
		}
		
		
		public function loadComplete(event:Event=null):void
		{
			
			if (img)
			{
				file = img.loader;
			}
			else
			{
				var imageSrc:String = propertyStates[0]["src"];
				file = FileManager.instance.fileList.getKey(imageSrc).loader;				
			}
			
			
			///////////////////////////////////////////////////////////////////////////////////////// 
			/// resample image if width and/or height are provided before load command is given.
			/// we may want to make resampling something the user must turn on (e.g. resample = true)
			/// and otherwise just scale the image to the right dimensions
			/////////////////////////////////////////////////////////////////////////////////////////
			
			// scale percentages needed to achieve desired diemensions
			_percentX = 1; 
			_percentY = 1;
			
			scaleX = 1;
			scaleY = 1;
			
			//trace(_resample,file.width,file.height,_width, _height, this.propertyStates[0]["width"])
			
			if (_resample){
			
				if (width && height)
				{
					// skip resampling if not needed to avoid image degradation
					if ((width != file.width) && (height != file.height))
					{
						_percentX = width / file.width;
						_percentY = height / file.height;
					}
				}
				
				else if (width)
				{
					// skip resampling if not needed to avoid image degradation
					if (width != file.width)
					{
						_percentX = width / file.width;
						_percentY = _percentX;
					}
				}
				
				else if (height)
				{
					// skip resampling if not needed to avoid image degradation
					if (height != file.height)
					{
						_percentY = height / file.height; 										
						_percentX = _percentY;
					}
				}	
			}			
			
			if ((_percentX != 1) && (_percentY != 1))
			{
				var resizeMatrix:Matrix = new Matrix();		
				resizeMatrix.scale(_percentX, _percentY);				
				_bitmapData = new BitmapData(file.width * _percentX, file.height * _percentY, true, 0x000000);
				_bitmapData.draw(file.content, resizeMatrix);
				_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);				
			}
			
			else
			{
				if((scaleX != 1) && (scaleY != 1)){
					_bitmapData = new BitmapData(file.width*scaleX, file.height*scaleY, true, 0x000000);
					_bitmapData.draw(file.content);
					_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);
				}
				else {
					_bitmapData = new BitmapData(file.width, file.height, true, 0x000000);
					_bitmapData.draw(file.content);
					_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);
				}	
			}
			
			_bitmap.smoothing = true;
			if(!_bitmapDataCache)_bitmapData = null;
			
			// very important to set width and height!
			width = _bitmap.width*scaleX;
			height = _bitmap.height*scaleY;
		
			
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
		
			// unload loader 
			// TODO: implement unloaders
			//if (!avatar) {
				//loader.unload();
				//loader.unloadAndStop(); 
				//loader = null;
			//}
			
			
			// send complete event
			bitmapComplete();
			
			// resample base bitmap
			if ((resample) || (normalize)) 
			{
				resampleBitmapData();
			}
			
			//process avatar images
			if (avatar) 
			{
				createBitmapDataArray(); // may need to call once resample is complete // may need to send out complete when done
			}		
			
		}
		
		
		override public function displayComplete():void
		{

			
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
					/*
					if(force_height_normalize){
						reduceY = pixelSize/height;
						reduceX = reduceY;
					}
					if(force_width_normalize){
						reduceX = pixelSize/width;
						reduceY = reduceX;
					}
					*/
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
					bitmapData.draw(file.content, resizeMatrix);
						
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
		
		protected function bitmapComplete():void 
		{
			dispatchEvent(new Event(BitmapFactory.COMPLETE));
		}
		
		
		private function loaderComplete():void {}
		
		private function resampleBitmapData():void {}
		

		
		private var _bitmap:Bitmap;
		public function get bitmap():Bitmap { return _bitmap; }
		
		private var _bitmapData:BitmapData;
		public function get bitmapData():BitmapData { return _bitmapData; }
		
		private var _bitmapDataCache:Boolean = false;
		public function get bitmapDataCache():Boolean  { return _bitmapDataCache; }
		public function set bitmapDataCache(value:Boolean):void
		{
			_bitmapDataCache = value;
		}
		
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
		
		private var _percentX:Number = 1;
		public function get percentX():Number{return _percentX;}
		public function set percentX(value:Number):void
		{
			_percentX = value;
		}
		private var _percentY:Number = 1;
		public function get percentY():Number{return _percentY;}
		public function set percentY(value:Number):void
		{
			_percentY = value;
		}
		
		private var _aspectRatio:Number = 1; //square
		public function get aspectRatio():Number{return _aspectRatio;}
		public function set aspectRatio(value:Number):void
		{
			_aspectRatio = value;
		}
		
		private var _resample:Boolean = true;
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
		public function set portrait(value:Boolean):void
		{
			_portrait = value;
		}
		private var _landscape:Boolean = false;
		public function get landscape():Boolean{return _landscape;}
		public function set landscape(value:Boolean):void
		{
			_landscape = value;
		}
		
		private var _resampleHeight:Number = 1;
		public function get resampleHeight():Number{return _resampleHeight;}
		public function set resampleHeight(value:Number):void
		{
			_resampleHeight = value;
		}
		
		private var _resampleWidth:Number = 1;
		public function get resampleWidth():Number{return _resampleWidth;}
		public function set resampleWidth(value:Number):void
		{
			_resampleWidth = value;
		}
	}
}