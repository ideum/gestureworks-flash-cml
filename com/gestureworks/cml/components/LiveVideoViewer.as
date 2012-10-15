package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import flash.display.DisplayObject;
	
	/**
	 * The LiveVideoViewer component is primarily meant to display a LiveVideo element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>liveVideo</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the LiveVideo element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Uma and Shaun
	 * @see Component
	 * @see com.gestureworks.cml.element.LiveVideo
	 * @see com.gestureworks.cml.element.TouchContainer
	 */
	public class LiveVideoViewer extends Component 
	{						
		/**
		 * live video viewer Constructor
		 */
		public function LiveVideoViewer() 
		{
			super();			
		}
		
		private var _liveVideo:*;
		/**
		 * Sets the livevideo element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get liveVideo():* {return _liveVideo}
		public function set liveVideo(value:*):void 
		{
		
			if (!value) return;
			
			if (value is DisplayObject)
				_liveVideo = value;
			else 
				_liveVideo = searchChildren(value);	
					trace("liveVideo:" +_liveVideo);
		}			
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on css class - this is the v2.0-v2.1 implementation
			if (!menu)
				menu = searchChildren(".menu_container");
			if (!frame)
				frame = searchChildren(".frame_element");
			if (!front)
				front = searchChildren(".video_container");
			if (!back)
				back = searchChildren(".info_container");				
			if (!background)
				background = searchChildren(".info_bg");	

			// automatically try to find elements based on AS3 class
			if (!liveVideo)
				liveVideo = searchChildren(LiveVideo);
				
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
			// update width and height to the size of the video, if not already specified
			if (!width && liveVideo)
				width = liveVideo.width;		
			if (!height && liveVideo)
				height = liveVideo.height;
				
			super.updateLayout();
		}		
		
		override protected function onStateEvent(event:StateEvent):void
		{				
			super.onStateEvent(event);
			if (event.value == "close" && liveVideo)
				liveVideo.stop();		
		}
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			liveVideo =  null;
		}
		
	}
}

		


