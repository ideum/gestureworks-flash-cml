package com.gestureworks.cml.element
{
	import com.greensock.TweenLite;
	import flash.events.TimerEvent;
	import flash.events.Event;

	/**
	 * The ImageSlideshow element creates a list of images and contains a build-in
	 * sequencer with fade transitions.
	 * 
	 * @author Ideum
	 * @see Slideshow
	 * @see ImageList
	 * @see ImageSlideshow
	 */	
	public class ImageSlideshow extends ImageSequence
	{	
		private var tween:TweenLite;
		
		/**
		 * Constructor
		 */
		public function ImageSlideshow()
		{
			super();
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			tween = null;
		}
		private var loaded:Boolean = false;
		
		/**
		 * Default index sets the default image and displays it
		 */		
		private var _defaultIndex:int;
		public function get defaultIndex():int { return _defaultIndex };
		public function set defaultIndex(value:int):void
		{
			_defaultIndex = value;
		}	
			
		/**
		 * Loads image
		 * @param	index
		 */
		public function loadDefault(index:int):void
		{	
			currentIndex = index
			fadein(index);
		}

		/**
		 * Image load callback
		 */
		override public function loadComplete():void 
		{
			loaded = true;  

			for (var i:int = 0; i < this.length; i++) 
			{
				getIndex(i).loadComplete();
			}	

			loadDefault(_defaultIndex);						
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Cross-fade duration in milliseconds, must be less than seqeunce rate 
		 */		
		private var _fadeDuration:Number=250;
		public function get fadeDuration():Number { return _fadeDuration; }
		public function set fadeDuration(value:Number):void 
		{ 
			_fadeDuration = value; 
		}
		
		/**
		 * Resets the sequencer 
		 */		
		override public function reset():void
		{
			if (hasIndex(currentIndex) && currentIndex > 0) 
				fadeout(currentIndex);
				
			currentIndex = 0;
			fadein(currentIndex);			
		}			
		
		/**
		 * Fades out
		 * @param index 
		 */		
		public function fadeout(index:int):void
		{
			var lastImage:* = getIndex(index);
			
			if (hasIndex(index))
			{				
				tween = TweenLite.to(lastImage, fadeDuration / 1000, { alpha:0, onComplete:onFadeOutEnd } );
				tween.play();
			}
			
			function onFadeOutEnd():void
			{
				hide(index);
				tween = null;
			}				
		}
		
		/**
		 * Fades in
		 * @param index 
		 */		
		public function fadein(index:int):void
		{
			var currentImage:* = getIndex(index);
			
			getIndex(index).alpha = 0;
			show(index);
						
			tween = TweenLite.to(currentImage, fadeDuration / 1000, { alpha:1, onComplete:onFadeInEnd } );
			tween.play();
			
			function onFadeInEnd():void
			{
				tween = null;
			}
		}
		
	
		override protected function showNext():void
		{
			var last:int = currentIndex;
			currentIndex++;			
			
			if (hasIndex(last))
				fadeout(last);
			fadein(currentIndex);			
		}
		
	}
}