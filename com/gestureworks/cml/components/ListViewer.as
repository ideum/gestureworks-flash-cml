package com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.core.GestureWorks;
	
	public class ListViewer extends ComponentKit
	{		
		private var i:int
		private var marginY:Number;
		private var marginX:Number;
		private var sepx:Number;
		private var sepy:Number;
		private var box:Number;
		private var sumx:Number;
		private var sumy:Number;
		private var close_packing:Boolean;
		private var n:int;
		
		public function ListViewer()
		{
			super();
		}
		
		public function dipose():void
		{
			parent.removeChild(this);
		}
		
		override public function displayComplete():void
		{			
			trace("list display viewer complete");
			listHorizontal();		
			//listVertical();	
			trace("---------------------------------------------------",this.id,this.layout);
		}
		
		
		private function listHorizontal():void
		{ 
			box = 540
			sepx = 10;
			sepy = 10;
			marginY = 25;
			marginX = 0;
			sumx = 0;
			close_packing = true;
			n = this.childList.length;
			
				//trace("album, items",this.childList.length);
				for (i=0; i<=n; i++)
					{
						//trace(this.childList.getIndex(i))
						if ((childList.getIndex(i) is TouchContainer))
						{
							trace(childList.getIndex(i).width);
							
							if(!close_packing) childList.getIndex(i).x = marginX + (i) * box + (i - 1) * sepx;
							else childList.getIndex(i).x = marginX + sumx + (i - 1) * sepx;
							
							childList.getIndex(i).y = 0;
							childList.getIndex(i).gestureList = { "tap":true, "double_tap":true };
							childList.getIndex(i).id = String(i);
						
							sumx+=childList.getIndex(i).width
						}
					}
					
					width = 2 * marginX + sumx + (n - 1) * sepx;
					height = childList.getIndex(0).height;
		}
		/*
		private function listVertical():void
		{ 
			box = 400
			sepx = 10;
			sepy = 10;
			marginY = 25;
			marginX = 0;
			sumy = 0;
			close_packing = true;
			n = this.childList.length;
			
				//trace("album, items",this.childList.length);
				for (i=0; i<=n; i++)
					{
						//trace(this.childList.getIndex(i))
						if ((childList.getIndex(i) is TouchContainer))
						{
							trace(childList.getIndex(i).height);
							
							if(!close_packing) childList.getIndex(i).y = marginY + (i) * box + (i - 1) * sepy;
							else childList.getIndex(i).y = marginY + sumy + (i - 1) * sepy;
							
							childList.getIndex(i).x = 0;
							childList.getIndex(i).gestureList = { "tap":true, "double_tap":true };
							childList.getIndex(i).id = String(i);
						
							sumy+=childList.getIndex(i).height
						}
					}
					
					height = 2 * marginX + sumy + (n - 1) * sepy;
					width = childList.getIndex(0).width;
		}
		*/

	}
}