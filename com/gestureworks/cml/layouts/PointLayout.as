package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	
	/**
	 * The PointLayout positions the objects of a container 
	 * based on a user defined list of xy coordinates. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		var pointContainer:Container = getImageContainer();
		pointContainer.x = 500;
		pointContainer.y = 20;
		addChild(pointContainer);
		
		var pointLayout:PointLayout = new PointLayout();
		pointLayout.points = "10,400,200,250,450,350,400,400,523";
		pointLayout.tween = true;
		pointLayout.tweenTime = 1500;
		pointContainer.applyLayout(pointLayout);			
		
		
		function getImageContainer():Container
		{
			var container:Container = new Container();
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
	 * @author Shaun
	 * @see GridLayout
	 * @see FanLayout 
	 * @see ListLayout
	 * @see PileLayout
	 * @see RandomLayout
	 * @see com.gestureworks.cml.factories.LayoutFactory
	 * @see com.gestureworks.cml.element.Container
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
		override public function layout(container:DisplayObjectContainer):void
		{
			var matrix:Matrix;
			if (!points) return;
			
			var pts:Array = points.split(",");
			if (pts.length % 2 != 0) pts.push("0");
			
			for (var i:int = 0; i < pts.length; i+=2) 
			{		
				var child:* = container.getChildAt(i/2);
				if (!child || !child is DisplayObject) return;
				
				matrix = child.transform.matrix;
				matrix.translate(pts[i], pts[i + 1]);			
				childTransformations.push(matrix);
			}
			
			super.layout(container);
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