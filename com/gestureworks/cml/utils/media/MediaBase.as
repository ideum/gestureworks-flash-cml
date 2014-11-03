package com.gestureworks.cml.utils.media 
{
	import com.gestureworks.cml.elements.TouchContainer;
	import flash.display.Bitmap;
	
	/**
	 * The base class containing abstract methods for media elements
	 * @author Ideum
	 */
	public class MediaBase extends TouchContainer
	{
		private var _src:String; 
		protected var initialized:Boolean;	
		protected var _isLoaded:Boolean;
		protected var _percentLoaded:Number = 0;
		
		/**
		 * A bitmap representation of the media element. If one is not provided, the <code>internalThumb</code> flag must be 
		 * set to <code>true</code> to internally generate the bitmap. 
		 */		
		public var thumbnail:Bitmap;
		
		/**
		 * Enables generation of a media thumbnail
		 * @default false
		 */		
		public var internalThumb:Boolean;
		
		/**
		 * Sepcifies an thumbnail source path to use in place of the default snapshot. The <code>internalThumb</code> 
		 * flag must be enabled. 
		 */		
		public var internalThumbSrc:String; 
		
		/**
		 * Scale to apply to internal thumb
		 * @default .25
		 */		
		public var internalThumbScale:Number = .25;	
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			super.init();
			if (!initialized) {
				initialized = true; 
				processSrc(src);
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
		protected function processSrc(value:String):void { }
		
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
		 * Closes media
		 */
		public function close():void {
			_src = null;
		}
	}

}