package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	
	/**
	 * Random
	 * Random Layout
	 * @author Charles Veasey
	 */
	public class RandomLayout extends LayoutFactory
	{
		public function RandomLayout() 
		{
			super();
		}
		
		private var _type:String = "randomXY";
		public function get type():String{return _type;}
		public function set type(value:String):void 
		{
			_type = value;
		}
		
		private var _minX:Number = 0;
		public function get minX():Number{return _minX;}
		public function set minX(value:Number):void 
		{
			_minX = value;
		}			
		
		private var _maxX:Number = 500;
		public function get maxX():Number{return _maxX;}
		public function set maxX(value:Number):void 
		{
			_maxX = value;
		}
		
		private var _minY:Number = 0;
		public function get minY():Number{return _minY;}
		public function set minY(value:Number):void 
		{
			_minY = value;
		}			
		
		private var _maxY:Number = 500;
		public function get maxY():Number{return _maxY;}
		public function set maxY(value:Number):void 
		{
			_maxY = value;
		}	
		private var _minRot:Number = 0;
		public function get minRot():Number{return _minRot;}
		public function set minRot(value:Number):void 
		{
			_minRot = value;
		}			
		
		private var _maxRot:Number = 360;
		public function get maxRot():Number{return _maxRot;}
		public function set maxRot(value:Number):void 
		{
			_maxRot = value;
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
				case "randomX" : randomX(container); break;
				case "randomY" : randomY(container); break;
				case "randomXY" : randomXY(container); break;
				case "randomXYRotation" : randomXYRotation(container); break;
				default: break;
			}	
		}		
		
		
		
		//////////////////////////////////////////////////////
		//  RANDOM TYPES 
		//  add new methods here, and also add 
		//  to switch
		//////////////////////////////////////////////////////
		

		/**
		 * Distributes the the children of the container randomly
		 * about the x-axis. The maximum x value is equal to the 
		 * container's width
		 * @param	container
		 */
		public function randomX(container:IContainer):void
		{
			for (var i:int = 0; i < container.childList.length; i++) 
			{				
				container.childList.getIndex(i).x = randomMinMax(minX, maxX);
			}			
		}
		
		/**
		 * Distributes the the children of the container randomly
		 * about the y-axis. The maximum y value is equal to the 
		 * container's width
		 * @param	container
		 */		
		public function randomY(container:IContainer):void
		{
			for (var i:int = 0; i < container.childList.length; i++) 
			{				
				container.childList.getIndex(i).y = randomMinMax(minY, maxY);	
			}			
		}
		
		/**
		 * Distributes the the children of the container randomly
		 * about the x,y-axes. The maximum x,y value is equal to the 
		 * container's width, height
		 * @param	container
		 */		
		public function randomXY(container:IContainer):void
		{
			for (var i:int = 0; i < container.childList.length; i++) 
			{
				container.childList.getIndex(i).x = randomMinMax(minX, maxX);
				container.childList.getIndex(i).y = randomMinMax(minY, maxY);		
			}			
		}
		
		/**
		 * Distributes the the children of the container randomly
		 * about the x,y-axes. The maximum x,y value is equal to the 
		 * container's width, height
		 * @param	container
		 */		
		public function randomXYRotation(container:IContainer):void
		{
			for (var i:int = 0; i < container.childList.length; i++) 
			{
				container.childList.getIndex(i).x = randomMinMax(minX, maxX);
				container.childList.getIndex(i).y = randomMinMax(minY, maxY);
				container.childList.getIndex(i).rotation = randomMinMax(minRot, maxRot);		
			}			
		}	
		

		
		private function randomMinMax(min:Number, max:Number):Number
		{
			return min + Math.random() * (max - min);
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
		
	}

}