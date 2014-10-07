package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
		
	/**
	 * The AudioPlayer component is primarily meant to display an Audio element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>audio</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the Audio element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Audio
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */	 	
	public class AudioPlayer extends Component 
	{	
		private var _audio:*;				
		
		/**
		 * Sets the audio element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get audio():* {return _audio}
		public function set audio(value:*):void {
			if (value is XML || value is String) {
				value = getElementById(value);
			}
			if (value is Audio) {
				_audio = value; 
				front = audio;
			}
		}				
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			// automatically try to find elements based on AS3 class
			if (!audio){
				audio = searchChildren(Audio);
			}
			
			if (audio) {
				audio.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			super.init();
		}		
		
		/**
		 * @inheritDoc
		 */
		override protected function updateLayout(event:*=null):void {
			// update width and height to the size of the audio, if not already specified
			if (!width && audio){
				width = audio.width;
			}
			if (!height && audio){
				height = audio.height;
			}
				
			super.updateLayout();
		}	
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void{				
			super.onStateEvent(event);
			if (event.value == "close" && audio){
				audio.stop();
			}
			else if (event.value == "play" && audio){
				audio.resume();
			}
			else if (event.value == "pause" && audio){
				audio.pause();
			}
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();	
			_audio = null;
		}
		
	}
}