package com.gestureworks.cml.elements 
{	
	import com.gestureworks.cml.base.media.MediaBase;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	
	/** 
	 * The ImageNew class loads and displays an external bitmap file.	 
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock "> 
		
		var img:Image = new Image();
		img.src = "path/to/image.png";
		img.init();
		addChild(img);
		
	 *	</codeblock> 
	 * 
	 * @author Ideum
	 */	  	
	public class Image extends MediaBase
	{			
		private var img:ImageLoader;	
		
		private var _fileData:Bitmap;		
		private var _bitmap:Bitmap;	
		private var _bitmapData:BitmapData;		
		private var _resample:Boolean = true;	
		private var _portrait:Boolean;
		private var _landscape:Boolean;
		private var _aspectRatio:Number = 0;			
		
		/**
		 * Constructor
		 */
		public function Image() {
			super();
		}			
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			super.init();
		}
		
		/**
		 * Load image file at provided source path
		 * @param	value  path to file
		 */
		override protected function processSrc(value:String):void {
			if (!initialized) {
				return; 
			}
			
			//abort process
			if (!value || !value.length) {
				return; 
			}			
						
			//preloaded
			if (FileManager.media.getContent(value)) {
				loadComplete();
			} 
			//load file
			else {
				img = new ImageLoader(value);
				img.addEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.addEventListener(LoaderEvent.PROGRESS, loading);
				img.addEventListener(LoaderEvent.ERROR, onError);
				img.load();
			}							
		}
		
		/**
		 * Bitmap loaded from file
		 */
		public function get fileData():Bitmap { return _fileData; };

		/**
		 * Reference to the currently loaded bitmap
		 */			
		public function get bitmap():Bitmap { return _bitmap; }
		public function set bitmap(b:Bitmap):void { 
			_bitmap = b; 
		}
		
		/**
		 * Reference to the currently loaded bitmapData
		 */				
		public function get bitmapData():BitmapData { return _bitmapData; }
		public function set bitmapData(b:BitmapData):void { 
			_bitmapData = b;
		}		
		
		/**
		 * Specifies whether the image is resampled to the provided width and/or height. In order for resampling to work, 
		 * this must be set to true, and a width and/or height must be set prior to calling open.
		 * @default true
		 */
		public function get resample():Boolean{ return _resample; }
		public function set resample(value:Boolean):void{
			_resample = value;
		}				
		
		/**
		 * Flag indicating the image has a portrait layout
		 * @default false
		 */
		public function get portrait():Boolean{return _portrait;}
		
		/**
		 * Flag indicating the image has a landscape layout
		 * @default false
		 */
		public function get landscape():Boolean{return _landscape;}								
				
		/**
		 * Aspect ratio (width/height) 
		 */
		public function get aspectRatio():Number { return _aspectRatio; }
		
		/**
		 * Outputs loader error event
		 * @param	event
		 */
		private function onError(event:LoaderEvent):void{
			trace("Error occured with "+ event.target+": "+event.text);
		}	
		
		/**
		 * @inheritDoc
		 */
		override protected function loading(event:Event = null):void {
			_percentLoaded = event.target.progress; 									
			super.loading(event);
		}
		
		/**
		 * Process loaded bitmap data
		 */		
		override protected function loadComplete(event:Event = null):void {				
			
			//retrieve file data
			if (img && img.rawContent){
				_fileData = img.rawContent;
				img.removeEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.removeEventListener(LoaderEvent.PROGRESS, loading);
				img.removeEventListener(LoaderEvent.ERROR, onError);
			}
			else if(FileManager.hasFile(src)){
				src = src ? src : state[0]["src"];					
				img = ImageLoader(FileManager.media.getLoader(src));
				_fileData = img.rawContent;		
			}
			
			//size bitmap
			_bitmap = DisplayUtils.resampledBitmap(_fileData, width, height);
			_bitmapData = _bitmap.bitmapData;

			//update dimensions
			width = _bitmap.width * scaleX;
			height = _bitmap.height * scaleY;			
										
			// establish orientation			
			_aspectRatio = width / height;
			_portrait = _aspectRatio <= 1; 
			_landscape = _aspectRatio > 1; 
			
			//add bitmap child
			_bitmap.smoothing = true;
			addChild(_bitmap);
			
			//update loaded state
			bitmapComplete();							
		}	
						
		/**
		 * Resize loaded image to the provided dimensions. Setting one of the dimensions to zero (or NaN), maintains the aspect ratio relative
		 * to the non-zero dimension. Setting both values to 0, sets dimension to the resolution of the loaded image file. 
		 * @param	w  resize width
		 * @param	h  resize height
		 */
		public function resize(w:Number = 0, h:Number = 0):void {
			if (resample && isLoaded) {		
			
				//update bitmap
				removeChild(_bitmap);				
				_bitmap = DisplayUtils.resampledBitmap(fileData, w, h);
				_bitmapData = _bitmap.bitmapData;
				addChild(bitmap);
				
				//update dimensions
				width = _bitmap.width;
				height = _bitmap.height;
				
				// establish orientation			
				_aspectRatio = width / height;
				_portrait = _aspectRatio <= 1; 
				_landscape = _aspectRatio > 1; 				
			}			
		}		
		
		/**
		 * Update loaded state 
		 */
		protected function bitmapComplete():void 
		{
			if (img) {
				img.removeEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.removeEventListener(LoaderEvent.PROGRESS, loading);
				img.removeEventListener(LoaderEvent.ERROR, onError);				
				img = null;				
			}
			
			super.loadComplete();
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function close():void {
			if (!initialized) {
				return; 
			}
			
			super.close();
			_aspectRatio = 0;
			_landscape = false;
			_portrait = false;
			
			if (_bitmapData){
				_bitmapData.dispose();
				_bitmapData = null;
			}
			
			if (_bitmap) {
				removeChild(_bitmap)
				if(_bitmap.bitmapData){
					_bitmap.bitmapData.dispose();
				}
				_bitmap = null;
			}
		}		
		
		/**
		 * Returns an Image clone
		 * @return
		 */
		override public function clone():* 
		{
			cloneExclusions.push("bitmap","bitmapData");
			var clone:Image = CloneUtils.clone(this, parent, cloneExclusions, true);
			
			if (bitmapData) {			
				clone.bitmapData = bitmapData.clone();
				clone.bitmap = new Bitmap(clone.bitmapData, PixelSnapping.NEVER, true);	
				DisplayUtils.removeAllChildrenByType(clone, [Bitmap]);
				clone.addChild(clone.bitmap);
			}	
			
			clone.init();
			
			return clone;			
		}
		
		/**
		 * @inheritDoc
		 */
	    override public function dispose():void
		{
			super.dispose();
				
   			if (img) {
				img.removeEventListener(LoaderEvent.COMPLETE, loadComplete);
				img.dispose();
				img = null;
			}
			
			_bitmap = null;
			_bitmapData = null;
			_fileData = null;
		}		
		
	}
}