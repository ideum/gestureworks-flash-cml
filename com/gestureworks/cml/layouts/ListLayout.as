package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.factories.LayoutFactory;
	import com.gestureworks.cml.interfaces.IContainer;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.sampler.NewObjectSample;
	
	/**	 
	 * The ListLayout positions the display objects in a list.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		//horizontal list layout 
		var h_list:Container = getImageContainer();
		h_list.x = 475;
		h_list.y = 25;
		addChild(h_list);
					
		var horiztonalLayout:ListLayout = new ListLayout();
		horiztonalLayout.spacingX = 200;
		horiztonalLayout.tween = true;
		horiztonalLayout.tweenTime = 1500;
		h_list.applyLayout(horiztonalLayout);
		
		//vertical list layout
		var v_list:Container = getImageContainer();
		v_list.x = 750;
		v_list.y = 200;
		addChild(v_list);
					
		var verticalLayout:ListLayout = new ListLayout();
		verticalLayout.type = "vertical";
		verticalLayout.useMargins = true;
		verticalLayout.marginY = 5;
		verticalLayout.tween = true;
		verticalLayout.tweenTime = 1500;
		v_list.applyLayout(verticalLayout);		

		
		function getImageContainer():Container
		{
			var container:Container = new Container();
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));			
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));			
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));			
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));			
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));			
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));						
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));						
			container.addChild(getImageElement("../../../../assets/images/plane.jpg"));						
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
	 * @see PileLayout
	 * @see PointLayout
	 * @see RandomLayout
	 * @see com.gestureworks.cml.factories.LayoutFactory
	 * @see com.gestureworks.cml.element.Container
	 */
	public class ListLayout extends LayoutFactory
	{
		private var n:int;
		
		/**
		 * Constructor
		 */
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
			var xVal:Number;
			var yVal:Number = originY;
			var matrix:Matrix;
			var columnWidth:Number = getMaxWidth(container);
			var rowHeight:Number = Math.max(getMaxHeight(container), container.height);
			var sumx:Number = centerColumn ? originX+(columnWidth / 2) : originX;
			var index:int = 0;
			
			for (var i:int = childTransformations.length; i < n; i++) 
			{		
				var child:* = container.getChildAt(i);
				if (!validObject(child)) continue;

				xVal = useMargins ? sumx + index * (2 * marginX) : index * spacingX + originX;
				xVal = centerColumn ? xVal - child.width/2 : xVal;         //adjust spacing for column centering
				yVal = centerRow ? rowHeight/2 - child.height/2 + yVal: yVal;	   //adjust spacing for row centering
				
				matrix = child.transform.matrix;
				translateTransform(matrix, xVal, yVal);
				childTransformations.push(matrix);
				sumx = centerColumn ?  sumx + columnWidth : sumx + child.width;
				index++;
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
			var xVal:Number = originX;
			var yVal:Number;
			var matrix:Matrix;
			var columnWidth:Number = Math.max(getMaxWidth(container), container.width);
			var rowHeight:Number = getMaxHeight(container);
			var sumy:Number = centerRow ? originY+(rowHeight / 2) : originY;	
			var index:int = 0;
			
			for (var i:int = childTransformations.length; i < n; i++) 
			{				
				var child :* = container.getChildAt(i);
				if (!validObject(child)) continue;
							
				yVal = useMargins ? sumy + index * (2 * marginY) : index * spacingY + originY;
				yVal = centerRow ? yVal - child.height / 2 : yVal;                //adjust spacing for row centering
				xVal = centerColumn ? columnWidth/2 - child.width/2 + xVal: xVal;		  //adjust spacing for column centering		
				
				matrix = child.transform.matrix;
				translateTransform(matrix, xVal, yVal);
				childTransformations.push(matrix);						
				sumy = centerRow ?  sumy + rowHeight : sumy + child.height;	
				index++;
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