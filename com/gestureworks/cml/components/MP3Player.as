package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.utils.Timer;
	
	/**
	 * MP3Player
	 * @author Charles Veasey
	 */
	public class MP3Player extends Component 
	{
		private var mp3:MP3Element;
		private var menu:Menu;
		private var info:*;
		
		public function MP3Player() 
		{
			super();
		}
		
		override public function displayComplete():void
		{
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			updateLayout();
		}		
		
		private function updateLayout():void		
		{
			mp3 = childList.getCSSClass("mp3_container", 0).childList.getCSSClass("mp3_element", 0);
			info = childList.getCSSClass("info_container", 0);						
			menu = childList.getCSSClass("menu_container", 0);
			
			if (menu)
			{
				if (menu.autoHide)
				{
					this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
					this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);				
				}
			}
			
			// update width and height
			width = childList.getCSSClass("mp3_container", 0).childList.getCSSClass("mp3_element", 0).width
			height = childList.getCSSClass("mp3_container", 0).childList.getCSSClass("mp3_element", 0).height
			
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
				var paddingLeft:Number = menu.paddingLeft;
				var paddingRight:Number = menu.paddingRight;
				var paddingBottom:Number = menu.paddingBottom;
				var position:String = menu.position;
				
	
					if(position=="bottom"){
						menu.y = height - btnHeight -paddingBottom;
						if(menu.childList.getCSSClass("info_btn", 0)) menu.childList.getCSSClass("info_btn", 0).x = paddingLeft;
						if((menu.childList.getCSSClass("play_btn", 0))&&(menu.childList.getCSSClass("info_btn", 0))) menu.childList.getCSSClass("play_btn", 0).x = menu.childList.getCSSClass("info_btn", 0).x + btnWidth + paddingLeft;
						if((menu.childList.getCSSClass("pause_btn", 0))&&(menu.childList.getCSSClass("play_btn", 0))) menu.childList.getCSSClass("pause_btn", 0).x = menu.childList.getCSSClass("play_btn", 0).x + btnWidth + paddingLeft;
						if(menu.childList.getCSSClass("close_btn", 0))menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft;
					}
					else if(position=="top"){
						menu.y = paddingBottom;
						if(menu.childList.getCSSClass("info_btn", 0)) menu.childList.getCSSClass("info_btn", 0).x = paddingLeft;
						if(menu.childList.getCSSClass("play_btn", 0)) menu.childList.getCSSClass("play_btn", 0).x = menu.childList.getCSSClass("info_btn", 0).x + btnWidth + paddingLeft;
						if((menu.childList.getCSSClass("pause_btn", 0))&&(menu.childList.getCSSClass("play_btn", 0))) menu.childList.getCSSClass("pause_btn", 0).x = menu.childList.getCSSClass("play_btn", 0).x + btnWidth + paddingLeft;
						if(menu.childList.getCSSClass("close_btn", 0)) menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft;
					}
					
					else if(position=="topLeft"){
						menu.y = paddingBottom;
						if(menu.childList.getCSSClass("info_btn", 0)) menu.childList.getCSSClass("info_btn", 0).x = paddingLeft;
						if(menu.childList.getCSSClass("play_btn", 0)) menu.childList.getCSSClass("play_btn", 0).x = paddingLeft + btnWidth + paddingRight;
						if(menu.childList.getCSSClass("pause_btn", 0)) menu.childList.getCSSClass("pause_btn", 0).x = paddingLeft + 2*btnWidth + 2*paddingRight;
						if(menu.childList.getCSSClass("close_btn", 0)) menu.childList.getCSSClass("close_btn", 0).x = paddingLeft  + 3*btnWidth + 3*paddingRight;
					}
					else if(position=="topRight"){
						menu.y = paddingBottom;
						if(menu.childList.getCSSClass("info_btn", 0)) menu.childList.getCSSClass("info_btn", 0).x = width - 4 * btnWidth - paddingLeft - 3*paddingRight
						if(menu.childList.getCSSClass("play_btn", 0)) menu.childList.getCSSClass("play_btn", 0).x = width - 3 * btnWidth - paddingLeft - 2*paddingRight;
						if(menu.childList.getCSSClass("pause_btn", 0)) menu.childList.getCSSClass("pause_btn", 0).x = width - 2*btnWidth - paddingLeft - paddingRight;
						if(menu.childList.getCSSClass("close_btn", 0)) menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft
					}
					
					else if(position=="bottomLeft"){
						menu.y = height - btnHeight -paddingBottom;
						if(menu.childList.getCSSClass("info_btn", 0)) menu.childList.getCSSClass("info_btn", 0).x = paddingLeft;
						if(menu.childList.getCSSClass("play_btn", 0)) menu.childList.getCSSClass("play_btn", 0).x = paddingLeft + btnWidth + paddingRight;
						if(menu.childList.getCSSClass("pause_btn", 0)) menu.childList.getCSSClass("pause_btn", 0).x = paddingLeft + 2*btnWidth + 2*paddingRight;
						if(menu.childList.getCSSClass("close_btn", 0)) menu.childList.getCSSClass("close_btn", 0).x = paddingLeft  + 3*btnWidth + 3*paddingRight;
					}
					else if(position=="bottomRight"){
						menu.y = height - btnHeight -paddingBottom;
						if(menu.childList.getCSSClass("info_btn", 0)) menu.childList.getCSSClass("info_btn", 0).x = width - 4 * btnWidth - paddingLeft - 3*paddingRight
						if(menu.childList.getCSSClass("play_btn", 0)) menu.childList.getCSSClass("play_btn", 0).x = width - 3 * btnWidth - paddingLeft - 2*paddingRight;
						if(menu.childList.getCSSClass("pause_btn", 0)) menu.childList.getCSSClass("pause_btn", 0).x = width - 2*btnWidth - paddingLeft - paddingRight;
						if(menu.childList.getCSSClass("close_btn", 0)) menu.childList.getCSSClass("close_btn", 0).x = width - btnWidth - paddingLeft
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
			{
				this.visible = false;
				mp3.pause();
			}
			else if (event.value == "play")
				mp3.resume();
			else if (event.value == "pause")
				mp3.pause();	
		}	
		
	}
}