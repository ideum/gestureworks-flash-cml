package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	
	/**
	 * The FanLayout positions the corners of the container's objects in the same location and rotates them individually
	 * around the corner.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var topLeftFan:Container = getImageContainer();
		topLeftFan.applyLayout(getFanLayout());
		addChild(topLeftFan);	 
		
		
		function getImageContainer():Container
		{
			var container:Container = new Container();
			container.addChild(getImageElement("plane.jpg));			
			container.addChild(getImageElement("plane.jpg));			
			container.addChild(getImageElement("plane.jpg));			
			container.addChild(getImageElement("plane.jpg));			
			container.addChild(getImageElement("plane.jpg));			
			container.addChild(getImageElement("plane.jpg));						
			container.addChild(getImageElement("plane.jpg));						
			container.addChild(getImageElement("plane.jpg));					
			return container;
		}

		
		function getFanLayout(angle:Number = 10, type:String = "topLeftOrigin"):FanLayout
		{
			var fanLayout:FanLayout = new FanLayout();
			fanLayout.angle = angle;
			fanLayout.type = type;
			fanLayout.tween = true;
			fanLayout.tweenTime = 1500;
			return fanLayout;
		}
		
		
		function getImageElement(source:String):Image
		{
			var img:Image = new Image();
			img.open(source);
			img.width = 250;
			img.height = 150;
			img.resample = true;
			return img;
		}			
		
	 * </codeblock>
	 * 
	 * @author Shaun
	 * @see GridLayout
	 * @see ListLayout
	 * @see PileLayout
	 * @see PointLayout
	 * @see RandomLayout
	 * @see com.gestureworks.cml.factories.LayoutFactory
	 * @see com.gestureworks.cml.element.Container
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
		 * @default 5
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
		override public function layout(container:DisplayObjectContainer):void 
		{
			switch (type) 
			{
				case "topLeftOrigin" : topLeftPivot(container); break;
				case "topRightOrigin" : topRightPivot(container); break;
				case "bottomLeftOrigin" : bottomLeftPivot(container); break;
				case "bottomRightOrigin" : bottomRightPivot(container); break;
				default: return;
			}
			
			super.layout(container);
		}
		
		/**
		 * Positions the top left corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */
		private function topLeftPivot(c:DisplayObjectContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = childTransformations.length; i < c.numChildren; i++) 
			{				
				var child:* = c.getChildAt(i);
				if (!validObject(child)) continue;
				
				var matrix:Matrix = child.transform.matrix;
				matrix.translate(originX, originY);
				matrix.rotate(degreesToRadians(nextAngle));
				childTransformations.push(matrix);
				nextAngle += angle;
			}			
		}        
		
		/**
		 * Positions the top right corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */		
		private function topRightPivot(c:DisplayObjectContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = childTransformations.length; i < c.numChildren; i++) 
			{				
				var child:* = c.getChildAt(i);
				if (!validObject(child)) continue;
				
				var matrix:Matrix = child.transform.matrix;
				matrix.translate(originX - child.width, originY);
				matrix = pointRotateMatrix(nextAngle, originX, originY, matrix);
				childTransformations.push(matrix);
				nextAngle += angle;
			}			
		}
		
		/**
		 * Positions the bottom left corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */		
		private function bottomLeftPivot(c:DisplayObjectContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = childTransformations.length; i < c.numChildren; i++) 
			{				
				var child:* = c.getChildAt(i);
				if (!validObject(child)) continue;
				
				var matrix:Matrix = child.transform.matrix;
				matrix.translate(originX, originY-child.height);
				matrix = pointRotateMatrix(nextAngle, originX, originY, matrix);
				childTransformations.push(matrix);
				nextAngle += angle;
			}			
		}		
		
		/**
		 * Positions the bottom right corner of the objects at the origin and rotates them around
		 * the origin at the specific angle
		 * @param	c  object container
		 */		
		private function bottomRightPivot(c:DisplayObjectContainer):void
		{
			var nextAngle:Number = 0;
			for (var i:int = childTransformations.length; i < c.numChildren; i++) 
			{				
				var child:* = c.getChildAt(i);
				if (!validObject(child)) continue;
				
				var matrix:Matrix = child.transform.matrix;
				matrix.translate(originX-child.width, originY-child.height);
				matrix = pointRotateMatrix(nextAngle, originX, originY, matrix);
				childTransformations.push(matrix);
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