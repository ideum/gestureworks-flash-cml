package com.gestureworks.cml.element
{	
	import com.gestureworks.core.DisplayList;	
	import flash.geom.ColorTransform;

	public class ButtonState extends Container
	{
		private var target:*;
		
		public function ButtonState()
		{
			super();
			target = this;
		}
		
		private var _color:Number;		
		public function get color():Number { return _color; }
		public function set color(value:Number):void 
		{ 
			_color = value;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = _color;
			target.transform.colorTransform = colorTransform;
			colorTransform = null;
		}
				
	}
}