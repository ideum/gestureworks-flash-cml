package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.utils.FrameRate;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.*;

	/**
	 * The Stage provides access to the stage from CML.
	 * 
	 * <p>This class is meant to be used within CML and is not compatible 
	 * with AS3.</p>
	 * 
	 * @author Charles
	 * @see flash.display.stage
	 */
	public class StageKit extends TouchContainer
	{
		/**
		 * Constructor
		 */
		public function StageKit() 
		{
			super();
			mouseChildren = true;			
		}
	
		/**
		 * This method provides the stage width and height and also the fullscreen depending on the condition
		 * @param	event
		 */
		override public function init():void {
			super.init();
			if (_width) width = _width;			
			if (_height) height = _height;
			if (_color) color = _color;
			if (_align) align = _align;
			if (_scaleMode) scaleMode = _align;
			if (_frameRate) frameRate = _frameRate;
			
						
			// fullscreen overrides dims
			if (_fullscreen)
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			else
				stage.displayState = StageDisplayState.NORMAL;	
				
			//display the frame rate
			if (displayFrameRate)
				stage.addChild(new FrameRate(frX, frY, frColor));		
				
			//display a sprite to exit full screen
			if (escapeSprite) {
				esX = esX ? esX : stage.stageWidth;
				esY = esY ? esY : stage.stageHeight;
				
				var ts:Sprite = new Sprite(); 
				ts.graphics.beginFill(esColor);
				ts.graphics.drawRect(0, 0, 50, 50);
				ts.x = esX - 50;
				ts.y = esY - 50;				
				ts.addEventListener(TouchEvent.TOUCH_TAP, function(e:TouchEvent):void {
					stage.displayState = StageDisplayState.NORMAL;
				});
				stage.addChild(ts);
			}
		}
		

		private var _fullscreen:Boolean = false;
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
		
		

		private var _width:Number = 0;
		/**
		 * Specifies the width of the screen. AIR only.
		 * @default 0 
		 */		
		override public function get width():Number {return _width;}
		override public function set width(value:Number):void 
		{
			_width = value;
						
			if (stage)
				stage.stageWidth = value;
		}			
		
		
		
		private var _height:Number = 0;
		/**
		 * Specifies the width of the screen. AIR only.
		 * @default 0 
		 */		
		override public function get height():Number {return _height;}
		override public function set height(value:Number):void 
		{
			_height = value;
			
			if (stage)
				stage.stageHeight = value;
		}
		

		
		private var _color:uint;
		/**
		 * Specifies the color of the stage. FlashPlayer 11.0+ only.
		 * @default 0xFFFFFF 
		 //*/		
		public function get color():uint {return _color;}
		public function set color(value:uint):void 
		{
			_color = value;
			
			if (stage && "color" in stage) {
				stage["color"] = value;
			}
		}	

		
		private var _scaleMode:String;
		/**
		 * Specifies the scale mode for the stage.
		 */		
		public function get scaleMode():String {return _scaleMode;}
		public function set scaleMode(value:String):void 
		{
			_scaleMode = value;
			
			if (stage) {
				switch (value) {
					case "exactFit":stage.scaleMode = StageScaleMode.EXACT_FIT; break; 
					case "noBorder":stage.scaleMode = StageScaleMode.NO_BORDER; break;
					case "noScale":stage.scaleMode = StageScaleMode.NO_SCALE; break;
					case "showAll":stage.scaleMode = StageScaleMode.SHOW_ALL; break;
				}
			}
		}
		
		
		private var _align:String;
		/**
		 * Specifies the StageAlign type.
		 */		
		public function get align():String {return _align;}
		public function set align(value:String):void 
		{
			_align = value;
			
			if (stage) {
				switch (value) {
					case "bottom":stage.align =  StageAlign.BOTTOM; break;
					case "bottomLeft":stage.align = StageAlign.BOTTOM_LEFT; break;
					case "bottomRight":stage.align = StageAlign.BOTTOM_RIGHT; break;
					case "left":stage.align = StageAlign.LEFT; break;
					case "right":stage.align = StageAlign.RIGHT; break;
					case "top":stage.align = StageAlign.TOP; break;
					case "topLeft":stage.align = StageAlign.TOP_LEFT; break;
					case "topRight":stage.align = StageAlign.TOP_RIGHT; break; 
				}
			}
		}
		
		
		private var _frameRate:Number;
		/**
		 *
		 */		
		public function get frameRate():Number {return _frameRate;}
		public function set frameRate(value:Number):void 
		{
			_frameRate = value;
			if (stage) stage.frameRate = value;
		}
		
		/**
		 * Display the frame rate 
		 */		
		public var displayFrameRate:Boolean = false;
		/**
		 * Frame rate x position
		 */
		public var frX:Number = 0;
		/**
		 * Frame rate y position
		 */
		public var frY:Number = 0;
		/**
		 * Frame rate color
		 */
		public var frColor:uint = 0xFFFFFF;
		/**
		 * Display sprite to exit full screen on touch  
		 */
		public var escapeSprite:Boolean = false;
		/**
		 * Escape sprite x position
		 */
		public var esX:Number = 0;
		/**
		 * Escape sprite y position
		 */		
		public var esY:Number = 0;
		/**
		 * Escape sprite color
		 */		
		public var esColor:uint = 0xFFFFFF;
		 
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
		}
				
	}	
}