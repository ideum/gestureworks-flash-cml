package com.gestureworks.cml.core 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.interfaces.IObject;
	import com.gestureworks.cml.utils.ChildList;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/** 
	 * The CMLObject is the base class for all CML Objects.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 */	 
	public class CMLObject extends EventDispatcher implements IObject
	{
		private var _cmlIndex:int;		
		private var _id:String
		private var _childList:ChildList;
		
		/**
		 * Constructor
		 */
		public function CMLObject() 
		{
			super();
			state = [];
			state[0] = new Dictionary(false);
			_childList = new ChildList;
		}	
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void { 			
			state = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public var state:Array;
		
		
		/**
		 * @inheritDoc
		 */
		public function get cmlIndex():int { return _cmlIndex };
		public function set cmlIndex(value:int):void {
			_cmlIndex = value;
		}		
		
		/**
		 * @inheritDoc
		 */
		public function get id():String {return _id};
		public function set id(value:String):void {
			_id = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get childList():ChildList { return _childList; }			
		public function set childList(value:ChildList):void { _childList = value };		
		
		/**
		 * @inheritDoc
		 */		
		public function init():void {}		
		
		/**
		 * @inheritDoc
		 */
		public function parseCML(cml:XMLList):XMLList {			
			return CMLParser.parseCML(this, cml);
		}
		
		/**
		 * @inheritDoc
		 */
		public function postparseCML(cml:XMLList):void {}
		
		/**
		 * @inheritDoc
		 */
		public function updateProperties(state:*=0):void {
			CMLParser.updateProperties(this, state);		
		}	
	
		/**
		 * Clone method.
		 * @return Clone
		 */
		public function clone():* { return new Object };
		
	}
}