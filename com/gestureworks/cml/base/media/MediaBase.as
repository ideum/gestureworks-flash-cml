package com.gestureworks.cml.base.media 
{
	import com.gestureworks.cml.elements.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import flash.display.Bitmap;
	import flash.events.Event;
	
	/**
	 * The base class containing abstract methods for media elements
	 * @author Ideum
	 */
	public class MediaBase extends TouchContainer
	{
		private var _src:String; 
		private var _thumbnail:Bitmap;	
		private var _thumbLoaded:Boolean;
		private var thumbScaleX:Number;
		private var thumbScaleY:Number; 
				
		protected var _isLoaded:Boolean;				
		protected var _percentLoaded:Number = 0;		
		
		/**
		 * Enables auto-generation of a media snapshot thumbnail. If undefined, the <code>thumbnail</code> attribute will reference the
		 * resulting bitmap.
		 * the <code>thumbnail</attribute>
		 * @default false
		 */		
		public var preview:Boolean;
		
		/**
		 * Sepcifies an external thumbnail image file to use in place of the media snapshot generated when the <code>preview</code> 
		 * flag is enabled.  
		 */		
		public var thumbSrc:String; 
		
		/**
		 * The width of the thumbnail. Setting one of the dimensions to zero will maintain the aspect ratio of the source bitmap
		 * (or snapshot when internally generated) relative to the non-zero dimension. If both are zero, the thumb will inherit 
		 * the dimensions of the source. 
		 * @default 0
		 */		
		public var thumbWidth:Number = 0;	
		
		/**
		 * The height of the thumbnail. Setting one of the dimensions to zero will maintain the aspect ratio of the source bitmap
		 * (or snapshot when internally generated) relative to the non-zero dimension. If both are zero, the thumb will inherit 
		 * the dimensions of the source. 
		 * @default 100
		 */				
		public var thumbHeight:Number = 100;
		
		/**
		 * Flag indicating the dimensions are cleared on close and, by extension, reassignment of the <code>src</code> attribute
		 * @default true
		 */
		public var resetDimensions:Boolean = true; 
		
		/**
		 * Dispatch playback progress events
		 * @default false
		 */
		public var playbackProgress:Boolean = false; 		
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			if (!initialized) {
				super.init();
				processSrc(src);
			}
		}
		
		/**
		 * Dispatch media status state event
		 * @param status current status
		 * @param value  value of current status
		 */
		protected function onStatus(status:String, value:*):void {
			if (status == MediaStatus.PLAYBACK_PROGRESS && !playbackProgress) {
				return; 
			}
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this, status, value));
		}
		
		/**
		 * A bitmap representation of the media element. If one is not provided, the @see #preview flag must be set to 
		 * <code>true</code> to internally generate the bitmap. The associated media object can be accessed through the 
		 * thumbnail's meta data (i.e. thumbnail.metaData["media"]);
		 */		
		public function get thumbnail():Bitmap { return _thumbnail; }
		public function set thumbnail(value:Bitmap):void {
			_thumbnail = value; 
			if (_thumbnail) {
				_thumbnail.metaData = { "media":this };
			}
		}
		
		/**
		 * Media file path
		 */
		public function get src():String { return _src; }
		public function set src(value:String):void {
			if (value == _src) {
				return; 
			}
			
			close();
			_src = value;
			processSrc(_src);
		}
		
		/**
		 * Process media source file
		 * @param	value  path to media file
		 */
		protected function processSrc(value:String):void {}
		
		/**
		 * Media loaded status
		 * @default false
		 */
		public function get isLoaded():Boolean { return _isLoaded; }			
		
		/**
		 * Percentage of bytes loaded
		 * @default 0
		 */
		public function get percentLoaded():Number { return _percentLoaded; }
		
		/**
		 * Thumbnail loaded status
		 */
		public function get thumbLoaded():Boolean { return _thumbLoaded; }
		
		/**
		 * Load progress update
		 */
		protected function loading(event:Event = null):void {
			onStatus(MediaStatus.PERCENT_LOADED, _percentLoaded);
		}
		
		/**
		 * Post-load handler
		 * @param	event
		 */
		protected function loadComplete(event:Event = null):void {
			_isLoaded = true; 			
			onStatus(MediaStatus.LOADED, _isLoaded);
			updateThumbnail();
		}
		
		/**
		 * Load or generate thumbnail
		 */
		protected function updateThumbnail():void {			
			if (thumbnail) {
				loadThumbComplete();
			}
			else{	
				//load external thumb file
				if (thumbSrc) {
					loadThumb();					
				}
				//generate snapshot 
				else if (preview) {
					generateThumb();
				}
			}
		}
		
		/**
		 * Auto-generate snapshot of the media element
		 */
		protected function generateThumb():void {				
			thumbnail = DisplayUtils.resampledBitmap(this, width, height);			
			loadThumbComplete();
		}
		
		/**
		 * Load thumb from provided source file
		 */
		private function loadThumb():void {
			//preloaded
			if (FileManager.media.getContent(thumbSrc)) {
				thumbnail = FileManager.media.getLoader(thumbSrc).rawContent; 
				loadThumbComplete();
			} 
			//load file
			else {
				var img:ImageLoader = new ImageLoader(thumbSrc);
				img.addEventListener(LoaderEvent.COMPLETE, loadThumbComplete);
				img.load();
			}			
		}	
		
		/**
		 * Thumb load complete handler
		 * @param	event
		 */
		private function loadThumbComplete(event:LoaderEvent = null):void {				
			if (event) {
				thumbnail = event.target.rawContent;
			}			
			scalePercentages();
			thumbnail = DisplayUtils.resampledBitmap(thumbnail, thumbnail.width * thumbScaleX, thumbnail.height * thumbScaleY);
			_thumbLoaded = true; 
			onStatus(MediaStatus.THUMB_LOADED, _thumbLoaded);
		}
		
		/**
		 * Calculate thumbnail scale percentages 
		 */
		private function scalePercentages():void {		
			
			if(thumbnail){
				thumbScaleX = 1;
				thumbScaleY = 1;
				
				if (thumbWidth && thumbHeight) { 
					thumbScaleX = thumbWidth / thumbnail.width;
					thumbScaleY = thumbHeight / thumbnail.height;
				}
				else if (thumbWidth) { 
					thumbScaleX = thumbScaleY = thumbWidth / thumbnail.width;
				}
				else if (thumbHeight) {
					thumbScaleY = thumbScaleX = thumbHeight / thumbnail.height;
				}			
			}
		}
		
		/**
		 * Closes media
		 */
		public function close():void {
			
			//has not been opened
			if (!initialized) {
				return; 
			}
			
			//clear source path
			_src = null;
			
			//clear thumbnail
			if(thumbnail){
				_thumbLoaded = false; 
				onStatus(MediaStatus.THUMB_LOADED, _thumbLoaded);
				thumbnail = null; 
			}
			
			//update loaded status
			_percentLoaded = 0;
			_isLoaded = false; 
			onStatus(MediaStatus.LOADED, _isLoaded);
			
			//clear dimensions
			if (resetDimensions) {
				width = 0;
				height = 0;
			}
		}
	}

}