package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	
	/**
	 * Positions a display container's children randomly about the x and y axes
	 * and applies a specified amount of random rotation. 
	 * 
	 * <p>Allowable types are: randomX, randomY, randomXY, randomXYRotation</p>
	 * <p>Default type is: RandomXY.</p>
	 * 
	 * @author Charles Veasey
	 */
	public class RandomLayout extends LayoutFactory
	{
		public function RandomLayout() 
		{
			super();
			type = "randomXY";
		}		
		
		private var _minX:Number = 0;
		/**
		 * The minimum random x value.
		 * @default 0
		 */
		public function get minX():Number{return _minX;}
		public function set minX(value:Number):void 
		{
			_minX = value;
		}			
		
		private var _maxX:Number = 500;
		/**
		 * The minimum random y value.
		 * @default 500
		 */		
		public function get maxX():Number{return _maxX;}
		public function set maxX(value:Number):void 
		{
			_maxX = value;
		}
		
		private var _minY:Number = 0;
		/**
		 * The minimum random y value.
		 * @default 0
		 */			
		public function get minY():Number{return _minY;}
		public function set minY(value:Number):void 
		{
			_minY = value;
		}			
		
		private var _maxY:Number = 500;
		/**
		 * The maximum random y value.
		 * @default 500
		 */				
		public function get maxY():Number{return _maxY;}
		public function set maxY(value:Number):void 
		{
			_maxY = value;
		}
		
		private var _minRot:Number = 0;
		/**
		 * The minimum rotation value.
		 * @default 0
		 */			
		public function get minRot():Number{return _minRot;}
		public function set minRot(value:Number):void 
		{
			_minRot = value;
		}			
		
		private var _maxRot:Number = 360;
		/**
		 * The maximum rotation value.
		 * @default 360
		 */			
		public function get maxRot():Number{return _maxRot;}
		public function set maxRot(value:Number):void 
		{
			_maxRot = value;
		}	
				
		
		/**
		 * Apply layout type to container object
		 * Object passed must implement DisplayObjectContainer
		 * @param	container
		 */
		override public function layout(container:DisplayObjectContainer):void
		{
			// switch layouts methods

			switch (type) 
			{
				case "randomX" : randomX(container); break;
				case "randomY" : randomY(container); break;
				case "randomXY" : randomXY(container); break;
				case "randomXYRotation" : randomXYRotation(container); break;
				default: return;
			}
			
			super.layout(container);
		}		
		
		
		
		//////////////////////////////////////////////////////
		//  RANDOM TYPES 
		//  add new methods here, and also add 
		//  to switch
		//////////////////////////////////////////////////////
		

		/**
		 * Distributes the the children of the container randomly
		 * about the x-axis.
		 * @param	container
		 */
		public function randomX(container:DisplayObjectContainer):void
		{
			var matrix:Matrix;
			var child:*;
			
			for (var i:int = 0; i < container.numChildren; i++) 
			{
				child = container.getChildAt(i);
				if (!child is DisplayObject) return;
				
				matrix = child.transform.matrix;
				matrix.translate(randomMinMax(minX, maxX), 0);			
				childTransformations.push(matrix);				
			}			
		}
		
		/**
		 * Distributes the the children of the container randomly
		 * about the y-axis.
		 * @param	container
		 */		
		public function randomY(container:DisplayObjectContainer):void
		{
			var matrix:Matrix;
			var child:*;
			
			for (var i:int = 0; i < container.numChildren; i++) 
			{				
				child = container.getChildAt(i);
				if (!child is DisplayObject) return;
				
				matrix = child.transform.matrix;
				matrix.translate(0, randomMinMax(minY, maxY));			
				childTransformations.push(matrix);
			}			
		}
		
		/**
		 * Distributes the the children of the container randomly
		 * about the x,y-axes.
		 * @param	container
		 */		
		public function randomXY(container:DisplayObjectContainer):void
		{
			var matrix:Matrix;
			var child:*;
			
			for (var i:int = 0; i < container.numChildren; i++) 
			{
				child = container.getChildAt(i);
				if (!child is DisplayObject) return;
				
				matrix = child.transform.matrix;
				matrix.translate(randomMinMax(minX, maxX), randomMinMax(minY, maxY));			
				childTransformations.push(matrix);
			}			
		}
		
		/**
		 * Distributes the the children of the container randomly
		 * about the x,y-axes and applies a random amount of rotation. 
		 * The maximum x,y value is equal to the container's width, height
		 * @param	container
		 */		
		public function randomXYRotation(container:DisplayObjectContainer):void
		{
			var matrix:Matrix;
			var child:*;
			
			for (var i:int = 0; i < container.numChildren; i++) 
			{
				child = container.getChildAt(i);
				if (!child is DisplayObject) return;
				
				matrix = child.transform.matrix;
				matrix.translate(randomMinMax(minX, maxX), randomMinMax(minY, maxY));
				matrix.rotate(degreesToRadians(randomMinMax(minRot, maxRot)));
				childTransformations.push(matrix);	
			}			
		}	

		/**
		 * Disposal method
		 */		
		override public function dispose():void 
		{
			super.dispose();
		}
		
	}

}