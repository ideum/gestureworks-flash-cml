package com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.cml.utils.List;

	/**
	 * ContainerList
	 * Set of display objects with iterator
	 * @author Charles Veasey 
	 */	
	
	public class ContainerList extends Container
	{
		protected var list:List;
		
		public function ContainerList()
		{
			list = new List();
		}
				
		protected var _currentIndex:int;
		public function get currentIndex():int { return _currentIndex; }
		
		protected var _length:int=0;
		public function get length():int { return list.length; }
		
		
		override public function postparseCML(cml:XMLList):void
		{
			for each(var node:* in cml.children())
			{
					list.append(node.@id);
			}		
		}
		
		public function showIndex(index:int):void
		{
			_currentIndex = index;
			var tmp:String = list.selectIndex(index).toString();
			DisplayList.object[tmp].visible = 1;			
		}
		
		public function hideIndex(index:int):void
		{
			var tmp:String = list.selectIndex(index).toString();
			DisplayList.object[tmp].visible = 0;		
		}		
			
		public function showKey(key:String):void
		{
			_currentIndex = list.search(key);
			DisplayList.object[key].visible = 1;			
		}
		
		
		public function hideKey(key:String):void
		{
			_currentIndex = list.search(key);
			DisplayList.object[key].visible = 0;			
		}	
		
		public function reset():void
		{
			_currentIndex = 0;			
		}
		
		public function hasNext():Boolean
		{
			return currentIndex < list.length;
		}
		
		public function hasPrev():Boolean
		{
			if (currentIndex > 0)
				return true;
			else
				return false;
		}		
		
		public function next():void
		{
			hideIndex(_currentIndex);			
			_currentIndex++;
			showIndex(_currentIndex);
		}
		
		public function prev():void
		{
			hideIndex(_currentIndex);			
			_currentIndex--;
			showIndex(_currentIndex);
		}		
	}
}