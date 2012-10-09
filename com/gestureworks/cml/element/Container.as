package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.managers.*;
	import flash.utils.Dictionary;
		
	/**
	 * Container controls the layout characteristics of child components.
	 * The container gives a large amount of control in keeping track of objects and can hold a variety of items.
	 * 
	 * @author ...
	 */
	
	public class Container extends ContainerFactory implements IContainer
	{				
		
		/**
		 * container constructor
		 */
		public function Container()
		{
			super();
		}	
		
		/**
		 * Defines the layoutlist
		 */
		public var layoutList:Dictionary = new Dictionary(true);
		
		private var _layout:*;
		/**
		 * sets the layout of the container
		 */
		public function get layout():* {return _layout;}
		public function set layout(value:*):void 
		{
			_layout = value;
		}
		
		private var _position:String;
		/**
		 * sets the position 
		 */
		public function get position():String {return _position;}
		public function set position(value:String):void 
		{
			_position = value;
		}
		
		private var _paddingLeft:Number=0;
		/**
		 * sets the number of pixels between the component's left border and the left edge of its content area.
		 * @default =0;
		 */
		public function get paddingLeft():Number {return _paddingLeft;}
		public function set paddingLeft(value:Number):void 
		{
			_paddingLeft = value;
		}	
		
		private var _paddingRight:Number=0;
		/**
		 * sets the number of pixels between the component's right border and the right edge of its content area.
		 * @default =0;
		 */
		public function get paddingRight():Number {return _paddingRight;}
		public function set paddingRight(value:Number):void 
		{
			_paddingRight = value;
		}	
		
		private var _paddingTop:Number=0;
		/**
		 * sets the number of pixels between the container's top border and the top of its content area.
		 * @default =0;
		 */
		public function get paddingTop():Number {return _paddingTop;}
		public function set paddingTop(value:Number):void 
		{
			_paddingTop = value;
		}	
		
		private var _paddingBottom:Number=0;
		/**
		 * sets the number of pixels between the container's bottom border and the bottom of its content area.
		 * @default =0;
		 */
		public function get paddingBottom():Number {return _paddingBottom;}
		public function set paddingBottom(value:Number):void 
		{
			_paddingBottom = value;
		}	
		
		private var _layoutComplete:Function;		
		/**
		 * Sets the function to call when the layout is complete
		 */
		public function get layoutComplete():Function { return _layoutComplete; }
		public function set layoutComplete(f:Function):void
		{
			_layoutComplete = f;
		}				
		
		private var _layoutUpdate:Function;		
		/**
		 * Sets the function to call when the layout updates
		 */
		public function get layoutUpdate():Function { return _layoutUpdate; }
		public function set layoutUpdate(f:Function):void
		{
			_layoutUpdate = f;
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
						if (attrValue == "true")
							attrValue = true;
						if (attrValue == "false")
							attrValue = false;
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
			{
				value.onComplete = layoutComplete;
				value.onUpdate = layoutUpdate;
				ILayout(value).layout(this);
			}
			else if (!value) {
				layoutList[String(layout)].onComplete = layoutComplete;								
				layoutList[String(layout)].onUpdate = layoutUpdate;
				layoutList[String(layout)].layout(this);
			}
			else {
				layout = value;					
				if (value is ILayout)
				{
					value.onComplete = layoutComplete;
					value.onUpdate = layoutUpdate;;
					value.layout(this);
				}
				else
				{
					layoutList[value].onComplete = layoutComplete;
					layoutList[value].onUpdate = layoutUpdate;
					layoutList[value].layout(this);
				}
			}
		}		
		
		/**
		 * shows the childlist index 
		 * @param	index
		 */
		public function showIndex(index:int):void
		{
			childList.getIndex(index).visible = true;
		}
		
		/**
		 * hides the childlist index
		 * @param	index
		 */
		public function hideIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}		
			
		/**
		 * shows the childlist key
		 * @param	key
		 */
		public function showKey(key:String):void
		{
			childList.getKey(key).visible = true;
		}
				
		/**
		 * hides the childlist key
		 * @param	key
		 */
		public function hideKey(key:String):void
		{
			childList.getKey(key).visible = false;
		}
		
		/**
		 * returns the childlist key
		 * @param	key
		 * @return
		 */
		public function getKey(key:String):*
		{
			return childList.getKey(key);
		}
		
		/**
		 * returns childlist index
		 * @param	index
		 * @return
		 */
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
			trace(value is Class);
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
		 * dispose method nullify the attributes 
		 */
	    override public function dispose():void 
		{
			super.dispose();
			layoutList = null;	
			layout = null;
		}
		
	}
}