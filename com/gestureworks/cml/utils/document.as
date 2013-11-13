package com.gestureworks.cml.utils {

	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.core.CMLParser;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class document {
		/**
		 * Searches the CML document by id. The first object is returned.
		 * @param	id
		 * @return Matched object.
		 */	
		static public function getElementById(id:String):* {	
			return CMLObjectList.instance.getId(id);
		}
		
		/**
		 * Searches the CML document by tagName as type Class. An array of objects are returned.
		 * @param	tagName
		 * @return Array of found objects.
		 */
		static public function getElementsByTagName(tagName:Class):Array {
			return CMLObjectList.instance.getClass(tagName).getValueArray();			
		}

		/**
		 * Searches the CML document by CSS class name. An array of objects are returned.
		 * @param	className
		 * @return
		 */
		static public function getElementsByClassName(className:String):Array {
			return CMLObjectList.instance.getCSSClass(className).getValueArray();
		}
		
		/**
		 * Searches the CML document by selector. The first object is returned.
		 * @param	selector
		 * @return
		 */
		static public function querySelector(selector:String):* {			
			return CMLParser.cmlDisplay.searchChildren(selector);
		}		

		/**
		 * Search the CML document by selector. An array of objects are returned.
		 * @param	selector
		 * @return
		 */
		static public function querySelectorAll(selector:*):Array {
			return CMLParser.cmlDisplay.searchChildren(selector, Array);
		}	
		
	}	
}
