package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.interfaces.IObject;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/** 
	 * The ObjectFactory is the base class for all CML Objects.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.factories.ElementFactory
	 * @see com.gestureworks.cml.factories.GraphicFactory
	 */	 
	public class CMLObject extends EventDispatcher implements IObject
	{
		/**
		 * Constructor
		 */
		public function CMLObject() 
		{
			super();
			state = [];
			state[0] = new Dictionary(false);
			this['propertyStates'] = state;
		}	
		
		/**	
		 * Dispose method
		 */
		public function dispose():void 
		{ 			
			state = null;
		}
		
		/**
		 * property states array
		 */
		public var state:Array;
		
		[Deprecated(replacement="state")]		
		public var propertyStates:Array;
		
		
		private var _cmlIndex:int;
		/**
		 * sets the index of cml
		 */
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}		
		
		private var _id:String
		/**
		 * sets the id
		 */
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		/**
		 * parses cml file
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList
		{			
			return CMLParser.instance.parseCML(this, cml);
		}
		
		/**
		 * postparse method 
		 * @param	cml
		 */
		public function postparseCML(cml:XMLList):void {}
		
		/**
		 * update the properties
		 * @param	state
		 */
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}	
	
				
		//////////////
		//  IClone  
		//////////////		
		
		/**
		 * Returns clone of self
		 */
		public function clone():* {return new Object};			
	}
}