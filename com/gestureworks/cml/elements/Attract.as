package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.GWTouchEvent;
	import com.gestureworks.managers.TouchManager;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.utils.Timer;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	/**
	 * The AttractKit creates an attract screen that is removed during touch and displayed after a timout period.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var a:AttractKit = new AttractKit;
		a.addChild(img1);
		a.addChild(img2);
		a.init();
		a.addChild();
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Container
	 */
	public class Attract extends TouchContainer
	{
		
		private var timer:Timer;
		
		/**
		 * Constructor
		 */
		public function Attract() 
		{
			super();
		}
		
		/**
		 * Automatically updates attract screen to stage size. This adds an event listener
		 * to the stage which listens for resize events, and adjust accordingly.
		 * @default false
		 */
		public var _autoupdate:Boolean = false;
		public function get autoupdate():Boolean{return _autoupdate;}
		public function set autoupdate(value:Boolean):void
		{
			_autoupdate = value;
			
			if (_autoupdate)
				stage.addEventListener(Event.RESIZE, updateLayout);
			else 
				stage.removeEventListener(Event.RESIZE, updateLayout);				
		}		
		
		private var _timeout:Number = 60000;
		/**
		 * Sets the amount of time in seconds before the program times out and the attract screen pops up.
		 */
		public function get timeout():Number { return _timeout; }
		public function set timeout(value:Number):void {
			_timeout = value * 1000;
		}
		
		private var _tweenFades:Boolean = false;
		/**
		 * Sets whether or not to fade the attract screen in and out.
		 */
		public function get tweenFades():Boolean { return _tweenFades; }
		public function set tweenFades(value:Boolean):void {
			_tweenFades = value;
		}
		
		private var _tweenTime:Number = 1;
		/**
		 * The duration of the tween in seconds
		 */
		public function get tweenTime():Number { return _tweenTime; }
		public function set tweenTime(value:Number):void {
			_tweenTime = value;
		}
		
		private var _attractState:Boolean;
		/**
		 * The current attract state (false = closed, true = open)
		 */
		public function get attractState():Boolean { return _attractState; }
		public function set attractState(value:Boolean):void {
			
			_attractState = value;
			
			if (_attractState) 
				onTimer();
		}		

		
		private var _center:Boolean = true;
		/**
		 * Sets whether or not to center chidren
		 */
		public function get center():Boolean { return _center; }
		public function set center(value:Boolean):void {
			_center = value;
		}
		
		
		/**
		 * CML callback initialisation
		 */
		override public function init():void
		{
			nativeTransform = false;
			CMLParser.instance.addEventListener(CMLParser.COMPLETE, cmlinit);
			
			addEventListener(GWTouchEvent.TOUCH_BEGIN, onAttractTouch);
			
			if (center) updateLayout();
			
			timer = new Timer(timeout);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}		

		/**
		 * Updates the child x and y position to the center of the stage
		 * @param	event
		 */
		public function updateLayout(event:Event=null):void
		{
			var child:DisplayObject;
			for (var i:int = 0; i < numChildren; i++) 
			{
				child = getChildAt(i) as DisplayObject;
				child.x = (stage.stageWidth - child.width) / 2;
				child.y = (stage.stageHeight -  child.height) / 2;				
			}			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{	
			super.dispose();
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, resetTimer);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resetTimer);
			stage.removeEventListener(Event.RESIZE, updateLayout);
			if (timer) {
				timer.stop();
				timer = null;
			}
		}		
		
		private function cmlinit(e:Event):void {
			CMLParser.instance.removeEventListener(CMLParser.COMPLETE, cmlinit);
			parent.setChildIndex(this, parent.numChildren - 1);
		}
		
		private function onAttractTouch(e:GWTouchEvent):void {
			
			for (var i:Number = 0; i < numChildren; i++) {
				if ("stop" in getChildAt(i)) {
					getChildAt(i)["stop"]();
				}
				
				if (getChildAt(i) is DisplayObjectContainer) {
					checkChildren(DisplayObjectContainer(getChildAt(i)), "stop");
				}
			}
			
			timer.start();
			if (tweenFades) {
				// fade out.
				TweenMax.to(this, tweenTime, { alpha:0, onComplete:visFunction } );
				
			} else {
				visible = false;
			}
		
			if (stage) {
				if (GestureWorks.activeSim) {
					stage.addEventListener(MouseEvent.MOUSE_MOVE, resetTimer);
				}
				else {
					stage.addEventListener(TouchEvent.TOUCH_MOVE, resetTimer);
				}
			}
			attractState = false;	
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "attractState", attractState));
		}
		
		
		private function visFunction():void { 
			visible = false; 
		}
		
		private function resetTimer(e:Event):void {
			timer.reset();
			timer.start();
		}
		
		private function onTimer(e:TimerEvent = null):void {
			timer.stop();
			
			for (var i:Number = 0; i < numChildren; i++) {
				if ("play" in getChildAt(i)) {
					getChildAt(i)["play"]();
				}
				
				if (getChildAt(i) is DisplayObjectContainer) {
					checkChildren(DisplayObjectContainer(getChildAt(i)), "play");
				}
			}
			
			if (tweenFades) {
				// fade in.
				visible = true;
				TweenMax.to(this, tweenTime, { alpha:1 } );
			} else {
				alpha = 1;
				visible = true;
			}
			
			parent.setChildIndex(this, parent.numChildren - 1);
		
			_attractState = true;	
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "attractState", attractState));
		}
		
		private function checkChildren(target:DisplayObjectContainer, method:String):void {
			for (var i:int = 0; i < target.numChildren; i++) 
			{
				if (method in target.getChildAt(i)) {
					target.getChildAt(i)[method]();
				}
				if (target.getChildAt(i) is DisplayObjectContainer)
					checkChildren(DisplayObjectContainer(target.getChildAt(i)), method);
			}
		}
	}
}