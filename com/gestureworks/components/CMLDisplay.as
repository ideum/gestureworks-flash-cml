package com.gestureworks.components
{	
	import com.gestureworks.cml.managers.CSSManager;
	import com.gestureworks.cml.managers.DisplayManager;
	import com.gestureworks.cml.core.DefaultStage;
	import com.gestureworks.cml.core.CMLParser;	
	import com.gestureworks.core.DisplayList;
	import com.gestureworks.utils.CMLLoader;
	
	import flash.display.Sprite;	
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */	
	
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
			
			createUI();
			commitUI();
			layoutUI();
			updateUI();
		}
		
		public function createUI():void
		{
			CMLParser.instance.cssFile = CMLLoader.settings.@css;
			CMLParser.instance.init(CMLLoader.settings, this);
									
			var p:* = parent;
			p.writeComplete = true;		
		}
		
		public function commitUI():void{}
		public function layoutUI():void{}
		public function updateUI():void{}
		public function onResize(event:Event):void{}
	}
}