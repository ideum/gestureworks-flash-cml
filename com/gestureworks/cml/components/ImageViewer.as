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
			if(childList.getCSSClass("frame_container", 0)){
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).width = width;
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).height = height;
			}
			// update info panel size
			if(childList.getCSSClass("info_container", 0)){
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_bg", 0).width = width;
				childList.getCSSClass("info_container", 0).childList.getCSSClass("info_bg", 0).height = height;
			}
			
			// update button placement
			if(childList.getCSSClass("menu_container", 0)){
				var btnWidth:Number = childList.getCSSClass("menu_container", 0).childList.getCSSClass("close_btn", 0).childList.getCSSClass("up", 0).childList.getCSSClass("btn-bg-up", 0).width;
				var btnHeight:Number = childList.getCSSClass("menu_container", 0).childList.getCSSClass("close_btn", 0).childList.getCSSClass("up", 0).childList.getCSSClass("btn-bg-up", 0).height;
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
			trace("StateEvent change",event.value);
			if (event.value == "info") 			childList.getCSSClass("info_container", 0).visible = true;
			else if (event.value == "flip") 	childList.getCSSClass("info_container", 0).visible = false;
			else if (event.value == "close") 	this.visible = false;
		}			
		
	}
	
}