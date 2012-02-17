package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.interfaces.ICML;	
	import com.gestureworks.cml.managers.FileManager;
	
	/**
	 * LibraryKit
	 * The LibraryKit contains classes that create and manage
	 * external library assets
	 * @author Charles Veasey
	 */
	
	public class LibraryKit implements ICML
	{
		public function LibraryKit(enforcer:SingletonEnforcer) {}		
		
		private static var _instance:LibraryKit;
		public static function get instance():LibraryKit 
		{ 
			if (_instance == null)
				_instance = new LibraryKit(new SingletonEnforcer());			
			return _instance;	
		}		
		
		public function parseCML(cml:XMLList):XMLList
		{
			var xmlList:XMLList = null;
			
			for each (var node:* in cml.*)
			{
				if (node.name().toString() == "Library")
					FileManager.instance.addToQueue(node.@src, node.@type);	
			}
			
			return xmlList;
		}		
	}
}

class SingletonEnforcer{}		