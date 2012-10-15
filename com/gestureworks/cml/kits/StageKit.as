package com.gestureworks.cml.kits 
{
	import com.gestureworks.cml.factories.*;
	import flash.display.*;
	import flash.events.Event;

	/**
	 * The StageKit provides access to the stage from CML.
	 * 
	 * <p>This class is meant to be used within CML and is not compatible 
	 * with AS3.</p>
	 * 
	 * @author Charles
	 * @see flash.display.stage
	 */
	public class StageKit extends ElementFactory
	{
		/**
		 * Constructor
		 */
		public function StageKit() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * This method provides the stage width and height and also the fullscreen depending on the condition
		 * @param	event
		 */
		public function onAddedToStage(event:Event = null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.stageWidth = width;				
			stage.stageHeight = height;
						
			// fullscreen overrides dims
			if (_fullscreen)
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				stage.displayState = StageDisplayState.NORMAL;			
		}

		

		public var _fullscreen:Boolean = false;
		/**
		 * Specifies whether or not to set the stage to fullscreen
		 * Choose: true or false
		 *
		 * @default false 
		 */		
		public function get fullscreen():Boolean {return _fullscreen;}
		public function set fullscreen(value:Boolean):void 
		{
			_fullscreen = value;
			
			if (stage)
			{			
				if (_fullscreen)
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				else
					stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		

		public var _width:Number = 1280;
		/**
		 * Specifies the width of the screen
		 * @default 1024 
		 */		
		override public function get width():Number {return _width;}
		override public function set width(value:Number):void 
		{
			_width = value;
			
			if (stage)
				stage.stageWidth = value;
		}			
		
		
		
		public var _height:Number = 720;
		/**
		 * Specifies the width of the screen
		 * @default 768 
		 */		
		override public function get height():Number {return _height;}
		override public function set height(value:Number):void 
		{
			_height = value;
			
			if (stage)
				stage.stageHeight = value;
		}
		
		
		
	}	
}