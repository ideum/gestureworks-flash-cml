package com.gestureworks.cml.utils
{
	import com.gestureworks.cml.interfaces.IList;
	import com.gestureworks.cml.interfaces.IListIterator;
	
	public class List implements IList, IListIterator 
	{
		private var array:Array;		
		
		public function List()
		{
			array = new Array;
		}
				
		private var _currentIndex:int=0;
		public function get currentIndex():int { return _currentIndex }
		public function set currentIndex(value:int):void { _currentIndex = value; }
		
		private var _currentValue:*;
		public function get currentValue():* { return array[currentIndex]; }		
		
		private var _length:int=0;
		public function get length():int { return array.length }


		public function getIndex(index:int):*
		{
			return array[index];
		}		
		
		public function selectIndex(index:int):*
		{
			_currentIndex = index;
			return array[index];
		}
		
		public function search(value:*):int
		{	
			return array.indexOf(value);
		}
		
		public function append(value:*):void
		{
			array.push(value);			
		}
		
		public function prepend(value:*):void
		{
			array.unshift(value);
			if (currentIndex > 0)
				_currentIndex++;			
		}
		
		public function insert(index:int, value:*):void 
		{
			if (index < 0 || index > array.length)
				throw new Error("array index out of bounds");
			
			var original:Array = array.slice();
			var temp:Array = original.splice(index);
			original[index] = value;
			original = original.concat(temp);
			array = original;
			if (currentIndex >= index)
				_currentIndex++;				
		}
		
		public function remove(index:int):void
		{			
			var original:Array = array.slice(); 
			var temp:Array = original.splice(index); 
			temp.shift();
			original = original.concat(temp); 
			array = original;
			if (currentIndex > 0 && currentIndex >= index)
				_currentIndex--;
		}
		
		public function checkExists(index:int):Boolean
		{
			if (array[index])
				return true;
			else
				return false;
		}		
		
		// iterator methods //
		public function reset():void
		{
			_currentIndex = 0;			
		}
		
		public function hasNext():Boolean
		{
			return _currentIndex < array.length-1;
		}
		
		public function hasPrev():Boolean
		{
			if (currentIndex > 0)
				return true;
			else
				return false;
		}		
		
		public function next():*
		{
			_currentIndex++;
			return array[currentIndex];
		}
		
		public function prev():*
		{
			_currentIndex--;
			return array[currentIndex];
		}
	}
}