package com.gestureworks.cml.element
{
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import com.gestureworks.cml.factories.TouchContainerFactory;
	import com.gestureworks.cml.interfaces.ILayout;
	import com.gestureworks.cml.core.CMLParser;
	
	/**
	 * TouchContainer can be used to create interative display containers.
	 * It is the CML version of TouchSprite. It keeps track of children through the childlist property.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var tc:TouchContainer = new TouchContainer();
		
		tc.x = 700;
		tc.y = 300;
		tc.alpha = .25;
		tc.scale = 1;
		
		//touch interactions
		tc.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
		
		//loading an image through image element
		var img:Image = new Image();
		img.open("orchid.jpg");
		img.x = 0;
		img.y = 0;
		img.width = 200;
		img.rotation = -20;
		img.id = "img1";
		img.scale = 2;
		tc.addChild(img);
		
		//initialise touch container
		tc.init();
		addChild(tc);
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Container
	 * @see Gesture
	 * @see GestureList
	 */
	public class TouchContainer extends TouchContainerFactory
	{	
		public var layoutList:Dictionary = new Dictionary(true);
		
		/**
		 * Constructor
		 */
		public function TouchContainer()
		{
			super();
			mouseChildren = false;
			disableAffineTransform = false; 
			disableNativeTransform = false;
		}

		/**
		 * Initialisation method
		 */
		public function init():void
		{

		}
		
		override public function displayComplete():void 
		{
			init();
		}
		
		/**
		 * shows index of the child list
		 * @param	index
		 */
		public function showIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}
		
		/**
		 * hides child list index 
		 * @param	index
		 */
		public function hideIndex(index:int):void
		{
			childList.getIndex(index).visible = false;
		}		
		
		/**
		 * shows the child list key visibility
		 * @param	key
		 */
		public function showKey(key:String):void
		{
			childList.getKey(key).visible = true;
		}
		
		/**
		 * hides childlist key visibility
		 * @param	key
		 */
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
		
		private var _cloneExclusions:Vector.<String> = new <String>
			["$x", "$y", "_$x", "_$y", "_x", "_y", "cO", "sO", "gO", "tiO", "trO", "tc", 
			"tt", "tp", "tg", "td", "clusterID", "pointCount", "dN", "N", "_dN", "_N", 
			"touchObjectID", "_touchObjectID", "_pointArray", "$transformPoint"];
		/**
		 * Returns a list of properties to exclude when cloning this object
		 */
		public function get cloneExclusions():Vector.<String> { return _cloneExclusions; }
				
		
		/**
		 * This method does a depth first search of childLists. Search parameter can be a simple CSS selector 
		 * (id or class) or AS3 Class. If found, a corresponding display object is returned, if not, null is returned.
		 * The first occurrance that matches the parameter is returned.
		 */			
		public function searchChildren(value:*, returnType:Class=null):*
		{		
			//trace(value is Class);
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
					loopSearch(this.childList.getValueArray(), value, searchType);
			}
			
			function loopSearch(arr:Array, val:*, sType:String):*
			{
				if (returnVal)
					return;
				
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
								returnVal = arr[i].childList[sType](val, 0);
								if (returnVal)
									return returnVal;						
							}
							else 
							{
								returnVal = arr[i].childList[sType](val);
								if (returnVal)
									return returnVal;
							}
							
							if (!returnVal && arr[i].childList.getValueArray())
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
			//cmlGestureList = makeGestureList(cml.GestureList);			
			
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
				layout.onComplete = layoutComplete;
				layout.onUpdate = layoutUpdate;
				ILayout(layout).layout(this);
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
		 * Adds child to display list and, if not already added, the child list
		 * @param	child
		 * @return
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{		
			if (childList.search(child) == -1) {
				
				if (child.hasOwnProperty("id") && String(child["id"]).length > 0)
					childToList(child["id"], child);
				else
					childToList(child.name, child);
			}
			
			return super.addChild(child);
		}
		
		/**
		 * Clone method
		 */
		public function clone():* 
		{		
			var clone:TouchContainer = CloneUtils.clone(this, this.parent, cloneExclusions);
			clone.graphics.copyFrom(this.graphics);
			clone.displayComplete();			
			
			return clone;
		}			
		
		
		/**
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			layoutList = null;			
		}
		

		
	}
}