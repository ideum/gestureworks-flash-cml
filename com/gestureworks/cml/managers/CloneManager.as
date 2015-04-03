package com.gestureworks.cml.managers 
{
	/**
	 * @author Ideum
	 */	
	public class CloneManager
	{			
		private static var _instance:CloneManager = new CloneManager();;
		
		public function CloneManager() {
			if(_instance){
				throw new Error("Error: Instantiation failed: Use CloneManager.instance() instead of new.");
			}
		}
		
		public static function get instance():CloneManager { return _instance; }
	}
}