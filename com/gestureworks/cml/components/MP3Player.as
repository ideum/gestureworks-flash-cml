package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;	
	
	/**
	 * The MP3Player is a component that is primarily meant to play MP3 audio files. It displays a waveform representation on the front side and meta-data on the back side.
	 * It is composed of the following elements: mp3, front, back, menu, and frame. The mp3 and front may be the same thing. 
	 * The mp3 is required. The width and height of the component is automatically set to the dimensions of the mp3 element unless it is 
	 * previously specifed by the component.
	 * 
	 *  @author ...
	 */
	
	public class MP3Player extends Component 
	{		
		/**
		 * constructor
		 */
		public function MP3Player() 
		{
			super();			
		}
		
		
		///////////////////////////////////////////////////////////////////////
		// Public Properties
		//////////////////////////////////////////////////////////////////////
		
		private var _mp3:*;
		/**
		 * Sets the mp3 element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get mp3():* {return _mp3}
		public function set mp3(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_mp3 = value;
			else 
				_mp3 = searchChildren(value);					
		}				
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!mp3)
				mp3 = searchChildren(".mp3_element");
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".image_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!backBackground)
				backBackground = searchChildren(".info_bg");	
			
			// automatically try to find elements based on AS3 class
			if (!mp3)
				mp3 = searchChildren(MP3Element);
				
			super.init();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{
			init();
		}			
		
		override protected function updateLayout(event:*=null):void 
		{
			// update width and height to the size of the mp3, if not already specified
			if (!width && mp3)
				width = mp3.width;
			if (!height && mp3)
				height = mp3.height;
				
			super.updateLayout();
		}	
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			super.onStateEvent(event);
			if (event.value == "close" && mp3)
				mp3.stop();
			else if (event.value == "play" && mp3)
				mp3.resume();
			else if (event.value == "pause" && mp3)
				mp3.pause();				
		}	
		
		/**
		 * dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			mp3 = null;					
		}
		
	}
}