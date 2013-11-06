package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.utils.List;
	import com.gestureworks.cml.events.StateEvent;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Timer;
	
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	/**
	 * The Slideshow element takes a set of display objects to its childList and plays through them with a crossfade set through tis rate and fade duration.
	 * The Slideshow element can be set to autoplay and loop, and has play(), pause(), and resume() functions accessible by other classes or AS3 code.
	 * Slideshow element can take anything that is a display object.
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var slideShow:Slideshow = new Slideshow();
		slideShow.x = 500;
		slideShow.y = 100;
		slideShow.rate = 2000;
		slideShow.fadeDuration = 1000;
		slideShow.loop = true;
		slideShow.autoplay = true;
		
		addChild(slideShow);
		
		slideShow.addChild(text1);
		slideShow.childToList("text1", text1);
		slidheShow.addChild(graphic1);
		slideShow.childToList("circle", graphic1);
		slideShow.init();
	 *
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Container
	 */
	public class Slideshow extends TouchContainer
	{
		private var slideshowItems:List;
		private var tween:TweenLite;
		private var moveForward:Boolean = true;
		private var maxWidth:Number = 0;
		private var maxHeight:Number = 0;
		
		protected var timer:Timer;
		
		/**
		 * Constructor
		 */
		public function Slideshow() {
			super();
			slideshowItems = new List();
			timer = new Timer(1000);
			mouseChildren = true;
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
		
		private var _currentIndex:int = -1;
		/**
		 * sets the current index of slides
		 * @default =-1;
		 */
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
		
		private var _autoplay:Boolean = false;
		/**
		 * Sets autoplay variable.
		 */
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void {
			_autoplay = value;
			if (_autoplay == true)
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

		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			var arr:Array = childList.getValueArray();
			for (var j:int = 0; j < arr.length; j++) {
				slideshowItems.append(arr[j]); 
			}
			
			for (var i:Number = slideshowItems.length; i > 0; i--) {
				if (getChildAt(slideshowItems.getIndex(i)).width > maxWidth) {
					maxWidth = getChildAt(slideshowItems.getIndex(i)).width;
					this.width = maxWidth;
				}
				if (getChildAt(slideshowItems.getIndex(i)).height > maxHeight) {
					maxHeight = getChildAt(slideshowItems.getIndex(i)).height;
					this.height = maxHeight;
				}
				removeChildAt(slideshowItems.getIndex(i));
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", "loaded", true));
			
			showNext();
			//init();
			if (autoplay)
				play();
		}
		
		/**
		 * plays the slideshow
		 */
		public function play():void {
			//reset();
			autoplay = true;
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		/**
		 * pauses the slideshow
		 */
		public function pause():void {
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
		}
		
		/**
		 * resume method
		 */
		public function forward():void {
			moveForward = true;
			if (_autoplay){
				if (!timer.hasEventListener(TimerEvent.TIMER)) {
					timer.addEventListener(TimerEvent.TIMER, onTimer);
					timer.start();
				}
			}
			else if (!_autoplay) {
				showNext();
			}
		}
		
		/**
		 * stops the slideshow
		 */
		public function stop():void {
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			reset();
		}
		
		public function reverse():void {
			moveForward = false;
			if (_autoplay){
				if (!timer.hasEventListener(TimerEvent.TIMER)) {
					timer.addEventListener(TimerEvent.TIMER, onTimer);
					timer.start();
				}
			}
			else if (!_autoplay) {
				showPrev();
			}
		}
		
		/**
		 * Goes to the next slide without restarting playback or changing play direction.
		 */
		public function next():void {
			showNext();
		}
		
		/**
		 * Goes to the previous slide without restarting playback or changing play direction.
		 */
		public function previous():void {
			showPrev();
		}
		
		public function snapTo(index:Number):void {
			
			for (var i:int = 0; i < numChildren; i++) {
				stopCheck(getChildAt(i));
			}
			
			if (slideshowItems.hasIndex(index) && index != _currentIndex) {
				fadeout(_currentIndex);
				fadein(index);
			}
			_currentIndex = index;
		}
		
		/**
		 * timer event
		 * @param	event
		 */
		public function onTimer(event:TimerEvent):void {
			if(autoplay){
				if (moveForward){
					showNext();
				} else if (!moveForward) {
					showPrev();
				}
			}
		}
		
		/**
		 * plays the slideshow
		 * @param	event
		 */
		public function onComplete(event:TimerEvent):void {
			play();
		}
		
		/**
		 * tweening for last item and removes the slide show items
		 * @param	index
		 */
		public function fadeout(index:int):void
		{
			var lastItem:DisplayObject = slideshowItems.getIndex(index);
			
			if (slideshowItems.getIndex(index))
			{
				tween = TweenLite.to(lastItem, fadeDuration / 1000, { alpha:0 , onComplete:onFadeOutEnd} );
				tween.play();
			}
			
			function onFadeOutEnd():void
			{
				lastItem.visible = false;
				if (contains(slideshowItems.getIndex(index))){
					removeChild(slideshowItems.getIndex(index));
				}
				tween = null;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "slideshowState", this, true));
			}				
		}
		
		/**
		 * adds the slideshow items and tweening for current item
		 * @param	index
		 */
		public function fadein(index:int):void
		{
			var currentItem:* = slideshowItems.getIndex(index);
			
			slideshowItems.getIndex(index).alpha = 0;
			slideshowItems.getIndex(index).visible = true;
			addChild(slideshowItems.getIndex(index));
			
			tween = TweenLite.to(currentItem, fadeDuration / 1000, { alpha:1 , onComplete:onFadeInEnd} );
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
			for (var i:int = 0; i < numChildren; i++) {
				stopCheck(getChildAt(i));
			}
			
			if (slideshowItems.hasIndex(_currentIndex)) {
				fadeout(last);
				fadein(_currentIndex);
			}
			else if (!slideshowItems.hasIndex(_currentIndex) && _loop) {
				_currentIndex = 0;
				fadeout(last);
				fadein (_currentIndex);
			}
			else { 
				fadeout(last); }
		}
		
		protected function showPrev():void {
			var last:int;
			last = _currentIndex;
			_currentIndex--;
			
			for (var i:int = 0; i < numChildren; i++) {
				stopCheck(getChildAt(i));
			}
			
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
		
		private function stopCheck(obj:DisplayObject):void {
			if ("stop" in obj)
				obj["stop"]();
			
			if (obj is DisplayObjectContainer && DisplayObjectContainer(obj).numChildren > 0) {
				for (var i:int = 0; i < DisplayObjectContainer(obj).numChildren; i++)
					stopCheck(DisplayObjectContainer(obj).getChildAt(i));
			}
		}
		
		protected function reset():void {
			
			for (var i:int = 0; i < numChildren; i++) {
				stopCheck(getChildAt(i));
			}
			
			if (slideshowItems.hasIndex(_currentIndex) && currentIndex > 0) {
				fadeout(_currentIndex);
				_currentIndex = 0;
				fadein(_currentIndex);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();			
			if(timer){
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
				timer.stop();
				timer = null;
			}
			tween = null;
			slideshowItems = null;
		}
		
		/**
		 * Method to clear children and reset the childlist so the slideshow can be repopulated by running
		 * init without simply appending or duplicating itself or the ChildList.
		 */
		public function clear():void {
			timer.stop();
			
			for each (var item:DisplayObject in slideshowItems.toArray()) {
				if (contains(item))
					removeChild(item);
			}
			while (childList.length > 0) {
				childList.removeIndex(0);
			}
		}
	}
	
}