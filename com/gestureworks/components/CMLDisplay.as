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
	
	/* 
		
		IMPORTANT NOTE TO DEVELOPER **********************************************
		 
		PlEASE DO NOT ERASE OR DEVALUE ANYTHING WHITHIN THIS CLASS IF YOU DO NOT UNDERSTAND IT'S CURRENT VALUE OR PLACE... PERIOD...
		IF YOU HAVE ANY QUESTIONS, ANY AT ALL. PLEASE ASK PAUL LACEY (paul@ideum.com) ABOUT IT'S IMPORTATANCE.
		IF PAUL IS UNABLE TO HELP YOU UNDERSTAND, THEN PLEASE LOOK AND READ THE ACTUAL CODE FOR IT'S PATH.
		SOMETHINGS AT FIRST MAY NOT BE CLEAR AS TO WHAT THE ACTUAL PURPOSE IS, BUT IT IS VALUABLE AND IS USED IF IT IS CURRENTLY WRITTTEN HERE.
		DO NOT TAKE CODE OUT UNLESS YOUR CHANGES ARE VERIEFIED, TESTED AND CONTINUE TO WORK WITH LEGACY BUILDS !
		
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
			//commitUI();
			//layoutUI();
			//updateUI();
		}
		
		public function createUI():void
		{
			CMLParser.instance.cssFile = CMLLoader.settings.@css;
			CMLParser.instance.init(CMLLoader.settings, this);
									
			
			// DO NOT DELETE.  This is the last disptach before the GestureWorks framework calls gestureworksInit();
			// This is accessed like this because of a legacy built that was calling directly from a binary build.  In a binary builds it is impossible to dispatch an event, therefore it is calling directly to the parent.
			// This is obviously not waiting for the entire cml framework to be parsed and loaded, therefore it must be altered (without breaking things) to do so.
			// it would also be better to have it dispatch a real event as opposed to a straight function call.  Good luck.
			var p:* = parent;
			p.writeComplete = true;		
		}
		
		//public function commitUI():void{}
		//public function layoutUI():void{}
		//public function updateUI():void{}
		//public function onResize(event:Event):void{}
	}
}