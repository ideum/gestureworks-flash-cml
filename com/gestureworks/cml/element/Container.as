package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	
	public class Container extends ContainerDisplay implements IContainer
	{				
		
		public function Container()
		{
			super();
		}	
		
		private var _layout:String;
		/**
		 * 
		 */
		public function get layout():String {return _layout;}
		public function set layout(value:String):void 
		{
			_layout = value;
		}
		
		private var _position:String;
		/**
		 * 
		 */
		public function get position():String {return _position;}
		public function set position(value:String):void 
		{
			_position = value;
		}
		
		private var _paddingLeft:Number=0;
		/**
		 * 
		 */
		public function get paddingLeft():Number {return _paddingLeft;}
		public function set paddingLeft(value:Number):void 
		{
			_paddingLeft = value;
		}	
		
		private var _paddingRight:Number=0;
		/**
		 * 
		 */
		public function get paddingRight():Number {return _paddingRight;}
		public function set paddingRight(value:Number):void 
		{
			_paddingRight = value;
		}	
		
		private var _paddingTop:Number=0;
		/**
		 * 
		 */
		public function get paddingTop():Number {return _paddingTop;}
		public function set paddingTop(value:Number):void 
		{
			_paddingTop = value;
		}	
		
		private var _paddingBottom:Number=0;
		/**
		 * 
		 */
		public function get paddingBottom():Number {return _paddingBottom;}
		public function set paddingBottom(value:Number):void 
		{
			_paddingBottom = value;
		}	
		
		
			
		public function showIndex(index:int):void
		{
			childList.getIndex(index).visible = true;
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
		
		public function getKey(key:String):*
		{
			return childList.getKey(key);
		}
			
		public function getIndex(index:int):*
		{
			return childList.getIndex(index);
		}
		
	
		
		/**
		 * This method does a depth first search of childLists. Search parameter can be a simple CSS selector 
		 * (id or class) or AS3 Class. If found, a corresponding display object is returned, if not, null is returned.
		 * The first occurrance that matches the parameter is returned.
		 */			
		public function searchChildren(value:*, returnType:Class=null):*
		{
			var returnVal:* = null;
			var searchType:String = null;
			
			if (returnType == Array)
			{
				var returnArray:Array = [];
			}
			
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
				if (returnType == Array)
					returnArray = this.childList.getKey(value).getValueArray();
				else
					return this.childList.getKey(value);
			}
			else if (searchType == "getCSSClass" && this.childList.getCSSClass(value, 0))
			{
				if (returnType == Array)
					returnArray = this.childList.getCSSClass(value).getValueArray();
				else
					return this.childList.getCSSClass(value, 0);
			}
			else if (searchType == "getClass" && this.childList.getClass(value, 0))
			{
				if (returnType == Array)
					returnArray = this.childList.getClass(value).getValueArray();
				else
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
				var tmp:Array;
				var i:int;
				
				if (returnType == Array)
				{					
					for (i = 0; i < arr.length; i++) 
					{
						if (arr[i].hasOwnProperty("childList"))
						{	
							if (sType == "getCSSClass" || sType == "getClass")
							{	
								if (arr[i].childList[sType](val))
									returnArray = returnArray.concat(arr[i].childList[sType](val).getValueArray());									
							}
							else 
							{
								if (arr[i].childList[sType](val))
									returnArray = returnArray.concat(arr[i].childList[sType](val).getValueArray());
							}
							
							if (arr[i].childList.getValueArray())
								loopSearch(arr[i].childList.getValueArray(), val, sType);
						}
					}					
				}
				
				else
				{					
					for (i = 0; i < arr.length; i++) 
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
			}
			
			
			if (returnType == Array)
				return returnArray;
			else
				return returnVal;
		}		
		
		
	}
}