package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.LiveVideo;
	import com.gestureworks.cml.events.StateEvent;
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
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.LiveVideo
	 * @see com.gestureworks.cml.elements.TouchContainer
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
		}			
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on AS3 class
			if (!liveVideo)
				liveVideo = searchChildren(LiveVideo);
				
			super.init();
		}	
			
		override public function updateLayout():void 
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
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			_liveVideo =  null;
		}
		
	}
}