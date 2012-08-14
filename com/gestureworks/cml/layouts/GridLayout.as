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
		 * Object passed must implement IContainer
		 * @param	container
		 */
		override public function layout(container:IContainer):void
		{
			var c:* = container;	
            var row:Number;
            var col:Number;
			var sumx:Number = 0;
			var sumy:Number = 0;
            var num:int = (columns * rows);
						
			
			for (var i:int = 0; i < c.childList.length; i++) 
			{		
				var child:* = c.childList.getIndex(i);
				if (!child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				if (leftToRight)
				{					
                    row = Math.floor(i / columns);               
                    col = (i % columns);
					
                    child.x = useMargins ? sumx + col * (2*marginX) : col * spacingX;
                    child.y = useMargins ? sumy + row * (2*marginY) : row * spacingY;
					
					sumx = col == columns-1 ? 0 : sumx + child.width * child.scaleX;
					sumy = col == columns-1 ? sumy + child.height * child.scaleY : sumy;						
				}
                else
                {
                    row = (i % rows);
                    col = Math.floor(i / rows);
               
                    child.x = useMargins ? sumx + col * (2*marginX) : col * spacingX;
                    child.y = useMargins ? sumy + row * (2*marginY) : row * spacingY;	

					sumx = row == rows-1 ? sumx + child.width * child.scaleX : sumx;
					sumy = row == rows - 1 ? 0 : sumy + child.height * child.scaleY;					
                }				
			}
	
		}	
   
		override public function dispose():void 
		{
			super.dispose();			
		}		
    }
}	
