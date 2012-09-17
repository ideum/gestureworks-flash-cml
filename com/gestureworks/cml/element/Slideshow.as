package com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.utils.List;
	import flash.display.DisplayObject;
	import flash.utils.Timer;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.core.tweens.IITween;
	import org.libspark.betweenas3.tweens.ITween;
	
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author josh
	 */
	public class Slideshow extends Container
	{
		private var slideshowItems:List;
		private var tween:ITween;
		
		protected var timer:Timer;
		
		public function Slideshow() {
			super();
			slideshowItems = new List();
			timer = new Timer(1000);
		}
		
		private var _fadeDuration:Number = 250;
		/**
		 * Cross-fade duration in milliseconds, must be less than seqeunce rate 
		 * @default 250
		 */
		public function get fadeDuration():Number { return _fadeDuration; }
		public function set fadeDuration(value:Number):void 
		{ 
			_fadeDuration = value; 
		}
		
		private var _currentIndex:int = 0;
		public function get currentIndex():int { return _currentIndex; }
		public function set currentIndex(value:int):void {
			_currentIndex = value;
		}
		
		private var _rate:Number;
		/**
		 * Rate of change between slides in milliseconds
		 * @default 1000
		 */
		public function get rate():Number { return _rate; }
		public function set rate(value:Number):void {
			_rate = value;
			timer.delay = _rate;
		}
		
		private var _autoplay:Boolean = true;
		/**
		 * Sets autoplay variable.
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void {
			_autoplay = value;
			if (_autoplay)
				this.addEventListener(Event.COMPLETE, onComplete);
		}
		
		private var _loop:Boolean = true;
		/**
		 * Sets whether or not the sequence will loop once it reaches the end or beginning depending on play direction.
		 */
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void {
			_loop = value;
		}
		
		override public function displayComplete():void 
		{
			super.displayComplete();
			
			slideshowItems.array = childList.getValueArray();
			
			for (var i:Number = slideshowItems.length - 1; i > 0; i--) {
				//trace("Removing item: " + slideshowItems.array[i]);
				removeChildAt(slideshowItems.array[i]);
			}
			
			//play();
			init();
		}
		
		public function init():void
		{
			play();
		}
		
		public function play():void {
			reset();
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		public function pause():void {
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
		}
		
		public function resume():void {
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		public function stop():void {
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			reset();
		}
		
		public function onTimer(event:TimerEvent):void {
			showNext();
		}
		
		public function onComplete(event:TimerEvent):void {
			play();
		}
		
		public function fadeout(index:int):void
		{
			var lastItem:DisplayObject = slideshowItems.array[index];
			
			if (slideshowItems.array[index])
			{
				tween = BetweenAS3.tween(lastItem, { alpha:0 }, null, fadeDuration/1000);
				tween.onComplete = onFadeOutEnd;
				tween.play();
			}
			
			function onFadeOutEnd():void
			{
				lastItem.visible = false;
				trace(lastItem.parent);
				if (contains(slideshowItems.array[index])){
					removeChild(slideshowItems.array[index]);
				}
				tween = null;
			}				
		}
		
		public function fadein(index:int):void
		{
			var currentItem:* = slideshowItems.array[index];
			
			slideshowItems.array[index].alpha = 0;
			slideshowItems.array[index].visible = true;
			addChild(slideshowItems.array[index]);
			
			tween = BetweenAS3.tween(currentItem, { alpha:1 }, null, fadeDuration/1000);
			tween.onComplete = onFadeInEnd;
			tween.play();
			
			function onFadeInEnd():void
			{
				tween = null;
			}				
		}
		
		protected function showNext():void
		{
			var last:int;
			last = _currentIndex;
			_currentIndex++;
			
			if (slideshowItems.hasIndex(_currentIndex)) {
				fadeout(last);
				fadein(_currentIndex);
			}
			else if (!slideshowItems.hasIndex(_currentIndex) && _loop) {
				_currentIndex = 0;
				fadeout(last);
				fadein (_currentIndex);
			}
			else { fadeout(last); }
		}
		
		protected function showPrev():void {
			var last:int;
			last = _currentIndex;
			_currentIndex--;
			
			if (slideshowItems.hasIndex(_currentIndex)) {
				
				fadeout(last);
				fadein(_currentIndex);
			}
			else if (!slideshowItems.hasIndex(_currentIndex) && _loop) {
				_currentIndex = slideshowItems.length - 1;
				fadeout(last);
				fadein (_currentIndex);
			}
			else {
				_currentIndex = 0;
				fadeout(last);
				fadein(_currentIndex);
			}
		}
		
		protected function reset():void {
			
			if (slideshowItems.hasIndex(_currentIndex) && currentIndex > 0) {
				fadeout(_currentIndex);
				_currentIndex = 0;
				fadein(_currentIndex);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			if (_autoplay)
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			timer.stop();
			timer = null;
			tween = null;
			
			for each (var item:DisplayObject in slideshowItems.array) {
				if (contains(item)) {
					removeChild(item);
				}
			}
			
			slideshowItems = null;
		}
	}
	
}