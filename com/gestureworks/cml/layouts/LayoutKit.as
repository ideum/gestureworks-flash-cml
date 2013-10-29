package com.gestureworks.cml.layouts 
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
			var ref:String = "";

			if (cml.@ref != undefined) {
				ref = String(cml.@ref);
			} 
			else if (cml.@classRef != undefined) {
				ref = String(cml.@classRef);
			}			
			
			if (ref.length) {				
				if (!ref.search("Layout") == -1) {
					ref = ref + "Layout";
				}
				obj = CMLParser.instance.createObject(ref);
			}
			else
				throw new Error("The Layout tag requires the 'ref' attribute");
			
			obj.id = cml.@id;
			
			LayoutManager.instance.addLayout(obj.id, obj);
			
			// apply attributes
			var attrName:String;
			var returnNode:XMLList = new XMLList;
			
			for each (var attrValue:* in cml.@*) {				
				attrName = attrValue.name().toString();
				if (attrName != "ref" && attrName != "classRef")
					LayoutManager.instance.layoutList[obj.id][attrName] = attrValue;
			}
			
			attrName = null;
			return xmlList;
		}		
	}
}

class SingletonEnforcer{}		