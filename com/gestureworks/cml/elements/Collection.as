package com.gestureworks.cml.elements 
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * @author Ideum
	 */
	public class Collection extends Container
	{		
		/**
		 * Constructor 
		 */
		public function Collection() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, defaultDimensions);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {						
			super.init();	
			
			//restrict display to dimensions
			scrollRect = new Rectangle(0, 0, width, height);
			
			graphics.beginFill(0xcccccc);
			graphics.drawRect(0, 0, width, height);
		}
		
		/**
		 * If undefined, inherit stage dimensions 
		 * @param	e
		 */
		private function defaultDimensions(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, defaultDimensions);
			width = width ? width : stage.stageWidth;
			height = height ? height : stage.stageHeight;
		}
	}
}