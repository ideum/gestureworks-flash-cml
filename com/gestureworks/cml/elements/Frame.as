package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.utils.CloneUtils;
	

	/**
	 * The Frame element create display object frames. It is designed
	 * to be used as an element of components.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
		var frame:Frame = new Frame();
		frame.width = 300;
		frame.height = 300;
		frame.x = 700;
		frame.y = 200;
		frame.frameAlpha = .7;
		frame.frameColor = 0xAAAABB;
		frame.frameThickness = 20;
		frame.init();
		addChild(frame);
		
	 * </codeblock>
	 *
	 * @author Ideum
	 */
	public class Frame extends Graphic
	{
		/**
		 * Constructor
		 */
		public function Frame() 
		{			
			super();
		}		
		
		
		private var _frameShape:String="rectangle";
		/**
		 * Sets frame shape
		 * @default "rectangle"
		 */			
		public function get frameShape():String{return _frameShape;}
		public function set frameShape(value:String):void
		{
			_frameShape = value;		
			init();	
		}
		
		private var _frameThickness:Number=30;
		/**
		 * Sets frame thickness
		 * @default 100
		 */			
		public function get frameThickness():Number{return _frameThickness;}
		public function set frameThickness(value:Number):void
		{
			_frameThickness = value;		
			init();	
		}
		
		private var _frameColor:Number=0x999999;
		/**
		 * Sets frame thickness
		 * @default 100
		 */
		public function get frameColor():Number{return _frameColor;}
		public function set frameColor(value:Number):void
		{
			_frameColor = value;
			init();
		}
		
		private var _frameAlpha:Number=0.3;
		/**
		 * Sets frame thickness
		 * @default 100
		 */
		public function get frameAlpha():Number{return _frameAlpha;}
		public function set frameAlpha(value:Number):void
		{
			_frameAlpha = value;	
			init();
		}
		
		/**
		 * Initialization method
		 */
		override public function init():void
		{
			updateGraphic();
		}		
		
		/**
		 * Update frame graphics
		 */
		public override function updateGraphic():void
		{
			graphics.clear();		
			
			if	(_frameShape=="rectangle"){
				graphics.lineStyle(2*_frameThickness, _frameColor, _frameAlpha);
				graphics.drawRect( -_frameThickness, -_frameThickness, width + 2 * _frameThickness, height + 2 * _frameThickness);
				graphics.lineStyle(2, _frameColor,_frameAlpha+0.5);
				graphics.drawRoundRect( -2 * _frameThickness, -2 * _frameThickness, width + 4 * _frameThickness, height + 4 * _frameThickness, 2 * _frameThickness, 2 * _frameThickness);
				graphics.lineStyle(4, _frameColor,0.8);
				graphics.drawRect( -2, -2, width + 4, height + 4);
			}	
		}
 
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
		}
		
		/**
		 * Returns a clone of self
		 * @return
		 */
		override public function clone():* 
		{
			var clone:Frame = CloneUtils.clone(this, this.parent);
			clone.updateGraphic();
			return clone;			
		}
		
	}
}