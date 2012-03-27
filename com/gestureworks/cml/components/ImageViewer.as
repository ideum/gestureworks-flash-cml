package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	
	/**
	 * ...
	 * @author Charles Veasey
	 */
	public class ImageViewer extends Component 
	{
		
		public function ImageViewer() 
		{
			super();			
		}
		
		override public function displayComplete():void
		{
			this.addEventListener(StateEvent.CHANGE, onStateEvent)
			updateLayout();
		}		
		
		private function updateLayout():void
		{
			// update width and height
			width = childList.getCSSClass("image_container", 0).childList.getCSSClass("image_element", 0).width
			height = childList.getCSSClass("image_container", 0).childList.getCSSClass("image_element", 0).height
			
			
			// update frame size
			if (childList.getCSSClass("frame_container", 0))
			{
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).width = width;
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).height = height;
			}
			// update info panel size
			if (childList.getCSSClass("info_container", 0))
			{
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_bg", 0).width = width;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_bg", 0).height = height;
			}
		
			// update info text size
			if (childList.getCSSClass("info_container", 0)) 
			{
				var textpaddingX:Number = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).paddingLeft;
				var textpaddingY:Number = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).paddingTop;
				var textSep:Number = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).paddingBottom;
				
				
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).x = textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).y = textpaddingY;
				
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).x = textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).y = childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).height + textpaddingY + textSep;
				
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).width = width - 2*textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).width = width-2*textpaddingX;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_description", 0).height = height-2*textpaddingY-textSep-childList.getCSSClass("info_container", 0).childList.getCSSClass("info_title", 0).height;
			}
			
			// update button placement
			if (childList.getCSSClass("menu_container", 0))
			{
				var btnWidth:Number = childList.getCSSClass("menu_container", 0).childList.getCSSClass("close_btn", 0).childList.getCSSClass("down", 0).childList.getCSSClass("btn-bg-down", 0).width;
				var btnHeight:Number = childList.getCSSClass("menu_container", 0).childList.getCSSClass("close_btn", 0).childList.getCSSClass("down", 0).childList.getCSSClass("btn-bg-down", 0).height;
				var paddingX:Number = childList.getCSSClass("menu_container", 0).paddingX;
				var paddingY:Number = childList.getCSSClass("menu_container", 0).paddingY;
				var position:String = childList.getCSSClass("menu_container", 0).position;
				
				if(position=="bottom"){
					childList.getCSSClass("menu_container", 0).y = height - btnHeight -paddingY;
					childList.getCSSClass("menu_container", 0).childList.getCSSClass("info_btn", 0).x = paddingX
					childList.getCSSClass("menu_container", 0).childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingX
				}
				else if(position=="top"){
					childList.getCSSClass("menu_container", 0).y = paddingY;
					childList.getCSSClass("menu_container", 0).childList.getCSSClass("info_btn", 0).x = paddingX
					childList.getCSSClass("menu_container", 0).childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingX
				}
			}	
		}
		
		private function onStateEvent(event:StateEvent):void
		{	
			//trace("StateEvent change", event.value);
			var info:* = childList.getCSSClass("info_container", 0)
			
			if (event.value == "info") {
				if (!info.visible) info.visible = true;
				else info.visible = false;
			}
			else if (event.value == "close") 	this.visible = false;
		}			
		
	}
	
}