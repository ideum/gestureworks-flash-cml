package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.Frame;
	import com.gestureworks.cml.element.Graphic;
	import com.gestureworks.cml.element.Menu;
	import com.gestureworks.cml.element.Text;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.core.GestureWorks;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import flash.utils.Dictionary;
	
	
	/**
	 * The Component manages a group of elements to create a high-level interactive touch container.
	 * 
	 * <p>It is composed of the following: 
	 * <ul>
	 * 	<li>front</li>
	 * 	<li>back</li>
	 * 	<li>menu</li>
	 * 	<li>frame</li>
	 * 	<li>background</li>
	 * </ul></p>
	 *  
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 
			
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.element.TouchContainer
	 */	
	public class Component extends TouchContainer 
	{	
		private var textFields:Array;	
		private var fontArray:Array = new Array();
					
		/**
		 * component Constructor
		 */
		public function Component() 
		{
			super();
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{	
			this.addEventListener(StateEvent.CHANGE, onStateEvent);
			
			if (!menu)
				menu = searchChildren(Menu);
			if (!frame)
				frame = searchChildren(Frame);
			if (!background && back && back.hasOwnProperty("searchChildren"))
				background = back.searchChildren(Graphic);	
			
			textFields = [];
			textFields = searchChildren(Text, Array);
			for (var i:int = 0; i < textFields.length; i++)
				fontArray.push(textFields[i].fontSize);
						
			updateLayout();				
		}
		
		/**
		 * CML Initialisation callback
		 */
		override public function displayComplete():void
		{
			init();
		}
		
		private var _fontIncrement:Number = 2;
		/**
		 * font increment
		 * @default 2;
		 */	
		public function get fontIncrement():Number {return _fontIncrement}
		public function set fontIncrement(value:Number):void 
		{	
			_fontIncrement = value;			
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
		
		
		private var _background:*;
		/**
		 * Sets the back background element.
		 * This can be set using a simple CSS selector (id or class) or directly to a display object.
		 * Regardless of how this set, a corresponding display object is always returned.
		 */		
		public function get background():* {return _background}
		public function set background(value:*):void 
		{	
			if (!value) return;
			
			if (value is DisplayObject)
				_background = value;
			else
				_background = searchChildren(value);				
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
		
		private var _side:String = "front";
		/**
		 * Specifies the currently displayed side
		 * @default "front"
		 */
		protected function get side():String { return _side; }
		
		protected function updateLayout(event:*=null):void
		{
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
			
			if (background)
			{
				background.width = width;
				background.height = height;
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
		 * handles touch event
		 * @param	event
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
		 * handles event
		 * @param	event
		 */
		public function onUp(event:*):void
		{
			if (menu)
				menu.mouseChildren = true;
		}	
		
		private var textCount:Number = 0;
				
		private function textSize():void
		{
			if (textFields)
			{
				if (textCount >= 3)
				{
				for (var j:int = 0; j < textFields.length; j++)
				{
				    textFields[j].fontSize = fontArray[j];		
			    }
			    textCount = 0;
				}
				else
				{
				for (var i:int = 0; i < textFields.length; i++)
				{
					textFields[i].fontSize += fontIncrement;
				}
			}
            }
		}
		
		protected function onStateEvent(event:StateEvent):void
		{
			
			if (event.value == "fontSize")
			{
				textSize();
				textCount++;
			}
			

			if (event.value == "info") 
			{
				if (back)
				{
					if (!back.visible) { 
						back.visible = true;
						_side = "back";
					}
					else { 
						back.visible = false;
					}
				}
				if (front && hideFrontOnFlip)
				{
					if (!front.visible) { 
						front.visible = true;
						_side = "front";
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
		 * Returns clone of self
		 */
		override public function clone():* 
		{
			
			var v:Vector.<String> = new <String>
			["$x", "$y", "_$x", "_$y", "_x", "_y", "cO", "sO", "gO", "tiO", "trO", "tc", 
			"tt", "tp", "tg", "td", "clusterID", "pointCount", "dN", "N", "_dN", "_N", 
			"touchObjectID", "_touchObjectID", "_pointArray", "$transformPoint" ];
			
			var clone:Component = CloneUtils.clone(this, null, v);
			
			if (clone.parent)
				clone.parent.addChild(clone);
			else
				this.parent.addChild(clone);
			
			var arr:Array = childList.getKeyArray();
			
			for (var i:int = 0; i < arr.length; i++) 
			{	
				for (var j:int = 0; j < numChildren; j++) 
				{
					if (getChildAt(j)["id"] == arr[i])
						clone.childList.replaceKey(String(arr[i]), clone.getChildAt(j));
				}				
			}
			
			if (front)
				clone.front = String(front.id);
			
			if (back)
				clone.back = String(back.id);
			
			if (background)
				clone.background = String(background.id);
			
			if (menu)	
				clone.menu = String(menu.id);
			
			if (frame)
				clone.frame = String(frame.id);	
				
			
			clone.displayComplete();
			return clone;
		}		
		
		
		override public function dispose():void 
		{
			super.dispose();
			textFields = null;
			front = null;
			back = null;
			background = null;
			menu = null;
			frame = null;
			
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