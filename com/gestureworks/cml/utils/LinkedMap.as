package com.gestureworks.cml.utils
{	
	import flash.utils.*;
	
	/**
	 * linked map maintains the order of entries
	 */
	public class LinkedMap
	{
		private var dictionary:Dictionary;
		private var list:List;
		private var listValue:List;
		
		/**
		 * constructor
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
		 * sets the current index of the element
		 */
		public function get currentIndex():int { return list.currentIndex }
		public function set currentIndex(value:int):void { list.currentIndex = value; }
		
		private var _currentKey:int = 0;
		/**
		 * returns the current key value
		 */
		public function get currentKey():* { return list.selectIndex(currentIndex) };
		
		private var _currentValue:*;
		/**
		 * returns the current value of entries
		 */
		public function get currentValue():* { return listValue.getIndex(currentIndex); }	
		
		private var _length:int = 0;
		/**
		 * returns the list length
		 */
		public function get length():int { return list.length }

		
		/**
		 * returns the index of the list
		 * @param	index
		 * @return
		 */
		public function getIndex(index:int):*
		{			
			return listValue.getIndex(index);
		}
		
		/**
		 * returns the object key
		 * @param	key
		 * @return
		 */
		public function getKey(key:*):*
		{			
			return dictionary[key];
		}
		
		/**
		 * returns the list
		 * @return
		 */
		public function getKeyArray():Array
		{			
			return list.array;
		}		
		
		/**
		 * returns the list value
		 * @return
		 */
		public function getValueArray():Array
		{			
			return listValue.array;
		}		
		
		
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
		
		/**
		 * returns the index
		 * @param	index
		 * @return
		 */
		public function selectIndex(index:int):*
		{
			currentIndex = index;
			return listValue.getIndex(index)
		}		
				
		/**
		 * returns the current key of the object
		 * @param	key
		 * @return
		 */
		public function selectKey(key:*):*
		{			
			currentIndex = list.search(key);
			return dictionary[currentKey];
		}
		
		/**
		 * searches and returns the result of object
		 * @param	value
		 * @return
		 */
		public function search(value:*):*
		{	
			var result:*=null;
			for each (var k:* in dictionary)
			{
				if (k == value)
					result = k;
			}
			return result;			
		}
		
		/**
		 * appends value to the list
		 * @param	key
		 * @param	value
		 */
		public function append(key:*, value:*):void 
		{
			//if (dictionary[key] != null)
				//list.remove(list.search(key));
			list.append(key);
			listValue.append(value);			
			dictionary[key] = value;		
		}
		
		/**
		 * prpends the key and the value
		 * @param	key
		 * @param	value
		 */
		public function prepend(key:*, value:*):void 
		{
			//if (dictionary[key] != null)
		//	{
			//	list.remove(list.search(key));
				//listValue.remove(list.search(key));			
			//}	
			
			list.prepend(key);
			listValue.prepend(value);
			
			dictionary[key] = value;
			if (currentIndex > 0)
				currentIndex++;			
		}
		
		/**
		 * replaces value with the key
		 * @param	key
		 * @param	value
		 */
		public function replaceKey(key:*, value:*):void 
		{
			dictionary[key] = value;	
		}		
		
		/**
		 * inserts key and value to the list
		 * @param	index
		 * @param	key
		 * @param	value
		 */
		public function insert(index:int, key:*, value:*):void 
		{
			//if (dictionary[key] != null)
			//{
			//	list.remove(list.search(key));
			//	listValue.remove(list.search(key));
			//}	
			
			list.insert(index, key);				
			listValue.insert(index, key);				
			
			dictionary[key] = value;
			if (currentIndex >= index)
				currentIndex++;			
		}		
		
		/**
		 * removes the object key and the list index
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
		 * removes the keys
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

		// iterator methods //
		/**
		 * restes the current index
		 */
		public function reset():void
		{
			currentIndex = 0;
		}
		
		/**
		 * returns the index
		 * @return
		 */
		public function hasNext():Boolean
		{
			return currentIndex < list.length-1;
		}
		
		/**
		 * compares the current index and returns true or false
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
		 * returns the next index
		 * @return
		 */
		public function next():*
		{
			currentIndex++;
			return listValue.getIndex(currentIndex);
		}
		
		/**
		 * returns the previous index
		 * @return
		 */
		public function prev():*
		{
			currentIndex--;
			return listValue.getIndex(currentIndex);
		}
		
		/**
		 * checks the value of object and returns true or false
		 * @param	value
		 * @return
		 */
		public function hasKey(value:String):Boolean
		{
			if (dictionary[value] == null)
				return false;
			else
				return true;
		}
		
	}
}