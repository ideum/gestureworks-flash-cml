package com.gestureworks.cml.layouts 
{
    import flash.geom.Point;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.interfaces.*;
   
    /**
     * A layout utility for laying out display objects in a grid
     *
     * @author 
     * @version
     */
    public class GridLayout extends LayoutFactory 
    {       
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
		

		private var _spacingX:int=20;
		/**
		 * An integer representing the spacing between columns
		 * @default 20
		 */		
		public function get spacingX():int {return _spacingX}
		public function set spacingX(value:int):void 
		{			
			_spacingX = value;		
		}
		
		
		private var _spacingY:int=20;
		/**
		 * An integer representing the spacing between rows
		 * @default 20
		 */		
		public function get spacingY():int {return _spacingY}
		public function set spacingY(value:int):void 
		{			
			_spacingY = value;		
		}
		
		
		private var _paddingX:int=20;
		/**
		 * An integer representing the padding between each column
		 * @default 20
		 */		
		public function get paddingX():int {return _paddingX}
		public function set paddingX(value:int):void 
		{			
			_paddingX = value;		
		}
		
		
		private var _paddingY:int=20;
		/**
		 * An integer representing the padding between each row
		 * @default 20;
		 */		
		public function get paddingY():int {return _paddingY}
		public function set paddingY(value:int):void 
		{			
			_paddingY = value;		
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
		 * Apply layout type to container object
		 * Object passed must implement IContainer
		 * @param	type
		 * @param	container
		 */
		override public function layout(container:IContainer):void
		{
			var c:* = container;		
			var arr:Array = createGrid(_columns, _rows, _spacingX, _spacingY, _paddingX, _paddingY, _leftToRight)
			
			// hide all but first button
			for (var i:int = 0; i < arr.length; i++) 
			{			
				if (c.childList.getIndex(i))
				{
					if (c.childList.getIndex(i).hasOwnProperty("x"))
						c.childList.getIndex(i).x = arr[i].x;
					if (c.childList.getIndex(i).hasOwnProperty("y"))					
						c.childList.getIndex(i).y = arr[i].y;
				}
			}
	
		}	


        /**
         * Creates the grid and returns an array of points with x and y values based on passed parameters.
         * The leftToRight addition was contributed by Skye Giordano.
         *
         * @param columns An integer representing the number of columns to be created in the grid
         * @param rows An integer representing the number of rows to be created in the grid
         * @param xSpacing An integer representing the spacing between columns
         * @param ySpacing An integer representing the spacing between rows
         * @param xPadding An integer representing the padding between each column
         * @param yPadding An integer representing the padding between each row
         * @param leftToRight An optional boolean that creates the grid from left-to-right or top-to-bottom (default: true)
         *
         * @return Array
         */
       
        public function createGrid(columns:int, rows:int, xSpacing:int, ySpacing:int, xPadding:int, yPadding:int, leftToRight:Boolean = true):Array
        {
            var arr:Array = new Array();
            var pt:Point;
            var row:Number;
            var col:Number;
            var num:int = (columns * rows);
           
            for (var i:int = 0; i <num; i++)
            {
                pt = new Point();
               
                if (leftToRight)
                {
                    row = (i % columns);
                    col = Math.floor(i / columns);
               
                    pt.x = (row * (xSpacing + xPadding));
                    pt.y = (col * (ySpacing + yPadding));
                }
                else
                {
                    row = (i % rows);
                    col = Math.floor(i / rows);
               
                    pt.x = (col * (xSpacing + xPadding));
                    pt.y = (row * (ySpacing + yPadding));
                }
               
                arr.push(pt);
            }
           
            return arr;
        }
   

    }
}	
