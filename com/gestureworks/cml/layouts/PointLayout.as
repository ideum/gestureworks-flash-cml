package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	
	/**
	 * Positions the objects of a container based on a user defined list of xy coordinates. 
	 * @author Shaun
	 */
	public class PointLayout extends LayoutFactory 
	{
		
		/**
		 * Constructor
		 */
		public function PointLayout() 
		{
			super();
		}
		
		/**
		 * A comma delimited String of xy coordinates. 
		 */
		private var _points:String;
		public function get points():String { return _points };
		public function set points(p:String):void
		{
			_points = p;
		}
		
		/**
		 * Places the display objects at user defined points
		 * @param	container
		 */
		override public function layout(container:IContainer):void
		{
			var c:* = container;							
			if (!points) return;
			
			var pts:Array = points.split(",");
			if (pts.length % 2 != 0) pts.push("0");
			
			for (var i:int = 0; i < pts.length; i+=2) 
			{		
				var child:* = c.childList.getIndex(i/2);
				if (!child || !child.hasOwnProperty("x") || !child.hasOwnProperty("y")) return;
				
				child.x = pts[i];
				child.y = pts[i + 1];				
			}
		}	
		
		/**
		 * Dispsal function
		 */
		override public function dispose():void 
		{
			super.dispose();
		}
	}

}