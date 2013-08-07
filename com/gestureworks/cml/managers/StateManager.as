package  
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author 
	 */
	public class StateManager 
	{		
		private static var states:Dictionary;
		
		public function StateManager() {
			if (_instance)
				throw new Error("Error: Instantiation failed: Use StateManager.getInstance() instead of new.");
		}
		
		public static function getInstance():StateManager {
			if (!_instance)
				_instance = new StateManager();
			return _instance;
		}			
		
		
	}

}