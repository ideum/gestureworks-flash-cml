package com.gestureworks.cml.element 
{
	import flash.text.*;
	import flash.events.Event;
	import com.gestureworks.cml.factories.TextFactory;

	public class LabelElement extends TextFactory
	{		
		public var txt:TextField;
		
		public function LabelElement()
		{						
			super();
			
			createUI();
			commitUI();
			layoutUI();
		}
		
		override protected function createUI():void 
		{
			//txt= new TextField();
			//addChild(txt);
		}
		
		override protected function commitUI():void 
		{
			/*txt.antiAliasType = antiAliasType;
			txt.selectable = selectable;
			txt.multiline = multiline;
			txt.wordWrap = wordWrap;
			txt.autoSize = autoSize;
			txt.text = label;*/
		}
		
		override protected function layoutUI():void
		{
			if (width == 0) width = 100;
			if (height == 0) height = 100;
			
			width = width;
			height = height;
			
			layoutText();
			
			//trace("width:", width, "height:", height, "text width:", txt.width, txt.textWidth, txt.textHeight);
		}
		
		override protected function layoutText():void 
		{			
			//txt.x += textX;
			//txt.y += textY;
		}
		
		override protected function updateText():void 
		{
			//text = label;
			
			layoutText();
			//trace("text:", txt.width, "textWidth:", txt.textWidth);
		}
	}
}