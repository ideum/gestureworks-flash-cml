package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;

	public class SWCElement extends ElementFactory
	{
		private var asset:*;
		private var _class:Class;
		
		public function SWCElement()
		{
			super();
		}
		
		private var _classRef:String;
		public function get classRef():String { return _classRef; }
		public function set classRef(value:String):void 
		{ 
			_classRef = value; 			
			_class = getDefinitionByName(_classRef) as Class;
			asset = new _class
			addChild(asset);
		}
		
		private var _color:Number;		
		public function get color():Number { return _color; }
		public function set color(value:Number):void 
		{ 
			_color = value;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = _color;
			asset.transform.colorTransform = colorTransform;
			colorTransform = null;
		}
		
		
	}
}