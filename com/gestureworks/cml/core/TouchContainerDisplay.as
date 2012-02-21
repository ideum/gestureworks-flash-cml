package com.gestureworks.cml.core
{
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.events.*;
	import flash.utils.*;
	
	
	/**
		* The GestureWorksCore class.
		* 
		* <strong>Important Properties</strong>
		* <pre>
		*  initialized:Boolean = false;
		*  settingsPath:String = null;
		*  fullscreen:Boolean = false;
		* </pre>
		* 
		* @see flash.display.Sprite
		* 
		* 
		* @langversion 3.0
		* @playerversion AIR 2.5
		* @playerversion Flash 10.1
		* @productversion GestureWorks 3.0
	*/
	
	public class TouchContainerDisplay extends TouchSprite implements IContainer, ICSS
	{
				
		/**
		*  GestureWorks Constructor.
		*  
		* @langversion 3.0
		* @playerversion AIR 1.5
		* @playerversion Flash 10
		* @playerversion Flash Lite 4
		* @productversion GestureWorks 1.5
		*/
		public function TouchContainerDisplay()
		{
			super();
			
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);			
			
			_childList = new LinkedMap;			
			
			addEventListener(GWTransformEvent.T_SCALE, scaleTransformHandler);
			alpha = 1;
		}
				
		
		
		//////////////////////////////////////////////////////////////
		// IOBJECT
		//////////////////////////////////////////////////////////////		
		
		
		public function dispose():void { parent.removeChild(this); }
		
		public var propertyStates:Array;
		
		
		private var _id:String
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
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
		
				
		
		private var cmlGestureList:Object;
		
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
		}
		
		
		
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
			trace("TOUCH CONTAINER - DIMENTIONS TO: ", dimensionsTo);
		}		
		
		
		public function childToList(id:String, child:*):void
		{			
			childList.append(id, child);			
		}		
		
		
		
		
		public function addAllChildren():void
		{			
			for (var i:int = 0; i < _childList.length; i++) 
			{
				addChild(_childList.getIndex(i));
			}
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
		
		

		
		// called in layoutCML() method of DisplayManager
		public function setDimensionsToChild():void
		{
			for (var i:int = 0; i < childList.length; i++) 
			{
				if (childList.getIndex(i).id == dimensionsTo)
				{
					this.width = childList.getIndex(i).width;
					this.height = childList.getIndex(i).height;
				}	
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