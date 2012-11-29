package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * The PileLayout positions the centers of the container's objects in the same 
	 * location and rotates them individually around the center.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
			
		var randomRotationPile:Container = getImageContainer();
		randomRotationPile.x = 700;
		randomRotationPile.y = 200;
		randomRotationPile.applyLayout(getPileLayout());
		addChild(randomRotationPile);
					
		var fixedRotationPile:Container = getImageContainer();
		fixedRotationPile.x = 1000;
		fixedRotationPile.y = 500;
		fixedRotationPile.applyLayout(getPileLayout(20));
		addChild(fixedRotationPile);
		
		
		function getImageContainer():Container
		{
			var container:Container = new Container();
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));						
			return container;
		}
		
		
		function getPileLayout(angle:Number = 0):PileLayout
		{
			var pileLayout:PileLayout = new PileLayout();
			pileLayout.angle = angle;
			pileLayout.tween = true;
			pileLayout.tweenTime = 1500;
			return pileLayout;
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
	 * @see FanLayout  
	 * @see ListLayout
	 * @see PointLayout
	 * @see RandomLayout
	 * @see com.gestureworks.cml.factories.LayoutFactory
	 * @see com.gestureworks.cml.element.Container
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
		 * Centers and rotates the container's display objects around a common point. If the angle of rotation has
		 * not been defined, the angle is random. 
		 * @param	container
		 */
		override public function layout(container:DisplayObjectContainer):void 
		{
			var c:DisplayObjectContainer = container;
			var nextAngle:Number = 0;
		
			for (var i:int = childTransformations.length; i < c.numChildren; i++) 
			{		
				var child:DisplayObject = c.getChildAt(i);
				if (!child is DisplayObject) return;
				
				var matrix:Matrix = child.transform.matrix;
				matrix.translate(originX - child.width / 2, originY - child.height / 2);
				nextAngle = !isNaN(angle) ? nextAngle += angle : randomMinMax(0, 360); 				
				matrix = pointRotateMatrix(nextAngle, originX, originY, matrix);
				childTransformations.push(matrix);				
			}
			
			super.layout(container);
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