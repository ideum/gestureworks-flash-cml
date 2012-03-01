package com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.kits.ComponentKit;
	//import com.gestureworks.cml.element.Component;
	import com.gestureworks.core.GestureWorks;
		import com.gestureworks.components.CMLDisplay; CMLDisplay;
	
	public class ListViewer extends ComponentKit
	{		
		
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
			resizeBelt();
		}
		
		
		private function resizeBelt():void
		{ 
			var album:* = this.parent.parent as TouchContainer
			var belt:* = this.parent as TouchContainer
			var background:* = belt.childList.getCSSClass("belt_bg", 0);
			var list:* = belt.childList.getCSSClass("list", 0)//.childList.getCSSClass("list")
			var listNumber:int = list.childList.length;
			
			//trace("resizeBelt belt", this.width, this.height);
			//trace(this.parent.parent as TouchContainer, album.id, album.belt_minValue, background.id);
			
			// update belt size
			belt.width = this.width;
			belt.height = this.height;
			
			// update background size
			background.width = this.width;
			background.height = this.height;
			
			// set belt min and max values
			album.belt_minValue = 0;
			album.belt_maxValue = this.width - album.width;
			
			var label_height:Number;
			var belt_height:Number;
			// loop through items in belt and update test field
			
			for (var i:int=0; i<listNumber; i++)
			{
				
				var itm:* = list.childList.getIndex(i);
				var img:* = list.childList.getIndex(i).childList.getCSSClass("image", 0);
				var md:* = list.childList.getIndex(i).childList.getCSSClass("metadata", 0)
				
				if (md) {
					var bg:* = md.childList.getCSSClass("title_bg", 0);
					var txt:* = md.childList.getCSSClass("title_text", 0);
					
					label_height = md.height; 
					belt_height = img.height; 
					
					md.y = img.height;
					bg.width = img.width;
					txt.width = img.width
				}
			}
			// update album height
			album.height = belt_height + label_height + album.bar_height -10;//????????
			album.update();
		}
	}
}