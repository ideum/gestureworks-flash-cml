package com.gestureworks.cml.element
{	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * The ImageSequence element creates a list of images and contains a build-in
	 * sequencer.
	 * 
	 * @author Ideum
	 * @see Slideshow
	 * @see ImageList
	 * @see ImageSlideshow
	 */	
	
	public class ImageSequence extends ImageList
	{
		protected var timer:Timer;
		protected var lastIndex:int=0;
		
		
		/**
		 * Constructor
		 */
		public function ImageSequence()
		{
			super();
			timer = new Timer(1000);
		}
		
		/**
		 * Sequencer rate in milliseconds
		 */		
		private var _rate:Number;
		public function get rate():Number { return _rate; }
		public function set rate(value:Number):void 
		{ 
			_rate = value;
			timer.delay = _rate;
		}		
		
		/**
		 * Whether the sequencer restarts once it reaches the end
		 */		
		private var _loop:Boolean=true;
		public function get loop():Boolean { return _loop; }
		public function set loop(value:Boolean):void 
		{ 
			_loop = value; 
		}		
		
		private var _autoplay:Boolean=false;
		/**
		 * Indicates whether the file plays upon load
		 * @default false
		 */			
		public function get autoplay():Boolean { return _autoplay; }
		public function set autoplay(value:Boolean):void 
		{	
			_autoplay = value;
			if (_autoplay)
				this.addEventListener(Event.COMPLETE, onComplete);
		}		
		
		private function onComplete(event:Event):void { play(); }
		
		
		import flash.events.Event;
		
		/**
		 * Starts the sequencer from the beginning 
		 */		
		public function play():void
		{
			reset();
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		/**
		 * Resumes the sequencer
		 */		
		public function resume():void
		{
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}		
		
		/**
		 * Pauses the sequencer 
		 */		
		public function pause():void
		{
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();			
		}
		
		/**
		 * Pauses and resets the sequencer
		 */		
		public function stop():void
		{
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			reset();
		}
		
		/**
		 * Resets the sequencer 
		 */		
		override public function reset():void
		{
			if (hasIndex(currentIndex) && currentIndex > 0) 
				hide(currentIndex);
				
			currentIndex = 0;
			show(currentIndex);				
		}
			
		
		
		protected function onTimer(event:TimerEvent):void
		{			
			if (hasNext())
				showNext();
			else
			{
				if (loop)
					reset();
				else
					stop();
			}
		}
		
		protected function showNext():void
		{	
			var last:int = currentIndex;
			currentIndex++;			
			
			if (hasIndex(last))
				toggle(last, currentIndex);
			else
				show(currentIndex);
		}
		
		/**
		 * Dispose methods and remove listener
		 */
		override public function dispose():void
		{
			super.dispose();
			timer = null;
			if (timer)
			{
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer = null;
			}
			this.removeEventListener(Event.COMPLETE, onComplete);
		}
		
	}
}