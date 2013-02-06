package com.gestureworks.cml.utils
{
	import com.gestureworks.cml.interfaces.IList;
	import com.gestureworks.cml.interfaces.IListIterator;
	import flash.utils.Proxy;
	
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
		
		l.reset();
		trace(l.next());	 
	 
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see LinkedMap
	 */
	public dynamic class List implements IList, IListIterator 
	{
		/**
		 * Stores the vector of items
		 */
		private var vector:Vector.<*>;	
		
		
		/**
		 * Constructor
		 */
		public function List()
		{
			vector = new Vector.<*>();
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
		public function get currentValue():* { return vector[currentIndex]; }		
		
		
		private var _length:int = 0;
		/**
		 * Returns the length of list
		 */
		public function get length():int { return vector.length }

		
		/**
		 * Returns the value by index
		 * @param	index
		 * @return
		 */
		public function getIndex(index:int):*
		{
			return vector[index];
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
			return vector[index];
		}
		
		
		/**
		 * Searches by value and returns the first index that matches the value
		 * @param	value
		 * @return
		 */
		public function search(value:*):int
		{	
			return vector.indexOf(value);
		}
		
		
		/**
		 * Searches by value and returns all found indices in an ordered array
		 * @param	value
		 * @return
		 */
		public function searchAll(value:*):Array
		{
			var arr:Array = [];
			
			for (var i:int = 0; i < length; i++) 
			{
				if (vector[i] == value)
					arr.push(i);
			}
			
			return arr;
		}
		
		
		/**
		 * Appends a value to the list
		 * @param	value
		 */
		public function append(value:*):void
		{
			vector.push(value);			
		}
		
		
		/**
		 * Prepends a value to the list
		 * @param	value
		 */
		public function prepend(value:*):void
		{
			vector.unshift(value);
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
			if (index < 0 || index > vector.length)
				throw new Error("vector index out of bounds");
			
			var original:Vector.<*> = vector.slice();
			var temp:Vector.<*> = original.splice(index, 1);
			original[index] = value;
			original = original.concat(temp);
			vector = original;
			if (currentIndex >= index)
				_currentIndex++;				
		}
		
		
		/**
		 * Removes a value by index
		 * @param	index
		 */
		public function remove(index:int):void
		{			
			var original:Vector.<*> = vector.slice(); 
			var temp:Vector.<*> = original.splice(index, 1); 
			temp.shift();
			original = original.concat(temp); 
			vector = original;
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
			if (vector[index])
				return true;
			else
				return false;
		}		
		
		
		/**
		 * Returns the previous index
		 * @return
		 */
		public function toArray():Array 
		{
			 var ret:Array = [];
			 for each (var elem:* in vector) ret.push(elem);
			 return ret;
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
			return _currentIndex < vector.length-1;
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
			return vector[currentIndex];
		}
		
		/**
		 * Returns the previous index
		 * @return
		 */
		public function prev():*
		{
			_currentIndex--;
			return vector[currentIndex];
		}
	
	
	}
}