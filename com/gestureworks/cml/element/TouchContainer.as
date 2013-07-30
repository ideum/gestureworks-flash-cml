package com.gestureworks.cml.element
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.factories.*;
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
	public class TouchContainer extends TouchSprite implements IContainer, ICSS
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
			mouseChildren = true; // required for touchevents to pass into children
			state = [];
			state[0] = new Dictionary(false);
			this['propertyStates'] = state;	
			_childList = new ChildList;			
			mouseChildren = false;
			disableAffineTransform = false; 
			disableNativeTransform = false;			
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
		 * Calls the Dispose method for each child possessing a Dispose method then removes all children. 
		 * This is the root destructor intended to be called by overriding dispose functions. 
		 */
		public function dispose():void 		
		{			
			for (var i:int = numChildren - 1; i >= 0; i--)
			{
				var child:Object = getChildAt(i);
				if (child.hasOwnProperty("dispose"))
					child["dispose"]();
				removeChildAt(i);
			}
			state = null; 
			_childList = null; 
			layout = null;
			layoutList = null;							
			cmlGestureList = null;
		}
		
		
		/**
		 * property states array
		 */
		public var state:Array;
		
		[Deprecated(replacement="state")]		
		public var propertyStates:Array;
		
		
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
		
		
		private var _className:String;
		/**
		 * sets the class name of displayobject
		 */
		public function get className():String { return _className ; }
		public function set className(value:String):void
		{
			_className = value;
			_class_ = value;
		}			
		
		/**
		 * CML callback Initialisation
		 */
		public function displayComplete():void{}
		

		
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
		
		
		//////////////////////////////////////////////////////////////
		//  ICSS 
		//////////////////////////////////////////////////////////////
		
		private var _class_:String;
		/**
		 * Object's css class; 
		 */			
		public function get class_():String {return _className;}
		public function set class_(value:String):void 
		{ 
			_class_ = value; 
			_className = value;
		}			
		
		
		
		
		
		//////////////////////////////////////////////////////////////
		// ICONTAINER
		//////////////////////////////////////////////////////////////				
		
		
		
		private var _childList:ChildList;
		/**
		 * returns the childlist
		 */
		public function get childList():ChildList {return _childList;}			
		
		
		
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
		
		private var _layout:*;
		/**
		 * speciffies the type of layout
		 */
		public function get layout():* {return _layout;}
		public function set layout(value:*):void 
		{
			_layout = value;
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
			for (var i:int = 0; i < _childList.length; i++) 
			{
				if(childList.getIndex(i) is DisplayObject)
				addChild(_childList.getIndex(i));
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
		 * TODO
		 * @param	value
		 * @return
		 */
		public function makeGestureList(value:XMLList):Object
		{			
			var gl:*;			
			gl = value.Gesture;
			
			var go:String;
			
			var object:Object = new Object();
			
			for (var i:int; i < gl.length(); i++)
			{
				if (gl[i].@gestureOn == undefined)
					go = "true";
				else 
					go = String(gl[i].@gestureOn);
					
				object[String((gl[i].@ref))] = go;
			}
			
			cmlGestureList = object;
			
			return object;
		}	
				

		public function activateTouch():void
		{
			this.gestureList = cmlGestureList;
		}
		
		
		
		//////////////////////////////////////////////////////////////
		// outline
		//////////////////////////////////////////////////////////////
		
		private var _outlineOn:String = "false";
		/**
		 * specifies the outline of container to true or false
		 * @default false;
		 */
		public function get outlineOn():String{return _outlineOn;}
		public function set outlineOn(value:String):void
		{
			_outlineOn = value;
		}
		private var _outline_stroke:int = 20;
		/**
		 * sets the line stroke of outline
		 * @default 20;
		 */
		public function get outline_stroke():int{return _outline_stroke;}
		public function set outline_stroke(value:int):void
		{
			_outline_stroke = value;
		}
		
		private var _outline_color:Number = 0xFFFFFF;
		/**
		 * sets the color of outline
		 */
		public function get outline_color():Number{return _outline_color;}
		public function set outline_color(value:Number):void
		{
			_outline_color = value;
		}
		
		private var _outline_alpha:Number = 1;
		/**
		 * sets the alpha of outline
		 * @default =1;
		 */
		public function get outline_alpha():Number{return _outline_alpha;}
		public function set outline_alpha(value:Number):void
		{
			_outline_alpha = value;
		}
		
		private var _outline_joint:String = "miter";
		/**
		 * TODO
		 */
		public function get outline_joint():String{return _outline_joint;}
		public function set outline_joint(value:String):void
		{
			_outline_joint = value;
		}
		
		
		
		//////////////////////////////////////////////////////////////
		

		
		private var _maxScale:Number = 0;
		/**
		* This method is called after class initialization.
		*/
		public function get maxScale():Number { return _maxScale; }
		/**
		* This method is called after class initialization.
		*/
		public function set maxScale(value:Number):void
		{
			_maxScale = value;
		}
		
		private var _minScale:Number = 0;
		/**
		* This method is called after class initialization.
		*/
		public function get minScale():Number { return _minScale; }
		/**
		* This method is called after class initialization.
		*/
		public function set minScale(value:Number):void
		{
			_minScale = value;
		}
		

		

		
		
		/**
		* This method is called after class initialization.
		*/
		protected function randomMinMax(min:Number, max:Number):Number
		{
			return min + (max - min) * Math.random();
		}

		
		private function displayEventHandler(event:Event):void
		{
			if (_outlineOn=="true")
			{
				graphics.lineStyle(_outline_stroke+1,_outline_color,_outline_alpha , true, "normal",null, _outline_joint)
				graphics.drawRect(-_outline_stroke*0.5, -_outline_stroke*0.5, width+_outline_stroke, height+_outline_stroke);
			}
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
				var arr:Array = childList.getValueArray()
				if (arr)
					loopSearch(arr, value, searchType);
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
		public function parseCML(cml:XMLList):XMLList
		{
			//cmlGestureList = makeGestureList(cml.GestureList);			
			
			var node:XML = XML(cml);
			var obj:Object;
			var layoutId:String;
			var layoutCnt:int = 0;
					var attrName:String;
					var returnNode:XMLList = new XMLList;
					
			for each (var item:XML in node.*) 
			{
				if (item.name() == "Layout") {
					
					obj = CMLParser.instance.createObject(item.@classRef);					

					
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
			clone.displayComplete();			
			
			return clone;
		}			

	}
}