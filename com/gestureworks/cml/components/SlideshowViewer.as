package  com.gestureworks.cml.components
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import flash.display.DisplayObject;
	
	/**
	 * The SlideshowViewer component is primarily meant to display a Slideshow element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>slideshow</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the YouTube element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.element.Slideshow
	 * @see com.gestureworks.cml.element.Stack
	 */		
	public class SlideshowViewer extends Component
	{
		/**
		 * slideshow Constructor
		 */
		public function SlideshowViewer() 
		{
			super();
		}
		
		private var _slideshow:*;
		/**
		 * Sets the slideshow element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get slideshow():* {return _slideshow}
		public function set slideshow(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_slideshow = value;
			else
				_slideshow = searchChildren(value);
		}
		
		private var _linkSlideshows:Boolean = false;		
		/**
		 * When the back is also an album, this flag indicates the actions applied to one album will be
		 * applied to the other album. Both albums must have the same number of objects. 
		 */
		public function get linkSlideshows():Boolean { return _linkSlideshows; }
		public function set linkSlideshows(l:Boolean):void
		{
			_linkSlideshows = l;
		}
		
		private var _pageButtons:*;
		/**
		 * Sets the page buttons element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */
		public function get pageButtons():* { return _pageButtons; }
		public function set pageButtons(value:*):void {
			if (!value) return;
			
			if (value is DisplayObject)
				_pageButtons = value;
			else
				_pageButtons = searchChildren(value);
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{			
			// automatically try to find elements based on AS3 class			
			var slideshows:Array = searchChildren(Slideshow, Array);
			
			if (!slideshow && slideshows[0])
				slideshow = slideshows[0];
			if (!front && slideshow)
				front = slideshow;
			if (!back && slideshows[1])
				back = slideshows[1];
			if (!pageButtons)
				pageButtons = searchChildren(RadioButtons);
				
			if (pageButtons) {
				RadioButtons(pageButtons).labels = "";
				var t:Number = slideshow.numChildren;
				for (var i:Number = 0; i < t; i++) {
					if (i != t-1)
						RadioButtons(pageButtons).labels += Number(i).toString() + ",";
					else
						RadioButtons(pageButtons).labels += Number(i).toString();
				}
				if (RadioButtons(pageButtons).labels != "" && RadioButtons(pageButtons).labels)
					RadioButtons(pageButtons).init();
			}
				
			synchSlideshows();
			
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			super.init();
		}
		
		/**
		 * If front and back slideshows can be linked, synchronize the back slideshow properties with the front and
		 * listen for state changes from each album. 
		 */
		private function synchSlideshows():void
		{
			linkSlideshows = linkSlideshows ? (back is Slideshow) : false;
			if (linkSlideshows)
			{				
				if (slideshow.numChildren != back.numChildren)
					throw new Error("Cannot link slideshows with different number of objects");
				
				back.rate = slideshow.rate;
				back.fadeDuration = slideshow.fadeDuration;
				back.currentIndex = slideshow.currentIndex;
				back.autoplay = slideshow.autoplay;
				back.loop = slideshow.loop;				
				//addEventListener(StateEvent.CHANGE, updateSlideshows);								
			}			
		}
		
		override protected function updateLayout(event:*=null):void 
		{
			// update width and height to the size of the slideshow, if not already specified
			if (!width && slideshow) {
				width = slideshow.width;
				if (linkSlideshows) {
					back.width = slideshow.width;
				}
			}
			if (!height && slideshow) {
				height = slideshow.height;
				if (linkSlideshows) {
					back.height = slideshow.height;
				}
			}
				
			super.updateLayout();
		}
		
		override protected function onStateEvent(event:StateEvent):void
		{	
			super.onStateEvent(event);
			
			if (event.value == "close" && slideshow){
				slideshow.stop();
				if (linkSlideshows)
					back.stop();
			}
			else if (event.value == "forward" && slideshow) {
				slideshow.forward();
				if (linkSlideshows)
					back.forward();
			}
			else if (event.value == "play" && slideshow) {
				slideshow.play();
				if (linkSlideshows)
					back.play();
			}
			else if (event.value == "pause" && slideshow) {
				slideshow.pause();		
				if (linkSlideshows)
					back.pause();
			}
			else if (event.value == "back" && slideshow) {
				slideshow.reverse();
				if (linkSlideshows)
					back.reverse();
			}
			else if (event.value == "loaded" && slideshow)
				updateLayout();
			else if (event.property == "slideshowState") {
				var indices:RadioButtons = searchChildren(RadioButtons);
				if (indices) {
					indices.selectButton(Slideshow(slideshow).currentIndex.toString());
				}
			}
			else if (event.property == "selectedLabel") {
				if (!isNaN(Number(event.value))) {
					var index:Number = Number(event.value);
					slideshow.snapTo(index)
					if (linkSlideshows)
						back.snapTo(index);
				}
			}
		}
		
		/**
		 * Dispose method to nullify the attributes and remove listener
		 */
		override public function dispose():void 
		{
			super.dispose();
			_slideshow = null; 
			_pageButtons = null;
		}
	}

}