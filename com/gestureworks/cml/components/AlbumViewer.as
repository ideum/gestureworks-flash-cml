package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.kits.*;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.core.GestureWorks;
	

	/**
	 * The AlbumViewer is a component that is primarily meant to display an <code>AlbumElement</code> on the front side and meta-data on the back side.
	 * It is composed of the following elements: album, front, back, menu, and frame. The width and height of the component is automatically set to the 
	 * dimensions of the album unless it is previously specifed by the component.
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
				album = searchChildren(AlbumElement);
			
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
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			album = null;	
		}
		
	}
	
}