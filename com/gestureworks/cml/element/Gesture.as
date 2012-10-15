package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ObjectFactory;	
	
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
	public class Gesture extends ObjectFactory 
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
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
		}
	}
}