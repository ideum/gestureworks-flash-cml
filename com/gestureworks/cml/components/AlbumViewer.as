package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	
	/**
	 * The AlbumViewer component is primarily meant to display an Album element and its associated meta-data.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>album</li>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 * 
	 * <p>The width and height of the component are automatically set to the dimensions of the Album element unless it is 
	 * previously specifed by the component.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  

			
	 * </codeblock>
	 * 
	 * @author Shaun
	 * @see Component 
	 * @see com.gestureworks.cml.element.Album 
	 * @see com.gestureworks.cml.element.TouchContainer
	 */
	public class AlbumViewer extends Component 
	{		
		/**
		 * Constructor
		 */
		public function AlbumViewer() 
		{
			super();
			mouseChildren = true;
			addEventListener(StateEvent.CHANGE, albumComplete);
			addEventListener(GWGestureEvent.ROTATE, updateAngle);
		}		
		
		/**
		 * Initialization function
		 */
		override public function init():void 
		{	
			// automatically try to find elements based on AS3 class			
			var albums:Array = searchChildren(Album, Array);
			
			if (!album && albums[0])
				album = albums[0];
			if (!front && album)
				front = album;
			if (!back && albums[1])
				back = albums[1];
			if (!pageButtons)
				pageButtons = searchChildren(RadioButtons);
				
			if (pageButtons) {
				RadioButtons(pageButtons).labels = "";
				var t:Number = Album(album).belt.numChildren-1; //exclude background
				for (var i:Number = 0; i < t; i++) {
					if (i != t-1)
						RadioButtons(pageButtons).labels += Number(i).toString() + ",";
					else
						RadioButtons(pageButtons).labels += Number(i).toString();
				}
				RadioButtons(pageButtons).init();
			}
									
			if (album && searchChildren(RadioButtons)) {
				album.addEventListener(StateEvent.CHANGE, onStateEvent);
			}
			super.init();
		}		
		
		private var _album:*;
		/**
		 * Sets the album element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned. 
		 */		
		public function get album():* {return _album}
		public function set album(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_album = value;
			else 
				_album = searchChildren(value);					
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
			if (album) album.dragAngle = value;
			if (linkAlbums && back) back.dragAngle = value;
		}

		/**
		 * Updates the angle of the album element
		 */
		override public function set rotationX(value:Number):void 
		{
			super.rotationX = value;
			if (album) album.dragAngle = value;
			if (linkAlbums && back) back.dragAngle = value;			
		}
		
		/**
		 * Updates the angle of the album element
		 */
		override public function set rotationY(value:Number):void 
		{
			super.rotationX = value;
			if (album) album.dragAngle = value;
			if (linkAlbums && back) back.dragAngle = value;			
		}	
		
	   /**
		* Updates the angle of the album element
		*/
		private function updateAngle(e:GWGestureEvent):void
		{
			if (album) album.dragAngle = rotation;
			if (linkAlbums && back) back.dragAngle = rotation;							
		}
		
		/**
		 * Updates dimensions and other attributes
		 */
		override protected function updateLayout(event:*=null):void 
		{
			
			
			// update width and height to the size of the album, if not already specified
			if (!width && album)
				width = album.width;
			if (!height && album)
				height = album.height;
										
			super.updateLayout();
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
					indices.selectButton(Album(album).currentIndex.toString());
				}
			}
			else if (event.value == "forward") {
				if (side == "back" && back is Album)
					back.next();
				else
					album.next();
			}
			else if (event.value == "back") {
				if (side == "back" && back is Album)
					back.previous();
				else
					album.previous();
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
				if (album.belt.numChildren != back.belt.numChildren)
					throw new Error("Cannot link albums with different number of objects");
				
				back.horizontal = album.horizontal;
				back.loop = album.loop;	
				back.margin = album.margin;
				back.snapping = album.snapping;
				back.centerContent = album.centerContent;
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
		
		public function clear():void
		{
			width = 0;
			height = 0;
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			album = null;	
			
			removeEventListener(StateEvent.CHANGE, albumComplete);
			removeEventListener(GWGestureEvent.ROTATE, updateAngle);
			removeEventListener(StateEvent.CHANGE, updateAlbums);				
		}
		
	}
	
}