package com.gestureworks.cml.element 
{
	import flash.events.TextEvent;
	import flash.text.*;
	import flash.events.Event;
	import com.gestureworks.cml.factories.TextFactory;

	public class TextElement extends TextFactory
	{				
		public function TextElement()
		{						
			super();
			
			createUI();
			commitUI();
			layoutUI();
			updateUI();
			
			updateTextFormat();
		}
		
		override protected function createUI():void 
		{
		}
		
		override protected function commitUI():void 
		{
			embedFonts = true;
		}
		
		override protected function layoutUI():void 
		{
			if (width == 0) width = 100;
			if (height == 0) height = 100;
			
			layoutText();
			updateTextFormat();
						
			addEventListener(Event.RESIZE, changeHandler);
		}
		
		private function changeHandler(event:Event):void
		{
		}
		
		override protected function updateText():void 
		{
			this.text = text;
		}
		
		override protected function layoutText():void 
		{			
		}
		
		override protected function updateTextFormat():void 
		{
			defaultTextFormat = textFormat;
			updateText();
		}
		
	}
}