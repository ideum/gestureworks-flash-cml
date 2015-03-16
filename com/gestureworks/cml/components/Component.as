package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.elements.Frame;
	import com.gestureworks.cml.elements.Menu;
	import com.gestureworks.cml.events.StateEvent;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;


	/**
	 * The Component manages a group of elements to create a high-level interactive touch container. It's fundamental composition includes
	 * a primary display element on the @see #front side, a secondary display on the @see #back side, a @see #menu for display controls, and
	 * a ui @see #frame.
	 * @author Ideum
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */	
	public class Component extends Container 
	{			
		private var _front:DisplayObject;
		private var _back:DisplayObject;
		private var _menu:DisplayObject;
		private var _frame:DisplayObject;
		private var _hideFrontOnFlip:Boolean = true;
		private var _timeout:Number = 0;
		private var _fadeDuration:Number = 0;
		private var _flipped:Boolean; 
		private var _trackActivity:Boolean; 
		
		protected var inactivityTimer:Timer;
		protected var fadeTween:TweenLite;
		
		/**
		 * Component Constructor
		 */
		public function Component() {
			super();
			mouseChildren = true; 
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {	
			
			addEventListener(StateEvent.CHANGE, onStateEvent);					
			
			//search for local instances
			if(!menu){
				menu = displayByTagName(Menu);
			}
			if(!frame){
				frame = displayByTagName(Frame);
			}
			
			//inactivity timer
			if (timeout > 0) {
				inactivityTimer = new Timer(timeout * 1000);
				inactivityTimer.addEventListener(TimerEvent.TIMER, onTimeout);
				trackActivity = true; 
			}
			
			//fade out animation
			if (fadeDuration > 0) {
				fadeTween = TweenLite.to(this, fadeDuration, { alpha:0, paused:true, onComplete:close }); 
			}
			
			updateLayout();	
			super.init();
		}
				
		/**
		 * Front side display of the component 
		 */		
		public function get front():* {return _front}
		public function set front(value:*):void {
			_front = displayById(value);
		}				
				
		/**
		 * Back side display of the component
		 */		
		public function get back():* {return _back}
		public function set back(value:*):void {
			_back = displayById(value);
		}		
		
		/**
		 * Menu control element
		 */		
		public function get menu():* {return _menu}
		public function set menu(value:*):void {
			_menu = displayById(value);
		}			
						
		/**
		 * Component frame
		 */		
		public function get frame():* {return _frame}
		public function set frame(value:*):void {	
			_frame = displayById(value);			
		}		
				
		/**
		 * Specifies whether the front is hidden when the the back is displayed
		 * @default true
		 */		
		public function get hideFrontOnFlip():Boolean { return _hideFrontOnFlip }
		public function set hideFrontOnFlip(value:Boolean):void {	
			_hideFrontOnFlip = value;			
		}						
		
		/**
		 * Inactivity time(seconds) limit permitted before component auto-closes. A time of zero disables auto-closing. 
		 * Override @see #onTimeout to customize auto-close behavior.
		 * @default 0
		 */
		public function get timeout():Number { return _timeout; }
		public function set timeout(value:Number):void {
			_timeout = value;
		}		
		
		/**
		 * Auto-close time out event handler
		 * @see #timeout
		 * @param	e
		 */
		protected function onTimeout(e:TimerEvent):void {
			if (fadeTween) {
				fadeTween.play();
			}
			else{
				close();
			}
		}		
		
		/**
		 * When set above 0 seconds, enables a fade animation on @see #timeout
		 * @default 0
		 */
		public function get fadeDuration():Number { return _fadeDuration; }
		public function set fadeDuration(value:Number):void {
			_fadeDuration = value;
		}	
		
		/**
		 * Control activity tracking for auto-close
		 * @see #timeout
		 */
		protected function get trackActivity():Boolean { return _trackActivity; }
		protected function set trackActivity(value:Boolean):void {
			_trackActivity = value; 
			if (_trackActivity) {
				restartTimer();
				menuDisplay();
			}
			else {
				stopTimer();
			}
		}
		
		/**
		 * Stop inactivity timer
		 */
		private function stopTimer():void {
			if (inactivityTimer) {
				inactivityTimer.stop();
			}
			stopFade();
		}
		
		/**
		 * Restart inactivity timer
		 */
		private function restartTimer():void {
			if (inactivityTimer) {
				inactivityTimer.reset();
				inactivityTimer.start();
			}
			stopFade();
		}
		
		/**
		 * Timer disposal
		 */
		private function disposeTimer():void {
			stopTimer();
			inactivityTimer = null; 
		}
		
		/**
		 * Reset fade animation
		 */
		private function stopFade():void {
			if (fadeTween) {
				fadeTween.pause();
				fadeTween.seek(0);
			}			
		}
		
		/**
		 * Fade tween disposal
		 */
		private function disposeFade():void {
			if (fadeTween) {
				fadeTween.kill();
				fadeTween = null;
			}
		}
		
		/**
		 * Invoke menu display settings
		 */
		private function menuDisplay():void {
			if (menu) {
				menu.startTimer();
			}
		}
				
		/**
		 * @inheritDoc
		 */
		override public function set visible(value:Boolean):void {
			super.visible = value;		
			trackActivity = value; 
		}
		
		/**
		 * Display the component
		 */
		public function open():void {
			visible = true;
		}
		
		/**
		 * Hide the component
		 */
		public function close():void {
			visible = false; 
		}	
		
		/**
		 * Switch between front and back side of the component
		 */
		public function flip():void {
			if(front && back){
				_flipped = !_flipped;
				
				front.visible =  hideFrontOnFlip ? !_flipped : true;
				back.visible = _flipped;
			}
		}
		
		/**
		 * True if back side is displayed, false otherwise
		 */
		public function get flipped():Boolean { return _flipped; }
		
		/**
		 * Equalize element and component dimensions. If component dimensions are undefined, 
		 * dimensions are set to the main(front) element.
		 */
		public function updateLayout():void {
			if (front) {
				width ? front.width = width : width = front.width; 
				height ? front.height = height : height = front.height; 
			}						
			if (back){
				back.width = width;
				back.height = height;
			}				
			if (frame){
				frame.width = width;
				frame.height = height;
			}						
			if (menu){
				menu.updateLayout(width, height);	
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set totalPointCount(value:int):void {
			super.totalPointCount = value;
			trackActivity = true; 
		}	
		
		/**
		 * Default state event handler listening for "value" event attributes "info" and "close" to invoke
		 * flip and close actions respectively. These are the events dispatched by menu controls. 
		 * @param	event
		 */
		protected function onStateEvent(event:StateEvent):void{		
			if (event.value == "info") {
				flip();				
			}
			else if (event.value == "close"){
				close();
			}
		}
		
		/**
		 * Restore start state
		 */
		public function reset():void {
			
			//return to front
			if (flipped) {
				flip();
			}
			
			//propagate reset
			if(menu){
				menu.reset();
			}
			
			//restart timer
			restartTimer();			
			
			//workaround to clear inertia cache
			if (releaseInertia && gestureList){
				var gestures:Object = gestureList;
				gestureList = gestures;
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* {
			
			//component clone 
			cloneExclusions.push("front", "back", "frame", "menu");			
			var clone:Component = super.clone();
		
			//verify element references
			if (!clone.front && front) {
				clone.front = clone.getChildAt(getChildIndex(front));
			}
			if (!clone.back && back) {
				clone.back = clone.getChildAt(getChildIndex(back));
			}
			if (!clone.menu && menu) {
				clone.menu = clone.getChildAt(getChildIndex(menu));
			}
			if (!clone.frame && frame) {
				clone.frame = clone.getChildAt(getChildIndex(frame));
			}
			
			clone.init();
			return clone;
		}
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			
			_front = null;
			_back = null;
			_menu = null;
			_frame = null;
			
			disposeFade();
			disposeTimer();
		}
	}

}