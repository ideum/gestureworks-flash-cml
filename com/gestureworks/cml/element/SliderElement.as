package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.*;
	import flash.utils.Dictionary;
	
	/**
	 * SliderElement
	 * @author Charles Veasey
	 */
	
	public class SliderElement extends Container 
	{
		
		private var elements = new Dictionary;		
		
		
		public function SliderElement() 
		{
			super();
			elements = new Dictionary(true);
		}
		
		
		/**
		 * Sets the orientation of the slider, choose horizontal or vertical
		 * @default horizontal
		 */
		private var _orientation:String = "horizontal";
		public function get orientation():String {return _orientation;}
		public function set orientation(value:String):void
		{
			_orientation = value;	
		}
		
		
		/**
		 * Sets the slider's mode, choose continuous or discrete
		 * @default continuous
		 */
		private var _mode:String = "continuous";
		public function get mode():String {return _mode;}
		public function set mode(value:String):void
		{
			_mode = value;	
		}		
		
		
		/**
		 * Sets whether discrete graphic marks are created
		 * @default false
		 */
		private var showMarks:Boolean = false;
		public function get showMarks():Boolean {return _showMarks;}
		public function set showMarks(value:Boolean):void
		{
			_showMarks = value;	
		}
		
		
		/**
		 * Sets the slider's background element through a child id
		 * @default null
		 */
		private var _background:String;
		public function get background():String {return _background;}
		public function set background(value:String):void
		{
			_background = value;	
		}			
		
		
		/**
		 * Sets the slider's foreground element through a child id
		 * @default null
		 */
		private var _foreground:String;
		public function get foreground():String {return _foreground;}
		public function set foreground(value:String):void
		{
			_foreground = value;	
		}
		
		
		/**
		 * Sets the slider's active (during interaction), 
		 * background element through a child id
		 * @default null
		 */
		private var _activeBackground:String;
		public function get activeBackground():String {return _activeBackground;}
		public function set activeBackground(value:String):void
		{
			_activeBackground = value;	
		}		
		
		
		/**
		 * Sets the slider's active (during interaction), 
		 * foreground element through a child id
		 * @default null
		 */
		private var _activeForeground:String;
		public function get activeForeground():String {return _activeForeground;}
		public function set activeForeground(value:String):void
		{
			_activeForeground = value;	
		}
		
		
		/**
		 * Sets the slider's active (during interaction), 
		 * foreground element through a child id
		 * @default null
		 */
		private var _activeForeground:String;
		public function get activeForeground():String {return _activeForeground;}
		public function set activeForeground(value:String):void
		{
			_activeForeground = value;
		}
		
		
		/**
		 * Sets the number of steps when mode is set to discrete
		 * @default 3
		 */
		private var _steps:int = 3;
		public function get steps():int {return _steps;}
		public function set steps(value:int):void
		{
			_steps = value;	
		}
		
		
		/**
		 * Sets the min output value when mode is set to continuous
		 * @default 0
		 */
		private var _min:Number = 0;
		public function get steps():Number {return _min;}
		public function set steps(value:Number):void
		{
			_steps = value;	
		}
		
		
		/**
		 * Sets the max output value when mode is set to continuous
		 * @default 100
		 */
		private var _max:Number = 100;
		public function get max():Number {return _max;}
		public function set max(value:Number):void
		{
			_max = value;	
		}				
		
		
		
		
	}

}