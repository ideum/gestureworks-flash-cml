package  com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.ButtonElement;
	import com.gestureworks.cml.element.GraphicElement;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.filters.DropShadowFilter;
	import flash.ui.Keyboard;

	/**
	 * The key element simulates a key on a keyboard by dispatching a keyboard event, containing the assigned character and key unicode values, when
	 * touched.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
		override protected function gestureworksInit():void
 		{
			trace("gestureWorksInit()");
			keyElementTestAS();
		}
		
		private function keyElementTestAS():void
		{
			var ke:KeyElement = new KeyElement();
			ke.text = "a";
			ke.init();
			addChild(ke);
		}
	 *  
	 * </codeblock>
	 * 
	 * @author Shaun
	 */
	public class KeyElement extends ButtonElement
	{
		private var _capsOn:Boolean = false;
		private var _shiftOn:Boolean = false;
		private var _keyCode:uint;
		private var _charCode:uint;
		private var _shiftCharCode:uint;
		
		private var _icon:*;
		private var _text:String;
		private var _shiftText:String;
		
		private var _initTextColor:uint;
		private var _downTextColor:uint;
		private var _upTextColor:uint;
		private var _overTextColor:uint;
		private var _outTextColor:uint;
		
		private var background:*;
		private var keyText:TextElement;
		private var dropShadow:DropShadowFilter = new DropShadowFilter();
		private var charCodeRef:uint;
		
		
		/**
		 * Constructor
		 */
		public function KeyElement() 
		{
			super();
		}

		/**
		 * Initialization function
		 */
		override public function init():void 
		{
			setBackground();
			setIcon();
			setText();
			setCodes();

			if (!dispatch)
				dispatch = "down:" + text;
			
			super.init();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{ 
			if(!parent || !(parent is TouchKeyboard))
				init();
		}
				
		/**
		 * A flag indicating the "capitalized" state of the text. Only valid
		 * for letter characters.
		 */
		public function get capsOn():Boolean { return _capsOn; }
		public function set capsOn(c:Boolean):void
		{
			_capsOn = c;
			if (!isLetterKey())
				return;
			
			if (capsOn)
			{
				keyText.text = text.toUpperCase();
				charCodeRef = keyText.text.charCodeAt(0);
			}
			else
			{
				keyText.text = text;
				charCodeRef = keyText.text.charCodeAt(0);
			}
		}
		
		/**
		 * A flag indicating the shift state of the text. Any key can have
		 * a text value for a shift state and one for the initial state.  
		 */
		public function get shiftOn():Boolean { return _shiftOn; }
		public function set shiftOn(s:Boolean):void
		{
			_shiftOn = s;			
			if (shiftOn)
			{
				keyText.text = shiftText;
				charCodeRef = shiftCharCode;
			}
			else 
			{
				keyText.text = text;
				charCodeRef = charCode;
			}
		}		
		
		/**
		 * The key code (unicode) value of the key pressed
		 */
		public function get keyCode():uint { return _keyCode; }
		public function set keyCode(a:uint):void
		{
			_keyCode = a;
		}
		
		/**
		 * The character code (unicode) value of the key pressed
		 */
		public function get charCode():uint { return _charCode; }
		public function set charCode(c:uint):void
		{
			_charCode = c;
		}
		
		/**
		 * The character code (unicode) value of the key pressed while in a shift state
		 */
		public function get shiftCharCode():uint { return _shiftCharCode; }
		public function set shiftCharCode(c:uint):void
		{
			_shiftCharCode = c;
		}
		
		/**
		 * The text displayed on the key while in a shift state
		 */
		public function get shiftText():String { return _shiftText; }
		public function set shiftText(sa:String):void
		{
			_shiftText = sa;
		}
		
		/**
		 * The text displayed on the key
		 */
		public function get text():String { return _text; }
		public function set text(t:String):void
		{
			_text = t;
		}
		
		/**
		 * The inital text color
		 */
		public function get initTextColor():uint { return _initTextColor; }
		public function set initTextColor(t:uint):void
		{
			_initTextColor = t;
		}
		
		/**
		 * The color of the text when touched down
		 */
		public function get downTextColor():uint { return _downTextColor; }
		public function set downTextColor(t:uint):void
		{
			_downTextColor = t;
		}
		
		/**
		 * The text color when touched up
		 */
		public function get upTextColor():uint { return _upTextColor; }
		public function set upTextColor(t:uint):void
		{
			_upTextColor = t;
		}		
		
		/**
		 * The text color when touched over
		 */
		public function get overTextColor():uint { return _overTextColor; }
		public function set overTextColor(t:uint):void
		{
			_overTextColor = t;
		}		
		
		/**
		 * The text color when touched out
		 */
		public function get outTextColor():uint { return _outTextColor };
		public function set outTextColor(t:uint):void
		{
			_outTextColor = t;
		}
		
		/**
		 * The icon displayed on the key element
		 */
		public function get icon():* { return _icon };
		public function set icon(i:*):void
		{
			if(!(i is DisplayObject))
				_icon = childList.getKey(String(i));	
			else
				_icon = i;
		}
		
		/**
		 * Set the background graphics for the key in each state. If a graphic is not provided for the initial state, 
		 * a default is generated. Each remaining state, without a provided graphic, is a copy or slight variation of 
		 * the initial graphic.
		 */
		private function setBackground():void
		{
			if (initial)
			{
				background = childList.getKey(initial);
				width = background.width;
				height = background.height;				
			}
			else 
			{
				background = new GraphicElement();											
				background.shape = "roundRectangle";
				background.cornerWidth = 12;
				background.width = width && width > 0? width : 45;
				background.height = height && height > 0 ? height : 45;	
				width = background.width;
				height = background.height;
				background.fill = "gradient";
				background.gradientColors = "0xA0A0A0,0x505050";
				background.gradientWidth = background.width;
				background.gradientHeight = background.height;
				background.gradientRotation = 90;
				background.lineColor = 0x787878;
				background.lineStroke = 3;	
				
				dropShadow.color = 0x000000;
				dropShadow.blurX = 5;
				dropShadow.blurY = 5;
				dropShadow.angle = 45;
				dropShadow.alpha = 0.4;
				dropShadow.distance = 5;
				background.filters = new Array(dropShadow);
				
				initial = background;
			}			
			if (!hit)
			{
				var hitBkg:* = CloneUtils.clone(background);
				hitBkg.alpha = 0;				
				hit = hitBkg;
			}
			if (!down)
			{
				var downBkg:* = CloneUtils.clone(background);
				downBkg.alpha = .5;
				down = downBkg;
			}
			if (!up)
			{
				up = CloneUtils.clone(background);				
			}
			if (!over)
			{		
				var overBkg:* = CloneUtils.clone(background);								
				overBkg.alpha = .5;				
				over = overBkg;
			}
			if (!out)
			{
				out = CloneUtils.clone(background);
			}
		}
		
		/**
		 * Set the text element displayed on the key. Allows the specification of a text or <code>TextElement</code> id through CML. If the 
		 * text value references a <code>TextElement</code>, the object is retrieved and displayed on the key. If it does not, a default 
		 * <code>TextElement</code> is generated and the text value becomes the text of the new element and the element is displayed on the key. 
		 */
		private function setText():void
		{
			//override text with character code
			if (charCode)
				text = String.fromCharCode(charCode);
			if (!text)
				text = "";
				
			if (childList.hasKey(text))
			{
				keyText = childList.getKey(text) as TextElement;
				keyText.textColor = initTextColor ? initTextColor : keyText.textColor;
				text = keyText.text;
				addChild(keyText);
			}
			else
			{
				keyText = new TextElement();
				keyText.text = text;
				keyText.height = background.height;
				keyText.width = background.width;
				keyText.textAlign = "center";
				keyText.verticalAlign = true;
				keyText.selectable = false;
				keyText.fontSize = 16;
				keyText.font = "HelveticaFont";
				keyText.textColor = initTextColor ? initTextColor : 0xFFFFFF;						
				addChild(keyText);
			}
			
			//default initital color
			if (!initTextColor)
				initTextColor = keyText.textColor;
			//override text with character code
			if (shiftCharCode)
				shiftText = String.fromCharCode(shiftCharCode);
			//default shift value for letter characters		
			if(!shiftText)
				shiftText = isLowerCaseLetter() ? text.toUpperCase() : isUpperCaseLetter() ? text.toLowerCase() : text; 
		}
		
		/**
		 * Sets the default key and character codes, if not provided, for both initial and shift states. 
		 */
		private function setCodes():void
		{		
			if (!keyCode)
				keyCode = text ? Keyboard[text.toUpperCase()] : 0;
			if (!charCode)
				charCode = text ? text.length == 1 ? text.charCodeAt(0) : 0 : 0;	
			if (!shiftCharCode)
				shiftCharCode = shiftText ? text.length == 1 ? shiftText.charCodeAt(0): 0 : 0;
				
			charCodeRef = charCode;
		}
		
		/**
		 * Sets the key icon if provided
		 */
		private function setIcon():void
		{
			if (icon)			
				addChild(icon);
		}
		
		/**
		 * The down event handler. Dispatches a KEY_DOWN event containing the character key codes. The key location has an arbitrary 
		 * value (10) to identify its origin.
		 * @param	event  event triggered when touched/clicked
		 */
		override protected function onDown(event:*):void 
		{	
			super.onDown(event);						
			keyText.textColor = downTextColor ? downTextColor : initTextColor; 			    
			dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, charCodeRef, keyCode, 10));
		}		
		
		/**
		 * The up event handler.
		 * @param	event  event triggered when a key is released from a down event
		 */
		override protected function onUp(event:*):void 
		{
			super.onUp(event);
			keyText.textColor = upTextColor ? upTextColor : initTextColor;
		}

		/**
		 * The over event handler.
		 * @param	event  event triggered when a key is intersected from outside
		 */
		override protected function onOver(event:*):void 
		{
			super.onOver(event);
			keyText.textColor = overTextColor ? overTextColor : initTextColor;
		}
		
		/**
		 * The out event handler.
		 * @param	event  event triggered when a key is released from an over event
		 */
		override protected function onOut(event:*):void 
		{
			super.onOut(event);
			keyText.textColor = outTextColor ? outTextColor : initTextColor;		
		}	
		
		/**
		 * Determines if the text is a letter
		 * @return
		 */
		private function isLetterKey():Boolean 
		{
			return isLowerCaseLetter() || isUpperCaseLetter();
		}
		
		/**
		 * Determines if the text is a lower case letter
		 * @return
		 */
		private function isLowerCaseLetter():Boolean
		{
			return text.length == 1 && (text >= "a" && text <= "z");
		}
		
		/**
		 * Determines if the text is an upper case letter
		 * @return
		 */
		private function isUpperCaseLetter():Boolean
		{
			return text.length == 1 && (text >= "A" && text <= "Z");
		}
		
		override public function dispose():void
		{
			super.dispose();
			background = null;
			keyText = null;
			icon = null;
			dropShadow = null;
		}
	}

}