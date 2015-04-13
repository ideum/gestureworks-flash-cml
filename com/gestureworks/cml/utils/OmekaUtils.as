package com.gestureworks.cml.utils 
{
	/**
	 * ...
	 * @author Ideum
	 */
	public class OmekaUtils 
	{
		private static var _instance:OmekaUtils;
		
		private var endpoint:String; 
		
		public function OmekaUtils(enforcer:SingletonEnforcer) { }
		
		public static function get instance(endpoint:String = null):OmekaUtils {
			if (!_instance) {
				_instance = new OmekaUtils(new SingletonEnforcer());
			}
			if (endpoint) {
				this.endpoint = endpoint;
			}
			return _instance;
		}
		
	}
	
	class SingletonEnforcer

}