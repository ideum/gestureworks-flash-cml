 package com.gestureworks.cml.elements
    {
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.document;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * The RadioButtons element represents a group of radio buttons generated from a user defined list of labels. Other configurable
	 * properties include the primary font characteristics (style, size, and color), placement direction (right to left or top to bottom), 
	 * and the spacing between the buttons.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 			
		var rButtons:RadioButtons = new RadioButtons("A,B,C,D,E");
		rButtons.x = 200;
		rButtons.y = 200;
		rButtons.labels = "Abracadabra,B,C,D,E,f,g,h,i,k";			
		rButtons.fontColor = 0xFF0216;			
		rButtons.verticalOffset = 70;
		rButtons.update();
		rButtons.addEventListener(StateEvent.CHANGE, testRBSelect);
		addChild(rButtons);
		
		
		function testRBSelect(event:StateEvent):void
		{
			trace(event.value);
		}	

	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see Button
	 * @see DropDownMenu
	 */
	public class RadioButtons extends TouchContainer 	 
	{		
		private var selected:Sprite;
		//private var selected:Graphic;
		private var radius:Number;
		private var labelList:Array;
		private var downStates:Array;
		private var _nestedButtons:Boolean = false;
		private var buttons:Array;
		
		/**
		 * RadioButton Constructor. Allows users to define a group of radio buttons by passing a comma delimited string containing
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
			
			mouseChildren = true;
		}   
		
		public var absOffset:Boolean = false;

		
		/**
		 * Initializes the configuration and display of the RadioButtons
		 */
		override public function init ():void
		{		
			if (nestedButtons) {
				buttons = getElementsByTagName(Button);				
				for each (var item:Button in buttons) {
					item.addEventListener(StateEvent.CHANGE, onButton);
				}
			}
			else {	
				if (!_labels) return;

				draw();
				addEventListener(GWTouchEvent.TOUCH_BEGIN, buttonSelected);
				if (_graphicsArray && _graphicsArray.length > 0) {
					_selectedLabel = _graphicsArray[0].name;
					_graphicsArray[0].alpha = 1;
				}
				else {
					_radioButtons[labelList[0]].addChild(selected);
					_selectedLabel = _radioButtons[labelList[0]].name;
				}
			}
		}		
		
		/**
		 * Clears the display and generates a new display based on the labels. 
		 */
		private function draw():void
		{
			clear();
			
			if (_pageButtons) {
				drawPageButtons("left");
			}
			
			if (_graphicReps) {
				_graphicsArray = [];
				_graphicsArray = _graphicReps.split(",");
				downStates = [];
				var grabStates:Array = [];
				for (var j:int = 0; j < _graphicsArray.length; j++) 
				{
					grabStates = _graphicsArray[j].split(":");
					if (grabStates.length == 2){
						_graphicsArray[j] = grabStates[0];
						downStates.push(grabStates[1]);
					}
				}
				grabStates = null;
				for (var i:int = 0; i < _graphicsArray.length; i++) 
				{
					_graphicsArray[i] = childList.getKey(_graphicsArray[i]);
					if (downStates && i < downStates.length) {
						downStates[i] = childList.getKey(downStates[i]);
					}
				}
			}
			
			if (_labels)
			{
				labelList = _labels.split(",");
				for (var index:Number = 0; index < labelList.length; index++ )
					drawButton(index);
					
				drawSelection();		
			}
			
			if (_pageButtons) {
				drawPageButtons("right");
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
		private function drawButton(index:Number):void
		{	
			var label:String = labelList[index];
			var caption:Text = new Text();			
			if (_fontSize)
				caption.fontSize = _fontSize;
			if (_fontStyle)
				caption.font = _fontStyle;
			if (_fontColor) 
				caption.color = _fontColor;	
			caption.alpha = _fontAlpha;
			
			var button:Sprite = new Sprite();
			var downButton:Sprite;
			button.name = label;
			radius = caption.fontSize/2;
			if (_graphicsArray && index < _graphicsArray.length) {
				button.addChild(_graphicsArray[index]);
				if (downStates.length == 0)
					button.alpha = 0.5;
				else if (index < downStates.length) {
					//_graphicsArray[index].visible = false;
					//button.addChild(downStates[index]);
					downButton = new Sprite();
					downButton.name = label;
					downButton.addChild(downStates[index]);
					downStates[index] = button;
					downStates[index].alpha = 0;
				}
				else button.alpha = 0.5;
				
				_graphicsArray[index] = button;
				if (downButton && index > 0) {
					Sprite(_graphicsArray[index]).alpha = 0;
					Sprite(downStates[index]).visible = true;
				}
			}
			else {
				button.graphics.lineStyle(_radioStroke, _radioStrokeColor);
				button.graphics.beginFill(_radioColor);			
				button.graphics.drawCircle(radius, radius, radius);			
				button.graphics.endFill();
			}
			setButtonPosition(button);
			if (downButton) {
				//setButtonPosition(downButton);
				downButton.x = button.x;
				downButton.y = button.y;
				addChild(downButton);
			}
					
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
			var lastLabel:Text = getLastChild(Text);
			if (lastLabel)
			{			
				//set a minimum distance to prevent overlap
				var min:Number;
				var offset:Number;
				
				if (_verticalLayout)
				{
					min = lastLabel.textHeight + 10 > button.height ? lastLabel.textHeight + 10 : button.height;
					offset = _verticalOffset > min ? _verticalOffset : min;
					if (absOffset) offset = _verticalOffset;
					button.y = lastLabel.y + offset;
				}
				else
				{
					min = lastLabel.textWidth + (lastLabel.textWidth * 0.1) > button.width ? lastLabel.textWidth + (lastLabel.textWidth * 0.1) : button.width;
					offset = _horizontalOffset > min ? _horizontalOffset : min;
					if (absOffset) offset = _horizontalOffset;
					button.x = lastLabel.x + offset;
				}
			}
		}
		
		
		private function drawPageButtons(side:String):void {
			radius = _fontSize/2;
			var button:Sprite = new Sprite();
			button.graphics.beginFill(_radioColor, 0);			
			button.graphics.drawCircle(radius, radius, radius);			
			button.graphics.endFill();
			
			
			switch (side) {
				case "left":
					button.name = "back";
					
					var left:Graphic = new Graphic();
					left.shape = "triangle";
					left.lineStroke = _radioStroke;
					left.lineColor = _radioStrokeColor;
					left.height = _fontSize;
					left.fill = "color";
					left.color = _radioColor;
					left.rotation = -90;
					left.y = left.height;
					left.name = "back";
					button.addChild(left);
					addChild(button);
					
					setButtonPosition(button);
					
					var captionLeft:Text = new Text();			
					captionLeft.fontSize = 1;
					captionLeft.autoSize = "left";
					captionLeft.text = "b";
					captionLeft.height = captionLeft.fontSize;
					captionLeft.x = button.x + button.width;
					//captionLeft.y = left.y - (captionLeft.height - captionLeft.getLineMetrics(0).height);
					captionLeft.selectable = false;
					captionLeft.alpha = 0;
					addChild(captionLeft);
					break;
				
				case "right":
					button.name = "forward";
					
					var right:Graphic = new Graphic();
					right.shape = "triangle";
					right.lineStroke = _radioStroke;
					right.lineColor = _radioStrokeColor;
					right.height = _fontSize;
					//right.width = _fontSize;
					right.fill = "color";
					right.color = _radioColor;
					right.rotation = 90;
					right.x = _fontSize;
					//right.y = right.height;
					right.name = "forward";
					button.addChild(right);
					addChild(button);
					setButtonPosition(button);
					
					var captionRight:Text = new Text();			
					captionRight.fontSize = 1;
					captionRight.autoSize = "left";
					captionRight.text = "f";
					captionRight.height = captionRight.fontSize;
					captionRight.x = button.x + button.width;
					//captionRight.y = left.y - (captionRight.height - captionRight.getLineMetrics(0).height);
					captionRight.selectable = false;
					captionRight.alpha = 0;
					addChild(captionRight);
					break;
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
			selected.graphics.beginFill(_selectedColor);		
			selected.graphics.drawCircle(radius, radius, radius * _selectedFillRatio);
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
		
		private var _graphicsArray:Array;
		private var _graphicReps:String;
		/**
		 * A comma delimited string of ids of display objects to use for buttons.
		 * If a display object is selected this way, its alpha will be dimmed when not selected.
		 */
		public function get graphicReps():String { return _graphicReps; }
		public function set graphicReps(value:String):void {
			_graphicReps = value;
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
			//if(fs > 9)
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
		
		private var _fontAlpha:Number = 1;
		/**
		 * The alpha for the labels.
		 */
		public function get fontAlpha():Number { return _fontAlpha; }
		public function set fontAlpha(value:Number):void {
			_fontAlpha = value;
		}
		
		private var _radioColor:uint = 0xffffff;
		/**
		 * The color for the radio buttons;
		 */
		public function get radioColor():uint { return _radioColor; }
		public function set radioColor(value:uint):void {
			_radioColor = value;
			if (_radioButtons && labelList) {
				for (var i:int = 0; i < labelList.length; i++) 
				{
					_radioButtons[labelList[i]].color = _radioColor;
				}
			}
		}
		
		private var _radioStroke:Number = 1;
		/**
		 * The stroke of the radio button's graphic.
		 */
		public function get radioStroke():Number { return _radioStroke; }
		public function set radioStroke(value:Number):void {
			_radioStroke = value;
		}
		
		private var _radioStrokeColor:uint = 0x000000;
		/**
		 * The color of a radio button's stroke;
		 */
		public function get radioStrokeColor():uint { return _radioStrokeColor; }
		public function set radioStrokeColor(value:uint):void {
			_radioStrokeColor = value;
		}
		
		private var _selectedColor:uint = 0x000000;
		/**
		 * The color of the fill of the selected radio button;
		 */
		public function get selectedColor():uint { return _selectedColor; }
		public function set selectedColor(value:uint):void {
			_selectedColor = value;
			if (selected) {
				//selected.color = _selectedColor;
				selected.graphics.clear();
				selected.graphics.beginFill(_selectedColor, 1);
				selected.graphics.drawCircle(radius, radius, radius * _selectedFillRatio);
				selected.graphics.endFill();
			}
		}
		
		private var _selectedFillRatio:Number = 0.6;
		/**
		 * The amount of fill when the radio button is selected.
		 */
		public function get selectedFillRatio():Number { return _selectedFillRatio; }
		public function set selectedFillRatio(value:Number):void {
			_selectedFillRatio = value;
		}
		
		private var _pageButtons:Boolean = false;
		/**
		 * Set whether or not the buttons are being used for pagination.
		 * This will automatically add arrows to either side of the buttons
		 * the same color as them.
		 */
		public function get pageButtons():Boolean { return _pageButtons; }
		public function set pageButtons(value:Boolean):void {
			_pageButtons = value;
		}
		
		/**
		 * Label name to button Sprite mapping
		 */
		private var _radioButtons:Dictionary = new Dictionary();
		public function get radioButtons():Dictionary { return _radioButtons; }
		
		private var _selectedLabel:String;
		/**
		 * The currently selected label
		 */
		public function get selectedLabel():String { return _selectedLabel; }
		
		
		/**
		 * Specifies whether the children are nested buttons.
		 */
		public function get nestedButtons():Boolean {
			return _nestedButtons;
		}
		
		public function set nestedButtons(value:Boolean):void {
			_nestedButtons = value;
		}
		
		public function selectButton(s:String):void {
			
			if (_graphicsArray) {
				for (var i:int = 0; i < _graphicsArray.length; i++) 
				{
					if (_graphicsArray[i].name != s) {
						if (downStates.length > 0 && i < downStates.length) {
							_graphicsArray[i].alpha = 0;
						} else {
							_graphicsArray[i].alpha = 0.5;
						}
					}
					else {
						_graphicsArray[i].alpha = 1;
					}
				}
			}
			else 
			{
				for (var j:int = 0; j < numChildren; j++) {
					if (selected && getChildAt(j).name == s) {
						Sprite(getChildAt(j)).addChild(selected);
						_selectedLabel = getChildAt(j).name;
					}
				}
			}
		}
		
		/**
		 * Handles the event indicating a radio button is selected 
		 * @param	event
		 */
		private function buttonSelected(event:*):void
		{	
			if (event.target is TextField || event.target is Text)
				return;
			if (event.target.name == "forward") {
				next();
				return;
			} else if (event.target.name == "back") {
				previous();
				return;
			}
			
			if (event.target is DisplayObject)
			{
				var button:DisplayObject = DisplayObject(event.target);
				if (_graphicsArray) {
					for (var i:int = 0; i < _graphicsArray.length; i++) 
					{
						if (_graphicsArray[i] != event.target) {
							if (compareChildren(_graphicsArray[i], event.target)) {
								_graphicsArray[i].alpha = 1;
								_selectedLabel = _graphicsArray[i].name;
								if (downStates && i < downStates.length) {
									_graphicsArray[i].alpha = 1;
									//downStates[i].visible = false;
								}
							}
							else if (downStates.length == 0) {
								_graphicsArray[i].alpha = 0.5;
							} else if (i < downStates.length) {
								//downStates[i].visible = true;
								_graphicsArray[i].alpha = 0;
							}
						}
					}
				}
				else if (selected && button.name != selected.name)
				{
					if (button is DisplayObjectContainer)
						DisplayObjectContainer(button).addChild(selected);
					else if (button is Text) {
						for (var s:String in _textElements) {
							if (_textElements[s] == button) {
								button = _radioButtons[s];
								DisplayObjectContainer(button).addChild(selected);
							}
						}
					}
					_selectedLabel = button.name;
				}
				dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedLabel", _selectedLabel, true));
			}
						
		}	
		
		private function compareChildren(target:*, comparison:*):Boolean {
			if ( target == comparison) {
				return true;
			} else if ( target is DisplayObjectContainer && target.numChildren > 0) {
				for (var i:Number = 0; i < target.numChildren; i++) {
					if (compareChildren(target.getChildAt(i), comparison)) {
						return true;
					}
				}
				return false;
			} else return false;
		}
		
		private function next():void {
			var button:Sprite;
			if (_graphicsArray ) {
				for (var j:int = 0; j < _graphicsArray.length; j++) 
				{
					if (_selectedLabel == _graphicsArray[j].name) {
						if (downStates.length == 0 || j >= downStates.length)
							_graphicsArray[j].alpha = 0.5;
						else if (downStates && j < downStates.length) {
							_graphicsArray[j].alpha = 0;
						}
						if (j + 1 < _graphicsArray.length)
							j++;
						else {
							_graphicsArray[j].alpha = 1;
							return;
						}
						_graphicsArray[j].alpha = 1;
						_selectedLabel = _graphicsArray[j].name;
						dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedLabel", _selectedLabel, true));
						return;
					}
				}
			}
			else {
				for (var i:int = 0; i < numChildren; i++) 
				{
					if (_selectedLabel == getChildAt(i).name) {
						
						// The childlist is populated in Button, Text pairs,
						// so we must increase by two to get to the next button
						// instead of getting caught up on the text element following
						// the current button.
						if (i + 2 < numChildren - 2)
							i += 2;
						button = Sprite(getChildAt(i));
						button.addChild(selected);
						_selectedLabel = button.name;
						dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedLabel", _selectedLabel, true));
						return;
					}
				}
			}
		}
		
		private function previous():void {
			var button:Sprite;
			
			if (_graphicsArray ) {
				for (var j:int = _graphicsArray.length - 1; j > -1; j--) 
				{
					if (_selectedLabel == _graphicsArray[j].name) {
						
						if(downStates.length == 0 || j >= downStates.length)
							_graphicsArray[j].alpha = 0.5;
						else if (downStates && j < downStates.length)
							_graphicsArray[j].alpha = 0;
						if (j - 1 > -1)
							j--;
						else {
							_graphicsArray[j].alpha = 1;
							return;
						}
						_graphicsArray[j].alpha = 1;
						_selectedLabel = _graphicsArray[j].name;
						dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedLabel", _selectedLabel, true));
						return;
					}
				}
			}
			else {
				for (var i:int = 0; i < numChildren; i++) 
				{
					if (_selectedLabel == getChildAt(i).name) {
						
						if (i - 2 > 1)
							i -= 2;
						button = Sprite(getChildAt(i));
						button.addChild(selected);
						_selectedLabel = button.name;
						dispatchEvent(new StateEvent(StateEvent.CHANGE, this, "selectedLabel", _selectedLabel, true));
						return;
					}
				}
			}
		}
		
		
		/**
		 * Event handler used when radio buttons contain nested buttons and the nestButtons flag set to true.
		 * The nested button must have to children:
		 * O = off state
		 * 1 = on state
		 */
		private function onButton(e:StateEvent):void {			
			for each (var item:Button in buttons) {
				if (item == e.target) {
					item.childList[0].visible = false;
					item.childList[1].visible = true;
				} 
				else {
					item.childList[0].visible = true;
					item.childList[1].visible = false;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			 selected = null;
			_textElements = null;
			_radioButtons = null;
			_labels = null;
			_graphicsArray = null;
			labelList = null;
			downStates = null;
			removeEventListener(GWTouchEvent.TOUCH_BEGIN, buttonSelected);
			
		}
	}
}