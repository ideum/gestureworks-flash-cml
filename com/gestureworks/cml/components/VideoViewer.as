package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.utils.Timer;
	
	/**
	 * VideoViewer
	 * @author Ideum
	 */
	public class VideoViewer extends Component 
	{
		private var video:VideoElement;
		private var menu:Menu;
		private var info:*;
		
		public function VideoViewer() 
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
			video = childList.getCSSClass("video_container", 0).childList.getCSSClass("video_element", 0);  
			info = childList.getCSSClass("info_container", 0);			
			menu = childList.getCSSClass("menu_container", 0);			
			
			if (menu.autoHide)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);				
			}
			
			// update width and height
			width = childList.getCSSClass("video_container", 0).childList.getCSSClass("video_element", 0).width
			height = childList.getCSSClass("video_container", 0).childList.getCSSClass("video_element", 0).height
			
			// update frame size
			if (info)
			{
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).width = width;
				childList.getCSSClass("frame_container", 0).childList.getCSSClass("frame_element", 0).height = height;
			}
			
			// update info panel size
			if (info)
			{
				info.childList.getCSSClass("info_bg", 0).width = width;
				info.childList.getCSSClass("info_bg", 0).height = height;
			}
		
			// update info text size
			if (info) 
			{
				var textpaddingX:Number = info.childList.getCSSClass("info_title", 0).paddingLeft;
				var textpaddingY:Number = info.childList.getCSSClass("info_title", 0).paddingTop;
				var textSep:Number = info.childList.getCSSClass("info_title", 0).paddingBottom;
				
				
				info.childList.getCSSClass("info_title", 0).x = textpaddingX;
				info.childList.getCSSClass("info_title", 0).y = textpaddingY;
				
				info.childList.getCSSClass("info_description", 0).x = textpaddingX;
				info.childList.getCSSClass("info_description", 0).y = info.childList.getCSSClass("info_title", 0).height + textpaddingY + textSep;
				
				info.childList.getCSSClass("info_title", 0).width = width - 2*textpaddingX;
				info.childList.getCSSClass("info_description", 0).width = width-2*textpaddingX;
				info.childList.getCSSClass("info_description", 0).height = height-2*textpaddingY-textSep-info.childList.getCSSClass("info_title", 0).height;
			}
			
			// update button placement
			if (childList.getCSSClass("menu_container", 0))
			{
				var btnWidth:Number = menu.childList.getCSSClass("close_btn", 0).childList.getCSSClass("down", 0).childList.getCSSClass("btn-bg-down", 0).width;
				var btnHeight:Number = menu.childList.getCSSClass("close_btn", 0).childList.getCSSClass("down", 0).childList.getCSSClass("btn-bg-down", 0).height;
				var paddingX:Number = menu.paddingX;
				var paddingY:Number = menu.paddingY;
				var position:String = menu.position;
				
				if(position=="bottom"){
					menu.y = height - btnHeight -paddingY;
					menu.childList.getCSSClass("info_btn", 0).x = paddingX;
					menu.childList.getCSSClass("play_btn", 0).x = menu.childList.getCSSClass("info_btn", 0).x + btnWidth + paddingX;
					menu.childList.getCSSClass("pause_btn", 0).x = menu.childList.getCSSClass("play_btn", 0).x + btnWidth + paddingX;
					menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingX;
				}
				else if(position=="top"){
					menu.y = paddingY;
					menu.childList.getCSSClass("info_btn", 0).x = paddingX;
					menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingX;
				}
			}				
		}
		
		private function onDown(event:*):void
		{
			menu.visible = true;
			menu.startTimer();
		}			
		
		private function onStateEvent(event:StateEvent):void
		{				
			if (event.value == "info") 
			{
				if (!info.visible) info.visible = true;
				else info.visible = false;
			}
			else if (event.value == "close")
				this.visible = false;
			else if (event.value == "play")
				video.resume();
			else if (event.value == "pause")
				video.pause();	
		}			
		
	}
	
}