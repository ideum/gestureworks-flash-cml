package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ObjectFactory;	
	
	public class Gesture extends ObjectFactory 
	{
		public function Gesture() 
		{
			super();
		}
		
		
		override public function parseCML(cml:XMLList):XMLList 
		{
			return new XMLList;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}