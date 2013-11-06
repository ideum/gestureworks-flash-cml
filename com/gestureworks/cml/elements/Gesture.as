package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLObject;
	
	/**
	 * The Gesture class allows you to create gestures in CML.
	 * 
	 * <p>It is not intended to be used outside of CML. Use native 
	 * methods of the TouchSprite or TouchContainer to assign 
	 * gestures in AS3.</p>
	 * 
	 * <p>When using this class as a CML tag, it a parent 
	 * <code>GestureList</code> tag is required.</p>
	 * 
	 * @author Ideum
	 * @see GestureList
	 * @see TouchContainer
	 */
	public class Gesture extends CMLObject 
	{
		/**
		 * Constructor
		 */
		public function Gesture() 
		{
			super();
		}
		
		/**
		 * Parses cml file
		 * @param	cml
		 * @return
		 */
		override public function parseCML(cml:XMLList):XMLList 
		{
			return new XMLList;
		}
	}
}