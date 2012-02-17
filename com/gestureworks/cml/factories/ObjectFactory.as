package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.interfaces.IObject;
	import flash.display.Sprite;	
	import flash.utils.Dictionary;
	
	/**
	 * ObjectFactory
	 * @authors Matthew Valverde and Charles Veasey 
	 */
	public class ObjectFactory implements IObject
	{
		public function ObjectFactory() 
		{
			super();
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);
		}
		
		
		////////////////
		//  IOBJECT  
		///////////////		
		
		public function dispose():void{};
		
		public var propertyStates:Array;
		
		
		private var _id:String
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		
		public function parseCML(cml:XMLList):XMLList
		{			
			return CMLParser.instance.parseCML(this, cml);
		}
		
		
		public function postparseCML(cml:XMLList):void {}
		
		
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}	
	
		
	}
}