package com.gestureworks.cml.utils
{
	import flash.display.Stage;
	
	/**
	 * The DefaultStage class provides global access to the default stage.
	 * 
	 * @author Ideum
	 */	
	
	public class DefaultStage
	{	
		/**
		 * Provides acces to the stage
		 */
		public var stage:Stage;	
		
		/**
		 * Constructor
		 * @param	enforcer
		 */
		public function DefaultStage(enforcer:SingletonEnforcer) {}
		
		private static var _instance:DefaultStage;
		/**
		 * Returns an instance of DefaultState class
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