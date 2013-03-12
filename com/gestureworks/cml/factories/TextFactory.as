package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.interfaces.ICSS;
	import com.gestureworks.cml.interfaces.IElement;
	import com.gestureworks.cml.utils.DisplayUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.text.TextFieldType;
	import flash.utils.Dictionary;
	
	
	/** 
	 * The TextFactory is the base class for all Text.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Ideum
	 * @see com.gestureworks.cml.factories.Text
	 * @see com.gestureworks.cml.factories.TLF
	 * @see com.gestureworks.cml.factories.ElementFactory
	 */	 
	public class TextFactory extends TextField implements IElement, ICSS
	{
		private var bmd:BitmapData;
		private var b:Bitmap;
		
		/**
		 * creates textformat variable
		 */
		public var textFormat:TextFormat = new TextFormat();
		
		/**
		 * Constructor
		 */
		public function TextFactory() 
		{
			super();
			
			propertyStates = [];
			propertyStates[0] = new Dictionary(false);

			textFormat.font = "OpenSansRegular";
			textFormat.color = color;
			textFormat.size = fontSize;
			antiAliasType = AntiAliasType.ADVANCED;
			blendMode = BlendMode.LAYER;
			embedFonts = true;					
		}
		
		
		/////////////////////////////////
		// IObject
		////////////////////////////////
		
		/**
		 * Dispose methods
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
		 * Sets the id
		 */
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		private var _cmlIndex:int;
		/**
		 * Sets the cml index
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
				CMLParser.attrLoop(this, cml);
				multiline = true;
				condenseWhite = true;
				this.propertyStates[0]["htmlText"] = cml.children();
				cml = new XMLList;				
			}
	
			return CMLParser.parseCML(this, cml);
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
			CMLParser.updateProperties(this, state);		
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
		
		private var _gridFitType:String;
		/**
		 * The type of grid fitting used for this text field. This property applies only if the flash.text.AntiAliasType property of the text field is set to flash.text.AntiAliasType.ADVANCED.
		 * The type of grid fitting used determines whether Flash Player forces strong horizontal and vertical lines to fit to a pixel or subpixel grid, or not at all.
		 * You can use the following string values: subpixel, pixel, none.
		 */
		override public function get gridFitType():String{return _gridFitType;}
		override public function set gridFitType(value:String):void
		{
			_gridFitType = value;
						
			switch (value) 
            {
                case "subpixel":
					super.gridFitType = GridFitType.SUBPIXEL;
                    break;
                case "pixel":
					super.gridFitType = GridFitType.PIXEL;
                    break;
                case "none":
                    super.gridFitType = GridFitType.NONE;
                    break;
            }
			
			updateTextFormat();			
		}	
		
		private var _htmlText:String = null;
		/**
		 * contains html representation of text field contents
		 */
		override public function get htmlText():String { return super.htmlText; }
		override public function set htmlText(value:String):void
		{
			super.htmlText = value;		
			verticalAlign = _verticalAlign;
			updateTextFormat();
		}
		
		private var _type:String = "input";
		/**
		 * type of text field
		 * @default  input;
		 */
		override public function get type():String { return _type; }
		override public function set type(value:String):void
		{
			_type = value;
			
			if (_type == "input")
				super.type = TextFieldType.INPUT;
			else
				super.type = TextFieldType.DYNAMIC;
			updateTextFormat();	
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
			updateTextFormat();
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
                    break;
                case "left":
					super.autoSize = TextFieldAutoSize.LEFT;
                    break;
                case "right":
                    super.autoSize = TextFieldAutoSize.RIGHT;
                    break;
                case "none":
                    super.autoSize = TextFieldAutoSize.NONE;
                    break;
            }
			
			updateTextFormat();			
		}
		
		
		private var _color:uint = 0x000000;
		/**
		 * Sets the color of the text in a text field
		 * @default = 0x000000;
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void 
		{ 
			_color = value;
			textFormat.color = value;
			updateTextFormat();				
		}	
		
		private var _textColor:uint = 0x000000;
		/**
		 * Sets the color of the text in a text field
		 * @default = 0x000000;
		 */
		override public function get textColor():uint { return _textColor; }
		override public function set textColor(value:uint):void 
		{
			_textColor = value;
			color = value;
			updateTextFormat();
		}			
		
		private var _textFormatColor:uint = 0x000000;
		[Deprecated(replacement = "color")] 		
		/**
		 * Sets the text format color
		 * @default = 0x000000;
		 */
		public function get textFormatColor():uint { return _textFormatColor; }
		public function set textFormatColor(value:uint):void
		{
			_textFormatColor = value;
			color = value;
			updateTextFormat();
		}
		
		private var _fontSize:Number = 15;
		/**
		 * Sets the font size of the text
		 * @default 15;
		 */
		public function get fontSize():Number {return _fontSize;}
		public function set fontSize(value:Number):void
		{
			_fontSize = value;
			textFormat.size = value;
			updateTextFormat();		
		}		
		
		private var _textSize:Number = 15;
		/**
		 * Sets the text size of the text
		 * @default 15;
		 */
		public function get textSize():Number {return _textSize;}
		public function set textSize(value:Number):void
		{
			_textSize = value;
			fontSize = value;
			updateTextFormat();
		}
		
		private var _font:String = "OpenSansRegular";
		/**
		 * Sets the font of the text
		 * @default "OpenSansRegular";
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
		 * Sets the line spacing of text
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
		 * Sets the number of additional pixels to appear between each character.
		 * @default 0;
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
		 * Sets the gap between certain character pairs 
		 */
		public function get kerning():Boolean{return _kerning;}
		public function set kerning(value:Boolean):void
		{
			_kerning = value;
			textFormat.kerning = value;
			updateTextFormat();			
		}
		
		
		
		
	
		// layout properties
		
		
		private var setY:Number = 0;
		private var _y:Number = 0;
		/**
		 * Sets y position of text
		 */
		override public function get y():Number { return super.y; }
		override public function set y(value:Number):void
		{
			super.y = value;
			setY = value;
			
		}
		
		
		private var _textAlign:String;
		/**
		 * Sets the allignment of text in text field
		 */
        public function get textAlign():String {return _textAlign}                
        public function set textAlign(value:String):void 
        {
            _textAlign = value;
            switch (value) 
            {
                case "center":
                    textFormat.align = TextFormatAlign.CENTER;
                    break;
                case "left":
                    textFormat.align = TextFormatAlign.LEFT;
                    break;
                case "right":
                    textFormat.align = TextFormatAlign.RIGHT;
                    break;
                case "justify":
                    textFormat.align = TextFormatAlign.JUSTIFY;
                    break;
            }
			updateTextFormat();		
        }

		
		private var _verticalAlign:Boolean = false;
		/**
		 * Sets the vertical allignment of text field
		 * @default false;
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
		
		
		/**
		 * Sets height of text text
		 */
		override public function set height(value:Number):void 
		{			
			super.height = value;
			verticalAlign = verticalAlign;
		}
		
		private var _horizontalCenter:Number = 0;
		/**
		 * Sets the horizontal center
		 */
		public function get horizontalCenter():Number{return _horizontalCenter;}
		public function set horizontalCenter(value:Number):void
		{
			_horizontalCenter = value;
			if (parent) x = ((parent.width - width) / 2) + value;
		}
		
		private var _verticalCenter:Number = 0;
		/**
		 * Sets the vertical center
		 */
		public function get verticalCenter():Number{return _verticalCenter;}
		public function set verticalCenter(value:Number):void
		{
			_verticalCenter = value;
			if (parent) y = ((parent.height - height) / 2) + value;
		}
		
		
			
		private var _textBitmap:Boolean = false;
		/**
		 * Sets whether the text is left to scale as vector or gets locked as a bitmap.
		 */
		public function get textBitmap():Boolean { return _textBitmap; }
		public function set textBitmap(value:Boolean):void {
			_textBitmap = value;
			updateTextFormat();
		}
		
		private var _scrollable:Boolean = false;
		/**
		 * Sets whether or not the text is scrollable.
		 */
		public function get scrollable():Boolean { return _scrollable; }
		public function set scrollable(value:Boolean):void {
			_scrollable = value;
			updateTextFormat();
		}
		
		
		// protected methods	
		protected function updateTextFormat():void 
		{
			defaultTextFormat = textFormat;
			
			if(b && b.bitmapData) {
				b.bitmapData.dispose();
				this.visible = true;
			}
					
			if (textBitmap) {
							
				b = DisplayUtils.toBitmap(this);
				
				if (this.parent) {
					if (parent.contains(b))
						parent.removeChild(b);
					this.visible = false;
					b.x = this.x;
					b.y = this.y;
					parent.addChild(b);
				}
			}
			if (scrollable) {
				this.scrollRect = new Rectangle(0, 0, this.width, this.height);
				trace("Hi, this is your scrollable text box speaking here. My width right now is:", this.width, "And my height is:", this.height);
			}
			
			super.text = this.text;			
		}
		
		//////////////
		//  IClone  
		//////////////		
		
		/**
		 * Returns clone of self
		 */
		public function clone():* { return new Object };
				
		
	}
}