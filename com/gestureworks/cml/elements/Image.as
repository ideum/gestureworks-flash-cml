package com.gestureworks.cml.elements 
{	
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.managers.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.events.*;	
	
	/** 
	 * The Image class loads and displays an external bitmap file.	 
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock "> 
		
		var img:Image = new Image();
		img.src = "my_image.png";
		img.init();
		addChild(img);
		
	 *	</codeblock> 
	 * 
	 * @author Ideum
	 */	  	
	public class Image extends TouchContainer
	{		
		// image file loader
		public var img:ImageLoader;
		
		// loaded bitmap data from file
		public var fileData:Bitmap;
		
		/**
		 * Constructor
		 */
		public function Image() 
		{
			super();	
			mouseChildren = false;
		}
			
		
		/**
		 * Initialisation method
		 */
		override public function init():void 
		{
		}	
		
		/**
		 * @inheritDoc
		 */
	    override public function dispose():void
		{
			super.dispose();
			fileData = null; 
			_sizeArray = null;
			_bitmapArray = null;
			_bitmapDataArray = null; 
				
   			if (img) {
				img.removeEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.dispose();
				img = null;
			}
			
			_bitmap = null;
			_bitmapData = null;
		}
		
		/**
		 * Returns a clone of this Image
		 * @return
		 */
		override public function clone():* 
		{
			var clone:Image = CloneUtils.clone(this, null);
			
			if (bitmapData) {			
				clone.bitmapData = bitmapData.clone();
				clone.bitmap = new Bitmap(clone.bitmapData, PixelSnapping.NEVER, true);				
			}	
			
			return clone;			
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
		public function set bitmap(b:Bitmap):void 
		{ 
			_bitmap = b; 
		}
		
	
		private var _bitmapData:BitmapData;
		/**
		 * Stores a reference to the currently loaded bitmapData
		 * @default null
		 */				
		public function get bitmapData():BitmapData { return _bitmapData; }
		public function set bitmapData(b:BitmapData):void 
		{ 
			_bitmapData = b;
		}
		
	
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
		/**
		 * specifies whether loaded image is normalised or not
		 * @default false
		 */
		public function get normalize():Boolean{return _normalize;}
		public function set normalize(value:Boolean):void
		{
			_normalize = value;
		}
		
		private var _avatar:Boolean = false;
		/**
		 * sets the avatar value
		 * @default false
		 */
		public function get avatar():Boolean{return _avatar;}
		public function set avatar(value:Boolean):void
		{
			_avatar = value;
		}
		
		
		private var _portrait:Boolean = false;
		/**
		 * specifies whether the loaded image is portrait or not
		 * @default false
		 */
		public function get portrait():Boolean{return _portrait;}
		
		
		private var _landscape:Boolean = false;
		/**
		 * specifies whether the loaded image is landscape or not
		 * @default false
		 */
		public function get landscape():Boolean{return _landscape;}
	
		
		private function resampleBitmapData():void {}
	
		
		private var _bitmapArray:Array = new Array();
		/**
		 * stores images in an array
		 */
		public function get bitmapArray():Array {return _bitmapArray;}
		
		//private var _sizeArray:Array = new Array(20, 50, 100, 200, 400, 800, 1200, 1600); // default size array list
		private var _sizeArray:Array = new Array(20, 50, 100, 200); // default size array list
		/**
		 * stores array list size 
		 */
		public function get sizeArray():Array {return _sizeArray;}
		public function set sizeArray(value:Array):void
		{
			_sizeArray = value;
		}
		
		protected var _bitmapDataArray:Array;
		/**
		 * stores bitmap data array
		 */
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
		public function open(file:String=null):void
		{
			if(file)
				src = file;
				
			if (FileManager.media.getContent(src)) {
				loadComplete();
			} 
			else {
				img = new ImageLoader(src);
				img.addEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.addEventListener(LoaderEvent.PROGRESS, onPercentLoad);
				img.addEventListener(LoaderEvent.ERROR, onError);
				img.load();
			}
		}	
		
		
		public var percentLoaded:Number;
		protected function onPercentLoad(event:LoaderEvent):void
		{
			/*if (event.property == "percentLoaded") {
				percentLoaded = event.value;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "percentLoaded", percentLoaded, true, true));
			}*/
		}
		
		/**
		 * Dispatches load error state event
		 * @param	event
		 */
		private function onError(event:LoaderEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "loadError", event.text));
		}		
		
		/**
		 * Closes the currently open image file
		 */
		public function close():void
		{
			isLoaded = false;
			//_src = null;
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
				_bitmap.bitmapData.dispose();
				_bitmap = null;
			}
				
		}		
		
		
		/**
		 * This is called when the image is loaded. Do not override this method.
		 */		
		public function loadComplete(event:Event=null):void
		{	
			if (img && img.rawContent)
			{
				fileData = img.rawContent;
				img.removeEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.removeEventListener(LoaderEvent.PROGRESS, onPercentLoad);
			}
			else
			{
				var imageSrc:String;
				
				if (src)
					imageSrc = src;
				else
					imageSrc = state[0]["src"];
					
				if (!FileManager.hasFile(imageSrc))
					return;
				
				img = ImageLoader(FileManager.media.getLoader(imageSrc));
				fileData = img.rawContent;		
			}

			
			// scale percentages needed to achieve desired diemensions
			var percentX:Number = 1; 
			var percentY:Number = 1;
			

			if (width && height)
			{
				if (width != fileData.width) {
					percentX = width / fileData.width;
				}
				if (height != fileData.height) {
					percentY = height / fileData.height;
				}
			}
			
			else if (width)
			{
				if (width != fileData.width)
				{
					percentX = width / fileData.width;
					percentY = percentX;
				}
			}
			
			else if (height)
			{
				if (height != fileData.height)
				{
					percentY = height / fileData.height; 										
					percentX = percentY;
				}
			}	
			
			if (resample && (percentX != 1) && (percentY != 1))
			{
				var resizeMatrix:Matrix = new Matrix();		
				resizeMatrix.scale(percentX, percentY);				
				_bitmapData = new BitmapData(fileData.width * percentX, fileData.height * percentY, true, 0x000000);
				_bitmapData.draw(fileData, resizeMatrix);
				_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);
				resizeMatrix = null;
			}			
			else
			{	
				_bitmapData = new BitmapData(fileData.width, fileData.height, true, 0x000000);
				_bitmapData.draw(fileData);
				_bitmap = new Bitmap(_bitmapData, PixelSnapping.NEVER, true);
				
				scaleX *= percentX;
				scaleY *= percentY;
			}

		
			
						
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
			
			
			_bitmap.smoothing = true;
			addChild(_bitmap);
				
			
			
			
			// Do this if it loaded itself. If using the preloader, the preloader handles unloading
			if (img &&  !_bitmapDataCache) 
			{
				//img.dispose(); --> disposing this will not allow suplicate src(s) across images.
				img = null;
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
		
		
		
		public function resize():void
		{
			// scale percentages needed to achieve desired diemensions
			var percentX:Number = 1; 
			var percentY:Number = 1;
								
			if (width && height)
			{
				if ((width != bitmap.width) && (height != bitmap.height))
				{
					percentX = width / bitmap.width;
					percentY = height / bitmap.height;
				}
			}
			
			else if (width)
			{
				if (width != bitmap.width)
				{
					percentX = width / bitmap.width;
					percentY = percentX;
				}
			}
			
			else if (height)
			{
				if (height != bitmap.height)
				{
					percentY = height / bitmap.height; 										
					percentX = percentY;
				}
			}	
			
			if (resample && (percentX != 1) && (percentY != 1))
			{
				var resizeMatrix:Matrix = new Matrix();		
				resizeMatrix.scale(percentX, percentY);				
				bitmapData = new BitmapData(bitmap.width * percentX, bitmap.height * percentY, true, 0x000000);
				bitmap = new Bitmap(bitmapData, PixelSnapping.NEVER, true);
				this.transform.matrix = resizeMatrix;
				resizeMatrix = null;
			}			
		
			
			// very important to set width and height!
			width = bitmap.width;
			height = bitmap.height;
			
		}		
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		// Protected Methods
		////////////////////////////////////////////////////////////////////////////////
	
		protected function bitmapComplete():void 
		{
			isLoaded = true;
			dispatchEvent(new Event(Event.COMPLETE, false, false));
			dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "isLoaded", isLoaded));
		}
	
		public var isLoaded:Boolean = false;

		////////////////////////////////////////////////////////////////////////////////
		// Private Methods
		////////////////////////////////////////////////////////////////////////////////		
				
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
					bitmapData.draw(fileData, resizeMatrix);
						
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