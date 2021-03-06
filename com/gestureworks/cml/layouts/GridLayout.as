package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.interfaces.*;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
   
	/**	 
	 * The GridLayout positions the display objects in a grid.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		var grid:Container = getImageContainer();
		grid.applyLayout(getGridLayout());
		addChild(grid);
		
		
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
		
		
		function getGridLayout():GridLayout
		{
			var gridLayout:GridLayout = new GridLayout();
			gridLayout.rows = 3;
			gridLayout.columns = 3;
			gridLayout.useMargins = true;
			gridLayout.marginX = 4;
			gridLayout.marginY = 4;			
			gridLayout.tween = true;
			gridLayout.tweenTime = 1500;
			return gridLayout;
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
	 * @see ListLayout
	 * @see PileLayout
	 * @see PointLayout
	 * @see RandomLayout
	 * @see com.gestureworks.cml.layouts.Layout
	 * @see com.gestureworks.cml.elements.Container
     */
    public class GridLayout extends Layout
    {      
		/**
		 * Constructor
		 */ 
        public function GridLayout():void 
		{ 
			super();		
		}
       
		
		private var _columns:int=2;
		/**
		 * An integer representing the number of columns to be created in the grid
		 * @default 2
		 */		
		public function get columns():int {return _columns}
		public function set columns(value:int):void 
		{			
			_columns = value;		
		}		
		
		
		private var _rows:int=1;
		/**
		 * An integer representing the number of rows to be created in the grid
		 * @default 1
		 */		
		public function get rows():int {return _rows}
		public function set rows(value:int):void 
		{			
			_rows = value;		
		}							
		
		private var _leftToRight:Boolean=true;
		/**
		 * An optional boolean that creates the grid from left-to-right or top-to-bottom
		 * @default true
		 */		
		public function get leftToRight():Boolean {return _leftToRight}
		public function set leftToRight(value:Boolean):void 
		{			
			_leftToRight = value;	
		}
		
		
		/**
		 * Apply grid layout to container object
		 * Object passed must implement DisplayObjectContainer
		 * @param	container
		 */
		override public function layout(container:DisplayObjectContainer):void
		{
            var row:Number;
            var col:Number;
			var sumx:Number = originX;
			var sumy:Number = originY;
            var num:int = (columns * rows);
			var child:*;
			var xVal:Number;
			var yVal:Number;
			var matrix:Matrix;
			var index:int = 0;
						
			for (var i:int = childTransformations.length; i < container.numChildren; i++) 
			{		
				child = container.getChildAt(i);				
				if (!validObject(child)) continue;
				
				if (leftToRight)
				{					
                    row = Math.floor(index / columns);               
                    col = (index % columns);

                    xVal = useMargins ? sumx + col * (2*marginX) : col * spacingX + originX;
                    yVal = useMargins ? sumy + row * (2 * marginY) : row * spacingY + originY;

					matrix = child.transform.matrix;
					translateTransform(matrix, xVal, yVal);
					childTransformations.push(matrix);
					
					sumx = col == columns - 1 ? originX : sumx + child.width;
					sumy = col == columns - 1 ? sumy + child.height  : sumy;											
				}
                else
                {
                    row = (index % rows);
                    col = Math.floor(index / rows);
               
                    xVal = useMargins ? sumx + col * (2*marginX) : col * spacingX + originX;
                    yVal = useMargins ? sumy + row * (2 * marginY) : row * spacingY + originY;	

					matrix = child.transform.matrix;
					translateTransform(matrix, xVal, yVal);
					childTransformations.push(matrix);

					sumx = row == rows-1 ? sumx + child.width : sumx;
					sumy = row == rows - 1 ? originY : sumy + child.height;					
                }

				index++;
			}
	
			super.layout(container);
		}	
   
		/**
		 * dispose function
		 */
		override public function dispose():void 
		{
			super.dispose();			
		}		
    }
}	
