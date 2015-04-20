package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.layouts.Layout;
	import com.gestureworks.cml.managers.CloneManager;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.utils.*;
	
	/**
	 * TouchContainer_New is the base interactive CML display container that all CML display objects extend. 
	 * It is the CML version of TouchSprite. It keeps track of children through the childlist property.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var tc:TouchContainer_New = new TouchContainer_New();
		tc.graphics.beginFill(0x0);
		tc.graphics.drawRect(0,0,300,300);
		
		tc.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Container
	 * @see Gesture
	 * @see GestureList
	 */ 
	public class TouchContainer extends TouchSprite implements IContainer, ICSS, IState
	{
		private var b:Bitmap;
		private var store:Array;
		private var initialTransform:Matrix;
		private var _cloneExclusions:Vector.<String> = new < String > ["_x", "_y", "cO", "sO", "gO", "tiO", "trO", "tc", "tt", "tp", "tg", "td", "clusterID", "pointCount",
																	   "dN", "N", "_dN", "_N", "touchObjectID", "_touchObjectID", "pointArray", "transformPoint", "transform",
																	   "childList"];				
																	   
		private var _id:String		
		private var _cmlIndex:int;		
		private var _relativeX:Boolean = false;
		private var _relativeY:Boolean = false;
		private var _childList:ChildList;
		private var _width:Number = 0;	
		private var _height:Number = 0;	
		private var _widthPercent:Number;	
		private var _heightPercent:Number;		
		private var _paddingLeft:Number=0;
		private var _paddingRight:Number=0;
		private var _paddingTop:Number=0;
		private var _paddingBottom:Number=0;
		private var _dropShadow:Boolean = false;
		private var _layout:Layout;
		private var _className:String;
		private var _stateId:String
		private var _dimensionsTo:Object;
		private var _toBitmap:Boolean = false;		
		
		protected var cmlGestureList:Object;
		
		public var initialized:Boolean;			
		public var state:Dictionary;			
				
		/**
		 * Constructor
		 * @param	_vto The vto(virtual transform object) will receive all gesture transformation updates applied to the touch container. 
		 */
		public function TouchContainer(_vto:Object=null){
			super(_vto);
			
			//state tracking
			state = new Dictionary(false);
			state[0] = new State(false);
			
			//all CML children including non display objects
			_childList = new ChildList;			
			
			//default child interaction
			mouseChildren = false;
			
			//internal gesture transformations
			nativeTransform = true;	
		}

		/**
		 * Initialization function
		 */
		public function init():void {
			updatePercentDim();	
			updatePadding();
			updateRelativePos();			
			contentToBitmap();
			initialTransform = transform.matrix;
			initialized = true; 
		}						
					
		/**
		 * @inheritDoc
		 */
		public function get id():String { return _id };
		public function set id(value:String):void{
			_id = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get cmlIndex():int { return _cmlIndex };
		public function set cmlIndex(value:int):void{
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
		public function postparseCML(cml:XMLList):void {}
			
		/**
		 * @inheritDoc
		 */	
		public function updateProperties(state:*=0):void{
			CMLParser.updateProperties(this, state);		
		}									
		
		/**
		 * Sets the width of the container
		 */
		override public function get width():Number{ return _width; }
		override public function set width(value:Number):void{
			if (value >= 0) {
				_width = value; 
			}
		}
		
		/**
		 * Sets the height of the container
		 */
		override public function get height():Number{ return _height; }
		override public function set height(value:Number):void {
			if(value >= 0){
				_height = value;
			}
		}
		
		/**
		 * Width of content bounds
		 */
		public function get displayWidth():Number { return super.width; }
		
		/**
		 * Height of content bounds
		 */
		public function get displayHeight():Number { return super.height; }
		
		/**
		 * Sets width to a specified percentage of the parent's width
		 */
		public function get widthPercent():Number{ return _widthPercent; }
		public function set widthPercent(value:Number):void{
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
		
		/**
		 * Sets height to a specified percentage of the parent's height
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
		
		/**
		 * Sets the number of pixels between the component's left border and the left edge of its content area.
		 * @default 0
		 */
		public function get paddingLeft():Number { return _paddingLeft; }
		public function set paddingLeft(value:Number):void {
			_paddingLeft = value;
		}			
		
		/**
		 * Sets the number of pixels between the component's right border and the right edge of its content area.
		 * @default 0
		 */
		public function get paddingRight():Number { return _paddingRight; }
		public function set paddingRight(value:Number):void {
			_paddingRight = value;
		}	
				
		/**
		 * Sets the number of pixels between the container's top border and the top of its content area.
		 * @default 0
		 */
		public function get paddingTop():Number { return _paddingTop; }
		public function set paddingTop(value:Number):void {
			_paddingTop = value;
		}	
				
		/**
		 * Sets the number of pixels between the container's bottom border and the bottom of its content area.
		 * @default 0
		 */
		public function get paddingBottom():Number { return _paddingBottom; }
		public function set paddingBottom(value:Number):void {
			_paddingBottom = value;
		}										

		/**
		 * Positions child display objects based on layout type
		 */
		public function get layout():* {return _layout;}
		public function set layout(value:*):void {
			if (value is XML || value is String) {
				document.getElementById(value);
			}
			if(value is Layout){
				_layout = value;
			}
		}
		
		/**
		 * If provided object is not an instance of <code>DisplayObject</code>, attempt to retrieve child display
		 * by id
		 * @param	value Object to evaluate
		 * @return
		 */
		public function displayById(value:*):DisplayObject {
			if (!(value is DisplayObject)) {
				value = getElementById(value);
			}
			return value as DisplayObject; 
		}

		/**
		 * If provided object is not an instance of <code>DisplayObject</code>, attempt to retrieve child display
		 * by tag name (or object type)
		 * @param	value Object to evaluate
		 * @return
		 */		
		public function displayByTagName(value:*):DisplayObject {
			if (!(value is DisplayObject)) {
				value = getElementsByTagName(value)[0];
			}
			return value as DisplayObject;
		}
		
		/**
		 * If provided object is not an instance of <code>DisplayObject</code>, attempt to retrieve child display
		 * by class name
		 * @param	value Object to evaluate
		 * @return
		 */		
		public function displayByClassName(value:*):DisplayObject {
			if (!(value is DisplayObject)) {
				value = getElementsByClassName(value);
			}
			return value as DisplayObject; 
		}
		
		//////////////////////////////////////////////////////////////
		//  ICSS 
		//////////////////////////////////////////////////////////////
		
		/**
		 * Grouping id
		 */
		public function get className():String { return _className ; }
		public function set className(value:String):void{
			_className = value;
		}			
			
		
		//////////////////////////////////////////////////////////////
		// ISTATE
		//////////////////////////////////////////////////////////////							
		
		/**
		 * @inheritDoc
		 */
		public function get stateId():* { return _stateId };
		public function set stateId(value:*):void{
			if(value){
				_stateId = value;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function loadState(sId:* = null, recursion:Boolean = false):void { 
			if (StateUtils.loadState(this, sId, recursion)){
				stateId = sId;
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		public function saveState(sId:* = null, recursion:Boolean = false):void { StateUtils.saveState(this, sId, recursion); }		
		
		/**
		 * @inheritDoc
		 */
		public function tweenState(sId:*= null, tweenTime:Number = 1, onComplete:Function= null):void {
			if (StateUtils.tweenState(this, sId, tweenTime, onComplete))
				stateId = sId;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set visible(value:Boolean):void {
			var tmp:Boolean = super.visible;
			super.visible = value;
			if(tmp != super.visible){
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "visible", value));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set totalPointCount(value:int):void {
			var tmp:int = super.totalPointCount;
			super.totalPointCount = value;
			if (tmp < value) {
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "activity", value));
			}
		}
			
		/**
		 * Sets child dimensions to specified percentages of the container's
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
						child.height = height * h / 100;			
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
					getChildAt(i).x = getChildAt(i - 1).width + getChildAt(i - 1).x;
					if ( getChildAt(i)['state'][0]['x'] ) {
						getChildAt(i).x += Number(getChildAt(i)['state'][0].x);
					}
				}					
			}	
			if (relativeY) {
				for (i = 1; i < numChildren; i++) {			
					getChildAt(i).y = getChildAt(i - 1).height + getChildAt(i - 1).y;
					if ( getChildAt(i)['state'][0]['y'] ) {
						getChildAt(i).y += Number(getChildAt(i)['state'][0].y);
					}					
				}					
			}				
		}
			
		/**
		 * Overwrites child coordinates and dimensions with padding values
		 */
		public function updatePadding():void {
			var i:int;
			var child:DisplayObject;
			for (i = 0; i < numChildren; i++) {
				child = getChildAt(i);
				
				if(paddingLeft){
					child.x = paddingLeft;
				}
				if (paddingRight) {
					child.width = width - paddingRight - child.x;
				}
				if(paddingTop){
					child.y = paddingTop;
				}
				if (paddingBottom) {
					child.height = height - paddingBottom - child.y; 
				}						
			}			
		}
				
		/**
		 * Sets the dimensions to given object
		 */
		public function get dimensionsTo():Object { return _dimensionsTo ; }
		public function set dimensionsTo(value:Object):void{
			_dimensionsTo = value;
			this.width = value.width;
			this.height = value.height;
			this.length = value.length;
		}

		/**
		 * Add child to childList
		 * @param	id
		 * @param	child
		 */
		public function childToList(id:String, child:*):void{			
			childList.append(id, child);			
		}		
		
		/**
		 * Method searches the child and adds to the list
		 */
		public function addAllChildren():void
		{		
			var n:int = childList.length;
			for (var i:int = 0; i < childList.length; i++) {
				if (childList.getIndex(i) is DisplayObject)				
				addChild(_childList.getIndex(i));
				if (n != childList.length)
					i--;
			}
		}		

		/**
		 * Sets the dimensions of each child
		 */
		public function setDimensionsToChild():void{
			for (var i:int = 0; i < childList.length; i++) {
				if (childList.getIndex(i).hasOwnProperty("id") && childList.getIndex(i).id == dimensionsTo){
					this.width = childList.getIndex(i).width;
					this.height = childList.getIndex(i).height;					
				}
			}
		}	
		
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
		
		/**
		 * Assigns CML declared gesture list
		 */
		public function activateTouch():void
		{
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
		public function getElementById(id:String):*{
			id = id && id.charAt(0) == "#" ? id.substring(1) : id;
			return childList.getKey(id);
		}
	
		/**
		 * Searches the CML childList by className. An array of objects are returned.
		 * @param	className
		 * @return
		 */
		public function getElementsByClassName(className:String):Array {
			className = className && className.charAt(0) == "." ? className.substring(1) : className;
			return childList.getCSSClass(className).getValueArray();
		}		
		
		/**
		 * Searches the CML childList by tagName as Class. An array of objects are returned.
		 * @param	tagName
		 * @return
		 */
		public function getElementsByTagName(tagName:Class):Array{
			return childList.getClass(tagName).getValueArray();
		}			
		
		/**
		 * Searches the CML childList by selector. The first object is returned.
		 * @param	selector
		 * @return
		 */
		public function querySelector(selector:String):* {			
			return searchChildren(selector);
		}		

		/**
		 * Search the CML childList by selector. An array of objects are returned.
		 * @param	selector
		 * @return
		 */
		public function querySelectorAll(selector:*):Array {
			return searchChildren(selector, Array);
		}								
	
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
		 * Default parseCML routine
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList {						
			var node:XML = XML(cml);
			var obj:Layout;
			var attrName:String;
			var ref:String = "";
			
			//Search for CML declared layout
			for each (var item:XML in node.*) {				
				if (item.name() == "Layout") {				
					ref = String(item.@ref);										
					if (ref) {
						obj = Layout(CMLParser.createObject(ref));
					}
					else
						throw new Error("The Layout tag must reference a qualified layout class name through the 'ref' attribute");							
					
					//apply attributes
					for each (var attrValue:* in item.@*) {				
						attrName = attrValue.name().toString();	
						attrValue = attrValue == "true" ? true : attrValue == "false" ? false : attrValue;
						if (attrName != "ref" && attrName != "classRef")
							obj[attrName] = attrValue;							
					}					
					layout = obj; 
				}
				else if (item.name() == "Clone") {
					CloneManager.instance.parseCMLClone(item, this);
				}
			}
			
			//remove processed 
			delete cml["Layout"];	
			delete cml["Clone"];
						
			CMLParser.instance.parseCML(this, cml);
			return cml.*;
		}
		
		/**
		 * Converts container to bitmap
		 */
		private function contentToBitmap():void {
			if(b && b.bitmapData) {
				b.bitmapData.dispose();
				this.visible = true;
			}
					
			if (toBitmap) {
				b = DisplayUtils.resampledBitmap(this, width, height);					
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
		public function applyLayout(value:Layout = null):void {			
			layout = value ? value : layout; 
			if(layout){
				layout.layout(this);
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
			if (numChildren <= 0) return;
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
		
		/**
		 * Convert container to bitmap on initialization
		 */		
		public function get toBitmap():Boolean { return _toBitmap; }
		public function set toBitmap(value:Boolean):void {
			_toBitmap = value;
		}
		
		/**
		 * When set true this containers children's x position will be laid out relatively 
		 * to each other.
		 */
		public function get relativeX():Boolean { return _relativeX; }		
		public function set relativeX(value:Boolean):void {
			_relativeX = value;
		}
		
		/**
		 * When set true this containers children's y position will be laid out relatively 
		 * to each other.
		 */		
		public function get relativeY():Boolean { return _relativeY; }		
		public function set relativeY(value:Boolean):void {
			_relativeY = value;
		}
		
		/**
		 * Reset transform to initial state
		 */
		public function resetTransform():void {
			if(initialized){
				transform.matrix = initialTransform;
			}
		}

		/**
		 * Clone method
		 */
		public function clone(parent:* = null):* {		
			var clone:TouchContainer = CloneUtils.clone(this, parent ? parent : this.parent, cloneExclusions);
			clone.graphics.copyFrom(this.graphics);
			clone.gestureList = CloneUtils.deepCopyObject(gestureList); 
			clone.init();			
			
			return clone;
		}	
		
		/**
		 * Destructor
		 */
		override public function dispose():void 		
		{			
			super.dispose();
			state = null; 
			_childList = null; 
			layout = null;				
			
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

	}
}