package com.gestureworks.cml.core
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	
	/**
	 * The ComponentKitDisplay class.
	 * 
	 * @see flash.display.Sprite
	 * 
	 * 
	 * @langversion 3.0
	 * @playerversion AIR 2.5
	 * @playerversion Flash 10.1
	 * @productversion GestureWorks 3.0
	 */
	
	public class ComponentKitDisplay extends Container
	{
		protected var renderKit:XML;		
		
		/**
		 *  ComponentKitDisplay Constructor.
		 *  
		 * @langversion 3.0
		 * @playerversion AIR 1.5
		 * @playerversion Flash 10
		 * @playerversion Flash Lite 4
		 * @productversion GestureWorks 1.5
		 */
		public function ComponentKitDisplay()
		{
			super();
		}
			
		
		private var _classRef:String;
		public function get classRef():String{return _classRef;}
		public function set classRef(value:String):void
		{
			_className = value;
			_classRef = value;			
		}
		
		
		private var _className:String;
		override public function get className():String { return _className ; }
		override public function set className(value:String):void
		{
			_className = value;
			_classRef = value;			
		}			
		
		
		private var _rendererList:String;
		public function get rendererList():String{return _rendererList;}
		public function set rendererList(value:String):void
		{			
			if (_rendererList == value)
				return;
				
			_rendererList = value;
		}
		
	}
}