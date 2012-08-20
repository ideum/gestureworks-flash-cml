package com.gestureworks.components
{	
	import com.gestureworks.cml.core.*;
	import com.gestureworks.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	public class CMLDisplay extends Sprite
	{
		
		public function CMLDisplay()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);			
			super();
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			DefaultStage.instance.stage = stage;			
			CMLParser.instance.init(CMLLoader.settings, this);	
		}

	}
}