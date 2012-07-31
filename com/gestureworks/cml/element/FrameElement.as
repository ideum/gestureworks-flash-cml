package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.GraphicFactory;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class FrameElement extends GraphicFactory
	{
		
		public function FrameElement() 
		{			
			super();
			layoutUI();
		}		
		
		
		override protected function layoutUI():void
		{			
			graphics.clear();		
			
			if(_shape=="rectangle"){
			// draw
			graphics.lineStyle(2*_frameThickness, _frameColor, _frameAlpha);
			graphics.drawRect( -_frameThickness, -_frameThickness, width + 2 * _frameThickness, height + 2 * _frameThickness);
			graphics.lineStyle(2, _frameColor,_frameAlpha+0.5);
			graphics.drawRoundRect( -2 * _frameThickness, -2 * _frameThickness, width + 4 * _frameThickness, height + 4 * _frameThickness, 2 * _frameThickness, 2 * _frameThickness);
			graphics.lineStyle(4, _frameColor,0.8);
			graphics.drawRect(-2, -2, width + 4, height + 4);
			}
			
			// complete			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected var _shape:String="rectangle";
		/**
		 * Sets frame shape
		 * @default "rectangle"
		 */			
		public function get frameShape():String{return _shape;}
		public function set frameShape(value:String):void
		{
			_shape = value;		
			layoutUI();
		}
		
		protected var _frameThickness:Number=30;
		/**
		 * Sets frame thickness
		 * @default 100
		 */			
		public function get frameThickness():Number{return _frameThickness;}
		public function set frameThickness(value:Number):void
		{
			_frameThickness = value;		
			layoutUI();
		}
		
		protected var _frameColor:Number=0x999999;
		/**
		 * Sets frame thickness
		 * @default 100
		 */			
		public function get frameColor():Number{return _frameColor;}
		public function set frameColor(value:Number):void
		{
			_frameColor = value;		
			layoutUI();
		}
		protected var _frameAlpha:Number=0.3;
		/**
		 * Sets frame thickness
		 * @default 100
		 */			
		public function get frameAlpha():Number{return _frameAlpha;}
		public function set frameAlpha(value:Number):void
		{
			_frameAlpha = value;		
			layoutUI();
		}

	}
}