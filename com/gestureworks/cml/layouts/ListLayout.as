package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.sampler.NewObjectSample;
	
	/**	 
	 * List Layout
	 * @author Charles Veasey
	 */
	public class ListLayout extends LayoutFactory
	{
		private var n:int;
		
		public function ListLayout() 
		{
			super();
			type = "horizontal";
		}
				
		
		/**
		 * Apply layout type to container object
		 * Object passed must implement IContainer
		 * @param	type
		 * @param	container
		 */
		override public function layout(container:DisplayObjectContainer):void
		{
			// switch layouts methods

			switch (type) 
			{
				case "vertical" : vertical(container); break;
				case "horizontal" : horizontal(container); break;
				default: return;
			}
			
			super.layout(container);
		}		
		
		
		
		//////////////////////////////////////////////////////
		//  List TYPES 
		//  add new methods here, and also add 
		//  to switch
		//////////////////////////////////////////////////////
		

		/**
		 * Distributes the the children of the container in a list
		 * about the x-axis. Margin is multiplied by 2 to represent the margin between
		 * two objects.
		 * @param	container
		 */
		public function horizontal(container:DisplayObjectContainer):void
		{		
			n = container.numChildren;
			var sumx:Number = 0;
			var xVal:Number;
			var matrix:Matrix;
			
			for (var i:int = 0; i < n; i++) 
			{		
				var child:* = container.getChildAt(i);
				if (!child is DisplayObject) return;

				xVal = useMargins ? sumx + i * (2*marginX) : i * spacingX;
				matrix = child.transform.matrix;
				matrix.translate(xVal, 0);			
				childTransformations.push(matrix);
				sumx += child.width;
			}
		}
		
		/**
		 * Distributes the the children of the container in a vertical list
		 * about the y-axis. Margin is multiplied by 2 to represent the margin between
		 * two objects.
		 * @param	container
		 */		
		public function vertical(container:DisplayObjectContainer):void
		{
			n = container.numChildren; 
			var sumy:Number = 0;
			var yVal:Number;
			var matrix:Matrix;
			
			for (var i:int = 0; i < n; i++) 
			{				
				var child :* = container.getChildAt(i);
				if (!child is DisplayObject) return;
							
				yVal = useMargins ? sumy + i * (2 * marginY) : i * spacingY;
				matrix = child.transform.matrix;
				matrix.translate(0, yVal);			
				childTransformations.push(matrix);						
				sumy += child.height;
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