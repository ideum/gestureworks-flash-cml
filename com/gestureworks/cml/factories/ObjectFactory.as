package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.interfaces.IObject;
	import flash.display.Sprite;	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * ObjectFactory
	 * @authors Charles Veasey 
	 */
	public class ObjectFactory extends EventDispatcher implements IObject
	{
		public function ObjectFactory() 
		{
			super();
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);
		}	
		
		public function dispose():void 
		{ 			
			propertyStates = null;
		}
		
		public var propertyStates:Array;
		
		private var _cmlIndex:int;
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}		
		
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