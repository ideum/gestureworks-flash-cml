package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.interfaces.ILayout;	
	import flash.geom.Matrix;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * Base layout class
	 * @author Charles Veasey and Shaun
	 */
	public class LayoutFactory extends ObjectFactory implements ILayout
	{
		
		/**
		 * Constructor
		 */
		public function LayoutFactory() 
		{
			super();
		}
		
		/**
		 * Horizontal distance between the origins of two objects
		 * @default 100
		 */
		private var _spacingX:Number = 100;
		public function get spacingX():Number { return _spacingX; }
		public function set spacingX(s:Number):void
		{
			_spacingX = s;
		}
		
		/**
		 * Vertical distance between the origins of two objects
		 * @default 100
		 */
		private var _spacingY:Number = 100;
		public function get spacingY():Number { return _spacingY; }
		public function set spacingY(s:Number):void
		{
			_spacingY = s;
		}
		
		/**
		 * Spacing added to the width of an object
		 * @default 10
		 */
		private var _marginX:Number = 10;
		public function get marginX():Number { return _marginX; }
		public function set marginX(m:Number):void
		{
			_marginX = m;
		}
		
		/**
		 * Spacing added to the height of an object
		 * @default 10
		 */
		private var _marginY:Number = 10;
		public function get marginY():Number { return _marginY; }
		public function set marginY(m:Number):void
		{
			_marginY = m;
		}				
		
		/**
		 * Flag indicating the use of margins or spacing
		 */
		private var _useMargins:Boolean = false;
		public function get useMargins():Boolean { return _useMargins; }
		public function set useMargins(um:Boolean):void
		{
			_useMargins = um;
		}
		
		/**
		 * Specifies a layout subtype
		 */
		private var _type:String;
		public function get type():String { return _type; }
		public function set type(t:String):void
		{
			_type = t;
		}
		
		/**
		 * Generates a reandom number between min and max
		 * @param	min  the bottom limit
		 * @param	max  the top limit
		 * @return  a random number
		 */
		protected function randomMinMax(min:Number, max:Number):Number
		{
			return min + Math.random() * (max - min);
		}
		
		/**
		 * Rotates an object around a spcecific point at a specific angle of rotation
		 * @param	obj  the object to rotate
		 * @param	angle  the angle of rotation
		 * @param	aroundX  the x coordinate of the point to rotate around
		 * @param	aroundY  the y coordinate of the point to rotate around
		 */
		protected function rotateAroundPoint(obj:*, angle:Number, aroundX:Number, aroundY:Number):void
		{		
			var m:Matrix = obj.transform.matrix;			 
			m.translate( -aroundX, -aroundY );
			m.rotate(Math.PI * angle / 180);
			m.translate( aroundX, aroundY );
			obj.transform.matrix = m;
		}				
		
		/**
		 * The object distribution function 
		 * @param	container
		 */
		public function layout(container:DisplayObjectContainer):void {}
	}

}