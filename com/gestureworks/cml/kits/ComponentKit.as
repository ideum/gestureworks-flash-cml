package com.gestureworks.cml.kits 
{	
	import com.gestureworks.cml.element.Container;
	
	public class ComponentKit extends Container
	{
		public function ComponentKit() 
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
		
		
		
		
		override public function dispose():void 
		{
			super.dispose();
		}
	}
}