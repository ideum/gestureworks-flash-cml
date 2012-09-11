package com.gestureworks.cml.element
{
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.managers.FileManager;
	import flash.display.DisplayObject;
	
	
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;
	
	public class SWFElement extends ElementFactory
	{
		private var asset:*;
		private var _class:Class;
		
		public function SWFElement()
		{
			super();
		}
		
		private var _src:String = "";
		/**
		 * src loads a swf movie file
		 */
		public function get src():String {return _src;}
		public function set src(value:String):void 
		{
			_src = value;
			
			if (FileManager.instance.fileList.selectKey(_src).loader)
				addChild(FileManager.instance.fileList.selectKey(_src).loader);
			else
				throw new Error("swf " + _src +  " failed to load");
		}
		
		private var _classRef:String;
		/**
		 * classRef loads a swf library class
		 * must be pre-loaded through the library kit
		 */
		public function get classRef():String { return _classRef; }
		public function set classRef(value:String):void 
		{ 
			_classRef = value; 			
			_class = getDefinitionByName(_classRef) as Class;
			asset = new _class
			addChild(asset);
			//color = _color;
		}
		
		private var _color:Number;
		/**
		 * Sets element's color in hex
		 */
		public function get color():Number { return _color; }
		public function set color(value:Number):void 
		{ 
			_color = value;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = _color;
			if (asset)
				asset.transform.colorTransform = colorTransform;
			colorTransform = null;
		}
		
	}
}