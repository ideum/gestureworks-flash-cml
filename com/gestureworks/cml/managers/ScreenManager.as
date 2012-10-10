package com.gestureworks.cml.managers
{	
	import flash.display.Screen;

	/**
	 * Screen Manager, Singleton
	 * Provides information about and access to the computer's monitor screens
	 * @author Charles Veasey 
	 */	
	public class ScreenManager
	{	
		/**
		 * allows single instance for this ScreenManager class
		 * @param	enforcer
		 */
		public function ScreenManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:ScreenManager;
		/**
		 * method returns screen manager
		 */
		public static function get instance():ScreenManager 
		{ 
			if (_instance == null)
				_instance = new ScreenManager(new SingletonEnforcer());			
			return _instance; 
		}
		
		private var _screens:Array;
		/**
		 * returns the number of screens
		 */
		public function get screen():Array 
		{ 
			return Screen.screens;
		}
		
		/**
		 * adds the x and y position of the window
		 * @param	window
		 * @param	screenIndex
		 */
		public function addWindow(window:Object, screenIndex:int):void
		{
			window.x = Screen.screens[screenIndex - 1].bounds.left;
			window.y = Screen.screens[screenIndex-1].bounds.top;
		}
	}
}

/**
 * class can only be access by the screenManager class only. 
 */
class SingletonEnforcer{}