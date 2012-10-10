////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.utils.LinkedMap;
	
	/**
	 * The CmlObjectList is the master list for all objects created through cml.
	 * 
	 * <p>It is populated by the CMLParser class.</p> 
	 * <p>It is a singleton class that can be accessed through the instance method.</p>
	 * <p>The class has an iterator and several other cml object selection functions:</p>
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
	 * @author Charles Veasey
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * @langversion 3.0
	 *
	 * @see com.gestureworks.cml.core.CMLParser
	 */
	public class CMLObjectList extends LinkedMap
	{	
		/**
		 * constructor allows single instance
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