package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.utils.*;
	
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
	public class TouchContainer extends TouchSprite implements IContainer, ICSS, IState
	{
		public var layoutList:Dictionary = new Dictionary(true);
		private var b:Bitmap;
		private var store:Array;
		
		private var _relativeX:Boolean = false;
		private var _relativeY:Boolean = false;
		private var _childList:ChildList;
				
		/**
		 * Constructor
		 */		
		public function TouchContainer(_vto:Object=null)
		{
			super(_vto);
			state = new Dictionary(false);
			state[0] = new State(false);
			_childList = new ChildList;			
			mouseChildren = false;
			affineTransform = false; 
			nativeTransform = true;	
		}

		/**
		 * Initialisation method
		 */
		public function init():void
		{
			updatePercentDim();
			updateRelativePos();	
			updatePadding();
			contentToBitmap();
		}

				
		//////////////////////////////////////////////////////////////
		// IOBJECT
		//////////////////////////////////////////////////////////////		
				
		
		/**
		 * Destructor
		 */
		override public function dispose():void 		
		{			
			super.dispose();
			state = null; 
			_childList = null; 
			layout = null;
			layoutList = null;							
			cmlGestureList = null;					
			
			if (childList) {
				for (var i:int = 0; i < childList.length; i++) {	
					var child:Object = childList.getIndex(i);
					if (child.hasOwnProperty("dispose"))
						child["dispose"]();
					childList.removeIndex(i);					
				}
			}
				
			CMLObjectList.instance.removeByValue(this);
		}
		
					
		private var _id:String
		/**
		 * @inheritDoc
		 */
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		private var _cmlIndex:int;
		/**
		 * @inheritDoc
		 */
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}	
		
		/**
		 * @inheritDoc
		 */		
		public function get childList():ChildList { return _childList };
		public function set childList(value:ChildList):void {
			_childList = value;
		}	
				
		
		/**
		 * @inheritDoc
		 */	
		public var state:Dictionary;
		
		/**
		 * @inheritDoc
		 */	
		public function postparseCML(cml:XMLList):void {}
			
		/**
		 * @inheritDoc
		 */	
		public function updateProperties(state:*=0):void
		{
			CMLParser.updateProperties(this, state);		
		}		
			
		/////////////////////////////////////////
		private var _group:String
		/**
		 * 
		 */
		public function get group():String {return _group};
		public function set group(value:String):void
		{
			_group = value;
		}
		///////////////////////////////////////////////////
		
		
		
		
		private var _width:Number = 0;
		/**
		 * sets the width of the container
		 */
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		private var _height:Number = 0;
		/**
		 * sets the height of the container
		 */
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}
		
		private var _widthPercent:Number;
		/**
		 * sets the width of the container
		 */
		public function get widthPercent():Number{return _widthPercent;}
		public function set widthPercent(value:Number):void
		{
			_widthPercent = value;
			if (parent) {
				if ( (width + x) > parent.width - parent['paddingLeft']) {
					width -= parent['paddingLeft'];
				}
				if ( (width + x) > parent.width - parent['paddingRight']) {
					width -= parent['paddingRight'];
				}	
			}
		}
		
		private var _heightPercent:Number;
		/**
		 * sets the height of the container
		 */
		public function get heightPercent():Number{return _heightPercent;}
		public function set heightPercent(value:Number):void
		{
			_heightPercent = value;
			if (parent) {
				if ( (height + y) > parent.height - parent['paddingTop']) {
					height -= parent['paddingTop'];
				}
				if ( (height + y) > parent.height - parent['paddingBottom']) {
					height -= parent['paddingBottom'];
				}
			}
		}		
		
		
		private var _position:*;
		/**
		 * Sets the position 
		 */
		public function get position():* {return _position;}
		public function set position(value:*):void 
		{
			_position = value;
		}
		
		private var _paddingLeft:Number=0;
		/**
		 * Sets the number of pixels between the component's left border and the left edge of its content area.
		 * @default 0
		 */
		public function get paddingLeft():Number {return _paddingLeft;}
		public function set paddingLeft(value:Number):void 
		{
			_paddingLeft = value;
		}	
		
		private var _paddingRight:Number=0;
		/**
		 * Sets the number of pixels between the component's right border and the right edge of its content area.
		 * @default 0
		 */
		public function get paddingRight():Number {return _paddingRight;}
		public function set paddingRight(value:Number):void 
		{
			_paddingRight = value;
		}	
		
		private var _paddingTop:Number=0;
		/**
		 * Sets the number of pixels between the container's top border and the top of its content area.
		 * @default 0
		 */
		public function get paddingTop():Number {return _paddingTop;}
		public function set paddingTop(value:Number):void 
		{
			_paddingTop = value;
		}	
		
		private var _paddingBottom:Number=0;
		/**
		 * Sets the number of pixels between the container's bottom border and the bottom of its content area.
		 * @default 0
		 */
		public function get paddingBottom():Number {return _paddingBottom;}
		public function set paddingBottom(value:Number):void 
		{
			_paddingBottom = value;
		}		
				
		
		private var dropShadowfilter:DropShadowFilter = new DropShadowFilter(1, 45, 0x333333, .5, 3, 3, 1, 1, false);		
		private var _dropShadow:Boolean = false;
		/**
		 * Sets the drop shadow effect
		 * @default false
		 */
		public function get dropShadow():Boolean { return _dropShadow; }		
		public function set dropShadow(value:Boolean):void 
		{ 			
			if (value)
				this.filters = new Array(dropShadowfilter);
			else	
				this.filters = [];
				
			_dropShadow = value;
		}
		
		/**
		 * Override targetList assignment to allow CML assignment
		 */
		//override public function set targetList(value:*):void 
		//{
			//if (value is XML) {				
				//var ids:Array = String(value).split(",");
				//for each(var id:String in ids) 					
					//super.targetList.push(document.getElementById(StringUtils.trim(id))); 
			//}
			//else if(value is Array)
				//super.targetList = value;
		//}
		
		private var _layout:*;
		/**
		 * specifies the type of layout
		 */
		public function get layout():* {return _layout;}
		public function set layout(value:*):void 
		{
			_layout = value;
		}			
		
		//////////////////////////////////////////////////////////////
		//  ICSS 
		//////////////////////////////////////////////////////////////
		

		private var _className:String;
		/**
		 * sets the class name of displayobject
		 */
		public function get className():String { return _className ; }
		public function set className(value:String):void
		{
			_className = value;
		}			
			
		
		//////////////////////////////////////////////////////////////
		// ISTATE
		//////////////////////////////////////////////////////////////				
		
		private var _stateId:String
		
		/**
		 * @inheritDoc
		 */
		public function get stateId():* {return _stateId};
		public function set stateId(value:*):void
		{
			_stateId = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadState(sId:* = null, recursion:Boolean = false):void { 
			if (StateUtils.loadState(this, sId, recursion)){
				_stateId = sId;
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		public function saveState(sId:* = null, recursion:Boolean = false):void { StateUtils.saveState(this, sId, recursion); }		
		
		/**
		 * @inheritDoc
		 */
		public function tweenState(sId:*= null, tweenTime:Number = 1):void {
			if (StateUtils.tweenState(this, sId, tweenTime))
				_stateId = sId;
		}			
			
		/**
		 *	Updates child percent dimensions within this container
		 */		
		public function updatePercentDim():void {	
			var i:int;
			var w:Number;
			var h:Number;
			var child:TouchContainer;			
			for (i = 0; i < numChildren; i++) {
				if (getChildAt(i) is TouchContainer) {
					child = TouchContainer(getChildAt(i));
					if (child.widthPercent) {
						w = Number(child.widthPercent);
						child.width = width * w / 100;
					}					
					if (child.heightPercent) {
						h = Number(child.heightPercent);
						child.height = parent.height * h / 100;			
					}
				}
			}
		}
		
		/**
		 *	Updates child relative positions within this container
		 */
		public function updateRelativePos():void {		
			var i:int;
			var child:DisplayObject;
			if (relativeX) {
				for (i = 1; i < numChildren; i++) {					
					getChildAt(i).x = getChildAt(i - 1).height + getChildAt(i - 1).x;
					if ( getChildAt(i)['state'][0]['x'] ) {
						getChildAt(i).x += Number(getChildAt(i)['state'][0].x);
					}
				}					
			}	
			if (relativeY) {
				for (i = 1; i < numChildren; i++) {			
					getChildAt(i - 1)['autosize'] = "true";
					getChildAt(i).y = getChildAt(i - 1).height + getChildAt(i - 1).y;
					if ( getChildAt(i)['state'][0]['y'] ) {
						getChildAt(i).y += Number(getChildAt(i)['state'][0].y);
					}					
				}					
			}				
		}

				
		/**
		 *	Updates child padding within this container
		 */
		public function updatePadding():void {
			var i:int;
			var child:DisplayObject;
			for (i = 0; i < numChildren; i++) {
				child = getChildAt(i);
				child.x += paddingLeft;
				child.y += paddingTop;
				if ( (child.width + child.x) > width - paddingLeft) {
					child.width -= paddingLeft;
				}
				if ( (child.width + child.x) > width - paddingRight) {
					child.width -= paddingRight;
				}
				if ( (child.height + child.y) > height - paddingTop) {
					child.height -= paddingTop;
				}
				if ( (child.height + child.y) > height - paddingBottom) {
					child.height -= paddingBottom;
				}				
			}			
		}
		
		private var _dimensionsTo:Object;
		/**
		 * Sets the dimensions of TouchContainer to given object
		 */
		public function get dimensionsTo():Object { return _dimensionsTo ; }
		public function set dimensionsTo(value:Object):void
		{
			_dimensionsTo = value;
			this.width = value.width;
			this.height = value.height;
			this.length = value.length;
		}		
		
		private var _autoShuffle:Boolean = false;
		/**
		 * autoshuffles
		 */
		public function get autoShuffle():Boolean{return _autoShuffle;}
		public function set autoShuffle(value:Boolean):void
		{
			_autoShuffle = value;			
		}
		

		/**
		 * child appended to the childlist
		 * @param	id
		 * @param	child
		 */
		public function childToList(id:String, child:*):void
		{			
			childList.append(id, child);			
		}		
		
		/**
		 * method searches the child and adds to the list
		 */
		public function addAllChildren():void
		{		
			var n:int = childList.length;
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i) is DisplayObject)				
				addChild(_childList.getIndex(i));
				if (n != childList.length)
					i--;
			}
		}		

		// called in layoutCML() method of DisplayManager
		/**
		 * method sets the dimensions of each child
		 */
		public function setDimensionsToChild():void
		{
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i).hasOwnProperty("id") && childList.getIndex(i).id == dimensionsTo)
				{
					this.width = childList.getIndex(i).width;
					this.height = childList.getIndex(i).height;					
				}
			}
		}	
		
		/**
		 * sets the mousechildren value to true or false.
		 */
		override public function get mouseChildren():Boolean 
		{
			return super.mouseChildren;
		}
		override public function set mouseChildren(value:Boolean):void 
		{
			super.mouseChildren = value;
		}

		protected var cmlGestureList:Object;
		
		/**
		 * Creates gestureList object from XML
		 * @param	value
		 * @return
		 */
		public function makeGestureList(value:XMLList):Object
		{			
			var gl:*;			
			gl = value.Gesture;
			
			var go:Boolean;
			
			var object:Object = new Object();
			
			for (var i:int; i < gl.length(); i++)
			{
				if (gl[i].@gestureOn == undefined || gl[i].@gestureOn == "true")
					go = true;
				else 
					go = false;
					
				object[String((gl[i].@ref))] = go;
			}
			
			cmlGestureList = object;
			
			return object;
		}	
				

		public function activateTouch():void
		{
			// checks if object is empty
			for (var s:String in cmlGestureList) {
				this.gestureList = cmlGestureList;
				break;
			}
			
		}
		
		

		//////////////////////////////////////////////////////////////
		// DOM methods
		//////////////////////////////////////////////////////////////	
		
	
		/**
		 * Searches CML childList by id. The first object is returned.
		 * @param	id
		 * @return
		 */
		public function getElementById(id:String):*
		{
			return childList.getKey(id);
		}
	
		/**
		 * Searches the CML childList by className. An array of objects are returned.
		 * @param	className
		 * @return
		 */
		public function getElementsByClassName(className:String):Array
		{
			return childList.getCSSClass(className).getValueArray();
		}		
		
		/**
		 * Searches the CML childList by tagName as Class. An array of objects are returned.
		 * @param	tagName
		 * @return
		 */
		public function getElementsByTagName(tagName:Class):Array
		{
			return childList.getClass(tagName).getValueArray();
		}			
		
		/**
		 * Searches the CML childList by selector. The first object is returned.
		 * @param	selector
		 * @return
		 */
		public function querySelector(selector:String):* 
		{			
			return searchChildren(selector);
		}		

		/**
		 * Search the CML childList by selector. An array of objects are returned.
		 * @param	selector
		 * @return
		 */
		public function querySelectorAll(selector:*):Array 
		{
			return searchChildren(selector, Array);
		}			
		
		private function updateChildren():void
		{			
			for (var i:int = 0; i < childList.length; i++)
			{
				if (childList.getIndex(i).hasOwnProperty("updateProperties")) 
					childList.getIndex(i).updateProperties();
			}
		}
				
	
		private var _sound:String;
		public function get sound():String { return _sound; }
		public function set sound(value:String):void {
			_sound = value;
			if (_sound) {
				//SoundUtils.attachSound(this, _sound);
			}
		}	
		
		private var _cloneExclusions:Vector.<String> = new <String>
			["_x", "_y", "cO", "sO", "gO", "tiO", "trO", "tc", 
			"tt", "tp", "tg", "td", "clusterID", "pointCount", "dN", "N", "_dN", "_N", 
		"touchObjectID", "_touchObjectID", "pointArray", "transformPoint", "transform", "childList"];
		/**
		 * Returns a list of properties to exclude when cloning this object
		 */
		public function get cloneExclusions():Vector.<String> { return _cloneExclusions; }
		
		
		/**
		 * This method does a depth first search of childLists. Search parameter can be a simple CSS selector 
		 * (id or class) or AS3 Class. If found, a corresponding display object is returned, if not, null is returned.
		 * The first occurrance that matches the parameter is returned, unless a returnType of Array (as class) is given;
		 */			
		public function searchChildren(value:*, returnType:Class=null):* {		
			var returnVal:* = null;
			var searchType:String = null;
			
			if (returnType == Array)
				var returnArray:Array = [];
				
			if (value is XML)
				value = value.toString();
			
			// determine search method
			if (value is Class) {				
				searchType = "getClass";
			}
			else if (value is String || XMLList) {				
				// determine type and strip the first character
				if (value.charAt(0) == "#") {
					searchType = "getKey";
					value = value.substring(1);
				}
				else if (value.charAt(0) == ".") {
					searchType = "getCSSClass";
					value = value.substring(1);
				}
				//default to id
				else  {
					searchType = "getKey";
				}
			}
			else {
				return;
			}
			
			// run first level search
			if (searchType == "getKey" && childList.getKey(value)) {
				if (returnType == Array) {
					for each (var item:* in childList) {
						if ("id" in item && item.id == value) {
							returnArray.push(item);
						}
					}
				}
				else
					return childList.getKey(value);
			}
			else if (searchType == "getCSSClass" && childList.getCSSClass(value, 0)) {
				if (returnType == Array)
					returnArray = childList.getCSSClass(value).getValueArray();
				else
					return childList.getCSSClass(value, 0);
			}
			else if (searchType == "getClass" && childList.getClass(value, 0)) {
				if (returnType == Array)
					returnArray = childList.getClass(value).getValueArray();
				else
					return childList.getClass(value, 0);
			}
			
			// recursive search through sub-children's childList
			if (childList.length) {				
				var arr:Array = childList.getValueArray()
				if (arr)
					loopSearch(arr, value, searchType);
			}
			
			function loopSearch(arr:Array, val:*, sType:String):* {
				if (returnVal) {
					return;
				}
				
				var tmp:Array;				
				if (returnType == Array) {					
					for (var i:int = 0; i < arr.length; i++) {
						if (arr[i].hasOwnProperty("childList")) {	
							if (sType == "getKey") {
								for each (var item:* in arr[i].childList) {
									if ("id" in item && item.id == value) {
										returnArray.push(item);
									}
								}								
							}
							else if (arr[i].childList[sType](val)) {
								returnArray = returnArray.concat(arr[i].childList[sType](val).getValueArray());		
							}
							
							if (arr[i].childList.getValueArray()) {
									loopSearch(arr[i].childList.getValueArray(), val, sType);
							}							
						}
					}					
				}
				
				else {					
					for (i = 0; i < arr.length; i++) {					
						if (arr[i].hasOwnProperty("childList")) {						
							
							if (sType == "getCSSClass" || sType == "getClass") {
								returnVal = arr[i].childList[sType](val, 0);
								if (returnVal)
									return returnVal;						
							}
							else {
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
			
			if (returnType == Array) {
				return returnArray;
			}
			else {
				return returnVal;
			}
		}	
		
	
		
		/**
		 * Parse cml for local layouts.
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList {
			//cmlGestureList = makeGestureList(cml.GestureList);			
			
			var node:XML = XML(cml);
			var obj:Object;
			var layoutId:String;
			var layoutCnt:int = 0;
			var attrName:String;
			var returnNode:XMLList = new XMLList;
			var ref:String = "";
			
			for each (var item:XML in node.*) {
				if (item.name() == "Layout") {
										
					if (item.@ref != undefined) {
						ref = String(item.@ref);
					} 
					else if (item.@classRef != undefined) {
						ref = String(item.@classRef);
					}	
					
					if (ref.length) {
						if (ref.search("Layout") == -1) {
							ref = ref + "Layout";
						}
						obj = CMLParser.createObject(ref);
					}
					else
						throw new Error("The Layout tag requires the 'ref' attribute");							
					
					//apply attributes
					for each (var attrValue:* in item.@*) {				
						attrName = attrValue.name().toString();						
						if (attrValue == "true")
							attrValue = true;
						else if (attrValue == "false")
							attrValue = false;
						if (attrName != "ref" && attrName != "classRef")
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
			
			//remove processed 
			delete cml["Layout"];			
			
			CMLParser.instance.parseCML(this, cml);
			return cml.*;
		}
		
		private function contentToBitmap():void {
			if(b && b.bitmapData) {
				b.bitmapData.dispose();
				this.visible = true;
			}
					
			if (toBitmap) {
				b = DisplayUtils.toBitmap(this);					
				b.x = this.x;
				b.y = this.y;
				store = DisplayUtils.removeAllChildren(this);
				addChild(b);
			}
			

		}
				
		/**
		 * Apply the containers layout
		 * @param	value
		 */		
		public function applyLayout(value:*=null):void
		{			
			if (!value && layout is ILayout)
			{
				ILayout(layout).layout(this);
			}
			else if (!value) {
				layoutList[String(layout)].layout(this);
			}
			else {
				layout = value;					
				if (value is ILayout)
				{
					value.layout(this);
				}
				else
				{
					layoutList[value].layout(this);
				}
			}
		}			
		
		/**
		 * Adds child to display list and, if not already added, the child list
		 * @param	child
		 * @return
		 */
		override public function addChildAt(child:DisplayObject, index:int):flash.display.DisplayObject 
		{	
			//child transfer
			if (child.parent is TouchContainer && TouchContainer(child.parent).childList.search(child) != -1) {
				childList.removeByValue(child);
			}
			
			if (childList.search(child) == -1) {
				
				if (child.hasOwnProperty("id") && String(child["id"]).length > 0)
					childToList(child["id"], child);
				else
					childToList(child.name, child);
			}
			
			return super.addChildAt(child, index);
		}		
		
		/**
		 * Adds child to display list and, if not already added, the child list
		 * @param	child
		 * @return
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{	
			//child transfer
			if (child.parent is TouchContainer && TouchContainer(child.parent).childList.search(child) != -1) {
				childList.removeByValue(child);
			}
			
			if (childList.search(child) == -1) {
				
				if (child.hasOwnProperty("id") && child["id"] && String(child["id"]).length > 0)
					childToList(child["id"], child);
				else
					childToList(child.name, child);
			}
			
			return super.addChild(child);
		}
		
		/**
		 * Removes child from display list and, if not already removed, the child list
		 * @param	child
		 * @return
		 */
		override public function removeChild(child:DisplayObject):flash.display.DisplayObject 
		{	
			if (childList.search(child) != -1) {
				childList.removeByValue(child);
			}
			
			return super.removeChild(child);
		}	
		
		/**
		 * Removes children from display list and, if not already removed, the child list
		 * @param	beginIndex
		 * @param	endIndex
		 */
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			if (endIndex < 0 || endIndex >= numChildren)
				endIndex = numChildren - 1;
				
			for (var i:int = beginIndex; i <= endIndex; i++) {
				var child:DisplayObject = getChildAt(i);
				if (childList.search(child) != -1)
					childList.removeByValue(child);
			}
			
			super.removeChildren(beginIndex, endIndex);
		}
		
		/**
		 * Removes child from display list and, if not already removed, the child list
		 * @param	index
		 * @return
		 */
		override public function removeChildAt(index:int):DisplayObject {	
			var child:DisplayObject = getChildAt(index);
			if (childList.search(child) != -1) {
				childList.removeByValue(child);
			}
			
			return super.removeChildAt(index);
		}
		
		private var _toBitmap:Boolean = false;
		
		public function get toBitmap():Boolean { return _toBitmap; }
		public function set toBitmap(value:Boolean):void {
			_toBitmap = value;
		}
		
		/**
		 * When set true this containers children's x position will be laid out relatively 
		 * to each other.
		 */
		public function get relativeX():Boolean {
			return _relativeX;
		}
		
		public function set relativeX(value:Boolean):void {
			_relativeX = value;
		}
		
		/**
		 * When set true this containers children's y position will be laid out relatively 
		 * to each other.
		 */		
		public function get relativeY():Boolean {
			return _relativeY;
		}
		
		public function set relativeY(value:Boolean):void {
			_relativeY = value;
		}

		/**
		 * Clone method
		 */
		public function clone():* 
		{		
			var clone:TouchContainer = CloneUtils.clone(this, this.parent, cloneExclusions);
			clone.graphics.copyFrom(this.graphics);
			clone.init();			
			
			return clone;
		}	
		
		

	}
}