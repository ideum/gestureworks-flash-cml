package com.gestureworks.cml.factories 
{	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	
	import com.gestureworks.cml.managers.FileManager; 
	
	public class BitmapFactory extends ElementFactory
	{
		protected var loader:Loader;
		public static var COMPLETE:String = "complete";	
		
		private var file:*;
		
		public function BitmapFactory() 
		{
			super();
			
			mouseChildren = false;
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
			trace("________________________________________hegiht" + height);
			
			_height = value;
			super.height = value;
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
		
		override public function displayComplete():void
		{
			var imageSrc:String = propertyStates[0]["src"];
			file = FileManager.instance.fileList.getKey(imageSrc).loader;
			
			var resizeMatrix:Matrix = new Matrix();
			

			if (width != 0 && height != 0)
			{
				_percentX = _width / file.width;
				_percentY = _height / file.height;				
			}
			else if (width != 0)
			{				
				_percentX = _width / file.width;
				_percentY = _percentX;			
			}	
			else if (height != 0)
			{
				_percentY = _height / file.height; 										
				_percentX = _percentY;
			}
			else 
			{
				_percentX = 1;
				_percentY = 1;
			}
			
			resizeMatrix.scale(_percentX, _percentY);				
			
			_bitmapData = new BitmapData(file.width, file.height, true, 0x000000);
			_bitmapData.draw(file.content, resizeMatrix);
			
			_bitmap = new Bitmap(_bitmapData,PixelSnapping.NEVER, true);
			_bitmap.smoothing=true;

			width = _bitmap.width*_percentX;
			height = _bitmap.height * _percentY;
			
			
			_aspectRatio = width / height;
			//trace(width, height);
			
			// establish orientation
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
		
		
		private function createBitmapDataArray():void
		{
			var avatarNum:int = _sizeArray.length;
			var resizeMatrix:Matrix
			var bitmapData:BitmapData
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
			
			// check for dim value
			// check for dim match
			// 
						
			
			
		}
		
		private function loaderComplete():void
		{			

		}
		
		private function resampleBitmapData():void
		{
			
		}
		
		protected function bitmapComplete():void 
		{
			dispatchEvent(new Event(BitmapFactory.COMPLETE));
			//trace(this);
		}
		
		private var _bitmap:Bitmap;
		public function get bitmap():Bitmap { return _bitmap; }
		
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
		
		private var _bitmapData:BitmapData;
		public function get bitmapData():BitmapData { return _bitmapData; }
		
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
		
		private var _normalize:Boolean = true;
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
		
		
		
		
		
		// default avatar display icon
	}
}