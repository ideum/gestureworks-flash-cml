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
	 * dimensions of the image unless it is previously specifed by the component.
	 */
	public class AlbumViewer extends Component 
	{
		private var textFields:Array;	
		
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
			this.addEventListener(StateEvent.CHANGE, onStateEvent);				
			
			// automatically try to find elements based on AS3 class
			if (!album)
				album = searchChildren(AlbumElement);
			if (!menu)
				menu = searchChildren(Menu);
			if (!frame)
				frame = searchChildren(FrameElement);
			if (!backBackground && back && back.hasOwnProperty("searchChildren"))
				backBackground = back.searchChildren(GraphicElement);	
			
			// this is the v2.0-v2.1 implementation
			if (autoTextLayout)
				textFields = searchChildren(TextElement, Array);
				
			updateLayout();	
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
		
		
		private var _front:*;
		/**
		 * Sets the front element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get front():* {return _front}
		public function set front(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_front = value;
			else 
				_front = searchChildren(value);			
		}				
		
		
		private var _back:*;
		/**
		 * Sets the back element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get back():* {return _back}
		public function set back(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_back = value;
			else
				_back = searchChildren(value);
		}		
		
		
		private var _backBackground:*;
		/**
		 * Sets the back background element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get backBackground():* {return _backBackground}
		public function set backBackground(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_backBackground = value;
			else
				_backBackground = searchChildren(value);				
		}
		
		
		private var _menu:*;
		/**
		 * Sets the menu element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get menu():* {return _menu}
		public function set menu(value:*):void 
		{
			if (!value) return;
			
			if (value is DisplayObject)
				_menu = value;
			else
				_menu = searchChildren(value);
		}			

		private var _frame:*;
		/**
		 * Sets the frame element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get frame():* {return _frame}
		public function set frame(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_frame = value;
			else
				_frame = searchChildren(value);				
		}			
		
		
		private var _hideFrontOnFlip:Boolean = false;
		/**
		 * Specifies whether the front is hidden when the the back is shown
		 * @default false
		 */		
		public function get hideFrontOnFlip():* {return _hideFrontOnFlip}
		public function set hideFrontOnFlip(value:*):void 
		{	
			_hideFrontOnFlip = value;			
		}				
		
		
		private var _autoTextLayout:Boolean = true;
		/**
		 * Specifies whether text fields will be automatically adjusted to the component's width
		 * @default true
		 */		
		public function get autoTextLayout():Boolean {return _autoTextLayout}
		public function set autoTextLayout(value:Boolean):void 
		{	
			_autoTextLayout = value;			
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
		private function updateLayout():void
		{			
			// update width and height to the size of the album, if not already specified
			if (!width && album)
				width = album.width;
			if (!height && album)
				height = album.height;
							
			if (front)
			{
				front.width = width;
				front.height = height;				
			}			
			
			if (back)
			{
				back.width = width;
				back.height = height;				
			}
			
			if (backBackground)
			{
				backBackground.width = width;
				backBackground.height = height;
			}
				
			if (frame)
			{
				frame.width = width;
				frame.height = height;
			}			
			
			if (menu)
			{				
				menu.updateLayout(width, height);
				
				if (menu.autoHide) {
					if (GestureWorks.activeTUIO)
						this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);
					else if	(GestureWorks.supportsTouch)
						this.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
					else	
						this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
						
					if (GestureWorks.activeTUIO)
						this.addEventListener(TuioTouchEvent.TOUCH_UP, onUp);
					else if	(GestureWorks.supportsTouch)
						this.addEventListener(TouchEvent.TOUCH_END, onUp);
					else	
						this.addEventListener(MouseEvent.MOUSE_UP, onUp);						
				}					
			}
			
			
			if (textFields && autoTextLayout)
			{
				for (var i:int = 0; i < textFields.length; i++) 
				{					
					textFields[i].x = textFields[i].x + textFields[i].paddingLeft;
					
					textFields[i].autoSize = "left";
					textFields[i].width = width - textFields[i].paddingLeft - textFields[i].paddingRight;
										
					if (i == 0)
						textFields[i].y = textFields[i].paddingTop;
					else
						textFields[i].y = textFields[i].paddingTop + textFields[i-1].paddingBottom + textFields[i-1].height;
				}
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
				album.dragAngle = rotation;
			}
		}
		
		/**
		 * Displays the menu for a limited 
		 * @param	event  the down event
		 */
		public function onDown(event:*):void
		{
			if (menu)
			{
				menu.visible = true;
				menu.startTimer();
			}
		}			

		/**
		 * Sets mouse children to true to allow menu content interaction
		 * @param	event
		 */
		public function onUp(event:*):void
		{
			if (menu)
				menu.mouseChildren = true;
		}		
		
		/**
		 * Switches between front and back
		 * @param	event
		 */
		override protected function onStateEvent(event:StateEvent):void
		{				
			if (event.value == "info") 
			{
				if (back)
				{
					if (!back.visible) { 
						back.visible = true;
					}
					else { 
						back.visible = false;
					}
				}
				if (front && hideFrontOnFlip)
				{
					if (!front.visible) { 
						front.visible = true;
					}
					else { 
						front.visible = false;
					}
				}
			}
			else if (event.value == "close")
			{
				this.visible = false;
			}			
		}
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			
			textFields = null;
			album = null;
			front = null;
			back = null;
			backBackground = null;
			menu = null;
			frame = null;
			
			this.removeEventListener(StateEvent.CHANGE, albumComplete);
			this.removeEventListener(StateEvent.CHANGE, onStateEvent);			
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, onDown);		
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, onDown);		
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);		
			this.removeEventListener(TuioTouchEvent.TOUCH_UP, onUp);
			this.removeEventListener(TouchEvent.TOUCH_END, onUp);
			this.removeEventListener(MouseEvent.MOUSE_UP, onUp);	
		}
		
	}
	
}