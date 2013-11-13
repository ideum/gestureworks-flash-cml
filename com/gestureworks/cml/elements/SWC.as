package com.gestureworks.cml.elements
{
	import flash.geom.ColorTransform;
	import flash.utils.getDefinitionByName;
	
	/**
	 * The SWC element displays an external class from a SWC library file.
	 * It is meant to be used within CML. It provides little difference from native methods when using AS3.
	 * 
	 * <p>The SWC libray must be included in the project's library, and must
	 * be registered somewhere in the project by using the following import statement:</p>
	 * 
	 * <code>import myAsset; myAsset;</code>
	 *
	 * <p>If the SWC library contains a package structure, then you must include it:</p>
	 * 
	 * <code>import org.openexhibits.myAsset; myAsset;</code>
	 * 
	 * @author Ideum
	 * @see SWF
	 */
	public class SWC extends TouchContainer
	{
		private var asset:*;
		private var _class:Class;
		
		/**
		 * Constructor
		 */
		public function SWC()
		{
			super();
			mouseChildren = true;
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void {}
		
		
		private var _classRef:String;
		/**
		 * Loads a swc library class. 
		 * It must be pre-loaded through the library kit
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
		 * Sets the color
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
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			asset = null;
            _class = null;
		}	
		
	}
}