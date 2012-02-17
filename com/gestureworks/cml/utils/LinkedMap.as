package com.gestureworks.cml.utils
{	
	import flash.utils.Dictionary;
	
	public class LinkedMap
	{
		private var dictionary:Dictionary;
		private var list:List;
		
		public function LinkedMap(weakKeys:Boolean=false)
		{
			dictionary = new Dictionary(weakKeys);
			list = new List;		
		}
		
		private var _currentIndex:int=0;
		public function get currentIndex():int { return list.currentIndex }
		public function set currentIndex(value:int):void { list.currentIndex = value; }
		
		private var _currentKey:int=0;
		public function get currentKey():* { return list.selectIndex(currentIndex) };
		
		private var _currentValue:*;
		public function get currentValue():* { return dictionary[currentKey]; }	
		
		private var _length:int=0;
		public function get length():int { return list.length }

		public function getIndex(index:int):*
		{
			currentIndex = index;
			return dictionary[currentKey];
		}
		
		public function getKey(key:*):*
		{			
			return dictionary[key];
		}		
		
		public function selectIndex(index:int):*
		{
			currentIndex = index;
			return dictionary[currentKey];
		}		
				
		public function selectKey(key:*):*
		{			
			currentIndex = list.search(key);
			return dictionary[currentKey];
		}
		
		public function search(value:*):*
		{	
			var result:*=null;
			for each (var k:* in dictionary)
			{
				if (dictionary[k] == value)
					result = k;
			}
			return result;			
		}
		
		public function append(key:*, value:*):void 
		{
			if (dictionary[key] != null)
				list.remove(list.search(key));
			list.append(key);				
			dictionary[key] = value;		
		}
		
		public function prepend(key:*, value:*):void 
		{
			if (dictionary[key] != null)
				list.remove(list.search(key));
			list.prepend(key);				
			dictionary[key] = value;
			if (currentIndex > 0)
				currentIndex++;			
		}
		
		public function insert(index:int, key:*, value:*):void 
		{
			if (dictionary[key] != null)
				list.remove(list.search(key));			
			list.insert(index, key);				
			dictionary[key] = value;
			if (currentIndex >= index)
				currentIndex++;			
		}		
		
		public function removeIndex(index:int):void
		{	
			var key:* = list.selectIndex(index);
			dictionary[key] = null;
			delete dictionary[key];			
			list.remove(index);
			if (currentIndex > 0 && currentIndex >= index)
				currentIndex--;
		}		
		
		public function removeKey(key:*):void
		{	
			var index:int = list.search(key);
			list.remove(index);
			dictionary[key] = null;
			delete dictionary[key];	
			if (currentIndex > 0 && currentIndex >= index)
				currentIndex++;			
		}

		// iterator methods //
		public function reset():void
		{
			currentIndex = 0;
		}
		
		public function hasNext():Boolean
		{
			return currentIndex < list.length-1;
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
			currentIndex++;
			return dictionary[currentKey];
		}
		
		public function prev():*
		{
			currentIndex--;
			return dictionary[currentKey];
		}
		
		public function hasKey(value:String):Boolean
		{
			if (dictionary[value] == null)
				return false;
			else
				return true;
		}
		
	}
}