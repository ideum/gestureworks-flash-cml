package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.elements.Window;
	
	/**
	 * Window Manager, Singleton
	 * @author Ideum
	 */	
	public class WindowManager {		
		private var windows:Vector.<Window>;
		
		public function WindowManager(enforcer:SingletonEnforcer) {
			windows = new Vector.<Window>;
		}
		
		/**
		 * Access point to singleton.
		 */		
		private static var _instance:WindowManager;
		public static function get instance():WindowManager { 
			if (_instance == null) {
				_instance = new WindowManager(new SingletonEnforcer());			
			}
			return _instance; 
		}		
		
		/**
		 * Append window, cloning doesn't work 
		 * @param display
		 * @param windowId
		 */		
		public function registerWindow(window:Window):void {
			windows.push(window);
		}	
	}
}

class SingletonEnforcer{}