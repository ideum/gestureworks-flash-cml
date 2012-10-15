package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.interfaces.ICML;
	import com.gestureworks.cml.managers.FileManager;
	
	/**
	 * The LibraryKit stores global libray assets that can be accessed throughout
	 * the CML file.
	 * 
	 * <p>This class is meant to be used within CML and is not compatible 
	 * with AS3.</p>
	 * 
	 * @author Charles
	 * @see com.gestureworks.element.SWF
	 */
	public class LibraryKit implements ICML
	{
		/**
		 * Constuctor
		 * @param	enforcer
		 */		 
		public function LibraryKit(enforcer:SingletonEnforcer) { }		
		
		
		private static var _instance:LibraryKit;
		/**
		 * Singleton accesor method
		 */
		public static function get instance():LibraryKit 
		{ 
			if (_instance == null)
				_instance = new LibraryKit(new SingletonEnforcer());			
			return _instance;	
		}		
		
		/**
		 * parses cml file
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList
		{
			var xmlList:XMLList = null;
			
			for each (var node:* in cml.*)
			{
				if (node.name().toString() == "Library") {
					var src:String = node.@src;
					FileManager.instance.addToQueue(src, node.@type);	
				}
			}
			
			return xmlList;
		}		
	}
}


class SingletonEnforcer{}		