package com.gestureworks.cml.core
{	
	import com.gestureworks.cml.core.*;
	import com.gestureworks.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	/**
	 * displays CMl objects
	 * 
	 *  @author..
	 */
	public class CMLDisplay extends Sprite
	{
		/**
		 * constructor
		 */
		public function CMLDisplay()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);			
			super();
		}
		
		/**
		 * initialisation method
		 * @param	e
		 */
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			DefaultStage.instance.stage = stage;			
			CMLParser.instance.init(CMLLoader.settings, this);
			var p:* = parent;
			p.writeComplete = true;					
		}

	}
}