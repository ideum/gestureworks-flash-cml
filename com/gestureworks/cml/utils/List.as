package com.gestureworks.cml.utils
{
	import com.gestureworks.cml.interfaces.IList;
	import com.gestureworks.cml.interfaces.IListIterator;
	
	/**
	 * List class stores more than one item at the same time
	 */
	public class List implements IList, IListIterator 
	{
		/**
		 * stores number of itmes in the array
		 */
		public var array:Array;		
		
		/**
		 * constructor
		 */
		public function List()
		{
			array = new Array;
		}
				
		private var _currentIndex:int = 0;
		/**
		 * sets the current index of the item
		 * @default=0;
		 */
		public function get currentIndex():int { return _currentIndex }
		public function set currentIndex(value:int):void { _currentIndex = value; }
		
		private var _currentValue:*;
		/**
		 * returns the current index of array
		 */
		public function get currentValue():* { return array[currentIndex]; }		
		
		private var _length:int = 0;
		/**
		 * returns the length of array
		 */
		public function get length():int { return array.length }

		/**
		 * returns the array index
		 * @param	index
		 * @return
		 */
		public function getIndex(index:int):*
		{
			return array[index];
		}		
		
		/**
		 * stores the index value in the current index and returns the array index
		 * @param	index
		 * @return
		 */
		public function selectIndex(index:int):*
		{
			_currentIndex = index;
			return array[index];
		}
		
		/**
		 * finds the value and returns the index position of item
		 * @param	value
		 * @return
		 */
		public function search(value:*):int
		{	
			return array.indexOf(value);
		}
		
		/**
		 * Adds one or more elements to the end of an array 
		 * @param	value
		 */
		public function append(value:*):void
		{
			array.push(value);			
		}
		
		/**
		 * Adds one or more elements to the beginning of an array and returns the new length of the array.
		 * @param	value
		 */
		public function prepend(value:*):void
		{
			array.unshift(value);
			if (currentIndex > 0)
				_currentIndex++;			
		}
		
		/**
		 * checks the condition and throws the error
		 * returns a new array that consists of a range of elements from the original array, without modifying the original array.
		 * adds elements and removes element from array
		 * inserts the index and the value of the element
		 * @param	index
		 * @param	value
		 */
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
		
		/**
		 * removes the index
		 * @param	index
		 */
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
		
		/**
		 * checks for the index
		 * @param	index
		 * @return
		 */
		public function hasIndex(index:int):Boolean
		{
			if (array[index])
				return true;
			else
				return false;
		}		
		
		// iterator methods //
		/**
		 * reset the current index value
		 */
		public function reset():void
		{
			_currentIndex = 0;			
		}
		
		/**
		 * returns next element
		 * @return
		 */
		public function hasNext():Boolean
		{
			return _currentIndex < array.length-1;
		}
		
		/**
		 * compares the current index value and returns tru or false
		 * @return
		 */
		public function hasPrev():Boolean
		{
			if (currentIndex > 0)
				return true;
			else
				return false;
		}		
		
		/**
		 * returns the next current index
		 * @return
		 */
		public function next():*
		{
			_currentIndex++;
			return array[currentIndex];
		}
		
		/**
		 * returns the previous current index
		 * @return
		 */
		public function prev():*
		{
			_currentIndex--;
			return array[currentIndex];
		}
	}
}