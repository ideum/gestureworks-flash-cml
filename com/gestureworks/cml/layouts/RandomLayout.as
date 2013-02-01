package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	
	/**
	 * The RandomLayout positions display objects randomly about the x- and y-axes
	 * and applies a specified amount of random rotation. 
	 * 
	 * <p>Allowable types are: randomX, randomY, randomXY, randomXYRotation</p>
	 * <p>Default type is: RandomXY.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
			
		var randomContainer:TouchContainer = getImageContainer();
		randomContainer.x = 500;
		randomContainer.y = 20;
		addChild(randomContainer);
		
		var randomLayout:RandomLayout = new RandomLayout();
		randomLayout.maxX = 400;
		randomLayout.maxY = 500;
		randomLayout.minRot = -30;
		randomLayout.maxRot = 30;
		randomLayout.type = "randomXYRotation";
		randomLayout.tween = true;
		randomLayout.tweenTime = 1500;
		randomContainer.applyLayout(randomLayout);
						
		
		function getImageContainer():TouchContainer
		{
			var container:TouchContainer = new TouchContainer();
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));			
			container.addChild(getImageElement("plane.jpg"));						
			return container;
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
	 * @author Ideum
	 * @see FanLayout 
	 * @see GridLayout
	 * @see ListLayout
	 * @see PileLayout
	 * @see RandomLayout
	 * @see LayoutFactory
	 */
	public class RandomLayout extends LayoutFactory
	{
		/**
		 * Constructor
		 */
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
		 * Since this is a rotaion dependent layout, override rotation mutator to prevent conflicts.
		 */
		override public function set rotation(value:Number):void {}
				
		
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
			
			for (var i:int = childTransformations.length; i < container.numChildren; i++) 
			{
				child = container.getChildAt(i);
				if(!validObject(child)) continue;
				
				matrix = child.transform.matrix;
				translateTransform(matrix, randomMinMax(minX, maxX), 0);						
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
			
			for (var i:int = childTransformations.length; i < container.numChildren; i++) 
			{				
				child = container.getChildAt(i);
				if(!validObject(child)) continue;
				
				matrix = child.transform.matrix;				
				translateTransform(matrix, 0, randomMinMax(minY, maxY));			
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
			
			for (var i:int = childTransformations.length; i < container.numChildren; i++) 
			{
				child = container.getChildAt(i);
				if (!validObject(child)) continue;
				
				matrix = child.transform.matrix;
				translateTransform(matrix, randomMinMax(minX, maxX), randomMinMax(minY, maxY));			
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
			
			for (var i:int = childTransformations.length; i < container.numChildren; i++) 
			{
				child = container.getChildAt(i);
				if (!validObject(child)) continue;
				
				matrix = child.transform.matrix;
				translateTransform(matrix, randomMinMax(minX, maxX), randomMinMax(minY, maxY));
				rotateTransform(matrix, degreesToRadians(randomMinMax(minRot, maxRot)));
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