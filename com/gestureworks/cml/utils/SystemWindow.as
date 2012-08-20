package com.gestureworks.cml.utils
{		
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;

	/**
	 * SystemWindow
	 * Operating system window 
	 * @author Charles Veasey
	 */	
	
	public class SystemWindow extends NativeWindow
	{
		private var background:Shape;
		
		public function SystemWindow(initOptions:NativeWindowInitOptions)
		{
			super(initOptions);
			
			this.addEventListener(NativeWindowBoundsEvent.RESIZE, onResize);
		}
		
		private var _id:String;
		public function get id():String {return _id;}
		public function set id(value:String):void 
		{ 
			_id = value; 
		}
		
		private var _backgroundColor:int;
		public function get backgroundColor():int {return _backgroundColor;}
		public function set backgroundColor(value:int):void 
		{
			_backgroundColor = value; 
			
			if (background == null)
			{
				background = new Shape;
				this.stage.addChildAt(background, 0);
				this.stage.addEventListener(Event.RESIZE, onResize);
			}
			background.graphics.clear();			
			background.graphics.beginFill(_backgroundColor, 1);
			background.graphics.drawRect(0, 0, this.width, this.height);
			background.graphics.endFill();			
		}
		
		private function onResize(event:NativeWindowBoundsEvent):void
		{
			background.width = this.width;
			background.height = this.height;
			
			this.stage.stageHeight = this.height;
			this.stage.stageWidth = this.width;			
		}
		
	}
}