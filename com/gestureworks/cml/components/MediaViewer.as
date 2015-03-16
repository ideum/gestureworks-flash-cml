package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.base.media.MediaStatus;
	import com.gestureworks.cml.elements.Button;
	import com.gestureworks.cml.elements.Media;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.interfaces.IStream;
	import com.gestureworks.cml.utils.DisplayUtils;
	
	/**
	 * The MediaViewer component displays an Media on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Media element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Media
	 */	 
	public class MediaViewer extends Component 
	{
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
			
			//search for local instance
			if (!front){
				front = displayByTagName(Media);
			}	
			
			//listen for image load
			if (front) {
				if (Media(front).isLoaded) {
					Media(front).image.resize(front.width, front.height);
				}
				else{
					front.addEventListener(StateEvent.CHANGE, onLoad);
				}
			}
			
			super.init();	
		}	
		
		/**
		 * Update layout on media load
		 * @param	event
		 */
		private function onLoad(event:StateEvent):void {
			if (event.property == MediaStatus.LOADED) {
				front.removeEventListener(StateEvent.CHANGE, onLoad);
				updateLayout();
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
			var displayStreamControls:Boolean = Media(front).current is IStream;
			for each(var control:Button in streamControls) {
				control.visible = displayStreamControls;
			}
			
			//update layout when media dimensions have changed			
			if (width != Media(front).width || height != Media(front).height) {
				
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
		override protected function onStateEvent(event:StateEvent):void {	
			
			super.onStateEvent(event);
			
			if(front){
				if (event.value == "close"){
					Media(front).stop();
				}
				else if (event.value == "play"){
					Media(front).resume();
				}
				else if (event.value == "pause"){
					Media(front).pause();		
				}
			}
		}	
	}
}