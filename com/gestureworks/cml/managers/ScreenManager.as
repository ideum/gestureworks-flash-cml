package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.element.SystemWindow;
	
	import flash.display.Screen;

	/**
	 * Screen Manager, Singleton
	 * Provides information about and access to the computer's monitor screens
	 * @author Charles Veasey 
	 */	
	public class ScreenManager
	{				
		public function ScreenManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:ScreenManager;
		public static function get instance():ScreenManager 
		{ 
			if (_instance == null)
				_instance = new ScreenManager(new SingletonEnforcer());			
			return _instance; 
		}
		
		private var _screens:Array;
		public function get screen():Array 
		{ 
			return Screen.screens;
		}
		
		public function addWindow(window:Object, screenIndex:int):void
		{
			window.x = Screen.screens[screenIndex - 1].bounds.left;
			window.y = Screen.screens[screenIndex-1].bounds.top;
		}
	}
}

class SingletonEnforcer{}