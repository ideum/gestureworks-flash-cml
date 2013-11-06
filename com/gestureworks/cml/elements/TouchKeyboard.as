package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.cml.elements.Key;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * The <code>TouchKeyboard</code> is a virtual keyboard providing an interface for a collection of <code>Key</code> objects
	 * and output management for key events. Default configurations are in place for convenience but the keyboard's style, layout, and key
	 * actions are customizable. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	
		var tk:TouchKeyboard = new TouchKeyboard();
		tk.init();
		addChild(tk);
		
		var txt1:Text = new Text();
		txt1.width = 400;
		txt1.height = 400;
		txt1.x = 1000;
		txt1.border = true;
		txt1.multiline = true;
		txt1.type = "input";
		addChild(txt1);	
	 * 
	 * 
	 * </codeblock>
	 * 
	 * @author Shaun
	 * @see Key
	 */
	public class TouchKeyboard extends TouchContainer
	{	
		private var _output:Text;
		private var _bkgPadding:Number;	
		private var _cornerWidth:Number = 2;
		private var _cornerHeight:Number = 5;
		private var _keySpacing:Number;
		private var _background:*;
		
		private var keys:Dictionary;
		private var shift:Boolean = false;
		private var bkgWidth:Number;
		private var bkgHeight:Number;
		private var currentTF:Text;
		private var caret:int = 0;
		
		/**
		 * Constructor
		 */
		public function TouchKeyboard() 
		{
			super();
			mouseChildren = true;
			keys = new Dictionary();
			keySpacing = 10;
			bkgPadding = 50;
			addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		/**
		 * Initialization function
		 * @param	event
		 */
		override public function init(): void
		{	
			generateKeys();
			setLayout();
		}
		
		/**
		 * The graphical canvas containing the keys
		 */
		public function get background():* { return _background; }
		public function set background(b:*):void
		{
			if (!(b is DisplayObject))
				_background = childList.getKey(String(b));	
			else
				_background = b;
		}
		
		/**
		 * A specified output text field
		 */
		public function get output():* { return _output; }
		public function set output(o:*):void
		{
			if(o is Text)
				_output = o;
			else 
				_output = CMLObjectList.instance.getId(String(o));
		}
			
		/**
		 * The space between the outermost keys and the edges of the background
		 */
		public function get bkgPadding():Number { return _bkgPadding; }
		public function set bkgPadding(b:Number):void
		{
			_bkgPadding = b;
		}
		
		/**
		 * The width of the ellipse used to draw the rounded background corners
		 */
		public function get cornerWidth():Number { return _cornerWidth; }
		public function set cornerWidth(w:Number):void {
			_cornerWidth = w;
		}		
		
		/**
		 * The height of the ellipse used to draw the rounded background corners
		 */		
		public function get cornerHeight():Number { return _cornerHeight; }
		public function set cornerHeight(h:Number):void {
			_cornerHeight = h;
		}				
		
		/**
		 * The spacing between the keys
		 */
		public function get keySpacing():Number { return _keySpacing; }
		public function set keySpacing(ks:Number):void
		{
			_keySpacing = ks;
		}
		
		/**
		 * If the keys are not customized through CML (the CML instantiation does not contain a
		 * container of KeyElements), the default keys are generated.
		 */
		private function generateKeys():void
		{
			if (searchChildren(Key))  
				generateCMLKeys();
			else
				generateDefKeys();
		}
		
		/**
		 * Key distribution function
		 */
		private function setLayout():void
		{	
			bkgWidth = bkgPadding;
			bkgHeight = bkgPadding;
			addBackground();
			addKeys();
		}
		
		/**
		 * Adds the background to the stage. If not provided, the default is added.
		 */
		private function addBackground():void
		{
			if (!background)
			{
				background = new Sprite();
				background.graphics.beginFill(0xCCCCCC, 1);
				background.graphics.drawRoundRect(0, 0, bkgPadding, bkgPadding, cornerWidth, cornerHeight);
				background.graphics.endFill();				
			}

			addChild(background);
		}
		
		/**
		 * Adds the keys to the background according to the specified spacing and dynamically adjusts the
		 * background to the key dimensions
		 */
		private function addKeys():void
		{
			var rowWidth:Number;
			var maxKeyHeight:Number;
			
			for each(var row:Array in keys)
			{
				rowWidth = bkgPadding;
				maxKeyHeight = 0;
				
				for each(var key:Key in row)
				{				
					key.y = bkgHeight;
					key.x = rowWidth;										
					rowWidth += key.width + keySpacing;
					maxKeyHeight = maxKeyHeight > key.height ? maxKeyHeight : key.height;					
					addChild(key);
				}
				
				bkgHeight += maxKeyHeight + keySpacing;
				bkgWidth = bkgWidth > rowWidth ? bkgWidth : rowWidth;						
			}
			background.width = bkgWidth + bkgPadding - keySpacing;
			background.height = bkgHeight + bkgPadding - keySpacing;
		}
		
		/**
		 * Generate deafault keys
		 */
		private function generateDefKeys():void
		{				
			var rowNum:int = 1;
			var rowArray:Array = new Array();
			
			for each(var row:Array in getDefKeySpecs())
			{				
				for each(var specs:String in row)
					rowArray.push(getKeyElement(specs));
					
				keys[rowNum] = rowArray;	
				rowArray = new Array();
				rowNum++;					
			}
		}
		
		/**
		 * Generate custom keys from CML
		 */
		private function generateCMLKeys():void
		{
			var rownNum:int = 1;
			var rowArray:Array = new Array();
			for (var i:int = 0; i < childList.length; i++)
			{
				var container:* = childList.getIndex(i);
				if (!(container is Container)) continue;

				for (var j:int = 0; j < container.childList.length; j++)
				{
					var key:* = container.childList.getIndex(j);
					if (!(key is Key)) continue;
					key.setup();
					rowArray.push(key);
				}
					
				keys[rownNum] = rowArray;
				rowArray = new Array();
				rownNum++;
			}
		}
		
		/**
		 * Parses the provided key specs to generate a default key element
		 * @param	specs
		 * @return
		 */
		private function getKeyElement(specs:String):Key
		{
			var key:Key = new Key();
			var wsRegEx:RegExp = / /gi;
			var specsArray:Array = specs.split(wsRegEx);
			
			key.text = specsArray[0] != "--" ? specsArray[0] : null;
			key.shiftText = specsArray[1] != "--" ? specsArray[1] : null;
			key.width = specsArray[2] != "--" ? Number(specsArray[2]) : null;
			key.keyCode = specsArray[3] != "--" ? Number(specsArray[3]) : null;
			key.init();
			
			return key;
		}
		
		/**
		 * Populates the default key specs. The rows are represented by Arrays and the key specs are "white space" delimited
		 * Strings. The spec order is text, shiftText, width, and key code. Double dashes "--" represent null values. 
		 * @return  a dictionary containing the default key specs
		 */
		private function getDefKeySpecs():Dictionary
		{
			var defKeySpecs:Dictionary = new Dictionary();
			
			var row1:Array = new Array();
			row1.push("` ~ -- --");
			row1.push("1 ! -- --");
			row1.push("2 @ -- --");
			row1.push("3 # -- --");
			row1.push("4 $ -- --");
			row1.push("5 % -- --");
			row1.push("6 ^ -- --");
			row1.push("7 & -- --");
			row1.push("8 * -- --");
			row1.push("9 ( -- --");
			row1.push("0 ) -- --");
			row1.push("- _ -- --");
			row1.push("= + -- --");
			row1.push("Backspace -- 110 --");     //Since "BACKSPACE" is a flash.ui.Keyboard constant, the associated keyCode/action is automatically resolved
			defKeySpecs[1] = row1;
			
			var row2:Array = new Array();
			row2.push("Tab -- 80 --");    
			row2.push("q -- -- --");
			row2.push("w -- -- --");
			row2.push("e -- -- --");
			row2.push("r -- -- --");
			row2.push("t -- -- --");
			row2.push("y -- -- --");
			row2.push("u -- -- --");
			row2.push("i -- -- --");
			row2.push("o -- -- --");
			row2.push("p -- -- --");
			row2.push("[ { -- --");
			row2.push("] } -- --");
			row2.push("\\ | 75 --");
			defKeySpecs[2] = row2;
			
			var row3:Array = new Array();
			row3.push("CapsLock -- 98 20");         //Since CAPSLOCK is not recognized by flash.ui.Keyboard, the keyCode must be specified to associate an action 
			row3.push("a -- -- --");
			row3.push("s -- -- --");
			row3.push("d -- -- --");
			row3.push("f -- -- --");
			row3.push("g -- -- --");
			row3.push("h -- -- --");
			row3.push("j -- -- --");
			row3.push("k -- -- --");
			row3.push("l -- -- --");
			row3.push("; : -- --");
			row3.push("' \" -- --");
			row3.push("Enter -- 112 --");
			defKeySpecs[3] = row3;
			
			var row4:Array = new Array();
			row4.push("Shift -- 125 --");
			row4.push("z -- -- --");
			row4.push("x -- -- --");
			row4.push("c -- -- --");
			row4.push("v -- -- --");
			row4.push("b -- -- --");
			row4.push("n -- -- --");
			row4.push("m -- -- --");
			row4.push(", < -- --");
			row4.push(". > -- --");
			row4.push("/ ? -- --");
			row4.push("Shift -- 140 --");
			defKeySpecs[4] = row4;
			
			var row5:Array = new Array();
			row5.push("-- -- 75 --");
			row5.push("-- -- 60 --");
			row5.push("-- -- 60 --");
			row5.push("-- -- 375 32");     //Since the space bar has no text, the keyCode must be specified to associate an action
			row5.push("-- -- 60 --");
			row5.push("-- -- 60 --");
			row5.push("-- -- 75 --");
			defKeySpecs[5] = row5;	
			
			return defKeySpecs;			
		}		
				
		//*****************KEY ACTIONS**********************************//
		
		/**
		 * Manages the key events dispatched by the key elements. If an output is not provided, the designated output is
		 * the most recently focused text field. 
		 * @param	event
		 */
		private function keyHandler(event:KeyboardEvent):void
		{	
			//key event was not dispatched from Key 
			if (event.keyLocation != 10) return;								
			
			//operations don't require a text field
			var charCode:Number = event.charCode;
			var keyCode:Number = event.keyCode;
			applyShift(keyCode);	
			applyCapsLock(keyCode);
			if(keyCode == 27) stage.displayState = StageDisplayState.NORMAL;  //ESCAPE KEY
			
			//designated text field or focused text field
			if (!output)
			{
				var focusedObj:* = stage.focus;
				if (focusedObj is TextField)
					focusedObj = focusedObj.parent;
				if ((focusedObj is Text) && !(focusedObj.parent is Key))
					currentTF = focusedObj;
			}
			else
				currentTF = output;
			
			//if text field not provided, don't process the key events
			if (!currentTF) return;

			if (event.target.outputText)
				addCharacter(event.target.text);
			//prioritize char codes, if none evaluate key codes
			else if (charCode != 0)
				addCharacter(String.fromCharCode(charCode));
			else
			{
				switch(keyCode)
				{
					case 8: //BACKSPACE
						if (currentTF.selectedText)
							deleteText();
						else
							backspace();
						break;
					case 13: //ENTER
						if (currentTF.multiline) addCharacter("\n");
						break;
					case 37: //LEFT ARROW
						caret--;
						currentTF.setSelection(caret, caret);
						break;
					case 39: //RIGHT ARROW
						caret++;
						currentTF.setSelection(caret, caret);
						break;
					case 38: //UP ARROW
						upArrow();
						break;
					case 40: //DOWN ARROW
						downArrow();
						break;
					case 46: //DELETE
						deleteText();
						break;
					default:
						addCharacter(String.fromCharCode(keyCode));
				}				
			}
				
			stage.focus = currentTF; //restore focus
			currentTF.setSelection(caret, caret); //reset caret
		}				
		
		/**
		 * Inserts a character into the current text field at the caret index
		 * @param	char
		 */
		private function addCharacter(char:String):void
		{
			var temp:String = currentTF.text;
			caret = currentTF.caretIndex;

			currentTF.text = temp.substring(0, caret) + char + temp.substring(caret, currentTF.textField.length);
			caret += char.length;			
		}	
		
		/**
		 * Removes the selected text from the current text field
		 */
		private function deleteText():void
		{
			var cText:String = currentTF.text;
			caret = currentTF.selectionBeginIndex;
			currentTF.text = cText.substring(0, caret) + cText.substring(currentTF.selectionEndIndex, cText.length);
		}
		
		/**
		 * Moves the caret back a space and deletes the character at that index
		 */
		private function backspace():void
		{
			var cText:String = currentTF.text;
			caret = currentTF.caretIndex;
			currentTF.text = cText.substring(0, caret - 1) + cText.substring(caret, cText.length);
			caret--;				
		}
		
		/**
		 * Moves the caret up to the previous line
		 * TODO requires the parsing of the text to determine previous lines and storing the
		 * index of the caret relative to the line and attempting to place the caret in the
		 * same position in the above line
		 */
		private function upArrow():void
		{			
			//caret = currentTF.caretIndex;
			//var text:String = currentTF.text;
			//var lastNL:int = text.lastIndexOf("\r");
			//var upCaret:int = text.substring(lastNL, caret).length;
			//caret = text.substring(0, lastNL).lastIndexOf("\r") + upCaret;
		}
		
		/**
		 * Moves the caret down to the next line
		 * TODO reverse the up arrow algorithm
		 */
		private function downArrow():void
		{
			
		}
		
		/**
		 * Applies the caps lock action to each key
		 */
		private function applyCapsLock(code:Number):void
		{
			if (code != 20)
				return;
				
			for each(var row:Array in keys)
			{
				for each(var key:Key in row)
					key.capsOn = !key.capsOn;
			}
		}
		
		/**
		 * Applies the shift action to each key
		 * @param	key
		 */
		private function applyShift(key:Number):void
		{		
			if (!shift && key == 16)
			{
				shift = true;
				for each(var row:Array in keys)
				{
					for each(var keyEl:Key in row)
						keyEl.shiftOn = shift;
				}
			}
			else if (shift)
			{
				shift = false;
				for each(var rw:Array in keys)
				{
					for each(var ke:Key in rw)
						ke.shiftOn = shift;
				}
			}
		}
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_output = null;
			_background = null;
			keys = null;
			currentTF = null;
		}
	}

}