package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.NumberUtils;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The ProgressBar provides a visual representation of the progress of a task over time.
	 * @author Ideum 
	 */
	public class ProgressBar extends Slider
	{
		private var _source:*;
		private var _bar:*;
		private var _barColor:uint = 0xFF0000;
				
		public function ProgressBar() 
		{
			super();
		}
		
		override public function init():void 
		{
			super.init();
		}
		
		/**
		 * Synchronize the bar width 
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			if (!isHorizontal() && bar) bar.width = value;
		}
		
		/**
		 * Synchronize the bar height 
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (isHorizontal() && bar) bar.height = value;
		}
		
		/**
		 * The source task 
		 */
		public function get source():* { return _source; }
		public function set source(s:*):void {
			_source = s;
			registerSource();
		}
		
		/**
		 * The bar object
		 */
		public function get bar():* { return _bar; }
		public function set bar(b:*):void
		{
			if (b is DisplayObject)
				_bar = b;
			else {
				_bar = searchChildren(b);
				_bar = CMLObjectList.instance.getId(b);
			}
		}
		
		/**
		 * The color of the default bar
		 */
		public function get barColor():uint { return _barColor; }
		public function set barColor(c:uint):void {
			_barColor = c;
		}
		
		/**
		 * Updates the bar with the progress of the source
		 */
		private function registerSource():void
		{
			if (!source) return;
			
			if (source is Video)
				source.addEventListener(StateEvent.CHANGE, videoProgress);
			
			//TODO: register loader source
		}
		
		/**
		 * Update bar relative to video position
		 * @param	e
		 */
		private function videoProgress(e:StateEvent):void {
			if (e.property == "position")
			{
				max = e.target.duration;						
				if (max > 0) 
					input(e.value);
			}			
		}
		
		/**
		 * Generates a default bar if one is not provided
		 */
		override protected function setupUI():void 
		{
			super.setupUI();
			if (!bar)
			{
				bar = rail.clone();
				bar.color = barColor;				
			}			
				
			isHorizontal() ? bar.scaleX = 0 : bar.scaleY = 0;			
			addChildAt(bar, getChildIndex(hit));			
		}
		
		/**
		 * Expands or contracts the bar on drag
		 * @param	event
		 */
		override protected function onDrag(event:GWGestureEvent):void 
		{
			if(knob){
				super.onDrag(event);
				synchBar();
			}
			else if (event)
			{
				if(isHorizontal())
					bar.width += event.value.drag_dx;
				else
					bar.height += event.value.drag_dy;
			}
			
			seek();
		}
		
		/**
		 * Expands or contracts the bar on hit touch
		 * @param	event
		 */
		override protected function onDownHit(event:*):void 
		{
			if (knob)
			{
				super.onDownHit(event);
				synchBar();
			}
			else
			{
				bar.width = isHorizontal() ? event.localX : bar.width;
				bar.height = isHorizontal() ? bar.height : event.localY;				
			}
			
			seek();
		}
		
		/**
		 * Sets the value of the progress bar
		 * @param	val
		 */
		override public function input(val:Number):void 
		{
			if (val < 0) 
				return;
			if (knob)
			{
				super.input(val);
				synchBar();
			}
			else 
			{
				if(isHorizontal())
					bar.scaleX = val;
				else
					bar.scaleY = val;
			}
		}
		
		/**
		 * Allows slider knob to be optional
		 */
		override protected function get defaultKnob():DisplayObject 
		{
			return null;
		}
		
		/**
		 * Updates bar dimensions with knob location
		 */
		private function synchBar():void
		{
			if (knob) {
				bar.width = isHorizontal() ? knob.x + knob.width/2 : bar.width;
				bar.height = isHorizontal() ? bar.height : knob.y;	
			}
		}
		
		/**
		 * Seeks the video position relative to the bar
		 */
		private function seek():void
		{
			if (source is Video) {
				source.seek((bar.width / width) * 100);
				if(source.isPlaying)
					source.resume();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_bar = null;
			if (_source) {
				_source.removeEventListener(StateEvent.CHANGE, videoProgress);
				_source = null;
			}
		}
	}

}