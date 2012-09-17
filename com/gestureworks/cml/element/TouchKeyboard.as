package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.element.ButtonElement;
	import com.gestureworks.cml.element.Container;
	import com.gestureworks.cml.element.GraphicElement;
	import com.gestureworks.cml.element.KeyElement;
	import com.gestureworks.cml.element.TextElement;
	import com.gestureworks.core.GestureWorks;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * @author Shaun
	 */
	public class TouchKeyboard extends Container
	{	
		private var _notepad:TextField;
		private var _bkgPadding:Number;		
		private var _keySpacing:Number;
		private var _background:Sprite;
		
		private var keys:Dictionary;
		private var shift:Boolean = false;
		private var bkgWidth:Number;
		private var bkgHeight:Number;
		private var currentTF:TextField;
		
		public function TouchKeyboard() 
		{
			super();
			keys = new Dictionary();
			keySpacing = 10;
			bkgPadding = 50;
			addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		public function init(event:Event = null): void
		{	
			generateKeys();
			setLayout();
		}
		
		override public function displayComplete():void
		{
			init();
		}		
		
		public function get background():Sprite { return _background; }
		public function set background(b:Sprite):void
		{
			_background = b;
		}
		
		public function get notepad():TextField { return _notepad; }
		public function set notepad(n:TextField):void
		{
			_notepad = n;
		}
			
		public function get bkgPadding():Number { return _bkgPadding; }
		public function set bkgPadding(b:Number):void
		{
			_bkgPadding = b;
		}
		
		public function get keySpacing():Number { return _keySpacing; }
		public function set keySpacing(ks:Number):void
		{
			_keySpacing = ks;
		}
		
		private function generateKeys():void
		{
			if (childList.length > 0)
				generateCMLKeys();
			else
				generateDefKeys();
		}
		
		private function setLayout():void
		{	
			bkgWidth = bkgPadding;
			bkgHeight = bkgPadding;
			addBackground();
			addKeys();
		}
		
		private function addBackground():void
		{
			if (!background)
			{
				background = new Sprite();
				background.graphics.beginFill(0xCCCCCC, 1);
				background.graphics.drawRoundRect(0, 0, bkgPadding, bkgPadding,2, 5);
				background.graphics.endFill();				
			}
			addChild(background);
		}
		
		private function addKeys():void
		{
			var rowWidth:Number;
			var maxKeyHeight:Number;
			
			for each(var row:Array in keys)
			{
				rowWidth = bkgPadding;
				maxKeyHeight = 0;
				
				for each(var key:KeyElement in row)
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
			
			background.width = bkgWidth + bkgPadding;
			background.height = bkgHeight + bkgPadding;
		}
		
		private function keyHandler(event:KeyboardEvent):void
		{	
			if (!notepad)
			{
				var focusedObj:* = stage.focus;
				if ((focusedObj is TextField) && !(focusedObj.parent is KeyElement))
					currentTF = focusedObj;
			}
			else
				currentTF = notepad;
						
			if (event.keyLocation != 10 || !currentTF) return;								
			var charCode:Number = event.charCode;
			var keyCode:Number = event.keyCode;
			applyShift(keyCode);
			
			if (charCode != 0)
				currentTF.appendText(String.fromCharCode(charCode));
			else
			{
				switch(keyCode)
				{
					case 20:
						applyCapsLock();
						break;
					case 13:
						if(currentTF.multiline) currentTF.appendText("\n");
						currentTF.appendText(String.fromCharCode(keyCode));
						break;
					case 8:
						var cText:String = currentTF.text;
						currentTF.text = cText.substring(0, cText.length - 1);
						break;
					default:
						currentTF.appendText(String.fromCharCode(keyCode));						
				}				
			}
			
			stage.focus = currentTF;
		}
		
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
		
		private function generateCMLKeys():void
		{
			var rownNum:int = 1;
			var rowArray:Array = new Array();
			for (var i:int = 0; i < childList.length; i++)
			{
				var r:Container = Container(childList.getIndex(i));
				for (var j:int = 0; j < r.childList.length; j++)
				{
					var ke:KeyElement = KeyElement(r.childList.getIndex(j));
					ke.initUI();
					rowArray.push(ke);
				}
					
				keys[rownNum] = rowArray;
				rowArray = new Array();
				rownNum++;
			}
		}
		
		private function getKeyElement(specs:String):KeyElement
		{
			var key:KeyElement = new KeyElement();
			var wsRegEx:RegExp = / /gi;
			var specsArray:Array = specs.split(wsRegEx);
			
			key.text = specsArray[0] != "--" ? specsArray[0] : null;
			key.shiftText = specsArray[1] != "--" ? specsArray[1] : null;
			key.width = specsArray[2] != "--" ? Number(specsArray[2]) : null;
			key.keyCode = specsArray[3] != "--" ? Number(specsArray[3]) : null;
			key.initUI();
			
			return key;
		}
		
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
			row1.push("Backspace -- 110 --");
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
			row3.push("Caps_Lock -- 98 --");
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
			row5.push("-- -- 375 32");
			row5.push("-- -- 60 --");
			row5.push("-- -- 60 --");
			row5.push("-- -- 75 --");
			defKeySpecs[5] = row5;	
			
			return defKeySpecs;			
		}
		
		private function applyCapsLock():void
		{
			for each(var row:Array in keys)
			{
				for each(var key:KeyElement in row)
					key.capsOn = !key.capsOn;
			}
		}
		
		private function applyShift(key:Number):void
		{
			var shiftKey:Boolean = key == 16;			
			
			if (!shift && shiftKey)
			{
				shift = true;
				for each(var row:Array in keys)
				{
					for each(var keyEl:KeyElement in row)
						keyEl.shiftOn = shift;
				}
			}
			else if (shift)
			{
				shift = false;
				for each(var rw:Array in keys)
				{
					for each(var ke:KeyElement in rw)
						ke.shiftOn = shift;
				}
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			_notepad = null;
			_background = null;
			keys = null;
			currentTF = null;
			removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
	}

}