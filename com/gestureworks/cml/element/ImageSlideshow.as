package com.gestureworks.cml.element
{
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.core.tweens.IITween;
	import org.libspark.betweenas3.tweens.ITween;
	
	import flash.events.TimerEvent;

	/**
	 * ImageSlideshow
	 * Image sequencer with cross-fade transitions
	 * @author Charles Veasey 
	 */	
	public class ImageSlideshow extends ImageSequence
	{	
		private var tween:ITween;
		
		public function ImageSlideshow()
		{
			super();
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
				tween = BetweenAS3.tween(lastImage, { alpha:0 }, null, fadeDuration/1000);
				tween.onComplete = onFadeOutEnd;
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
						
			tween = BetweenAS3.tween(currentImage, { alpha:1 }, null, fadeDuration/1000);
			tween.onComplete = onFadeInEnd;
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