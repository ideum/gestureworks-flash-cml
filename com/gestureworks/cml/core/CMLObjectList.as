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
		
		
		/**
		 * Returns cml object by id value.
		 * Same as: CMLObjectList.instance.getKey(value)
		 * @param	value
		 */
		public function getId(value:String):*
		{
			return CMLObjectList.instance.getKey(value);
		}
		
		
	}
}

class SingletonEnforcer{}