package com.gestureworks.cml.elements
{	
	import flash.display.Stage;
	import flash.events.Event;
	import com.gestureworks.cml.elements.TouchContainer
	
	/**
	 * The View element is touchable display container with its default size set to the stage.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
		var view:View = new View();
		addChild(view);		
	 * </codeblock>
	 * @author Ideum
	 * @see TouchContainer
	 * @see Container
	 */	
	
	public class View extends TouchContainer
	{		
		/**
		 * Constructor
		 */
		public function View() 
		{
			super();
			mouseChildren = true
			if (stage) addedToStage();
			else addEventListener(Event.ADDED_TO_STAGE, addedToStage);				
		}
		
        private function addedToStage(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			init();
		}

		/**
		 * Initialisation method
		 * @param	e
		 */
		override public function init():void
		{
			this.width = stage.width;
			this.height = stage.height;			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
	}
}