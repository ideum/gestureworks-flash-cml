package com.gestureworks.cml.element
{
	import flash.utils.Dictionary;
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.cml.interfaces.ILayout;
	import com.gestureworks.cml.core.CMLParser;
	
	public class TouchContainer extends TouchContainerDisplay
	{	
		public var layoutList:Dictionary = new Dictionary(true);
		
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
		
		/**
		 * Parse cml for local layouts.
		 * @param	cml
		 * @return
		 */
		override public function parseCML(cml:XMLList):XMLList
		{
			var node:XML = XML(cml);
			var obj:Object;
			var layoutId:String;
			var layoutCnt:int = 0;
						
			for each (var item:XML in node.*) 
			{
				if (item.name() == "Layout") {
					
					obj = CMLParser.instance.createObject(item.@classRef);					
					var attrName:String;
					var returnNode:XMLList = new XMLList;
					
					//apply attributes
					for each (var attrValue:* in item.@*)
					{				
						attrName = attrValue.name().toString();
						if (attrName != "classRef")
							obj[attrName] = attrValue;
					}					
					
					//layout id is either user defined or index
					if (item.@id != undefined)
						layoutId = item.@id;
					else 
						layoutId = layoutCnt.toString();					
					layoutList[layoutId] = obj;
					
					//by default layout is the first local layout child, the user can specify the initial
					//layout through the container's layout property
					if (layoutCnt == 0)
						layout = layoutId;
					
					//increment index	
					layoutCnt++;						
				}
			}
			
			//remove all layout children and continue parsing
			delete cml["Layout"];			
			CMLParser.instance.parseCML(this, cml);
			
			return cml.*;
		}		

		/**
		 * Apply the containers layout
		 * @param	value
		 */
		public function applyLayout(value:*=null):void
		{			
			if (!value && layout is ILayout)
				ILayout(value).layout(this);
			else if (!value) {
				layoutList[String(layout)].layout(this);
			}
			else {
				layout = value;					
				if (value is ILayout)
					value.layout(this);
				else
					layoutList[value].layout(this);
			}
		}		

		
		
	}
}