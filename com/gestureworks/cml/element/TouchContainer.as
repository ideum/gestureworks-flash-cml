package com.gestureworks.cml.element
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
		
		/**
		 * Constructor
		 */		
		public function TouchContainer()
		{
			super();
			state = [];
			state[0] = new Dictionary(false);
			_childList = new ChildList;			
			mouseChildren = false;
			affineTransform = true; 
			nativeTransform = true;			
		}

		/**
		 * Initialisation method
		 */
		public function init():void
		{
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
		 * sets childlist id
		 */
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		private var _cmlIndex:int;
		/**
		 * sets the cml index
		 */
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}	
		
		/**
		 * property states array
		 */
		public var state:Array;
		
		/**
		 * postparse method
		 * @param	cml
		 */
		public function postparseCML(cml:XMLList):void {}
			
		/**
		 * update properties of child
		 * @param	state
		 */
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
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
		
		//////////////////////////////////////////////////////////////
		// IELEMENT
		//////////////////////////////////////////////////////////////		
		
		
		
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
		//////////////////////////////////////////////////////////////
		// ICONTAINER
		//////////////////////////////////////////////////////////////						
		
		
		private var _childList:ChildList;
		/**
		 * returns the childlist
		 */
		public function get childList():ChildList { return _childList; }	
		
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
		// ISTATE
		//////////////////////////////////////////////////////////////				
		
		private var _stateIndex:int = 0;
		public function get stateIndex():int { return _stateIndex; }
		
		private var _stateId:String
		/**
		 * Sets the state id
		 */
		public function get stateId():String {return _stateId};
		public function set stateId(value:String):void
		{
			_stateId = value;
		}
		
		/**
		 * Loads state by index number. If the first parameter is NaN, the current state will be saved.
		 * @param sIndex State index to be loaded.
		 * @param recursion If true the state will load recursively through the display list starting at the current display ojbect.
		 */
		public function loadState(sIndex:int = NaN, recursion:Boolean = false):void { 
			if (StateUtils.loadState(this, sIndex, recursion)){
				_stateIndex = sIndex;
				if ("stateId" in state[_stateIndex]) 
					stateId = state[_stateIndex]["stateId"];
			}
		}
		
		/**
		 * Load state by stateId. If the first parameter is null, the current state will be save.
		 * @param sId State id to load.
		 * @param recursion If true, the state will load recursively through the display list starting at the current display ojbect.
		 */
		public function loadStateById(sId:String = null, recursion:Boolean = false):void { 
			if (StateUtils.loadStateById(this, sId, recursion)){
				_stateIndex = StateUtils.getStateById(this, sId);
				stateId = sId;
			}
		}	
		
		/**
		 * Save state by index number. If the first parameter is NaN, the current state will be saved.
		 * @param sIndex State index to save.
		 * @param recursion If true the state will save recursively through the display list starting at the current display ojbect.
		 */
		public function saveState(sIndex:int = NaN, recursion:Boolean = false):void { StateUtils.saveState(this, sIndex, recursion); }		
		
		/**
		 * Save state by stateId. If the first parameter is null, the current state will be saved.
		 * @param sIndex State index to be save.
		 * @param recursion If true the state will save recursively through the display list starting at current display ojbect.
		 */
		public function saveStateById(sId:String, recursion:Boolean = false):void { StateUtils.saveStateById(this, sId, recursion); }
		
		/**
		 * Tween state by stateIndex from current to given state index. If the first parameter is null, the current state will be used.
		 * @param sIndex State index to tween.
		 * @param tweenTime Duration of tween
		 */
		public function tweenState(sIndex:int = NaN, tweenTime:Number = 1):void { 
			if (StateUtils.tweenState(this, sIndex, tweenTime))
				_stateIndex = sIndex;
		}			
		
		/**
		 * Tween state by stateId from current to given id. If the first parameter is null, the current state will be used.
		 * @param sId State id to tween.
		 */
		public function tweenStateById(sId:String, tweenTime:Number = 1):void { 
			if (StateUtils.tweenStateById(this, sId, tweenTime))
				_stateIndex = StateUtils.getStateById(this, sId);
		}			
		
		
		
		private var _dimensionsTo:String;
		/**
		 * sets the dimensions of touchcontainer
		 */
		public function get dimensionsTo():String { return _dimensionsTo ; }
		public function set dimensionsTo(value:String):void
		{
			_dimensionsTo = value;
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
		// TODO: Complete DOM methods
		//////////////////////////////////////////////////////////////	
		
	
		/**
		 * Returns the child element by id
		 * @param	id
		 * @return
		 */
		public function getElementById(id:String):*
		{
			return childList.getKey(id);
		}
	
		/**
		 * Returns the child element by CSS class name
		 * @param	className
		 * @return
		 */
		public function getElementsByClassName(className:String):Array
		{
			return childList.getCSSClass(className).getValueArray();
		}		
		
		
		/**
		 * Returns the child element by Tag name / AS3 class name
		 * @param	tagName
		 * @return
		 */
		public function getElementsByTagName(tagName:String):Array
		{
			tagName = tagName.toUpperCase();
			tagName = getQualifiedClassName(tagName);
			var cls:Class = getDefinitionByName(tagName) as Class;
			return childList.getClass(cls).getValueArray();
		}			
		
		
		private function updateChildren():void
		{			
			for (var i:int = 0; i < childList.length; i++)
			{
				if (childList.getIndex(i).hasOwnProperty("updateProperties")) 
					childList.getIndex(i).updateProperties();
			}
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
	
		private var _sound:String;
		public function get sound():String { return _sound; }
		public function set sound(value:String):void {
			_sound = value;
			if (_sound) {
				//SoundUtils.attachSound(this, _sound);
			}
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
			["_x", "_y", "cO", "sO", "gO", "tiO", "trO", "tc", 
			"tt", "tp", "tg", "td", "clusterID", "pointCount", "dN", "N", "_dN", "_N", 
		"touchObjectID", "_touchObjectID", "pointArray", "transformPoint", "transform"];
		/**
		 * Returns a list of properties to exclude when cloning this object
		 */
		public function get cloneExclusions():Vector.<String> { return _cloneExclusions; }
		
		
		/**
		 * This method does a depth first search of childLists. Search parameter can be a simple CSS selector 
		 * (id or class) or AS3 Class. If found, a corresponding display object is returned, if not, null is returned.
		 * The first occurrance that matches the parameter is returned.
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
			else if (value is String) {				
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
			if (searchType == "getKey" && this.childList.getKey(value)) {
				if (returnType == Array)
					returnArray = this.childList.getKey(value).getValueArray();
				else
					return this.childList.getKey(value);
			}
			else if (searchType == "getCSSClass" && this.childList.getCSSClass(value, 0)) {
				if (returnType == Array)
					returnArray = this.childList.getCSSClass(value).getValueArray();
				else
					return this.childList.getCSSClass(value, 0);
			}
			else if (searchType == "getClass" && this.childList.getClass(value, 0)) {
				if (returnType == Array)
					returnArray = this.childList.getClass(value).getValueArray();
				else
					return this.childList.getClass(value, 0);
			}
			
			// recursive search through sub-children's childList
			else {
				var arr:Array = childList.getValueArray()
				if (arr)
					loopSearch(arr, value, searchType);
			}
			
			function loopSearch(arr:Array, val:*, sType:String):* {
				
				if (returnVal)
					return;
				
				var tmp:Array;
				
				
				if (returnType == Array) {					
					for (var i:int = 0; i < arr.length; i++) {
						if (arr[i].hasOwnProperty("childList")) {	
							
							if (arr[i].childList[sType](val)) {
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
		public function parseCML(cml:XMLList):XMLList {
			//cmlGestureList = makeGestureList(cml.GestureList);			
			
			var node:XML = XML(cml);
			var obj:Object;
			var layoutId:String;
			var layoutCnt:int = 0;
					var attrName:String;
					var returnNode:XMLList = new XMLList;
					
			for each (var item:XML in node.*) {
				if (item.name() == "Layout") {
					
					obj = CMLParser.instance.createObject(item.@classRef);					
					
					//apply attributes
					for each (var attrValue:* in item.@*) {				
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
		override public function addChildAt(child:DisplayObject, index:int):flash.display.DisplayObject 
		{	
			if (child.parent) {
				child.parent.removeChild(child);
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
			if (child.parent) {
				child.parent.removeChild(child);
			}
			
			if (childList.search(child) == -1) {
				
				if (child.hasOwnProperty("id") && String(child["id"]).length > 0)
					childToList(child["id"], child);
				else
					childToList(child.name, child);
			}
			
			return super.addChild(child);
		}
		
		/**
		 * Adds child to display list and, if not already added, the child list
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
		
		private var _toBitmap:Boolean = false;
		
		public function get toBitmap():Boolean { return _toBitmap; }
		public function set toBitmap(b:Boolean):void {
			_toBitmap = b;
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