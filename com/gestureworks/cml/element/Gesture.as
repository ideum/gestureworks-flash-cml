package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ObjectFactory;	
	
	/**
	 * TODO
	 */
	public class Gesture extends ObjectFactory 
	{
		/**
		 * constructor
		 */
		public function Gesture() 
		{
			super();
		}
		
		/**
		 * parses cml file
		 * @param	cml
		 * @return
		 */
		override public function parseCML(cml:XMLList):XMLList 
		{
			return new XMLList;
		}
		
		/**
		 * dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
		}
	}
}