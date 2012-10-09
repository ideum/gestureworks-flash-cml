package com.gestureworks.cml.core
{
	import flash.display.Stage;
	
	/**
	 * DefaultStage, Singleton
	 * Provides global access to the default stage, used by the window manager and display manager
	 * @author Charles Veasey
	 */	
	
	public class DefaultStage
	{	
		/**
		 * stage variable
		 */
		public var stage:Stage;	
		
		/**
		 * constructor
		 * @param	enforcer
		 */
		public function DefaultStage(enforcer:SingletonEnforcer) {}
		
		private static var _instance:DefaultStage;
		/**
		 * singleton
		 */
		public static function get instance():DefaultStage
		{
			if (_instance == null)
				_instance = new DefaultStage(new SingletonEnforcer());
			return DefaultStage._instance;			
		}			
	}
}

class SingletonEnforcer{}