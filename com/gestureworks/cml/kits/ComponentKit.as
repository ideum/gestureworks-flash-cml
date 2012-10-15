package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.element.Container;
	
	/**
	 * The ComponentKit creates and manges components. It contains
	 * a special property called the rendererList, which allows for the 
	 * creation of multiple objects through a CML template system called 
	 * the RenderKit
	 * 
	 * <p>This class is meant to be used within CML and is not compatible 
	 * with AS3.</p>
	 * 
	 * @author Ideum
	 * @see RenderKit
	 */
	public class ComponentKit extends Container
	{
		/**
		 * Constructor
		 */	
		public function ComponentKit() 
		{
			super();			
		}
		
		
		private var _classRef:String;
		/**
		 * Specifies the class reference to the object
		 */
		public function get classRef():String{return _classRef;}
		public function set classRef(value:String):void
		{
			_className = value;
			_classRef = value;			
		}
		
		
		private var _className:String;
		/**
		 * Specifies the class name of object
		 */
		override public function get className():String { return _className ; }
		override public function set className(value:String):void
		{
			_className = value;
			_classRef = value;			
		}			
		
		
		private var _rendererList:String;
		/**
		 * Specifies a RenderKit renderer
		 */
		public function get rendererList():String{return _rendererList;}
		public function set rendererList(value:String):void
		{			
			if (_rendererList == value)
				return;
				
			_rendererList = value;
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