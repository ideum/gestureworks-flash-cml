package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Positions the centers of the container's objects in the same location and rotates them individually
	 * around the center. 
	 * @author Shaun
	 */
	public class PileLayout extends LayoutFactory
	{
		
		/**
		 * Constructor
		 */
		public function PileLayout() 
		{
			super();
		}	
		
		/**
		 * The x coordinate the display objects are centered and rotated on
		 */
		private var _originX:Number = 0;
		public function get originX():Number { return _originX; }
		public function set originX(ox:Number):void
		{
			_originX = ox;
		}

		/**
		 * The y coordinate the display objects are centered and rotated on
		 */		
		private var _originY:Number = 0;
		public function get originY():Number { return _originY; }
		public function set originY(oy:Number):void
		{
			_originY = oy;
		}
		
		/**
		 * The angle of rotation between the display objects
		 */
		private var _angle:Number;
		public function get angle():Number { return _angle; }
		public function set angle(a:Number):void
		{
			_angle = a;
		}

		/**
		 * Centers the object on the origin
		 * @param	obj  the display object
		 */
		private function centerOnOrigin(obj:*):void
		{
			obj.x = originX - obj.width/2;
			obj.y = originY - obj.height/2;			
		}

		/**
		 * Centers and rotates the container's display objects around a common point. If the angle of rotation has
		 * not been defined, the angle is random. 
		 * @param	container
		 */
		override public function layout(container:DisplayObjectContainer):void 
		{
			var c:DisplayObjectContainer = container;
			var nextAngle:Number = 0;
		
			for (var i:int = 0; i < c.numChildren; i++) 
			{		
				var child:DisplayObject = c.getChildAt(i);
				if (!child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				centerOnOrigin(child);
				nextAngle = angle ? nextAngle += angle : randomMinMax(0, 360); 				
				rotateAroundPoint(child, nextAngle, originX, originY);						
			}					
		}
		
		/**
		 * Disposal function
		 */
		override public function dispose():void 
		{
			super.dispose();
		}
		
	}

}