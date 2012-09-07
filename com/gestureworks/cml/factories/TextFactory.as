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
	
	
	public class TextFactory extends TextField implements IElement, ICSS
	{
		public var textFormat:TextFormat = new TextFormat();
		
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
		
		public function dispose():void{};
		
		public var propertyStates:Array;
		
		
		private var _id:String
		public function get id():String {return _id};
		public function set id(value:String):void
		{
			_id = value;
		}
		
		private var _cmlIndex:int;
		public function get cmlIndex():int {return _cmlIndex};
		public function set cmlIndex(value:int):void
		{
			_cmlIndex = value;
		}
		
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
		
		
		public function postparseCML(cml:XMLList):void {}
		
		
		public function updateProperties(state:Number=0):void
		{
			CMLParser.instance.updateProperties(this, state);		
		}	
		
		
		/////////////////////////////////
		// ICSS
		////////////////////////////////		
		
		/**
		 * Object's css class; 
		 */		
		private var _class_:String;
		public function get class_():String { return _class_; }
		public function set class_(value:String):void 
		{ 
			_class_ = value; 
		}	
		
	
		
		/////////////////////////////////
		// TEXT 
		////////////////////////////////		
		
		private var _htmlText:String;
		override public function get htmlText():String { return super.htmlText; }
		override public function set htmlText(value:String):void
		{
			//trace("html", value);
			super.htmlText = value;			
			verticalAlign = _verticalAlign;
		}
		
		private var _type:String = "input";
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
		override public function get text():String { return super.text; }
		override public function set text(value:String):void
		{
			super.text = value;			
			verticalAlign = _verticalAlign;
		}
		
		private var setY:Number = 0;
		private var _y:Number = 0;
		override public function get y():Number { return super.y; }
		override public function set y(value:Number):void
		{
			super.y = value;
			setY = value;
		}
		
		private var _autoSize:String;
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
		public function get color():int { return _color; }
		public function set color(value:int):void 
		{ 
			_textFormatColor = value;
			textFormat.color = textFormatColor;
			updateTextFormat();
		}	
		
		private var _textFormatColor:uint=0x000000;
		public function get textFormatColor():uint{return _textFormatColor;}
		public function set textFormatColor(value:uint):void
		{
			_textFormatColor = value;
			textFormat.color = textFormatColor;
			updateTextFormat();
		}
		
		private var _verticalAlign:Boolean=false;
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
		public function get fontSize():Number {return _textSize;}
		public function set fontSize(value:Number):void
		{
			_textSize = value;
			textFormat.size = textSize;
			updateTextFormat();			
		}		
		
		private var _textSize:Number = 15;
		public function get textSize():Number {return _textSize;}
		public function set textSize(value:Number):void
		{
			_textSize = value;
			textFormat.size = textSize;
			updateTextFormat();
		}
		
		private var _font:String = "OpenSansRegular";
		public function get font():String{return _font;}
		public function set font(value:String):void
		{
			_font = value;
			textFormat.font = font;
			updateTextFormat();
		}
		
		private var _leading:Number = 0;
		public function get leading():Number{return _leading;}
		public function set leading(value:Number):void
		{
			_leading = value;
			textFormat.leading = leading;
			updateTextFormat();
		}
		
		private var _letterSpacing:Number = 0;
		public function get letterSpacing():Number{return _letterSpacing;}
		public function set letterSpacing(value:Number):void
		{
			_letterSpacing = value;
			textFormat.letterSpacing = letterSpacing;
			updateTextFormat();
		}
		
		private var _underline:Boolean;
		public function get underline():Boolean{return _underline;}
		public function set underline(value:Boolean):void
		{
			_underline = value;
			textFormat.underline = value;
			updateTextFormat();
		}
		
		private var _kerning:Boolean;
		public function get kerning():Boolean{return _kerning;}
		public function set kerning(value:Boolean):void
		{
			_kerning = value;
			textFormat.kerning = value;
			updateTextFormat();
		}
		
		private var _paddingLeft:Number = 0;
		public function get paddingLeft():Number{return _paddingLeft;}
		public function set paddingLeft(value:Number):void 
		{
			_paddingLeft = value;
			layoutText();
		}
		
		private var _paddingTop:Number = 0;
		public function get paddingTop():Number{return _paddingTop;}
		public function set paddingTop(value:Number):void
		{
			_paddingTop = value;
			layoutText();
		}
		
		private var _paddingRight:Number = 0;
		public function get paddingRight():Number{return _paddingRight;}
		public function set paddingRight(value:Number):void 
		{
			_paddingRight = value;
			layoutText();
		}
		
		private var _paddingBottom:Number = 0;
		public function get paddingBottom():Number{return _paddingBottom;}
		public function set paddingBottom(value:Number):void
		{
			_paddingBottom = value;
			layoutText();
		}
		
		private var _widthPercent:String="";
		public function get widthPercent():String{return _widthPercent;}
		public function set widthPercent(value:String):void
		{
			_widthPercent = value;
			var number:Number = Number(widthPercent.slice(0, widthPercent.indexOf("%")));
			if (parent) width = parent.width * (number / 100);
		}
				
		private var _heightPercent:String="";
		public function get heightPercent():String{	return _heightPercent;}
		public function set heightPercent(value:String):void
		{
			_heightPercent = value;
			var number:Number = Number(heightPercent.slice(0, heightPercent.indexOf("%")));
			if (parent) height = parent.height * (number / 100);
		}
		
		private var _horizontalCenter:Number=0;
		public function get horizontalCenter():Number{return _horizontalCenter;}
		public function set horizontalCenter(value:Number):void
		{
			_horizontalCenter = value;
			if (parent) x = ((parent.width - width) / 2) + value;
		}
		
		private var _verticalCenter:Number=0;
		public function get verticalCenter():Number{return _verticalCenter;}
		public function set verticalCenter(value:Number):void
		{
			_verticalCenter = value;
			if (parent) y = ((parent.height - height) / 2) + value;
		}
		
		private var _top:Number=0;
		public function get top():Number{return _top;}
		public function set top(value:Number):void
		{
			_top = value;
			y = value;
		}
		
		private var _bottom:Number=0;
		public function get bottom():Number{return _bottom;}
		public function set bottom(value:Number):void
		{
			_bottom = value;			
			if (parent) y = (parent.height - height) + value;
		}
		
		private var _left:Number=0;
		public function get left():Number{return _left;}
		public function set left(value:Number):void
		{
			_left = value;
			x = value
		}
		
		private var _right:Number=0;
		public function get right():Number{return _right;}
		public function set right(value:Number):void
		{
			_right = value;
			if (parent) x = (parent.width - width) + value;
		}
		
		private var _index:int;
		public function get index():int{return _index;}
		public function set index(value:int):void
		{
			_index = value;
		}
		
		
		private var _className:String;
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
		protected function layoutUI():void{}
		public function updateUI():void{}
	}
}