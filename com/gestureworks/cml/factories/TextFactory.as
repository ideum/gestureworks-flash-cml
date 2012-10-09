package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.interfaces.IElement;
	import com.gestureworks.cml.interfaces.ICSS;
	import com.gestureworks.cml.core.CMLParser;
	
	import flash.text.*;
	import flash.display.BlendMode;
	import flash.utils.Dictionary;
	import flash.text.TextFieldType;
	import com.gestureworks.cml.managers.CSSManager;
	
	/**
	 * TextFactory class is used to create text display and input for display objects.
	 * The base class for text element
	 * 
	 * @author ..
	 */
	public class TextFactory extends TextField implements IElement, ICSS
	{
		/**
		 * creates textformat variable
		 */
		public var textFormat:TextFormat = new TextFormat();
		
		/**
		 * constructor
		 */
		public function TextFactory() 
		{
			super();
			
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);
			
			textFormat.font = font;
			textFormat.color = textFormatColor;
			textFormat.size = textSize;
			antiAliasType = AntiAliasType.ADVANCED;
			blendMode = BlendMode.LAYER;
		}
		
		
		/////////////////////////////////
		// IObject
		////////////////////////////////
		
		/**
		 * dispose method to nullify attributes
		 */
		public function dispose():void
		{
			textFormat = null;
			propertyStates = null;
		}
		
		/**
		 * array for property states
		 */
		public var propertyStates:Array;
		
		
		private var _id:String
		/**
		 * sets the id
		 */
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		private var _cmlIndex:int;
		/**
		 * sets the cml index
		 */
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}
		
		/**
		 * parses the cml file
		 * @param	cml
		 * @return
		 */
		public function parseCML(cml:XMLList):XMLList
		{
			// if TextElement has child, then interpret as htmlText
			if (String(cml).length > 0) {
				multiline = true;
				super.htmlText = String(cml.children());
				cml = new XMLList;
			}
			return CMLParser.instance.parseCML(this, cml);
		}
		
		/**
		 * post parse method
		 * @param	cml
		 */
		public function postparseCML(cml:XMLList):void {}
		
		/**
		 *update properties 
		 * @param	state
		 */
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}	
		
		
		/////////////////////////////////
		// ICSS
		////////////////////////////////		
		
		private var _class_:String;
			/**
		 * Object's css class; 
		 */		
		public function get class_():String { return _class_; }
		public function set class_(value:String):void 
		{ 
			_class_ = value; 
		}	
		
	
		
		/////////////////////////////////
		// TEXT 
		////////////////////////////////		
		
		private var _htmlText:String;
		/**
		 * contains htnl representation of text field contents
		 */
		override public function get htmlText():String { return super.htmlText; }
		override public function set htmlText(value:String):void
		{
			//trace("html", value);
			super.htmlText = value;			
			verticalAlign = _verticalAlign;
		}
		
		private var _type:String = "input";
		/**
		 * type of text field
		 * @default= input;
		 */
		override public function get type():String { return _type; }
		override public function set type(value:String):void
		{
			
			_type = value;
			
			if (_type == "input")
				super.type = TextFieldType.INPUT;
			else
				super.type = TextFieldType.DYNAMIC;
		}
		
		private var _text:String;
		/**
		 * A string that is the current text in the text field.
		 */
		override public function get text():String { return super.text; }
		override public function set text(value:String):void
		{
			super.text = value;			
			verticalAlign = _verticalAlign;
		}
		
		private var setY:Number = 0;
		private var _y:Number = 0;
		/**
		 * sets y position of text
		 */
		override public function get y():Number { return super.y; }
		override public function set y(value:Number):void
		{
			super.y = value;
			setY = value;
		}
		
		private var _autoSize:String;
		/**
		 * Controls automatic sizing and alignment of text fields.
		 */
		override public function get autoSize():String{return _autoSize;}
		override public function set autoSize(value:String):void
		{
			_autoSize = value;
						
			switch (value) 
            {
                case "center":
					super.autoSize = TextFieldAutoSize.CENTER;
                   // updateTextFormat();
                    break;
                case "left":
					super.autoSize = TextFieldAutoSize.LEFT;
                   // updateTextFormat();
                    break;
                case "right":
                    super.autoSize = TextFieldAutoSize.RIGHT;
                   // updateTextFormat();
                    break;
                case "none":
                    super.autoSize = TextFieldAutoSize.NONE;
                   // updateTextFormat();
                    break;
            }

		}
		
		private var _color:int;
		/**
		 * sets the color of the text in a text field
		 */
		public function get color():int { return _color; }
		public function set color(value:int):void 
		{ 
			_textFormatColor = value;
			textFormat.color = textFormatColor;
			updateTextFormat();
		}	
		
		private var _textFormatColor:uint = 0x000000;
		/**
		 * sets the text format color
		 * @default = 0x000000;
		 */
		public function get textFormatColor():uint{return _textFormatColor;}
		public function set textFormatColor(value:uint):void
		{
			_textFormatColor = value;
			textFormat.color = textFormatColor;
			updateTextFormat();
		}
		
		private var _verticalAlign:Boolean = false;
		/**
		 * sets the vertical allignment of text field
		 * @default =false;
		 */
		public function get verticalAlign():Boolean{return _verticalAlign;}
		public function set verticalAlign(value:Boolean):void 
		{
			_verticalAlign = value;
			
			if (_verticalAlign)
			{
				var sum:Number = 0;
				for (var i:int = 0; i < this.numLines; i++)
				{
					sum += this.getLineMetrics(i).height;
				}
				super.y = setY + (this.height - sum) / 2;
			}	
		}		
		
		private var _textAlign:String;
		/**
		 * sets the allignment of text in text field
		 */
        public function get textAlign():String {return _textAlign}                
        public function set textAlign(value:String):void 
        {
            _textAlign = value;
            switch (value) 
            {
                case "center":
                    textFormat.align = TextFormatAlign.CENTER;
                    updateTextFormat();
                    break;
                case "left":
                    textFormat.align = TextFormatAlign.LEFT;
                    updateTextFormat();
                    break;
                case "right":
                    textFormat.align = TextFormatAlign.RIGHT;
                    updateTextFormat();
                    break;
                case "justify":
                    textFormat.align = TextFormatAlign.JUSTIFY;
                    updateTextFormat();
                    break;
            }
        }
		
		private var _fontSize:Number = 15;
		/**
		 * sets the fontsize of the text
		 * @default=15;
		 */
		public function get fontSize():Number {return _textSize;}
		public function set fontSize(value:Number):void
		{
			_textSize = value;
			textFormat.size = textSize;
			updateTextFormat();			
		}		
		
		private var _textSize:Number = 15;
		/**
		 * sets the text size of the text
		 * @default=15;
		 */
		public function get textSize():Number {return _textSize;}
		public function set textSize(value:Number):void
		{
			_textSize = value;
			textFormat.size = textSize;
			updateTextFormat();
		}
		
		private var _font:String = "OpenSansRegular";
		/**
		 * sets the font of the text
		 * @default="OpenSansRegular";
		 */
		public function get font():String{return _font;}
		public function set font(value:String):void
		{
			_font = value;
			textFormat.font = font;
			updateTextFormat();
		}
		
		private var _leading:Number = 0;
		/**
		 * sets the line spacing of text
		 */
		public function get leading():Number{return _leading;}
		public function set leading(value:Number):void
		{
			_leading = value;
			textFormat.leading = leading;
			updateTextFormat();
		}
		
		private var _letterSpacing:Number = 0;
		/**
		 * sets the number of additional pixels to appear between each character.
		 * @default=0;
		 */
		public function get letterSpacing():Number{return _letterSpacing;}
		public function set letterSpacing(value:Number):void
		{
			_letterSpacing = value;
			textFormat.letterSpacing = letterSpacing;
			updateTextFormat();
		}
		
		private var _underline:Boolean;
		/**
		 * indicates whether text is underlined or not
		 */
		public function get underline():Boolean{return _underline;}
		public function set underline(value:Boolean):void
		{
			_underline = value;
			textFormat.underline = value;
			updateTextFormat();
		}
		
		private var _kerning:Boolean;
		/**
		 * sets the gap between certain character pairs 
		 */
		public function get kerning():Boolean{return _kerning;}
		public function set kerning(value:Boolean):void
		{
			_kerning = value;
			textFormat.kerning = value;
			updateTextFormat();
		}
		
		private var _paddingLeft:Number = 0;
		/**
		 * sets the number of pixels between the left of the Label and the left of the text.
		 */
		public function get paddingLeft():Number{return _paddingLeft;}
		public function set paddingLeft(value:Number):void 
		{
			_paddingLeft = value;
			layoutText();
		}
		
		private var _paddingTop:Number = 0;
		/**
		 * sets the number of pixels between the top of the Label and the top of the text.
		 */
		public function get paddingTop():Number{return _paddingTop;}
		public function set paddingTop(value:Number):void
		{
			_paddingTop = value;
			layoutText();
		}
		
		private var _paddingRight:Number = 0;
		/**
		 * sets the number of pixels between the right of the Label and the right of the text. 
		 */
		public function get paddingRight():Number{return _paddingRight;}
		public function set paddingRight(value:Number):void 
		{
			_paddingRight = value;
			layoutText();
		}
		
		private var _paddingBottom:Number = 0;
		/**
		 * sets the number of pixels between the bottom of the Label and the bottom of the text.
		 */
		public function get paddingBottom():Number{return _paddingBottom;}
		public function set paddingBottom(value:Number):void
		{
			_paddingBottom = value;
			layoutText();
		}
		
		private var _widthPercent:String = "";
		/**
		 * sets the width percent of text
		 */
		public function get widthPercent():String{return _widthPercent;}
		public function set widthPercent(value:String):void
		{
			_widthPercent = value;
			var number:Number = Number(widthPercent.slice(0, widthPercent.indexOf("%")));
			if (parent) width = parent.width * (number / 100);
		}
				
		private var _heightPercent:String = "";
		/**
		 * sets the height percent of text
		 */
		public function get heightPercent():String{	return _heightPercent;}
		public function set heightPercent(value:String):void
		{
			_heightPercent = value;
			var number:Number = Number(heightPercent.slice(0, heightPercent.indexOf("%")));
			if (parent) height = parent.height * (number / 100);
		}
		
		/**
		 * sets height of text text
		 */
		override public function set height(value:Number):void 
		{			
			super.height = value;
			verticalAlign = verticalAlign;
		}
		
		private var _horizontalCenter:Number = 0;
		/**
		 * sets the horizontal center
		 */
		public function get horizontalCenter():Number{return _horizontalCenter;}
		public function set horizontalCenter(value:Number):void
		{
			_horizontalCenter = value;
			if (parent) x = ((parent.width - width) / 2) + value;
		}
		
		private var _verticalCenter:Number = 0;
		/**
		 * sets the vertical center
		 */
		public function get verticalCenter():Number{return _verticalCenter;}
		public function set verticalCenter(value:Number):void
		{
			_verticalCenter = value;
			if (parent) y = ((parent.height - height) / 2) + value;
		}
		
		private var _top:Number = 0;
		/**
		 * sets the top value
		 * @default=0;
		 */
		public function get top():Number{return _top;}
		public function set top(value:Number):void
		{
			_top = value;
			y = value;
		}
		
		private var _bottom:Number = 0;
		/**
		 * sets the bottom 
		 * @default =0;
		 */
		public function get bottom():Number{return _bottom;}
		public function set bottom(value:Number):void
		{
			_bottom = value;			
			if (parent) y = (parent.height - height) + value;
		}
		
		private var _left:Number = 0;
		/**
		 * sets the left
		 */
		public function get left():Number{return _left;}
		public function set left(value:Number):void
		{
			_left = value;
			x = value
		}
		
		private var _right:Number = 0;
		/**
		 * sets the right
		 */
		public function get right():Number{return _right;}
		public function set right(value:Number):void
		{
			_right = value;
			if (parent) x = (parent.width - width) + value;
		}
		
		private var _index:int;
		/**
		 * specify the text index
		 */
		public function get index():int{return _index;}
		public function set index(value:int):void
		{
			_index = value;
		}
		
		
		private var _className:String;
		/**
		 * specify the class name 
		 */
		public function get className():String { return _className ; }
		public function set className(value:String):void
		{
			_className = value;
		}			
		
		protected function layoutText():void{}
		protected function updateText():void{}
		protected function updateTextFormat():void{}
		protected function createUI():void{}
		protected function commitUI():void{}
		protected function layoutUI():void { }
		
		/**
		 * update method
		 */
		public function updateUI():void{}
	}
}