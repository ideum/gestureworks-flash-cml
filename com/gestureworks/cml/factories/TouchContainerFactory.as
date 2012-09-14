package com.gestureworks.cml.factories
{
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.cml.core.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.utils.*;
	
	
	
	public class TouchContainerFactory extends TouchSprite implements IContainer, ICSS
	{
				
		public function TouchContainerFactory()
		{
			super();
			mouseChildren = true; // required for touchevents to pass into children
			
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);			
			
			_childList = new LinkedMap;			
			
			addEventListener(GWTransformEvent.T_SCALE, scaleTransformHandler);
			//alpha = 1;
		}
				
		
		
		//////////////////////////////////////////////////////////////
		// IOBJECT
		//////////////////////////////////////////////////////////////		
				
		
		/**
		 * Calls the dispose method for each child possessing a dispose method then removes all children. 
		 * This is the root deconstructor intended to be called by overriding dispose functions. 
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
		
			propertyStates = null;
			_childList = null; 
			layout = null;
			cmlGestureList = null;
			
			removeEventListener(GWTransformEvent.T_SCALE, scaleTransformHandler);			
		}
		
		public var propertyStates:Array;
		
		
		private var _id:String
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		private var _cmlIndex:int;
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}	
		
		
		public function parseCML(cml:XMLList):XMLList
		{
			var obj:XMLList = CMLParser.instance.parseCML(this, cml);			
			cmlGestureList = makeGestureList(cml.GestureList);			
			return obj;
		}
		
		
		public function postparseCML(cml:XMLList):void {}
			
		
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}		
			
		/////////////////////////////////////////
		private var _group:String
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
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		private var _height:Number = 0;
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
		}		
		
		
		private var _className:String;
		public function get className():String { return _className ; }
		public function set className(value:String):void
		{
			_className = value;
		}			
		
		public function displayComplete():void{}
		

		//////////////////////////////////////////////////////////////
		//  ICSS 
		//////////////////////////////////////////////////////////////
		
		private var _class_:String;
		/**
		 * Object's css class; 
		 */			
		public function get class_():String {return _class_;}
		public function set class_(value:String):void 
		{ 
			_class_ = value; 
		}			
		
		
		
		
		
		//////////////////////////////////////////////////////////////
		// ICONTAINER
		//////////////////////////////////////////////////////////////				
		
		
		
		private var _childList:LinkedMap;
		public function get childList():LinkedMap {return _childList;}			
		
		
		
		private var _dimensionsTo:String;
		public function get dimensionsTo():String { return _dimensionsTo ; }
		public function set dimensionsTo(value:String):void
		{
			_dimensionsTo = value;
			//trace("TOUCH CONTAINER - DIMENTIONS TO: ", dimensionsTo);
		}		
		
		private var _autoShuffle:Boolean = false;
		public function get autoShuffle():Boolean{return _autoShuffle;}
		public function set autoShuffle(value:Boolean):void
		{
			_autoShuffle = value;			
		}
		
		private var _layout:*;
		/**
		 * 
		 */
		public function get layout():* {return _layout;}
		public function set layout(value:*):void 
		{
			_layout = value;
		}
		
		public function childToList(id:String, child:*):void
		{			
			childList.append(id, child);			
		}		
		
		
		
		
		public function addAllChildren():void
		{			
			for (var i:int = 0; i < _childList.length; i++) 
			{
				if(childList.getIndex(i) is DisplayObject)
				addChild(_childList.getIndex(i));
			}
		}		
		
		
		

		
		// called in layoutCML() method of DisplayManager
		public function setDimensionsToChild():void
		{
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i).id == dimensionsTo)
				{
					this.width = childList.getIndex(i).width;
					this.height = childList.getIndex(i).height;
					
					//trace(width, height);
				}
				
				//trace("TOUCH CONTAINER - DIMENSIONS TO: ", dimensionsTo);
				
			}
			
		}	
		
		
		override public function get mouseChildren():Boolean 
		{
			return super.mouseChildren;
		}
		
		override public function set mouseChildren(value:Boolean):void 
		{
			//trace("mouseChildren in touch container:", value)
			super.mouseChildren = value;
		}
		
		
		
		
		protected var cmlGestureList:Object;
		
		public function makeGestureList(value:XMLList):Object
		{			
			var gl:*;
			
			if (gl === value.Gesture) 
				return null;
			
			gl = value.Gesture;
			
			var object:Object = new Object();
			
			for (var i:int; i < gl.length(); i++)
			{					
				object[(gl[i].@ref).toString()] = gl[i].@gestureOn;
			}
			
			return object;
		}	
		
		
		
		public function activateTouch():void
		{
			this.gestureList = cmlGestureList;
			
			for (var j:String in gestureList) {
				//trace("gesture:",this.id, j+":"+gestureList[j]);
			}
		}
				
		
		
		
		
		
		
		
		//////////////////////////////////////////////////////////////
		// outline
		//////////////////////////////////////////////////////////////
		
		private var _outlineOn:String = "false";
		public function get outlineOn():String{return _outlineOn;}
		public function set outlineOn(value:String):void
		{
			_outlineOn = value;
		}
		private var _outline_stroke:int = 20;
		public function get outline_stroke():int{return _outline_stroke;}
		public function set outline_stroke(value:int):void
		{
			_outline_stroke = value;
		}
		
		private var _outline_color:Number = 0xFFFFFF;
		public function get outline_color():Number{return _outline_color;}
		public function set outline_color(value:Number):void
		{
			_outline_color = value;
		}
		
		private var _outline_alpha:Number = 1;
		public function get outline_alpha():Number{return _outline_alpha;}
		public function set outline_alpha(value:Number):void
		{
			_outline_alpha = value;
		}
		
		private var _outline_joint:String = "miter";
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
			
			//childrenHaveUpdated();
		}
		
		
		
		/**
		* This method is called after class initialization.
		*/
		protected function scaleTransformHandler(event:GWTransformEvent):void
		{			
			//if(maxScale && minScale) scaleY=scaleY>Number(maxScale)?Number(maxScale):scaleY<Number(minScale)?Number(minScale):scaleY;
			//if(maxScale && minScale) scaleX=scaleX>Number(maxScale)?Number(maxScale):scaleX<Number(minScale)?Number(minScale):scaleX;
		}
		
		/**
		* This method is called after class initialization.
		*/
		protected function displayHandler(event:DisplayEvent):void{}
		
		/**
		* This method is called after class initialization.
		*/
		protected function childrenHaveUpdated():void{}
		
		/**
		* This method is called after class initialization.
		*/
		protected function thumbUpdate(event:Event):void{}
	}
}