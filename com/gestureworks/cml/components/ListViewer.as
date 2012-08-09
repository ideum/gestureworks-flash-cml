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
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function displayComplete():void
		{			
			trace("list display viewer complete");
			resizeBelt();
		}
		
		
		private function resizeBelt():void
		{ 
			trace(parent.parent, parent.parent.parent)
			
			var album:* = this.parent.parent.parent as TouchContainer
			//var album:* = this.parent.parent as TouchContainer
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
				var md:* = list.childList.getIndex(i).childList.getCSSClass("metadata", 0);
				
				var scX:Number = img.scaleX;
				var scY:Number = 1//img.scaleY
				
				if (md) {
					var bg:* = md.childList.getCSSClass("title_bg", 0);
					var txt:* = md.childList.getCSSClass("title_text", 0);
					
					label_height = md.height; 
					belt_height = img.height*scY; 
					
					md.y = img.height * scY;
					bg.width = img.width * scX;
					txt.width = img.width * scX;
				}
			}
			// update album height
						
			album.height = belt_height + label_height + album.bar_height -10;//????????
			album.update();
		}
	}
}