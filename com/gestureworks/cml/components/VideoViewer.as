package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The VideoViewer component is primarily meant to display a Video element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>video</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the Video element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component 
	 * @see com.gestureworks.cml.elements.Video
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */			
	public class VideoViewer extends Component 
	{				
		private var initialScale:Number;
		private var infoBtn:Button;
		private var playBtn:Button;
		private var pauseBtn:Button;
		private var closeBtn:Button;
		
		public var staticVisual:Image;
		public var secondaryContentURL:String;
		
		/**
		 * Constructor
		 */
		public function VideoViewer() 
		{
			super();
		}
		
		///////////////////////////////////////////////////////////////////////
		// Public Properties
		//////////////////////////////////////////////////////////////////////
		
		private var _video:*;
		/**
		 * Sets the video element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get video():* {return _video}
		public function set video(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_video = value;
			else 
				_video = searchChildren(value);
				
			//_video.playButton = playBtn;
		}
				
		private var _slider:*;
		/**
		 * Sets the slider element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get slider():* {return _slider}
		public function set slider(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_slider = value;
			else 
				_slider = searchChildren(value);		
		}

		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on AS3 class
			if (!video)
				video = searchChildren(Video);
				
				
			video.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			// automatically try to find elements based on AS3 class
			if (!slider)
				slider = searchChildren(Slider);
									
			super.init();
						
			infoBtn = menu.getChildAt(0);
			playBtn = menu.getChildAt(1);
			pauseBtn = menu.getChildAt(2);
			closeBtn = menu.getChildAt(3);
		}	
			
		override protected function updateLayout(event:*=null):void 
		{
			// update width and height to the size of the video, if not already specified
			if (!width && video)
				width = video.width;
			if (!height && video)
				height = video.height;
				
			super.updateLayout();
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			super.onStateEvent(event);
			if (event.value == "close" && video)
				video.stop();
			else if (event.value == "play" && video)
				video.resume();
			else if (event.value == "pause" && video)
				video.pause();				
			else if (event.property == "position" && video) {
				if (menu) {
					if (menu.slider && Video(video).isPlaying) {
						Slider(menu.slider).input(event.value * 100);
					}
				}
			}
			else if (menu.slider && event.target is Slider) {
				video.pause();
				video.seek(event.value);
				addEventListener(GWTouchEvent.TOUCH_END, onRelease);
			}
		}
		
		private function onRelease(e:*):void {
			removeEventListener(GWTouchEvent.TOUCH_END, onRelease);
			video.resume();
		}
			
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			this.removeAllListeners();
			staticVisual.removeAllListeners();
			staticVisual = null;
			_video = null;
			_slider = null;
		}
		
		override public function set scale(value:Number):void {
			super.scale = value;
			if (!initialScale) {
				initialScale = value;
				
				minScale = value;
				maxScale = 920 / width;
				
				infoBtn.scale = .5 / value;
				playBtn.scale = .5 / value;
				pauseBtn.scale = .5 / value;
				closeBtn.scale = .5 / value;
			}
		}
		
		public function resetScale():void {
			scale = initialScale;
		}
		
		override public function clone():* 
		{	
			cloneExclusions.push("backs", "textFields");
			var clone:VideoViewer = CloneUtils.clone(this, this.parent, cloneExclusions);
			//var clone:VideoViewer = CloneUtils.clone(this, this.parent);
				
			//CloneUtils.copyChildList(this, clone);	// commented out b/c it was duplicating childlist (2012/2/6)
			
			if (video) {
				clone.video = String(video.id);
				//clone.video = video.clone();
			}
	
			if (front){
				clone.front = String(front.id);
			}
			
			if (back) {
				clone.back = String(back.id);
			}
			
			if (background){
				clone.background = String(background.id);
			}
			
			if (menu)	{
				clone.menu = String(menu.id);
			}
			
			if (frame) {
				clone.frame = String(frame.id);
			}
			
			if (fronts.length > 1) {
				clone.fronts = [];
				for (var l:int = 0; l < fronts.length; l++) 
				{
					for (var m:int = 0; m < clone.numChildren; m++) 
					{
						if (fronts[l].name == clone.getChildAt(m).name) {
							clone.fronts[l] = clone.getChildAt(m);
						}
					}
				}
			}
			
			if (backs.length > 1) {
				clone.backs = [];
				for (var j:int = 0; j < backs.length; j++) 
				{
					for (var k:int = 0; k < clone.numChildren; k++) 
					{
						if (backs[j].name == clone.getChildAt(k).name) {
							clone.backs[j] = clone.getChildAt(k);
						}
					}
				}
			}
			
			clone.init();				
			//clone.updateLayout();
			
			return clone;
		}
		
		
		
		/*private function onLoadComplete(e:StateEvent):void
		{
			if (e.property == "isLoaded") {
				video.removeEventListener(StateEvent.CHANGE, onLoadComplete);
				isLoaded = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "isLoaded", isLoaded));
			}
		}
		
		public var isLoaded:Boolean = true;*/
	}
}