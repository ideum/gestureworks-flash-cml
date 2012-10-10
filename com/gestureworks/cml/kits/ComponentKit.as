package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.element.Container;
	
	/**
	 * ComponentKit creates and manges the component
	 */
	public class ComponentKit extends Container
	{
		/**
		 * constructor
		 */	
		public function ComponentKit() 
		{
			super();			
		}
		
		
		private var _classRef:String;
		/**
		 * specifies the class reference of object
		 */
		public function get classRef():String{return _classRef;}
		public function set classRef(value:String):void
		{
			_className = value;
			_classRef = value;			
		}
		
		
		private var _className:String;
		/**
		 * specifies the class name of object
		 */
		override public function get className():String { return _className ; }
		override public function set className(value:String):void
		{
			_className = value;
			_classRef = value;			
		}			
		
		
		private var _rendererList:String;
		/**
		 * renders the list
		 */
		public function get rendererList():String{return _rendererList;}
		public function set rendererList(value:String):void
		{			
			if (_rendererList == value)
				return;
				
			_rendererList = value;
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