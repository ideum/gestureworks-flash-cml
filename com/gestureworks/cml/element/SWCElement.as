package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;

	/**
	 * SWC element displays an external class from a SWC library file that has been loaded through a LibraryKit.
	 * @author..
	 */
	public class SWCElement extends ElementFactory
	{
		private var asset:*;
		private var _class:Class;
		
		/**
		 * constructor
		 */
		public function SWCElement()
		{
			super();
		}
		
		/**
		 * initialisation method
		 */
		public function init():void {
			
		}
		
		private var _classRef:String;
		/**
		 * classRef loads a swc library class
		 * must be pre-loaded through the library kit
		 */
		public function get classRef():String { return _classRef; }
		public function set classRef(value:String):void 
		{ 
			_classRef = value; 			
			_class = getDefinitionByName(_classRef) as Class;
			asset = new _class
			addChild(asset);
		}
		
		private var _color:Number;
		/**
		 * sets the color
		 */
		public function get color():Number { return _color; }
		public function set color(value:Number):void 
		{ 
			_color = value;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = _color;
			asset.transform.colorTransform = colorTransform;
			colorTransform = null;
		}
		
		/**
		 * dispose method to nullify attributes
		 */
		override public function dispose():void
		{
			super.dispose();
			asset = null;
            _class = null;
		}	
		
	}
}