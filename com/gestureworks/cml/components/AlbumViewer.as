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
			if (!album)
				album = searchChildren(Album);
			
			super.init();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{
			init();
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
		
		/**
		 * Updates the angle of the album element
		 */
		override public function set rotation(value:Number):void 
		{
			super.rotation = value;
			if(album) album.dragAngle = value;
		}

		/**
		 * Updates the angle of the album element
		 */
		override public function set rotationX(value:Number):void 
		{
			super.rotationX = value;
			if(album) album.dragAngle = value;
		}
		
		/**
		 * Updates the angle of the album element
		 */
		override public function set rotationY(value:Number):void 
		{
			super.rotationX = value;
			if(album) album.dragAngle = value;
		}	
		
	   /**
		* Updates the angle of the album element
		*/
		private function updateAngle(e:GWGestureEvent):void
		{
			if (album)
				album.dragAngle = rotation;
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
		 * Updates the viewer when the album element is loaded
		 * @param	e
		 */
		private function albumComplete(e:StateEvent):void
		{
			if (e.property == "isLoaded" && e.value)
			{
				updateLayout();
				album.dragAngle = rotation;
			}
		}		
		
		/**
		 * Dispose method
		 */
		override public function dispose():void 
		{
			super.dispose();
			album = null;	
		}
		
	}
	
}