package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.display.DisplayObjectContainer;
	
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
		
		private var _close_packing:Boolean = true;
		[Deprecated(replacement="closePacking()")] 
		public function get close_packing():Boolean{return _close_packing;}
		public function set close_packing(value:Boolean):void 
		{
			_close_packing = value;
		}

		private var _closePacking:Boolean = false;
		public function get closePacking():Boolean { return _closePacking; }
		public function set closePacking(value:Boolean):void 
		{
			_closePacking= value;
		}		
		
		private var _blockX:Number = 400;
		public function get blockX():Number{return _blockX;}
		public function set blockX(value:Number):void 
		{
			_blockX = value;
		}
		
		private var _blockY:Number = 400;
		public function get blockY():Number{return _blockY;}
		public function set blockY(value:Number):void 
		{
			_blockY = value;
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
				default: break;
			}	
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
			
			for (var i:int = 0; i < n; i++) 
			{		
				var obj:* = container.getChildAt(i);
				
				if (!closePacking) {
		
					obj.x = i * blockX + i * (2*marginX);
					obj.y = 0;					
				}
				else {
					
					obj.x = useMargins ? sumx + i * (2*marginX) : i * spacingX;
					obj.y = 0;
				}
				sumx += obj.width * obj.scaleX;
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
			
			for (var i:int = 0; i < n; i++) 
			{				
				var obj:* = container.getChildAt(i);
							
					if (!closePacking) {
						obj.x = 0;
						obj.y = i * blockY + i * (2*marginY);
					}
					else {
						obj.x = 0;
						obj.y = useMargins ? sumy + i * (2*marginY) : i * spacingY;
					}
					sumy += obj.height;
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