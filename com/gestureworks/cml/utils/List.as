package com.gestureworks.cml.utils
{
	import com.gestureworks.cml.interfaces.IList;
	import com.gestureworks.cml.interfaces.IListIterator;
	
	/**
	 * The List utility is a data structure that creates an ordered
	 * list, has a built-in two-way iterator, and contains many 
	 * options for storing and retreiving values.
	 * 
	 * <p>The structure is comprised of:
	 * <ul>
	 * 	<li>index - the index number (must be an integer)</li>
	 * 	<li>value - the stored value (can be anything)</li>
	 * </ul></p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var l:List = new List();
		l.append(new Sprite());
		l.append(new TouchSprite());
		
		lm.reset();
		//trace(lm.next());	 
	 
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see LinkedMap
	 */
	public class List implements IList, IListIterator 
	{
		/**
		 * Stores the array of items
		 */
		public var array:Array;		
		
		
		/**
		 * Constructor
		 */
		public function List()
		{
			array = new Array;
		}
		
		
		private var _currentIndex:int = 0;
		/**
		 * Returns and sets the current index
		 */
		public function get currentIndex():int { return _currentIndex }
		public function set currentIndex(value:int):void { _currentIndex = value; }
		
		
		private var _currentValue:*;
		/**
		 * Returns the current value
		 */
		public function get currentValue():* { return array[currentIndex]; }		
		
		
		private var _length:int = 0;
		/**
		 * Returns the length of list
		 */
		public function get length():int { return array.length }

		
		/**
		 * Returns the value by index
		 * @param	index
		 * @return
		 */
		public function getIndex(index:int):*
		{
			return array[index];
		}		
		
		
		/**
		 * Returns a value by index and increments the current index 
		 * to the provided index parameter
		 * @param	index
		 * @return
		 */
		public function selectIndex(index:int):*
		{
			_currentIndex = index;
			return array[index];
		}
		
		
		/**
		 * Searches by value and returns the index that matches the value
		 * @param	value
		 * @return
		 */
		public function search(value:*):int
		{	
			return array.indexOf(value);
		}
		
		
		/**
		 * Appends a value to the list
		 * @param	value
		 */
		public function append(value:*):void
		{
			array.push(value);			
		}
		
		
		/**
		 * Prepends a value to the list
		 * @param	value
		 */
		public function prepend(value:*):void
		{
			array.unshift(value);
			if (currentIndex > 0)
				_currentIndex++;			
		}
		
		
		/**
		 * Inserts a new value by index
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
		 * Removes a value by index
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
		 * Returns true if a value exists for the index
		 * @param	value
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
		 * Resets the current index to zero
		 */
		public function reset():void
		{
			_currentIndex = 0;			
		}
		
		/**
		 * Returns true if the iteration can return one more than the current index
		 * @return
		 */
		public function hasNext():Boolean
		{
			return _currentIndex < array.length-1;
		}
		
		/**
		 * Returns true if the iteration can return one less than the current index
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
		 * Returns the next value
		 * @return
		 */
		public function next():*
		{
			_currentIndex++;
			return array[currentIndex];
		}
		
		/**
		 * Returns the previous index
		 * @return
		 */
		public function prev():*
		{
			_currentIndex--;
			return array[currentIndex];
		}
	}
}