package com.gestureworks.cml.utils
{	
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.utils.Dictionary;
	
	/**
	 * The LinkedMap utility is a data structure that creates an ordered
	 * Dictionary, has a built-in two-way iterator, and contains many 
	 * options for storing and retrieving values.
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
		
		/**
		 * Returns a LinkedMap of objects that are of the 
		 * specified CSS class if no second argument is given.
		 * Returns the nth object of the retuned LinkedMap
		 * if the second argument is present. 
		 * @param	value
		 * @param	index
		 * @return
		 */
		public function getCSSClass(value:String, index:int=-1):*
		{
			var tmp:LinkedMap = new LinkedMap(true);
			
			for (var i:int = 0; i < this.length; i++) 
			{
				if (this.getIndex(i).hasOwnProperty("class_"))
				{
					if (this.getIndex(i).class_ == value)
						tmp.append(this.getIndex(i).id, this.getIndex(i));
				}
			}
						
			if (index > -1)
				return tmp.getIndex(index);
			else
				return tmp;
		}
		
		
		/**
		 * Returns a LinkedMap of objects that are of the 
		 * specified AS3 class if no second argument is given.
		 * Returns the nth object of the returned LinkedMap
		 * if the second argument is present.
		 * @param	value
		 * @param	index
		 * @return
		 */
		public function getClass(value:Class, index:int=-1):*
		{
			var tmp:LinkedMap = new LinkedMap(true);
			
			for (var i:int = 0; i < this.length; i++) 
			{
				if (this.getIndex(i) is value)
					tmp.append(this.getIndex(i).id, this.getIndex(i));
			}	
			
			if (index > -1)
				return tmp.getIndex(index);
			else
				return tmp;				
		}		
		
		private var dictionary:Dictionary;
		private var list:List;
		private var listValue:List;
		
		/**
		 * Constructor
		 * @param	weakKeys
		 */
		public function LinkedMap(weakKeys:Boolean=false)
		{
			dictionary = new Dictionary(weakKeys);
			list = new List;
			listValue = new List;
		}
		
		private var _currentIndex:int = 0;
		/**
		 * Returns and sets the current index
		 */
		public function get currentIndex():int { return list.currentIndex }
		public function set currentIndex(value:int):void { list.currentIndex = value; }

		
		private var _uniqueKey:Boolean = false;
		/**
		 * Determines whether the structure enforces unique keys. If 
		 * set to true, a duplicate key value will replace the old one.
		 * @default false
		 */
		public function get uniqueKey():Boolean { return _uniqueKey }
		public function set uniqueKey(value:Boolean):void { _uniqueKey = value }		
		
		
		private var _currentKey:int = 0;
		/**
		 * Returns the current key
		 */
		public function get currentKey():* { return list.selectIndex(currentIndex) };
		
		private var _currentValue:*;
		/**
		 * Returns the current value
		 */
		public function get currentValue():* { return listValue.getIndex(currentIndex); }	
		
		private var _length:int = 0;
		/**
		 * Returns the list length
		 */
		public function get length():int { return list.length }

		
		/**
		 * Returns the value by index
		 * @param	index
		 * @return
		 */
		public function getIndex(index:int):*
		{			
			return listValue.getIndex(index);
		}
		
		/**
		 * Returns the value by key
		 * @param	key
		 * @return
		 */
		public function getKey(key:*):*
		{			
			return dictionary[key];
		}
		
		/**
		 * Returns an array of keys
		 * @return
		 */
		public function getKeyArray():Array
		{			
			return list.array;
		}		
		
		/**
		 * Returns an array of values
		 * @return
		 */
		public function getValueArray():Array
		{			
			return listValue.array;
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
			return listValue.getIndex(index)
		}		
				
		/**
		 * Returns a value by key and increments the current index 
		 * to the provided index parameter
		 * @param	key
		 * @return
		 */
		public function selectKey(key:*):*
		{			
			currentIndex = list.search(key);
			return dictionary[currentKey];
		}
		
		/**
		 * Searches by value and returns the last value found
		 * @param	value
		 * @return
		 */
		public function search(value:*):*
		{
			/*
			var result:*=null;
			for each (var k:* in dictionary)
			{
				if (k == value) {
					result = k;
				}
			}
			return result;	
			*/
			
			var index:int = listValue.search(value);
			return listValue.getIndex(index);
		}
		
		/**
		 * Appends a value to the list
		 * @param	key
		 * @param	value
		 */
		public function append(key:*, value:*):void 
		{
			if (uniqueKey){
				if (dictionary[key] != null){
					list.remove(list.search(key));
					listValue.remove(list.search(key));
				}
			}
			
			list.append(key);
			listValue.append(value);			
			dictionary[key] = value;		
		}
		
		/**
		 * Prepends a key and value
		 * @param	key
		 * @param	value
		 */
		public function prepend(key:*, value:*):void 
		{
			if (uniqueKey){
				if (dictionary[key] != null){
					list.remove(list.search(key));
					listValue.remove(list.search(key));
				}
			}	
			
			list.prepend(key);
			listValue.prepend(value);
			
			dictionary[key] = value;
			if (currentIndex > 0)
				currentIndex++;			
		}
		
		/**
		 * Replaces a value by key
		 * @param	key
		 * @param	value
		 */
		public function replaceKey(key:*, value:*):void 
		{
			dictionary[key] = value;	
		}		
		
		/**
		 * Inserts a new key and value by index
		 * @param	index
		 * @param	key
		 * @param	value
		 */
		public function insert(index:int, key:*, value:*):void 
		{
			if (uniqueKey){
				if (dictionary[key] != null){
					list.remove(list.search(key));
					listValue.remove(list.search(key));
				}
			}	
			
			list.insert(index, key);				
			listValue.insert(index, key);				
			
			dictionary[key] = value;
			if (currentIndex >= index)
				currentIndex++;			
		}		
		
		/**
		 * Removes a value by index
		 * @param	index
		 */
		public function removeIndex(index:int):void
		{	
			var key:* = list.selectIndex(index);
			dictionary[key] = null;
			delete dictionary[key];			
			
			list.remove(index);			
			listValue.remove(index);			
			
			if (currentIndex > 0 && currentIndex >= index)
				currentIndex--;
		}		
		
		/**
		 * Removes a value by key
		 * @param	key
		 */
		public function removeKey(key:*):void
		{	
			var index:int = list.search(key);
			
			list.remove(index);
			listValue.remove(index);
			
			dictionary[key] = null;
			delete dictionary[key];	
			if (currentIndex > 0 && currentIndex >= index)
				currentIndex++;			
		}

		/**
		 * Returns true if a value exists for the key
		 * @param	value
		 * @return
		 */
		public function hasKey(key:String):Boolean
		{
			if (dictionary[key] == null)
				return false;
			else
				return true;
		}		
		
		
		// iterator methods //
		
		
		/**
		 * Resets the current index to zero
		 */
		public function reset():void
		{
			currentIndex = 0;
		}
		
		/**
		 * Returns true if the iteration can return one more than the current index
		 * @return
		 */
		public function hasNext():Boolean
		{
			return currentIndex < list.length-1;
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
			currentIndex++;
			return listValue.getIndex(currentIndex);
		}
		
		/**
		 * Returns the previous index
		 * @return
		 */
		public function prev():*
		{
			currentIndex--;
			return listValue.getIndex(currentIndex);
		}
		
		
	}
}