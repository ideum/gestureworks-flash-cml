package com.gestureworks.cml.utils 
{	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * The Waveform utility creates a graphical waveform, 
	 * often used for visual representations of sound.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var w:Waveform = new Waveform;
		w.draw();
		addChild(w);
	 
	 * </codeblock>
	 * 
	 * @author Ideum
	 */	
	public class Waveform extends Sprite 
	{
		/**
		 * Waveform origin
		 * @default 150
		 */				
		private var _origin:Number;

		/**
		 * Graphics object
		 * @default null
		 */	
		private var _g:Graphics;
		
		/**
		 * Sprite object
		 * @default null
		 */	
		private var _sp:Sprite;
		
		
		/**
		 * Creates a Waveform object, sets property defaults,
		 * add the waveform object to the stage
		 * 
		 * @param none
		 * @return none 
		 */				
		public function Waveform() {
			
			super();
			propertyDefaults();
			_sp = new Sprite;
			_averageGain = new Array;
			_g = _sp.graphics;
			addChild(_sp);

		}
		
		
		/**
		 * Waveform width
		 * @default 500
		 */			
		private var _waveWidth:Number;
		public function get waveWidth():Number { return _waveWidth; }
		public function set waveWidth(val:Number):void { _waveWidth = val; }		
		
		/**
		 * Waveform height
		 * @default 150
		 */			
		private var _waveHeight:Number;
		public function get waveHeight():Number { return _waveHeight; }
		public function set waveHeight(val:Number):void { 
			_waveHeight = val; 
			_origin = _waveHeight * .5;
		}
		
		/**
		 * Color of drawn waveform in RGB
		 * @default "255,255,255"
		 */	
		private var _waveColor:uint = 0x000000;
		public function get waveColor():uint { return _waveColor; }
		public function set waveColor(val:uint):void { 
			_waveColor = val;
		}
		
		/**
		 * Array of average gain values
		 * @default null
		 */	
		private var _averageGain:Array;
		public function get averageGain():Array { return _averageGain; }
		public function set averageGain(val:Array):void { _averageGain = val; }
		
				
		/**
		 * Frees object memory
		 * @param none
		 * @return none 
		 */		
		public function Dispose():void {
			
			//removeChild(_sp);
			_sp = null;
			_averageGain = [];
			_averageGain = null;
			
		}
		
		/**
		 * Draws waveform
		 * @param none
		 * @return none 
		 */		
		public function draw():void {
			
			_g.clear();
			_g.lineStyle(0, _waveColor);
			_g.beginFill(_waveColor, 0.5);
			_g.moveTo(0, _origin);
			
			var lgth:int = _averageGain.length;
					
			for (var i:uint = 0; i < lgth; i += 8) {
				_g.lineTo(i * (_waveWidth / lgth), _averageGain[i] * _waveHeight * .4 + _origin);
				_g.lineTo(i * (_waveWidth / lgth), _origin);	
			
			}
			
			_g.endFill();		
		}
		
		/**
		 * Sets property defaults
		 * @param none
		 * @return none 
		 */				
		private function propertyDefaults():void {
			
			_waveColor = 0x000000;
			_waveWidth = 500;
			_waveHeight = 150;
			_origin = _waveHeight * 0.5;
			
		}		
		
	}//class
}//package