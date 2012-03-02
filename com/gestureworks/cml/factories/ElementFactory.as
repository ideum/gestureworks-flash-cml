package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.interfaces.ICML;
	import com.gestureworks.cml.interfaces.IElement;
	import com.gestureworks.cml.interfaces.ICSS;
	import com.gestureworks.cml.interfaces.IClone;
	import com.gestureworks.cml.core.CMLObjectList;
	
	//import com.gestureworks.core.TouchSprite;
	
	import com.gestureworks.cml.core.*;

	import flash.utils.Dictionary;	
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	/**
	 * ElementFactory
	 * Base class for display elememts
	 * @authors Charles Veasey
	 */	
	
	public class ElementFactory extends Sprite implements IElement, ICSS, IClone
	{
		public function ElementFactory() 
		{
			mouseChildren = true;
			super();
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);
			
			super.scaleX = 1;
			super.scaleY = 1;
		}			
		
		

		////////////////
		//  IObject  
		///////////////		
		
		
		/**
		 * Destructor
		 */
		public function dispose():void
		{
			if (parent) parent.removeChild(this);
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
			return CMLParser.instance.parseCML(this, cml);
		}
		
		
		public function postparseCML(cml:XMLList):void {}
		
		
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}	
		

		private var _className:String;
		public function get className():String { return _className ; }
		public function set className(value:String):void
		{
			_className = value;
		}				
		
		
		/////////////////////////////////////////////////////
		//  IElement  
		/////////////////////////////////////////////////////
		
		
		private var _width:Number = 0;
		/**
		 * Sets width of the display object in pixels
		 * @default 0
		 */
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			layoutUI();
		}
		
		
		private var _height:Number = 0;
		/**
		 * Sets width of the display object in pixels
		 * @default 0
		 */		
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
			layoutUI();
		}		
		
		
		private var _scaleX:Number = 1;
		/**
		 * Sets width of the display object in pixels
		 * @default 0
		 */	
		override public function get scaleX():Number{return _scaleX;}		
		override public function set scaleX(value:Number):void
		{
			_scaleX = value
			super.scaleX = value;
		}		
		
		
		private var _scaleY:Number = 1;
		/**
		 * Sets width of the display object in pixels
		 * @default 0
		 */	
		override public function get scaleY():Number{return _scaleY;}		
		override public function set scaleY(value:Number):void
		{
			_scaleY = value
			super.scaleY = value;
		}			
		
		
		private var _minScale:Number = 0;
		/**
		 * Sets minimum scale of the display object in pixels
		 * @default 0;
		 */		
		public function get minScale():Number{return _minScale;}
		public function set minScale(value:Number):void
		{
			_minScale = value;
		}
		

		private var _maxScale:Number = 0;
		/**
		 * Sets maximum scale of the display object in pixels
		 * @default 0
		 */				
		public function get maxScale():Number{return _maxScale;}
		public function set maxScale(value:Number):void
		{
			_maxScale = value;
		}		
		
		
		
		
		
		private var originalScale:int = 1;
		
		/*
		 * Display Manager onEnterFrame Event callback 
		 * 
		 */
		
		/*
		public function onEnterFrame():void
		{					
			if (parent && fixedScale)
			{
				scale = originalScale / parent["scaleX"];
			}
		}	*/	
		

		
		private var _widthPercent:String = "";		
		public function get widthPercent():String{return _widthPercent;}
		public function set widthPercent(value:String):void
		{
			_widthPercent = value;
			var number:Number = Number(widthPercent.slice(0, widthPercent.indexOf("%")));
			if (parent) width = parent.width * (number / 100);
		}
				
		
		private var _heightPercent:*="";
		public function get heightPercent():String{	return _heightPercent;}
		public function set heightPercent(value:String):void
		{
			_heightPercent = value;
			var number:Number = Number(heightPercent.slice(0, heightPercent.indexOf("%")));
			if (parent) height = parent.height * (number / 100);
		}		
		
		
		
		
		
		/**
		 * Sets minimum scale of the display object in pixels
		 * @default 0
		 */		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			layoutUI();
		}
		
		
		private var _horizontalCenter:Number=0;
		public function get horizontalCenter():Number{return _horizontalCenter;}
		public function set horizontalCenter(value:Number):void
		{
			_horizontalCenter = value;
			if (parent) x = ((parent.width - width) / 2) + value;
		}
		
		private var _verticalCenter:Number=0;
		public function get verticalCenter():Number{return _verticalCenter;}
		public function set verticalCenter(value:Number):void
		{
			_verticalCenter = value;
			if (parent) y = ((parent.height - height) / 2) + value;
		}
		
		private var _top:Number=0;
		public function get top():Number{return _top;}
		public function set top(value:Number):void
		{
			_top = value;
			y = value;
		}
		
		private var _left:Number=0;
		public function get left():Number{return _left;}
		public function set left(value:Number):void
		{
			_left = value;
			x = value
		}		
		
		private var _bottom:Number=0;
		public function get bottom():Number{return _bottom;}
		public function set bottom(value:Number):void
		{
			_bottom = value;			
			if (parent) y = (parent.height - height) + value;
		}
		
		private var _right:Number=0;
		public function get right():Number{return _right;}
		public function set right(value:Number):void
		{
			_right = value;
			if (parent) x = (parent.width - width) + value;
		}
		

		
		private var _index:int;
		public function get index():int{return _index;}
		public function set index(value:int):void
		{
			_index = value;
		}	
		
		private var _debugStyle:*;
		public function get debugStyle():*{return _debugStyle;}
		public function set debugStyle(value:*):void
		{
			_debugStyle = value;
		}
		
		private var _fixedScale:Boolean = false;
		public function get fixedScale():Boolean{return _fixedScale;}
		public function set fixedScale(value:Boolean):void
		{
			_fixedScale = value;
			originalScale = scaleX;
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
		

		private var _displayEvents:String = "complete";
		/**
		 * Use for dispatch completes. Can be set to whatever string needed.
		 */		
		public function get displayEvents():String{return _displayEvents;}
		public function set displayEvents(value:String):void
		{
			_displayEvents = value;
		}
	
		
		
		
		public function displayComplete():void {}		
		
		
		//////////////
		//  ICSS 
		//////////////
		
		private var _class_:String;
		/**
		 * Object's css class; 
		 */			
		public function get class_():String {return _class_;}
		public function set class_(value:String):void 
		{			
			_class_ = value; 
		}	
		
		
		
		//////////////
		//  IClone  
		//////////////		
		
		/**
		 * Returns clone of self
		 */
		public function clone():Object {return new Object};	
				
		
		
		
		
		/**
		 * Prints to console
		 * @param anything
		 */		
		public function print(value:*):void
		{
			trace(value);
			
			//TODO: create console class and throw in hook here
		}
		
		protected function createUI():void{}
		protected function commitUI():void{}
		protected function layoutUI():void{}
		//public function updateUI():void{}
		protected function updateUI():void{}
	}
}