package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.elements.Window;
	import com.gestureworks.cml.utils.DefaultStage;
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.cml.utils.List;
	import flash.display.DisplayObject;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	/**
	 * Window Manager, Singleton
	 * Creates and manages system windows
	 * @author Ideum
	 */	
	public class WindowManager
	{		
		private var windows:LinkedMap;
		private var displays:List;
		private var background:Shape;		
		public var nativeWindowInitOptions:NativeWindowInitOptions;
		
		public function WindowManager()
		{
			windows = new LinkedMap;
			displays = new List;
			nativeWindowInitOptions = new NativeWindowInitOptions;
			nativeWindowInitOptions.maximizable = true;
			nativeWindowInitOptions.minimizable = true;
			nativeWindowInitOptions.resizable = true;
			nativeWindowInitOptions.systemChrome = NativeWindowSystemChrome.STANDARD;
			nativeWindowInitOptions.transparent = false;
			nativeWindowInitOptions.type = NativeWindowType.NORMAL;
			
			//target default window
			if (DefaultStage.instance.stage)
			{	
				windows.append("default", DefaultStage.instance.stage.nativeWindow);
				DefaultStage.instance.stage.scaleMode = StageScaleMode.NO_SCALE;
				DefaultStage.instance.stage.align = StageAlign.TOP_LEFT;				
			}	
		}
		
		/**
		 * Access point to singleton 
		 */		
		private static var _instance:WindowManager;
		public static function get instance():WindowManager 
		{ 
			if (_instance == null)
				_instance = new WindowManager(new SingletonEnforcer());			
			return _instance; 
		}		

		/**
		 * Creates a new window, must give an id
		 * @param windowId 
		 */		
		public function createWindow(windowId:String):void
		{
			var window:Window = new Window(nativeWindowInitOptions);			
			window.stage.scaleMode = StageScaleMode.NO_SCALE;
			window.stage.align = StageAlign.TOP_LEFT;
			window.bounds = new Rectangle(0, 0, 500, 400);
			windows.append(windowId, window);
		}
				
		/**
		 * Activate created window (open and bring to the front) 
		 * @param windowId 
		 */
		public function activateWindow(windowId:String):void
		{			
			var window:Object = windows.selectKey(windowId);
			window.activate();
		}
		
		/**
		 * Get Window by string id
		 * @param windowId
		 * @return systemWindow
		 */		
		public function getWindowKey(windowId:String):Object
		{
			return windows.selectKey(windowId);
		}
		
		/**
		 * Get window by index
		 * @param windowIndex
		 * @return systemWindow 
		 */		
		public function getWindowIndex(windowIndex:int):Object
		{
			return windows.selectIndex(windowIndex);
		}
		
		/**
		 * Append display object to window, cloning doesn't work 
		 * @param display
		 * @param windowId
		 */		
		public function appendDisplay(display:*, windowId:String):void
		{
			var window:Object = windows.selectKey(windowId);			
			
			if (displays.search(display) == -1)
				window.stage.addChild(display as DisplayObject);
			else
			{	
				window.stage.addChild(display.clone() as DisplayObject);
			}	
			displays.append(display);
		}
		
		/**
		 * Remove display object from window
		 * @param windowId
		 * @param viewId 
		 */		
		public function removeDisplay(display:*, windowId:String):void {}
		
		/**
		 * 
		 * @param windowId
		 * @param color 
		 */		
		public function setBackgroundColor(windowId:String, color:int):void
		{
			var window:Object = windows.selectKey(windowId);

			if (windowId == "default")
			{
				if (background == null)
				{
					background = new Shape;
					window.stage.addChildAt(background, 0);
					window.stage.addEventListener(Event.RESIZE, onResize);					
				}
			
				background.graphics.clear();			
				background.graphics.beginFill(color, 1);
				background.graphics.drawRect(0, 0, window.width, window.height);
				background.graphics.endFill();
			}
			else 
				window.backgroundColor = color;
		}
		
		//adjust background size on window resize
		private function onResize(event:Event):void
		{	
			background.width = event.target.stageWidth;
			background.height = event.target.stageHeight;	
		}		
	}
}

class SingletonEnforcer{}