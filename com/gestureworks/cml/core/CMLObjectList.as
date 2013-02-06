package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.utils.ChildList;
	import com.gestureworks.cml.utils.LinkedMap;
	
	/**
	 * The CMLObjectList class is the master list for all objects created through CML.
	 * 
	 * <p>It is populated by the CMLParser class. It is a singleton class that can 
	 * be accessed through the instance method. The class has an iterator and 
	 * several other cml object selection functions:</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
	 * // returns object by given id string
	 * CMLObjectList.instance.getId("my-id");
	 * 
	 * // returns object by given css class string
	 * CMLObjectList.instance.getCSSClass("my-css-class");
	 * 
	 * // returns object by given as3 class
	 * CMLObjectList.instance.getClass("ImageElement");
	 * 
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.core.CMLParser
	 * @see com.gestureworks.cml.core.CMLDisplay
	 */
	public class CMLObjectList extends ChildList
	{	
		/**
		 * Constructor allows single instance
		 * @inheritDoc
		 * @param	enforcer
		 */
		public function CMLObjectList(enforcer:SingletonEnforcer) {}
		
		private static var _instance:CMLObjectList;
		
		/**
		 * Singleton accessor
		 * @param	none
		 * @return  singleton instance of class.
		 */
		public static function get instance():CMLObjectList 
		{ 
			if (_instance == null)
				_instance = new CMLObjectList(new SingletonEnforcer());			
			return _instance; 
		}
		
		
		/**
		 * Returns cml object by id value.
		 * Same as: CMLObjectList.instance.getKey(value)
		 * @param	id	The string cml object id.
		 * @return  object	The corresponding display object if found.
		 */
		public function getId(id:String):* 
		{
			return CMLObjectList.instance.getKey(id);
		}
	
	}
}
/**
 * class can only be access by the CMLObjectlist class only. 
 */
class SingletonEnforcer{}