package com.gestureworks.cml.elements
{		
	import com.gestureworks.cml.managers.WindowManager;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;

	/**
	 * Operating system window, CML wrapper for AS3's NativeWindow class. 
	 * @author Ideum
	 */	
	public class Window extends NativeWindow
	{
		private var _id:String;
		private var _backgroundColor:int;
		private var background:Shape;
			
		public function Window(initOptions:NativeWindowInitOptions)
		{
			super(initOptions);
		}
		
		public function parseCML(cml:XMLList):void
		{						
			var window:Object;

			for each (var node:* in cml.*)
			{
				if (node.@id != "default")
					WindowManager.instance.createWindow(node.@id);
				
				window = WindowManager.instance.getWindowKey(node.@id);
								
				for each (var attr:* in node.@*)
				{
					if (attr.name() == "screen") 
						ScreenManager.instance.addWindow(window, attr);					
					else if (attr.name() == "fullscreen" && attr == "true")
						window.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					else if (attr.name() == "backgroundColor")
						WindowManager.instance.setBackgroundColor(node.@id, attr);
					else if (attr.name() == "ref")
					{
						if (DisplayList.object[attr.toString()])
							WindowManager.instance.appendDisplay(DisplayList.object[attr.toString()], node.@id);						
					}
					else if (window.hasOwnProperty(attr.name().toString()))
						window[attr.name().toString()] = attr;						
				}
								
				if (node.@id != "default")
					WindowManager.instance.activateWindow(node.@id);
			}
		}			
		
		public function get id():String {return _id;}
		public function set id(value:String):void 
		{ 
			_id = value; 
		}
		
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