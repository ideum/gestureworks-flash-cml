package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.TouchContainerDisplay;
	
	public class TouchContainer extends TouchContainerDisplay
	{	
		public function TouchContainer()
		{
			super();
			//mouseChildren = false;
		}
		
		/*
		override public function get mouseChildren():Boolean 
		{
			return super.mouseChildren;
		}
		
		override public function set mouseChildren(value:Boolean):void 
		{
			//trace("mouseChildren in touch container:", value)
			super.mouseChildren = value;
		}*/

		
		public function showIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}
		
		public function hideIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}		
			
		public function showKey(key:String):void
		{
			childList.getKey(key).visible = true;
		}
				
		public function hideKey(key:String):void
		{
			childList.getKey(key).visible = false;
		}		
	
		
		private var _scale:Number = 1;
		/**
		 * Scales display object
		 */	
		public function get scale():Number{return _scale;}
		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = scale;
			scaleY = scale;
		}		
		
		
		
		/**
		 * This method does a depth first search of childLists. Search parameter can a simple CSS selector 
		 * (id or class) or AS3 Class. If found, a corresponding display object is returned, if not, null is returned.
		 * The first occurrance that matches the parameter is returned.
		 */			
		public function searchChildren(value:*):*
		{
			var returnVal:* = null;
			var searchType:String = null;
			
			// determine search method
			if (value is Class)
			{
				searchType = "getClass";
			}
			else
			{				
				// determine type and strip the first character
				if (value.charAt(0) == "#")
				{
					searchType = "getKey";
					value = value.substring(1);
				}
				else if (value.charAt(0) == ".")
				{
					searchType = "getCSSClass";
					value = value.substring(1);
				}
				else //default to id
				{
					searchType = "getKey";
				}
			}				
			
			// run first level search
			if (searchType == "getKey" && this.childList.getKey(value))
			{	
				return this.childList.getKey(value);
			}
			else if (searchType == "getCSSClass" && this.childList.getCSSClass(value, 0))
			{
				return this.childList.getCSSClass(value, 0);
			}
			else if (searchType == "getClass" && this.childList.getClass(value, 0))
			{
				return this.childList.getClass(value, 0);
			}
			
			// recursive search through sub-children's childList
			else 
			{
				if (this.childList.getValueArray())
					returnVal = loopSearch(this.childList.getValueArray(), value, searchType);
			}
			
			function loopSearch(arr:Array, val:*, sType:String):*
			{	
				for (var i:int = 0; i < arr.length; i++) 
				{					
					if (arr[i].hasOwnProperty("childList"))
					{												
						if (sType == "getCSSClass" || sType == "getClass")
						{
							if (arr[i].childList[sType](val, 0))
								return arr[i].childList[sType](val, 0);						
						}
						else 
						{
							if (arr[i].childList[sType](val))
								return arr[i].childList[sType](val);
						}
						
						if (arr[i].childList.getValueArray())
							loopSearch(arr[i].childList.getValueArray(), val, sType);							
					}
				}				
			}
			
			return returnVal;
		}				
		
		
	}
}