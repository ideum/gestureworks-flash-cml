package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	
	/**
	 * Random
	 * Random Layout
	 * @author Charles Veasey
	 */
	public class ListLayout extends LayoutFactory
	{
		private var n:int;
		
		public function ListLayout() 
		{
			super();
		}
		
		private var _type:String = "horizontal";
		public function get type():String{return _type;}
		public function set type(value:String):void 
		{
			_type = value;
		}
		
		private var _close_packing:Boolean = false;
		public function get close_packing():Boolean{return _close_packing;}
		public function set close_packing(value:Boolean):void 
		{
			_close_packing = value;
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
		
		private var _paddingX:Number = 25;
		public function get paddingX():Number{return _paddingX;}
		public function set paddingX(value:Number):void 
		{
			_paddingX = value;
		}	
		private var _paddingY:Number = 25;
		public function get paddingY():Number{return _paddingY;}
		public function set paddingY(value:Number):void 
		{
			_paddingY = value;
		}
		
		private var _marginX:Number = 10;
		public function get marginX():Number{return _marginX;}
		public function set marginX(value:Number):void 
		{
			_marginX = value;
		}
		
		private var _marginY:Number = 10;
		public function get marginY():Number{return _marginY;}
		public function set marginY(value:Number):void 
		{
			_marginY = value;
		}		
				
		
		/**
		 * Apply layout type to container object
		 * Object passed must implement IContainer
		 * @param	type
		 * @param	container
		 */
		override public function layout(container:IContainer):void
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
		 * about the x-axis.
		 * @param	container
		 */
		public function horizontal(container:IContainer):void
		{
			n = container.childList.length;
			var sumx:Number = 0;
			
			trace("horizontal layout",n)
			
			for (var i:int = 0; i < n; i++) 
			{				
				//trace(container.childList.getIndex(i).width);
							
				if (!close_packing) {
					container.childList.getIndex(i).x = paddingX + (i) * blockX + (i - 1) * marginX;
					container.childList.getIndex(i).y = 0;
				}
				else {
					container.childList.getIndex(i).x = paddingX + sumx + (i - 1) * marginX;
					container.childList.getIndex(i).y = 0;
				}
				sumx += container.childList.getIndex(i).width
				
				trace( container.childList.getIndex(i).id);
			}
			container.width = 2 * paddingX + sumx + (n - 1) * marginX;
			//container.height = container.childList.getIndex(0).height;
			
		//	trace("container layout height", container.height, container.childList.getKey(""))
			
		}
		
		/**
		 * Distributes the the children of the container in a vertical list
		 * about the y-axis. The maximum y value is equal to the 
		 * container's width
		 * @param	container
		 */		
		public function vertical(container:IContainer):void
		{
			n = container.childList.length; 
			var sumy:Number = 0;
			
			for (var i:int = 0; i < container.childList.length; i++) 
			{				
				//trace(container.childList.getIndex(i).height);
							
					if (!close_packing) {
						container.childList.getIndex(i).y = paddingY + (i) * blockY + (i - 1) * marginY;
						container.childList.getIndex(i).x = 0;
					}
					else {
						container.childList.getIndex(i).y = paddingY + sumy + (i - 1) * marginY;
						container.childList.getIndex(i).x = 0;
					}
					sumy+=container.childList.getIndex(i).height
			}	
			container.height = 2 * paddingX + sumy + (n - 1) * marginY;
			container.width = container.childList.getIndex(0).width;
		}

	}

}