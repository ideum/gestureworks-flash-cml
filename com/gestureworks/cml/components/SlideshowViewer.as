package  com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.Slideshow;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * The SlideshowViewer component displays an Slideshow on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Slideshow element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Slideshow
	 */	
	public class SlideshowViewer extends Component
	{		
		private var _linkSlideshows:Boolean;
		
		/**
		 * @inheritDoc
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on AS3 class			
			var slideshows:Array = searchChildren(Slideshow, Array);
			
			if (!front && slideshows[0]) {
				front = slideshows[0];
			}
			if (!back && slideshows[1]) {
				back = slideshows[1];
			}
				
			synchSlideshows();			
			super.init();
		}
				
		/**
		 * When the back is also an album, this flag indicates the actions applied to one album will be
		 * applied to the other album. Both albums must have the same number of objects. 
		 * @default false
		 */
		public function get linkSlideshows():Boolean { return _linkSlideshows; }
		public function set linkSlideshows(value:Boolean):void{
			_linkSlideshows = value;
		}
		
		
		/**
		 * If front and back slideshows can be linked, synchronize the back slideshow properties with the front and
		 * listen for state changes from each album. 
		 */
		private function synchSlideshows():void{
			if (linkSlideshows){				
				if (Slideshow(front).numChildren != back.numChildren)
					throw new Error("Cannot link slideshows with different number of objects");
				
				back.rate = Slideshow(front).rate;
				back.fadeDuration = Slideshow(front).fadeDuration;
				back.currentIndex = Slideshow(front).currentIndex;
				back.autoplay = Slideshow(front).autoplay;
				back.loop = Slideshow(front).loop;											
			}			
		}
		
		/**
		 * @inheritDoc		 
		 */
		override protected function onStateEvent(event:StateEvent):void{	
			super.onStateEvent(event);
			
			if(front){
				if (event.value == "close"){
					Slideshow(front).stop();
					if (linkSlideshows)
						back.stop();
				}
				else if (event.value == "forward") {
					Slideshow(front).forward();
					if (linkSlideshows)
						back.forward();
				}
				else if (event.value == "play") {
					Slideshow(front).play();
					if (linkSlideshows)
						back.play();
				}
				else if (event.value == "pause") {
					Slideshow(front).pause();		
					if (linkSlideshows)
						back.pause();
				}
				else if (event.value == "back") {
					Slideshow(front).reverse();
					if (linkSlideshows)
						back.reverse();
				}
				else if (event.value == "loaded"){
					updateLayout();
				}
			}
		}
	}

}