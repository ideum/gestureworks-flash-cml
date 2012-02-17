package com.gestureworks.cml.core
{
	import com.gestureworks.cml.utils.LinkedMap;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import com.gestureworks.events.DisplayEvent;
	
	public class ContainerDisplay extends ElementFactory
	{
		public function ContainerDisplay()
		{
			_childList = new LinkedMap;
		}	
		
		override public function dispose():void{parent.removeChild(this);}
				
		
		private var _childList:LinkedMap;
		public function get childList():LinkedMap {return _childList;}	
		
		
		private var _dimensionsTo:String;
		public function get dimensionsTo():String { return _dimensionsTo ; }
		public function set dimensionsTo(value:String):void
		{
			_dimensionsTo = value;	
		}
		
		
		public function addAllChildren():void
		{	
			for (var i:int = 0; i < _childList.length; i++) 
			{
				addChild(_childList.getIndex(i));
			}
		}
		
		private var _infoSource:String="";
		public function get infoSource():String{return _infoSource;}
		public function set infoSource(value:String):void{_infoSource = value;}
		
		
		
		public function childToList(id:String, child:*):void
		{
			childList.append(id, child);
		}
		

		// called in layoutCML() method of DisplayManager
		public function setDimensionsToChild():void
		{
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i).id == dimensionsTo)
				{
					this.width = childList.getIndex(i).width;
					this.height = childList.getIndex(i).height;
				}	
			}

			// is this still neccesary???
			//updateChildren();
		}		

		
		private function updateChildren():void
		{			
			for (var i:int = 0; i < childList.length; i++)
			{
				if (childList.getIndex(i).hasOwnProperty("updateProperties")) 
					childList.getIndex(i).updateProperties();
			}
			
			//childrenHaveUpdated();
		}
			


	}
}