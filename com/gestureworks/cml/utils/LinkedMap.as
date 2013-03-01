package com.gestureworks.cml.utils
{	
	import adobe.utils.CustomActions;
	import com.gestureworks.cml.element.Key;
	/**
	 * The LinkedMap utility is a data structure that creates an ordered
	 * map that can store duplicate keys. It has a built-in two-way iterator, 
	 * and contains many options for storing and retrieving values.
	 * 
	 * <p>The structure is comprised of:
	 * <ul>
	 * 	<li>index - the index number (must be an integer)</li>
	 * 	<li>key - the reference key (ussually a string, but can be anything)</li>
	 * 	<li>value - the stored value (can be anything)</li>
	 * </ul></p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		var lm:LinkedMap = new LinkedMap();
		lm.append("s1", new Sprite());
		lm.append("s2", new TouchSprite());
		
		lm.reset();
		trace(lm.next());
	 
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see List
	 */
	public class LinkedMap
	{
		private var keys:List;
		private var values:List;
		
		/**
		 * Constructor
		 * @param	weakKeys
		 */
		public function LinkedMap(weakKeys:Boolean=false)
		{
			keys = new List;
			values = new List;
		}
		
		/**
		 * Returns and sets the current index
		 */
		public function get currentIndex():int { return keys.currentIndex }
		public function set currentIndex(value:int):void { keys.currentIndex = value; }		
		
		
		
		private var _currentKey:int = 0;
		/**
		 * Returns the current key
		 */
		public function get currentKey():* { return keys.selectIndex(currentIndex) };
		
		private var _currentValue:*;
		/**
		 * Returns the current value
		 */
		public function get currentValue():* { return values.getIndex(currentIndex); }	
		
		private var _length:int = 0;
		/**
		 * Returns the length of the LinkedMap
		 */
		public function get length():int { return values.length }

		
		
		/**
		 * Returns the value by index
		 * @param	index
		 * @return
		 */
		public function getIndex(index:int):*
		{			
			return values.getIndex(index);
		}
		
		/**
		 * Returns the value by key
		 * @param	key
		 * @return
		 */
		public function getKey(key:*):*
		{
			return getIndex(keys.search(key));
		}
		
		/**
		 * Returns an array of keys.
		 * @return
		 */
		public function getKeyArray():Array
		{			
			return keys.toArray();
		}		
		
		/**
		 * Returns an array of values
		 * @return
		 */
		public function getValueArray():Array
		{			
			return values.toArray();
		}		
				
		/**
		 * Returns a multidimensional array of key / value pairs
		 * @return
		 */
		public function toArray():Array
		{
			var ret:Array = [];
			var k:Array = keys.toArray();
			var v:Array = values.toArray();
			
			for (var i:int = 0; i < length; i++){
				ret[i] = [];
				ret[i][0] = k[i];
				ret[i][1] = v[i];
			}
			
			return ret;
		}		
		
		
		/**
		 * Returns a value by index and increments the current index 
		 * to the provided index parameter
		 * @param	index
		 * @return
		 */
		public function selectIndex(index:int):*
		{
			currentIndex = index;
			return values.getIndex(currentIndex);
		}		
				
		/**
		 * Returns a value by key and increments the current index 
		 * to the provided index parameter
		 * @param	key
		 * @return
		 */
		public function selectKey(key:*):*
		{			
			currentIndex = keys.search(key);
			return values.getIndex(currentIndex);
		}
		
		
		/**
		 * Searches by value and returns the first index found
		 * @param	value
		 * @return
		 */
		public function search(value:*):int
		{
			return values.search(value);
		}
		
		/**
		 * Searches by value and returns an array of indices found
		 * @param	value
		 * @return
		 */
		public function searchAll(value:*):Array
		{
			return values.searchAll(value);
		}		
	
		
		/**
		 * Appends a value to the keys
		 * @param	key
		 * @param	value
		 */
		public function append(key:*, value:*):void 
		{			
			keys.append(key);
			values.append(value);			
		}
		
		/**
		 * Prepends a key and value
		 * @param	key
		 * @param	value
		 */
		public function prepend(key:*, value:*):void 
		{
			keys.prepend(key);
			values.prepend(value);		
		}
		
		/**
		 * Replaces a value by key. If more than one key is found. The first instance will be replaced.
		 * To replace all keys, repeatedly call replaceKey until key is no longer found.
		 * @param	key
		 * @param	value
		 */
		public function replaceKey(key:*, value:*):void 
		{
			var i:int = keys.search(key);
			keys[i] = key;
			values[i] = value;
		}		
		
		/**
		 * Inserts a new key and value by index
		 * @param	index
		 * @param	key
		 * @param	value
		 */
		public function insert(index:int, key:*, value:*):void 
		{
			keys.insert(index, key);				
			values.insert(index, value);		
		}		
		
		/**
		 * Removes a value by index
		 * @param	index
		 */
		public function removeIndex(index:int):void
		{				
			keys.remove(index);			
			values.remove(index);			
		}		
		
		/**
		 * Removes a value by key
		 * @param	key
		 */
		public function removeKey(key:*):void
		{	
			var i:int = keys.search(key);
			keys.remove(i);
			values.remove(i);		
		}

		/**
		 * Returns true if a value exists for the key
		 * @param	value
		 * @return
		 */
		public function hasKey(key:String):Boolean
		{
			if (keys.search(key) >= 0)
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
			keys.reset();
		}
		
		/**
		 * Returns true if the iteration can return one more than the current index
		 * @return
		 */
		public function hasNext():Boolean
		{
			return keys.hasNext();
		}
		
		/**
		 * Returns true if the iteration can return one less than the current index
		 * @return
		 */
		public function hasPrev():Boolean
		{
			return keys.hasPrev();
		}		
		
		/**
		 * Returns the next value
		 * @return
		 */
		public function next():*
		{
			currentIndex++;
			return values.getIndex(currentIndex);
		}
		
		/**
		 * Returns the previous index
		 * @return
		 */
		public function prev():*
		{
			currentIndex--;
			return values.getIndex(currentIndex);
		}
		
		
	}
}