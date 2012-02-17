package com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.utils.List;
	
	/**
	 * ImageList
	 * Set of images, array with iterator and toggle
	 * @author Charles Veasey
	 */	
	
	public class ImageList extends ElementFactory
	{
		private var image:ImageElement;		
		private var list:List;
		
		public function ImageList() 
		{
			list = new List;
		}
		
		private var _currentIndex:int=0;
		public function get currentIndex():int { return list.currentIndex }
		public function set currentIndex(value:int):void { list.currentIndex = value; }
		
		private var _currentValue:*;
		public function get currentValue():* { return list.currentValue; }	
		
		private var _length:int=0;
		public function get length():int { return list.length }		
		
		private var _autoShow:Boolean=false;
		public function get autoShow():Boolean { return _autoShow; }
		public function set autoShow(value:Boolean):void 
		{ 
			_autoShow = value; 	
		}

		public function get(index:int):*
		{
			return list.get(index);
		}			
		
		public function select(index:int):*
		{
			return list.select(index);
		}		
		
		public function search(value:*):*
		{	
			return list.search(value);			
		}
		
		public function append(file:String):void 
		{	
			var img:ImageElement = new ImageElement;
			img.src = file;
			list.append(img);
			if (_autoShow)
				addChild(img);	
		}
		
		public function prepend(file:String):void 
		{
			var img:ImageElement = new ImageElement;
			img.src = file;
			list.prepend(img);
			if (_autoShow)
				addChild(img);			
		}
		
		public function insert(index:int, file:String):void 
		{
			var img:ImageElement = new ImageElement;
			img.src = file;
			list.insert(index, img);
			if (_autoShow)
				addChild(img);		
		}		
		
		public function removeIndex(index:int):void
		{	
			list.remove(index);	
		}		
		
		public function reset():void
		{
			list.currentIndex = 0;		
		}
		
		public function hasNext():Boolean
		{
			return list.hasNext();
		}
		
		public function hasPrev():Boolean
		{
			return list.hasPrev();
		}		
		
		public function next():*
		{
			return list.next();
		}
		
		public function prev():*
		{
			return list.prev();
		}
		
		public function checkExists(index:int):Boolean
		{
			return list.checkExists(index);
		}
		
		public function show(index:int):void
		{
			addChild(list.select(index));
		}
		
		public function hide(index:int):void
		{
			removeChild(list.get(index));
		}
		
		public function toggle(index1:int, index2:int):void
		{	
			if (contains(list.get(index1)))
			{	
				removeChild(list.get(index1));
				addChild(list.select(index2));
			}
			else if (contains(list.get(index2)))
			{	
				removeChild(list.get(index2));
				addChild(list.select(index1));			
			}
		}
		
	}
}