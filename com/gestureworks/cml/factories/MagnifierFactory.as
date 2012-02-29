package com.gestureworks.cml.factories 
{
	import com.gestureworks.core.TouchSprite;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class MagnifierFactory extends TouchSprite
	{		
		public function MagnifierFactory() 
		{
			super();
		}
		
		protected var _target:*;
		public function get target():*
		{
			return _target;
		}
		public function set target(value:*):void
		{
			_target = value;
		}
		
		protected var _lineStroke:int = 6;
		public function get lineStroke():int
		{
			return _lineStroke;
		}
		public function set lineStroke(value:int):void
		{
			_lineStroke = value;
			updateUI();
		}
		
		protected var _width:Number = 200;
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			_width = value;
			updateUI()
		}
		
		protected var _height:Number = 200;
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			_height = value;
			updateUI()
		}
		
		protected var _color:uint = 0x000000;
		public function get color():uint
		{
			return _color;
		}
		public function set color(value:uint):void
		{
			_color = value;
			updateUI();
		}
		
		protected var _isCircle:Boolean;
		public function get isCircle():Boolean
		{
			return _isCircle;
		}
		public function set isCircle(value:Boolean):void
		{
			_isCircle = value;
			updateUI();
		}
		
		protected var _fillColor:uint = 0x000000;
		public function get fillColor():uint
		{
			return _fillColor;
		}
		public function set fillColor(value:uint):void
		{
			_fillColor = value;
			updateUI();
		}
		
		protected var _fillAlpha:Number=0;
		public function get fillAlpha():Number
		{
			return _fillAlpha;
		}
		public function set fillAlpha(value:Number):void
		{
			_fillAlpha = value;
			updateUI();
		}
		
		protected function updateUI():void{}		
	}

}