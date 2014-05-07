package com.gestureworks.cml.elements
{		
	import com.gestureworks.cml.core.CMLObject;
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.utils.DefaultStage;
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	/**
	 * Operating system window, CML proxy for AS3's NativeWindow class. 
	 * @author Ideum
	 */
	public class Window extends CMLObject
	{
		private var _screen:int;
		private var _nativeWindow:NativeWindow;
		private var _name:String;
		private var isDefault:Boolean = false;
		private var initOptions:NativeWindowInitOptions;
		
		public function Window(initOptions:NativeWindowInitOptions = null) {
			if (initOptions) {
				this.initOptions = initOptions;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateProperties(key:* = 0):void {
			if ( state[key]["isDefault"] && state[key]["isDefault"] == "true" ) {
				isDefault = true;
				nativeWindow = DefaultStage.instance.stage.nativeWindow;
			}
			else {
				if (!initOptions) {
					initOptions = new NativeWindowInitOptions();
					CMLParser.updateProperties(initOptions, key, state);
				}
				nativeWindow = new NativeWindow(initOptions);
				nativeWindow.activate();
				
				// default stage properties
				nativeWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
				nativeWindow.stage.align = StageAlign.TOP_LEFT;		
			}
			CMLParser.updateProperties(nativeWindow, key, state);
			CMLParser.updateProperties(this, key, state);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {
			var item:*;					
			if (isDefault) {
				for each (item in childList) {
					if (item is DisplayObject) {
						CMLParser.cmlDisplay.addChild(item);					
					}
				}
			}
			else {
				for each (item in childList) {
					if (item is DisplayObject) {
						nativeWindow.stage.addChild(item);					
					}
				}
			}
		}	
		
		//////////////////////////////////////////////////////////////
		// WINDOW
		//////////////////////////////////////////////////////////////	
		
		/**
		 * Sets screen index. This will set the x, y position based on the screen 
		 * position as determined by the operating system.
		 */
		public function get screen():int {
			return _screen;
		}
		public function set screen(value:int):void {
			nativeWindow.x = Screen.screens[value-1].bounds.left;			
			nativeWindow.y = Screen.screens[value-1].bounds.top;		
			_screen = value;
		}
		
		/**
		 * Reference to the AS3 NativeWindow object that this represents.
		 */
		public function get nativeWindow():NativeWindow {
			return _nativeWindow;
		}
		public function set nativeWindow(value:NativeWindow):void {
			_nativeWindow = value;
		}
		
		/**
		 * Associates a name with this object.
		 */
		public function get name():String {
			return _name;
		}
		public function set name(value:String):void {
			_name = value;
		}
		
	}
}