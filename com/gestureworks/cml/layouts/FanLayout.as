package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.display.Sprite;
	
	/**
	 * Positions the corners of the container's objects in the same location and rotates them individually
	 * around the corner. 
	 * @author Shaun
	 */
	public class FanLayout extends LayoutFactory
	{
		
		/**
		 * Constructor
		 */
		public function FanLayout() 
		{
			super();
			type = "topLeftOrigin";
		}
		
		/**
		 * The x origin of rotation
		 */
		private var _originX:Number = 0;
		public function get originX():Number { return _originX; }
		public function set originX(ox:Number):void
		{
			_originX = ox;
		}
		
		/**
		 * The y origin of rotation
		 */
		private var _originY:Number = 0;
		public function get originY():Number { return _originY; }
		public function set originY(oy:Number):void
		{
			_originY = oy;
		}		
		
		/**
		 * The angle of rotation
		 */
		private var _angle:Number = 5;
		public function get angle():Number { return _angle; }
		public function set angle(a:Number):void 
		{
			_angle = a;
		}
		
		/**
		 * Positions and rotates the objects based on the type
		 * @param	container
		 */
		override public function layout(container:IContainer):void 
		{
			switch (type) 
			{
				case "topLeftOrigin" : topLeftPivot(container); break;
				case "topRightOrigin" : topRightPivot(container); break;
				case "bottomLeftOrigin" : bottomLeftPivot(container); break;
				case "bottomRightOrigin" : bottomRightPivot(container); break;
				default: break;
			}
		}
		
		/**
		 * Positions the top left corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */
		private function topLeftPivot(c:IContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = 0; i < c.childList.length; i++) 
			{				
				var child:* = c.childList.getIndex(i);
				if (!child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				child.x = originX;
				child.y = originY;
				child.rotation = nextAngle;
				nextAngle += angle;
			}
		}
		
		/**
		 * Positions the top right corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */		
		private function topRightPivot(c:IContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = 0; i < c.childList.length; i++) 
			{				
				var child:* = c.childList.getIndex(i);
				if (!child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				child.x = originX - child.width;
				child.y = originY;
				rotateAroundPoint(child, nextAngle, originX, originY);				
				nextAngle += angle;
			}			
		}
		
		/**
		 * Positions the bottom left corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */		
		private function bottomLeftPivot(c:IContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = 0; i < c.childList.length; i++) 
			{				
				var child:* = c.childList.getIndex(i);
				if (!child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				child.x = originX;
				child.y = originY - child.height;
				rotateAroundPoint(child, nextAngle, originX, originY);				
				nextAngle += angle;
			}			
		}		
		
		/**
		 * Positions the bottom right corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */		
		private function bottomRightPivot(c:IContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = 0; i < c.childList.length; i++) 
			{				
				var child:* = c.childList.getIndex(i);
				if (!child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				child.x = originX - child.width;
				child.y = originY - child.height;
				rotateAroundPoint(child, nextAngle, originX, originY);				
				nextAngle += angle;
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