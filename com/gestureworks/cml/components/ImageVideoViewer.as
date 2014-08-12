package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.utils.document;
	import flash.display.DisplayObject;
	
	public class ImageVideoViewer extends Component 
	{		
		private var initialScale:Number; 
		private var infoBtn:Button;
		private var playBtn:Button;
		private var pauseBtn:Button;
		private var closeBtn:Button;
		
		public var video:Video;
		public var secondaryContentURL:String;
		
		/**
		 * image viewer Constructor
		 */
		public function ImageVideoViewer() 
		{
			super();
			mouseChildren = true;
			nativeTransform = true;
			affineTransform = true;			
		}
		
		private var _image:*;
		/**
		 * Sets the image element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get image():* {return _image}
		public function set image(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_image = value;
			else 
				_image = searchChildren(value);					
		}			
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{				
			// automatically try to find elements based on AS3 class
			if (!image)
				image = searchChildren(Image);
			
			if (image)
				image.addEventListener(StateEvent.CHANGE, onLoadComplete);
				
			super.init();	
			
			infoBtn = menu.getChildAt(0);
			playBtn = menu.getChildAt(1);
			pauseBtn = menu.getChildAt(2);
			closeBtn = menu.getChildAt(3);
		}
		
		private function onLoadComplete(e:StateEvent):void
		{
			if (e.property == "isLoaded") {
				image.removeEventListener(StateEvent.CHANGE, onLoadComplete);
				isLoaded = true;
				dispatchEvent(new StateEvent(StateEvent.CHANGE, id, "isLoaded", isLoaded));
			}
		}
		
		public var isLoaded:Boolean = true;
			
		override protected function updateLayout(event:*=null):void 
		{		
			if (image) {
				// update width and height to the size of the image, if not already specified
				//if (!width && image)
					width = image.width;
				//if (!height && image)
					height = image.height;	
			}
			super.updateLayout();
			menu.updateLayout(width, height);
		}
		
		// Should only be called after child video has recieved a metadata callback!
		public function videoLayoutUpdate(event:StateEvent):void {
			if ( !(event.property == "sizeLoaded" && event.value == true )) {
				return;
			}
			
			super.onStateEvent(event);
			if (video) {
				width = video.width;
				height = video.height;
			}
			
			scale = 300 / width;
			super.updateLayout();
			menu.updateLayout(width, height);
			
			
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			super.onStateEvent(event);
				
			if (event.value == "close" && video) {
				video.stop(); 
			}
			else if (event.value == "play") {
				if (video) { 
					if (video.isPaused) { video.resume(); }
					else if (!video.isPlaying) { video.play(); }
				}
			}
			else if (event.value == "pause") {
				if (video) { video.pause(); }
			}
		}
		
		public function startVideo():void {
			if (!video) {
				video = new Video();
				video.addEventListener(StateEvent.CHANGE, videoLayoutUpdate);
				addChildAt(video, 0);
				video.src = secondaryContentURL;
				video.autoplay = true;
			}
			video.open();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			image = null;
			video.removeAllListeners();
			video = null;
		}
		
		override public function clone():* 
		{	
			cloneExclusions.push("backs", "textFields");
			var clone:ImageVideoViewer = CloneUtils.clone(this, this.parent, cloneExclusions);		
				
			//CloneUtils.copyChildList(this, clone);	// commented out b/c it was duplicating childlist (2012/2/6)
			
			if (image) {
				clone.image = String(image.id);
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
		
		override public function set scale(value:Number):void {
			super.scale = value;
			if (!initialScale) {
				initialScale = value;
				
				minScale = value;
				/*if (_image.landscape == true)
					maxScale = 920 / width;
				else
					maxScale = 920 / height;*/
				maxScale = 1920 / width;
				
				/*infoBtn.scale = .5 / value;
				playBtn.scale = .5 / value;
				pauseBtn.scale = .5 / value;
				closeBtn.scale = .5 / value;*/
			}
		}
		
		public function resetScale():void {
			scale = initialScale;
		}
	}
	
}