package com.gestureworks.cml.element
{	
	import com.gestureworks.utils.Map;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;

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
		
		private function onResize(event:Event):void
		{
			background.width = this.width;
			background.height = this.height;
		}
		
	}
}