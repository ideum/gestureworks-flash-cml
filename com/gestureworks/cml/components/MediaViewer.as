package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Button;
	import com.gestureworks.cml.elements.Media;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.utils.DisplayUtils;
	
	/**
	 * The MediaViewerNew component is primarily meant to display a Media element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>media</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <p>The width and height of the component are automatically set to the dimensions of the Media element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * 
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Media
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */	 
	public class MediaViewer extends Component 
	{
		private var _media:Media;
		private var streamOps:RegExp = /(play|pause|stop|resume|seek|volume|pan)$/i;  
		private var streamControls:Array
		
		/**
		 * Constructor
		 */
		public function MediaViewer() {
			super();			
			streamControls = [];
		}
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			// automatically try to find elements based on AS3 class
			if (!media){
				media = searchChildren(Media);
			}
			super.init();		
		}			
		
		/**
		 * Media element
		 */		
		public function get media():* { return _media; }
		public function set media(value:*):void {
			if (value is XML || value is String) {
				value = getElementById(value);
			}
			
			if (value is Media) {
				_media = value;
				_media.mediaUpdate = mediaUpdate
				front = _media;
			}
		}					
		
		/**
		 * @inheritDoc
		 */
		override public function set menu(value:*):void {
			super.menu = value;
			if (menu) {
				storeStreamControls();
			}
		}
		
		/**
		 * Store stream controls to toggle visibility based on the media type
		 */
		private function storeStreamControls():void {
			streamControls.length = 0;
			var controls:Array = DisplayUtils.getAllChildrenByType(menu, Button);
			
			//evaluate button dispatch instruction to identify stream control
			for each(var control:Button in controls) {				
				if (control.dispatch.search(streamOps) > -1){
					streamControls.push(control);
				}
			}
		}
		
		//TODO: Abstract content update to Component
		/**
		 * Media change actions
		 */
		private function mediaUpdate():void {
			
			//update controls
			var displayStreamControls:Boolean = media.current is IStream;
			for each(var control:Button in streamControls) {
				control.visible = displayStreamControls;
			}
			
			//update layout when media dimensions have changed			
			if (width != media.width || height != media.height) {
				
				width = 0;
				height = 0;
				init();
				
				if (back) {
					DisplayUtils.initAll(back);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateLayout():void {
			// update width and height to the size of the media, if not already specified
			if (!width && media)
				width = media.width;
			if (!height && media)
				height = media.height;
				
			super.updateLayout();
		}		
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void {	
			super.onStateEvent(event);
			if (event.value == "close" && media)
				media.stop();
			else if (event.value == "play" && media)
				media.resume();
			else if (event.value == "pause" && media)
				media.pause();				
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();	
			_media = null;
		}	
	}
}