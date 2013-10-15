package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	
	/**
	 * The WavPlayer component is primarily meant to display a WAV element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>wav</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the WAV element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.element.WAV
	 * @see com.gestureworks.cml.element.TouchContainer
	 */		
	public class WAVPlayer extends Component 
	{		
		/**
		 * Constructor
		 */
		public function WAVPlayer() 
		{
			super();			
		}
		
		private var _wav:*;
		/**
		 * Sets the wav element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get wav():* {return _wav}
		public function set wav(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_wav = value;
			else 
				_wav = searchChildren(value);					
		}			
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!wav)
				wav = searchChildren(".wav_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".image_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!wav)
				wav = searchChildren(WAV);
			
			super.init();
		}		
			
		
		override protected function updateLayout(event:*=null):void 
		{
			// update width and height to the size of the wav, if not already specified
			if (!width && wav)
				width = wav.width;
			if (!height && wav)
				height = wav.height;
				
			super.updateLayout();
		}		
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			super.onStateEvent(event);
			
			if (event.value == "close" && wav)
				wav.stop();
			else if (event.value == "play")
				wav.play();
			else if (event.value == "pause")
				wav.pause();				
		}	
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			_wav = null; 
		}
		
	}
}