package com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.core.GestureWorks;
	
	public class NodeViewer extends ComponentKit
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
		
		public function NodeViewer()
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
			//listHorizontal();		
			//listVertical();	
			//trace("---------------------------------------------------",this.id,this.layout);
		}
	}
}