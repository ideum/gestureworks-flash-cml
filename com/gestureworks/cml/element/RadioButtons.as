 package com.gestureworks.cml.element
    {
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import com.gestureworks.core.GestureWorks;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.cml.element.TextElement;
	
	/**
	 * The RadioButtons element represents a group of radio buttons generated from a user defined list of labels. Other configurable
	 * properties include the primary font characteristics (style, size, and color), placement direction (right to left or top to bottom), 
	 * and the spacing between the buttons.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 			
		override protected function gestureworksInit():void
 		{
			radioButtonsTest();
		}
	 
		private function radioButtonsTest()
		{
			var rButtons:RadioButtons = new RadioButtons("A,B,C,D,E");
			rButtons.x = 200;
			rButtons.y = 200;
		    rButtons.labels = "Abracadabra,B,C,D,E,f,g,h,i,k";			
			rButtons.fontColor = 0xFF0216;			
			rButtons.verticalOffset = 70;
			rButtons.update();
			rButtons.addEventListener(StateEvent.CHANGE, testRBSelect);
			addChild(rButtons);
		}
		
		private function testRBSelect(event:StateEvent):void
		{
			trace(event.value);
		}
	 * 
	 * 
	 * </codeblock>
	 * @author Shaun
	 */
	public class RadioButtons extends ElementFactory 	 
	{		
		private var selected:Sprite;
		private var radius:Number;
		
		/**
		 * RadioButton constructor. Allows users to define a group of radio buttons by passing a comma delimited string containing
		 * label names. 
		 * @param	labels  the comma delimited list of labels 
		 */
		public function RadioButtons(labels:String=null)
		{
			super();
			if (labels != null)
			{
				_labels = labels;
				init();
			}
		}   
		
		/**
		 * Initializes the configuration and display of the RadioButtons
		 */
		public function init ():void
		{		
			draw();
			
			if (GestureWorks.activeTUIO) 
				this.addEventListener(TuioTouchEvent.TOUCH_DOWN, buttonSelected);
			else if (GestureWorks.supportsTouch) 
				this.addEventListener(TouchEvent.TOUCH_BEGIN, buttonSelected);
			else 
				this.addEventListener(MouseEvent.MOUSE_DOWN, buttonSelected);
		}	
		
		/**
		 * CML display initialization callback
		 */
		public override function displayComplete():void
		{
			super.displayComplete();
			init();
		}		
		
		/**
		 * Clears the display and generates a new display based on the labels. 
		 */
		private function draw():void
		{
			clear();
			
			if (_labels)
			{
				var labelList:Array = _labels.split(",");
				for (var index:String in labelList)
					drawButton(labelList[index]);
					
				drawSelection();		
			}
		}
		
		/**
		 * Removes all children from the display.
		 */
		private function clear():void
		{		
			for (var i:int = numChildren-1; i >= 0; i--)
				removeChildAt(i);
		}	
		
		/**
		 * Re-draws the display to incorporate any changes.
		 */
		public function update():void
		{
			draw();
		}
			
		/**
		 * Creates a button and an associated caption for the provided label and adds them
		 * to the display object. The size of the button is a factor of the font size.
		 * @param	label  the label name
		 */
		private function drawButton(label:String):void
		{	
			var caption:TextElement = new TextElement();			
			if (_fontSize)
				caption.fontSize = _fontSize;
			if (_fontStyle)
				caption.font = _fontStyle;
			if (_fontColor) 
				caption.color = _fontColor;	
				
			var button:Sprite = new Sprite();
			radius = caption.fontSize/2;
			button.name = label;
			button.graphics.lineStyle(1, 0x000000);
			button.graphics.beginFill(0xFFFFFF);			
			button.graphics.drawCircle(radius, radius, radius);			
			button.graphics.endFill();														
			setButtonPosition(button);
					
			caption.autoSize = "left";
			caption.text = label;
			caption.height = caption.fontSize;
			caption.x = button.x + button.width;
			caption.y = button.y - (caption.height - caption.getLineMetrics(0).height);
			caption.selectable = false;
			
			_radioButtons[label] = button;
			_textElements[label] = caption;
			
			addChild(button);
			addChild(caption);												
		}
		
		/**
		 * Position the buttons according to the layout type and the space occupied by the previously
		 * added button-label pair.
		 * @param	button  the button to position
		 */
		private function setButtonPosition(button:Sprite):void
		{
			var lastLabel:TextElement = getLastChild(TextElement);
			if (lastLabel)
			{			
				//set a minimum distance to prevent overlap
				var min:Number;
				var offset:Number;
				
				if (_verticalLayout)
				{
					min = lastLabel.textHeight + 10 ;
					offset = _verticalOffset > min ? _verticalOffset : min;
					button.y = lastLabel.y + offset;
				}
				else
				{
					min = lastLabel.textWidth + 10;
					offset = _horizontalOffset > min ? _horizontalOffset : min;
					button.x = lastLabel.x + offset;
				}
			}
		}
		
		/**
		 * Returns the last child object of the provided type
		 * @param	type  the type of object to retrieve
		 * @return  the most recently added object of the specified type, null if none exist
		 */
		private function getLastChild(type:Class):*
		{
			for (var i:int = numChildren-1; i > 0; i--)
			{
				var child:* = getChildAt(i);
				if (child is type)
					return child;
			}
			return null;
		}		
		
		/**
		 * Draws the inner circle representing the selected state of the radio button. 
		 */
		private function drawSelection(): void
		{		
			selected = new Sprite();
			selected.name = "selected";
			selected.graphics.lineStyle(1, 0x000000);
			selected.graphics.beginFill(0x000000);		
			selected.graphics.drawCircle(radius, radius, radius*.6);
			selected.graphics.endFill();
		}
		
		/**
		 * Comma delimited string of button labels
		 */
		private var _labels:String;
		public function get labels():String { return _labels; }
		public function set labels(labels:String):void
		{
			_labels = labels;

		}		
		
		/**
		 * Vertical distance between buttons
		 */
		private var _verticalOffset:Number;
		public function get verticalOffset():Number { return _verticalOffset; }
		public function set verticalOffset(vo:Number):void		
		{
			_verticalOffset = vo;
		}
		
		/**
		 * Horizontal distance between button 
		 */
		private var _horizontalOffset:Number;
		public function get horizontalOffset():Number { return _horizontalOffset; }
		public function set horizontalOffset(ho:Number):void
		{
			_horizontalOffset = ho;
		}
		
		/**
		 * Flag indicating whether the buttons in a sequence are displayed vertically or horizontally.
		 */
		private var _verticalLayout:Boolean = true;
		public function get verticalLayout():Boolean { return _verticalLayout };
		public function set verticalLayout(vl:Boolean):void 
		{
			_verticalLayout = vl;
		}
		
		/**
		 * The label font name
		 */
		private var _fontStyle:String;
		public function get fontStyle():String { return _fontStyle; }
		public function set fontStyle(fs:String):void
		{
			_fontStyle = fs;
		}
		
		/**
		 * The label font size (minimum size is 9)
		 */
		private var _fontSize:Number;
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(fs:Number):void
		{
			if(fs > 9)
				_fontSize = fs;
		}
		
		/**
		 * The label font color
		 */
		private var _fontColor:uint;
		public function get fontColor():uint { return _fontColor; }
		public function set fontColor(fc:uint):void
		{
			_fontColor = fc;
		}
		
		/**
		 * Label name to TextElement mapping
		 */
		private var _textElements:Dictionary = new Dictionary();
		public function get textEls():Dictionary { return _textElements; }
		
		/**
		 * Label name to button Sprite mapping
		 */
		private var _radioButtons:Dictionary = new Dictionary();
		public function get radioButtons():Dictionary { return _radioButtons; }
		
		/**
		 * The currently selected label
		 */
		private var _selectedLabel:String;
		public function get selectedLabel():String { return _selectedLabel; }
				
		
		/**
		 * Handles the event indicating a radio button is selected 
		 * @param	event
		 */
		private function buttonSelected(event:*):void
		{		
			if (event.target is Sprite)
			{
				var button:Sprite = Sprite(event.target);
				if (button.name != selected.name)
				{
					button.addChild(selected);
					_selectedLabel = button.name;
				}
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "selectedLabel", _selectedLabel, true));		
			}
		}	
		
		/**
		 * dispose method to nullify attributes and remove listeners
		 */
		override public function dispose():void
		{
			super.dispose();
			 selected = null;
			_textElements = null;
			_radioButtons = null;
			this.removeEventListener(TuioTouchEvent.TOUCH_DOWN, buttonSelected);
			this.removeEventListener(TouchEvent.TOUCH_BEGIN, buttonSelected);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, buttonSelected);
			
		}
	}
}