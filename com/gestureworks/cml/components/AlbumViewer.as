package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.elements.Album;
	import com.gestureworks.cml.elements.RadioButtons;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The AlbumViewer component displays an Album on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Album element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component 
	 * @see com.gestureworks.cml.elements.Album 
	 */
	public class AlbumViewer extends Component 
	{		
		/**
		 * Constructor
		 */
		public function AlbumViewer() {
			super();
			addEventListener(StateEvent.CHANGE, albumComplete);
			addEventListener(GWGestureEvent.ROTATE, updateAngle);
		}		
		
		/**
		 * Initialization function
		 */
		override public function init():void {	
			// automatically try to find elements based on AS3 class			
			var albums:Array = searchChildren(Album, Array);
			if (!front && albums[0]) {
				front = albums[0];
			}
			if (!back && albums[1]) {
				back = albums[1];
			}
			
			super.init();				
		}		
		
		private var _linkAlbums:Boolean = false;		
		/**
		 * When the back is also an album, this flag indicates the actions applied to one album will be
		 * applied to the other album. Both albums must have the same number of objects. 
		 */
		public function get linkAlbums():Boolean { return _linkAlbums; }
		public function set linkAlbums(l:Boolean):void
		{
			_linkAlbums = l;
		}
		
		/**
		 * Updates the angle of the album element
		 */
		override public function set rotation(value:Number):void 
		{
			super.rotation = value;
			if (front) front.dragAngle = value;
			if (linkAlbums && back) back.dragAngle = value;
		}

		/**
		 * Updates the angle of the album element
		 */
		override public function set rotationX(value:Number):void 
		{
			super.rotationX = value;
			if (front) front.dragAngle = value;
			if (linkAlbums && back) back.dragAngle = value;			
		}
		
		/**
		 * Updates the angle of the album element
		 */
		override public function set rotationY(value:Number):void 
		{
			super.rotationX = value;
			if (front) front.dragAngle = value;
			if (linkAlbums && back) back.dragAngle = value;			
		}	
		
	   /**
		* Updates the angle of the album element
		*/
		private function updateAngle(e:GWGestureEvent):void
		{
			if (front) front.dragAngle = rotation;
			if (linkAlbums && back) back.dragAngle = rotation;							
		}
		
		/**
		 * Process AlbumViewer state events
		 * @param	event
		 */
		override protected function onStateEvent(event:StateEvent):void 
		{			
			if (event.property == "albumState") {
				var indices:RadioButtons = searchChildren(RadioButtons);
				if (indices) {
					indices.selectButton(Album(front).currentIndex.toString());
				}
			}
			else if (event.value == "forward") {
				if (flipped && back is Album)
					back.next();
				else
					front.next();
			}
			else if (event.value == "back") {
				if (flipped && back is Album)
					back.previous();
				else
					front.previous();
			}
			else
				super.onStateEvent(event);			
		}

		/**
		 * If front and back albums can be linked, synchronize the back album properties with the front and
		 * listen for state changes from each album. 
		 */
		private function synchAlbums():void
		{
			linkAlbums = linkAlbums ? (back is Album) : false;
			if (linkAlbums)
			{				
				if (front.belt.numChildren != back.belt.numChildren)
					throw new Error("Cannot link albums with different number of objects");
				
				back.horizontal = front.horizontal;
				back.loop = front.loop;	
				back.margin = front.margin;
				back.snapping = front.snapping;
				back.centerContent = front.centerContent;
				addEventListener(StateEvent.CHANGE, updateAlbums);								
			}			
		}
		
		/**
		 * Each album reports its state changes (horizontal or vertical movement) to the viewer and the viewer updates the alternate album
		 * with the changes. 
		 * @param	e
		 */
		private function updateAlbums(e:StateEvent):void
		{
			if (e.property == "albumState" && e.value)
			{
				var link:Album = e.target == front ? back : front;
				link.updateState(e.value);
			}
		}
		
		/**
		 * Updates the viewer when the album element is loaded
		 * @param	e
		 */
		private function albumComplete(e:StateEvent):void
		{
			if (e.property == "isLoaded" && e.value)
			{
				updateLayout();
				e.target.dragAngle = rotation;
				if (e.target == back && linkAlbums)
					synchAlbums();
			}
		}		
		
	}
	
}