package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.utils.LinkedMap;
	
	/**
	 * CMLObjects, Singleton 
	 * Master list for objects created through cml
	 * @author Charles Veasey
	 */
	public class CMLObjectList extends LinkedMap
	{		
		public function CMLObjectList(enforcer:SingletonEnforcer) {}
		
		private static var _instance:CMLObjectList;
		public static function get instance():CMLObjectList 
		{ 
			if (_instance == null)
				_instance = new CMLObjectList(new SingletonEnforcer());			
			return _instance; 
		}	
	}
}

class SingletonEnforcer{}