package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.interfaces.ICSS;
	import com.gestureworks.cml.interfaces.IElement;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;
	
	/** 
	 * The ElementFactory is the base class for all Elements.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.factories.GraphicFactory
	 * @see com.gestureworks.cml.factories.ObjectFactory
	 */		
	public class ElementFactory extends Sprite implements IElement, ICSS
	{
		
		/**
		 * Constructor
		 */
		public function ElementFactory() 
		{
			super();
			
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);
				
			super.scaleX = 1;
			super.scaleY = 1;
			
			mouseChildren = true;
		}			
		

		
	
		////////////////
		//  IObject  
		///////////////		
		
		
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
			
			propertyStates = null
			debugStyle = null;
		}
		
		/**
		 * creates propertystates array
		 */
		public var propertyStates:Array;
		
		private var _id:String
		/**
		 * sets the id of child
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
		 * parses cml file
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList
		{			
			return CMLParser.instance.parseCML(this, cml);
		}
		
		/**
		 * post parses the cml file
		 * @param	cml
		 */
		public function postparseCML(cml:XMLList):void {}
		
		/**
		 * this method updates the properties
		 * @param	state
		 */
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}	
		

		private var _className:String;
		/**
		 * specifies the class name of the displayobject
		 */
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
		
		
		private var _widthPercent:String = "";		
		/**
		 * sets the percent of width of display object
		 */
		public function get widthPercent():String{return _widthPercent;}
		public function set widthPercent(value:String):void
		{
			_widthPercent = value;
			var number:Number = Number(widthPercent.slice(0, widthPercent.indexOf("%")));
			if (parent) width = parent.width * (number / 100);
		}
				
		
		private var _heightPercent:*= "";
		/**
		 * sets the height percent of display object
		 */
		public function get heightPercent():String{	return _heightPercent;}
		public function set heightPercent(value:String):void
		{
			_heightPercent = value;
			var number:Number = Number(heightPercent.slice(0, heightPercent.indexOf("%")));
			if (parent) height = parent.height * (number / 100);
		}		
		
		
		
		
		private var _scale:Number = 1;
		/**
		 * Sets both the x and y scale values
		 * @default 1
		 */				
		public function get scale():Number{	return _scale;}
		public function set scale(value:Number):void
		{
			_scale = value;
			scaleX = value;
			scaleY = value;
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
				this.filters.push(dropShadowfilter);
			else	
				this.filters = [];
				
			_dropShadow = value;
		}
		

		private var blurFilter:BlurFilter = new BlurFilter(2, 2, 1);
		private var _blur:Boolean = false;
		/**
		 * Sets the drop shadow effect
		 * @default false
		 */
		public function get blur():Boolean { return _blur; }		
		public function set blur(value:Boolean):void 
		{ 			
			if (value)
				this.filters.push(blurFilter);
			else	
				this.filters = [];
				
			_blur = value;
		}		
		
		
		/**
		 * sets the alpha for display objects
		 * @default 0
		 */		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
		}
		
		
		private var _horizontalCenter:Number = 0;
		/**
		 * sets the horizontal center of display object
		 * @default 0
		 */
		public function get horizontalCenter():Number{return _horizontalCenter;}
		public function set horizontalCenter(value:Number):void
		{
			_horizontalCenter = value;
			if (parent) x = ((parent.width - width) / 2) + value;
		}
		
		private var _verticalCenter:Number = 0;
		/**
		 * sets the vertical center of display object
		 * @default 0
		 */
		public function get verticalCenter():Number{return _verticalCenter;}
		public function set verticalCenter(value:Number):void
		{
			_verticalCenter = value;
			if (parent) y = ((parent.height - height) / 2) + value;
		}
		
		private var _top:Number = 0;
		/**
		 * sets top value
		 */
		public function get top():Number{return _top;}
		public function set top(value:Number):void
		{
			_top = value;
			y = value;
		}
		
		private var _left:Number = 0;
		/**
		 * sets left value
		 */
		public function get left():Number{return _left;}
		public function set left(value:Number):void
		{
			_left = value;
			x = value
		}		
		
		private var _bottom:Number = 0;
		/**
		 * sets the bottom value
		 */
		public function get bottom():Number{return _bottom;}
		public function set bottom(value:Number):void
		{
			_bottom = value;			
			if (parent) y = (parent.height - height) + value;
		}
		
		private var _right:Number = 0;
		/**
		 * sets the right value
		 */
		public function get right():Number{return _right;}
		public function set right(value:Number):void
		{
			_right = value;
			if (parent) x = (parent.width - width) + value;
		}
		
		private var _index:int;
		/**
		 * sets the index of display object
		 */
		public function get index():int{return _index;}
		public function set index(value:int):void
		{
			_index = value;
		}	
		
		private var _debugStyle:*;
		/**
		 * sets the debug style
		 */
		public function get debugStyle():*{return _debugStyle;}
		public function set debugStyle(value:*):void
		{
			_debugStyle = value;
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
	
		/**
		 * CML callback
		 */		
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
		public function clone():* 
		{
			var clone:ElementFactory = CloneUtils.clone(this, this.parent);
			clone.displayComplete();
			return clone;
		}
		
	}
}