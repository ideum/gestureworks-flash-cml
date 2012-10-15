package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.interfaces.ICML;
	import com.gestureworks.cml.managers.LayoutManager;
	
	/**
	 * The LayoutKit stores global layouts that can be accessed throughout
	 * the CML file.
	 * 
	 * <p>This class is meant to be used within CML and is not compatible 
	 * with AS3.</p>
	 * 
	 * @author Charles
	 * @see Container
	 * @see LayoutFactory
	 */
	public class LayoutKit implements ICML
	{
		public function LayoutKit(enforcer:SingletonEnforcer) {}		
		
		private static var _instance:LayoutKit;
		/**
		 * Singleton accesor method
		 */
		public static function get instance():LayoutKit 
		{ 
			if (_instance == null)
				_instance = new LayoutKit(new SingletonEnforcer());			
			return _instance;	
		}		
		
		/**
		 * Parses cml
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList
		{
			var xmlList:XMLList = null;
			var obj:*;
			
			for each (var node:* in cml.*)
			{
				if (node.name().toString() == "Layout")
				{					
					obj = CMLParser.instance.createObject(node.@classRef);
					obj.id = node.@id;
					
					LayoutManager.instance.addLayout(obj.id, obj);
					
					// apply attributes
					var attrName:String;
					var returnNode:XMLList = new XMLList;
					
					for each (var attrValue:* in node.@*)
					{				
						attrName = attrValue.name().toString();
						if (attrName != "classRef")
							LayoutManager.instance.layoutList[obj.id][attrName] = attrValue;
					}
					
					attrName = null;					
					
				}
			}
			
			return xmlList;
		}		
	}
}

class SingletonEnforcer{}		