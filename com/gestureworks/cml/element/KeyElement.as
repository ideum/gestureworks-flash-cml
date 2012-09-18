package  com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.ButtonElement;
	import com.gestureworks.cml.element.GraphicElement;
	import com.gestureworks.cml.utils.CloneUtils;
	import com.gestureworks.cml.utils.NumberUtils;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.text.DefaultFonts;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.DropShadowFilter;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	/**
	 * The key element simulates a key on a keyboard by dispatching a keyboard event, containing the assigned character and key unicode values, when
	 * touched.
	 * @author Shaun
	 */
	public class KeyElement extends ButtonElement
	{
		private var _capsOn:Boolean = false;
		private var _shiftOn:Boolean = false;
		private var _keyCode:uint;
		private var _charCode:uint;
		private var _shiftKeyCode:uint;
		private var _shiftCharCode:uint;
		
		private var _text:String;
		private var _shiftText:String;
		
		private var _initTextColor:uint;
		private var _downTextColor:uint;
		private var _upTextColor:uint;
		private var _overTextColor:uint;
		private var _outTextColor:uint;
		
		private var background:GraphicElement;
		private var keyText:TextElement;
		private var dropShadow:DropShadowFilter = new DropShadowFilter();
		private var keyCodeRef:uint;
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
		
		public function initUI():void
		{
			setBackground();
			setText();
			setCodes();

			if (!dispatch)
				dispatch = "down:" + text;
			
			super.displayComplete();
		}
		
		/**
		 * CML initialization
		 */
		override public function displayComplete():void
		{
			initUI();
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
				keyCodeRef = shiftKeyCode;
				charCodeRef = shiftCharCode;
			}
			else 
			{
				keyText.text = text;
				keyCodeRef = keyCode;
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
		 * The shift key code (unicode) value of the key pressed while in a shift state
		 */
		public function get shiftKeyCode():uint { return _shiftKeyCode; }
		public function set shiftKeyCode(c:uint):void
		{
			_shiftKeyCode = c;
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
		 * Set the background graphics for the key in each state. If a graphic is not provided for the initial state, 
		 * a default is generated. Each remaining state, without a provided graphic, is a copy or slight variation of 
		 * the initial graphic.
		 */
		private function setBackground():void
		{
			if (init)
			{
				background = childList.getKey(init) as GraphicElement;
			}
			else 
			{
				init = "initKey";
				background = new GraphicElement();											
				background.id = init;
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
				
				addStateElements(background);
			}			
			if (!hit)
			{
				hit = "hitKey";
				var hitBkg:GraphicElement = CloneUtils.clone(background) as GraphicElement;
				hitBkg.id = hit;
				hitBkg.alpha = 0;				
				addStateElements(hitBkg);
			}
			if (!down)
			{
				down = "downKey";
				var downBkg:GraphicElement = CloneUtils.clone(background) as GraphicElement;
				downBkg.id = down;
				downBkg.alpha = .5;
				addStateElements(downBkg);
			}
			if (!up)
			{
				up = "upKey";
				var upBkg:GraphicElement = CloneUtils.clone(background) as GraphicElement;
				upBkg.id = up;
				addStateElements(upBkg);
			}
			if (!over)
			{		
				over = "overKey";
				var overBkg:GraphicElement = CloneUtils.clone(background) as GraphicElement;								
				overBkg.id = over;
				overBkg.alpha = .5;				
				addStateElements(overBkg);
			}
			if (!out)
			{
				out = "outKey";
				var outBkg:GraphicElement = CloneUtils.clone(background) as GraphicElement;
				outBkg.id = out;
				addStateElements(outBkg);
			}
		}
		
		/**
		 * Set the text element displayed on the key. Allows the specification of a text or <code>TextElement</code> id through CML. If the 
		 * text value references a <code>TextElement</code>, the object is retrieved and displayed on the key. If it does not, a default 
		 * <code>TextElement</code> is generated and the text value becomes the text of the new element and the element is displayed on the key. 
		 */
		private function setText():void
		{
			if (!text)
				text = "";
				
			if (childList.hasKey(text))
			{
				keyText = childList.getKey(text) as TextElement;
				keyText.textColor = initTextColor ? initTextColor : keyText.textColor;
				text = keyText.text;
				addStateElements(keyText);
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
				addStateElements(keyText);
			}
			
			//default init color
			if (!initTextColor)
				initTextColor = keyText.textColor;
			//default shift value for letter characters		
			if (!shiftText)
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
			if (!shiftKeyCode)
				shiftKeyCode = shiftText ? Keyboard[shiftText.toUpperCase()] : 0;
			if (!shiftCharCode)
				shiftCharCode = shiftText ? text.length == 1 ? shiftText.charCodeAt(0): 0 : 0;		
				
			keyCodeRef = keyCode;
			charCodeRef = charCode;
		}
		
		/**
		 * Adds the elements to both the display list and the cml childList to allow the <code>ButtonElement</code> to
		 * handle the graphic transitions
		 * @param	g
		 */
		private function addStateElements(g:*):void
		{
			childToList(g.id, g);
			addChild(g);
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
			dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, charCodeRef, keyCodeRef, 10));
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
			dropShadow = null;
		}
	}

}