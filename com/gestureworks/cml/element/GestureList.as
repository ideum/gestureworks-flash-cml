package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ElementFactory;
	
	public class GestureList extends ElementFactory
	{
		public function GestureList() 
		{
			super();			
		}
		
		private var _gestureList:XMLList;
		public function get gestureList():XMLList{return _gestureList;}
		public function set gestureList(value:XMLList):void
		{
			if (gestureList === value.Gesture) 
				return;
			
			_gestureList = value.Gesture;
			
			var object:Object = new Object();
			
			for (var i:int; i < gestureList.length(); i++)
			{				
				object[(gestureList[i].@ref).toString()] = gestureList[i].@gestureOn;
			}
			
			var p:* = parent;
			if(p) p.gestureList = object;
		}
			
		override public function parseCML(cml:XMLList):XMLList 
		{
			this.gestureList = cml;			
			return new XMLList;
		}	
		
		override public function dispose():void
		{
			super.dispose();
			gestureList = null;
		}
	}
}