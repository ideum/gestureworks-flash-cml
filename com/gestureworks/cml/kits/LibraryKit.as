package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.interfaces.ICML;	
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.cml.core.CMLParser;
	
	/**
	 * The LibraryKit contains creates and manages external library assets
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
				if (node.name().toString() == "Library") {
					
					var src:String = node.@src;
									
					/* Relative paths not working for security reasons.
					// rootDirectory allows you to change the root path	
					if (CMLParser.instance.relativePaths && CMLParser.instance.rootDirectory 
						&& CMLParser.instance.rootDirectory.length > 1) {
						src = CMLParser.instance.rootDirectory + src;
						src = CMLParser.instance.relToAbsPath(src);
					}					
					*/
					
					FileManager.instance.addToQueue(src, node.@type);	
					
				}
			}
			
			return xmlList;
		}		
	}
}

class SingletonEnforcer{}		