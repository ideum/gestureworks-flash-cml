package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.utils.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.text.engine.FontMetrics;
	import flash.utils.*;
	
	/**
	 * The Text element displays a text field. It has most of the functionality
	 * the the TextField and TextFormat AS3 classes combined
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	  			
		var txt:Text = new Text();
		txt.x = 200;
		txt.y = 200;
		txt.font = "OpenSansBold";
		txt.fontSize = 30;			
		txt.color = 0xFF0000;		
		addChild(txt);
		
	 * </codeblock>
	 * 
	 * @inheritDoc TextFactory
	 * @author Ideum
	 * @see SWF
	 */	
	public class Text extends TouchContainer {
		private var _index:int;				
		private var _verticalAlign:Boolean = false;
		private var _horizontalCenter:Number = 0;
		private var _verticalCenter:Number = 0;
		private var _textBitmap:Boolean = false;
		private var _scrollable:Boolean = false;
		private var _autosize:Boolean = true;

		private var b:Bitmap;
		private var bmd:BitmapData;		
		private var setY:Number = 0;		
		
		/**
		 * Constructor
		 */
		public function Text() {
			super();
			mouseChildren = true; // leave for selectable text
			
			mouseChildren = true;
			_textField = new TextField;
			_textFormat = new TextFormat;
			addChild(textField);			

			textFormat.font = "OpenSansRegular";
			textFormat.color = 0x000000;
			textFormat.size = fontSize;
			
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.blendMode = BlendMode.NORMAL;
			textField.gridFitType = GridFitType.NONE;
			textField.embedFonts = true;	
			textField.selectable = false;
			textField.text = " "; // keep space for past consistency
			
			// keep default for past consistency 
			width = 100;
			height = 100;		
			
			updateTextFormat();
		}
		
		/**
		 * CML initialization method
		 */
		override public function init():void {
			super.init();
			if (!width) width = 100;
			if (!height) height = 100;			
			updateTextFormat();		
		}
		
		/**
		 * @inheritDoc
		 */
		override public function parseCML(cml:XMLList):XMLList {			
			
			// make gesture list
			var g:XML = <GestureList />;				
			for each (var item:XML in cml.children()) {
				if (item.name() == "GestureList") {
					g.appendChild(item.children().copy());
				}
				else if (item.name() == "Gesture") {
					g.appendChild(item.copy());
				}
			}			
			makeGestureList(XMLList(g));
			
			// if TextElement has other children, then interpret as htmlText
			if (String(cml).length > 0 && cml["State"] == undefined) {
				CMLParser.attrLoop(this, cml);
				textField.multiline = true;
				textField.condenseWhite = true;
				this.state[0]["htmlText"] = cml.children();
				cml = new XMLList;
			}
	
			return CMLParser.parseCML(this, cml);
		}
		
		/**
		 * TextField object
		 */		
		protected var _textField:TextField;
		
		/**
		 * TextFormat object
		 */
		protected var _textFormat:TextFormat;		
		
		/**
		 * Specifies the text index.
		 */
		public function get index():int { return _index; } // not really sure what this is?
		public function set index(value:int):void {
			_index = value;
		}			
		
		
		/////////////////////////////////
		// TextField Properties 
		////////////////////////////////			
		
		/**
		 * When set to true and the text field is not in focus, Flash Player highlights the 
		 * selection in the text field in gray. When set to false and the text field is not in
		 * focus, Flash Player does not highlight the selection in the text field.
		 */
		public function get alwaysShowSelection():Boolean { return textField.alwaysShowSelection; }
		public function set alwaysShowSelection(value:Boolean):void {
			textField.alwaysShowSelection = value;
			if (toBitmap) {
				updateTextFormat();
			}
		}
		
		/**
		 * The type of anti-aliasing used for this text field. Use flash.text.AntiAliasType
		 * constants for this property. You can control this setting only if the font is
		 * embedded (with the embedFonts property set to true). 
		 * The default setting is flash.text.AntiAliasType.NORMAL.
		 * 
		 *   To set values for this property, use the following string values:String valueDescriptionflash.text.AntiAliasType.NORMALApplies the regular text anti-aliasing. This value matches the type of anti-aliasing that
		 * Flash Player 7 and earlier versions used.flash.text.AntiAliasType.ADVANCED Applies advanced anti-aliasing, which makes text more legible. (This feature became
		 * available in Flash Player 8.) Advanced anti-aliasing allows for high-quality rendering
		 * of font faces at small sizes. It is best used with applications
		 * with a lot of small text. Advanced anti-aliasing is not recommended for
		 * fonts that are larger than 48 points.
		 */
		public function get antiAliasType():String { return textField.antiAliasType; }
		public function set antiAliasType (value:String):void {
			textField.antiAliasType = value;
			if (toBitmap) {
				updateTextFormat();
			}		
		}

		/**
		 * Controls automatic sizing and alignment of text fields.
		 * Acceptable values for the TextFieldAutoSize constants: TextFieldAutoSize.NONE (the default),
		 * TextFieldAutoSize.LEFT, TextFieldAutoSize.RIGHT, and TextFieldAutoSize.CENTER.
		 * 
		 *   If autoSize is set to TextFieldAutoSize.NONE (the default) no resizing occurs.If autoSize is set to TextFieldAutoSize.LEFT, the text is
		 * treated as left-justified text, meaning that the left margin of the text field remains fixed and any
		 * resizing of a single line of the text field is on the right margin. If the text includes a line break
		 * (for example, "\n" or "\r"), the bottom is also resized to fit the next
		 * line of text. If wordWrap is also set to true, only the bottom
		 * of the text field is resized and the right side remains fixed.If autoSize is set to TextFieldAutoSize.RIGHT, the text is treated as
		 * right-justified text, meaning that the right margin of the text field remains fixed and any resizing
		 * of a single line of the text field is on the left margin. If the text includes a line break
		 * (for example, "\n" or "\r"), the bottom is also resized to fit the next
		 * line of text. If wordWrap is also set to true, only the bottom
		 * of the text field is resized and the left side remains fixed.If autoSize is set to TextFieldAutoSize.CENTER, the text is treated as
		 * center-justified text, meaning that any resizing of a single line of the text field is equally distributed
		 * to both the right and left margins. If the text includes a line break (for example, "\n" or 
		 * "\r"), the bottom is also resized to fit the next line of text. If wordWrap is also
		 * set to true, only the bottom of the text field is resized and the left and
		 * right sides remain fixed.
		 * @throws	ArgumentError The autoSize specified is not a member of flash.text.TextFieldAutoSize.
		 */
		public function get autoSize():String { return textField.autoSize; }
		public function set autoSize(value:String):void {
			if (value == "true") { value = "left"; }
			textField.autoSize = value;
			super.width = textField.textWidth;
			super.height = textField.textHeight;
			if (toBitmap) {
				updateTextFormat();
			}		
		}
		
		/**
		 * Auto-sizes based on text.
		 */
		public function get autosize():Boolean { return _autosize; }
		public function set autosize(value:Boolean):void {
			if (value) {
				autoSize = "left";
			}
			_autosize = value;
		}		
		
		/**
		 * Specifies whether the text field has a background fill. If true, the text field has a
		 * background fill. If false, the text field has no background fill.
		 */
		public function get background():Boolean { return textField.background };
		public function set background(value:Boolean):void {
			textField.background = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * The color of the text field background. The default value is 0xFFFFFF (white). 
		 * This property can be retrieved or set, even if there currently is no background, but the 
		 * color is visible only if the text field has the background property set to 
		 * true.
		 */
		public function get backgroundColor():uint { return textField.backgroundColor };
		public function set backgroundColor(value:uint):void {
			textField.backgroundColor = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Specifies whether the text field has a border. If true, the text field has a border.
		 * If false, the text field has no border. Use the borderColor property 
		 * to set the border color.
		 */
		public function get border():Boolean { return textField.border; }
		public function set border(value:Boolean):void {
			textField.border = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}

		/**
		 * The color of the text field border. The default value is 0x000000 (black). 
		 * This property can be retrieved or set, even if there currently is no border, but the 
		 * color is visible only if the text field has the border property set to 
		 * true.
		 */
		public function get borderColor():uint { return textField.borderColor; }
		public function set borderColor(value:uint):void {
			textField.borderColor = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * An integer (1-based index) that indicates the bottommost line that is currently visible in
		 * the specified text field. Think of the text field as a window onto a block of text.
		 * The scrollV property is the 1-based index of the topmost visible line
		 * in the window.
		 * 
		 *   All the text between the lines indicated by scrollV and bottomScrollV
		 * is currently visible in the text field.
		 */
		public function get bottomScrollV():int { return textField.bottomScrollV; }
		
		/**
		 * The index of the insertion point (caret) position. If no insertion point is displayed,
		 * the value is the position the insertion point would be if you restored focus to the field (typically where the 
		 * insertion point last was, or 0 if the field has not had focus).
		 * 
		 *   Selection span indexes are zero-based (for example, the first position is 0,
		 * the second position is 1, and so on).
		 */
		public function get caretIndex():int { return textField.caretIndex };
		
		/**
		 * A Boolean value that specifies whether extra white space (spaces, line breaks, and so on)
		 * in a text field with HTML text is removed. The default value is false.
		 * The condenseWhite property only affects text set with
		 * the htmlText property, not the text property. If you set 
		 * text with the text property, condenseWhite is ignored.
		 * 
		 *   If condenseWhite is set to true, use standard HTML commands such as
		 * <BR> and <P> to place line breaks in the text field.Set the condenseWhite property before setting the htmlText property.
		 */
		public function get condenseWhite():Boolean { return textField.condenseWhite; }
		public function set condenseWhite(value:Boolean):void {
			textField.condenseWhite = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Specifies whether the text field is a password text field. If the value of this property is true,
		 * the text field is treated as a password text field and hides the input characters using asterisks instead of the
		 * actual characters. If false, the text field is not treated as a password text field. When password mode
		 * is enabled, the Cut and Copy commands and their corresponding keyboard shortcuts will
		 * not function.  This security mechanism prevents an unscrupulous user from using the shortcuts to discover
		 * a password on an unattended computer.
		 */
		public function get displayAsPassword():Boolean { return textField.displayAsPassword; }
		public function set displayAsPassword (value:Boolean):void {
			textField.displayAsPassword = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Specifies whether to render by using embedded font outlines. 
		 * If false, Flash Player renders the text field by using
		 * device fonts.
		 * 
		 *   If you set the embedFonts property to true for a text field, 
		 * you must specify a font for that text by using the font property of 
		 * a TextFormat object applied to the text field.
		 * If the specified font is not embedded in the SWF file, the text is not displayed.
		 */
		public function get embedFonts():Boolean { return textField.embedFonts; }
		public function set embedFonts (value:Boolean):void	{
			textField.embedFonts = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
				
		/**
		 * The type of grid fitting used for this text field. This property applies only if the flash.text.AntiAliasType property of the text field is set to flash.text.AntiAliasType.ADVANCED.
		 * The type of grid fitting used determines whether Flash Player forces strong horizontal and vertical lines to fit to a pixel or subpixel grid, or not at all.
		 * You can use the following string values: subpixel, pixel, none.
		 */
		public function get gridFitType():String{return textField.gridFitType;}
		public function set gridFitType(value:String):void {
			textField.gridFitType = value;			
			if (toBitmap) {
				updateTextFormat();
			}				
		}	
		
		/**
		 * Contains the html representation of text field contents.
		 */
		public function get htmlText():String { return textField.htmlText; }
		public function set htmlText(value:String):void {
			textField.htmlText = value;		
			verticalAlign = _verticalAlign;
			updateTextFormat();
		}
		
		/**
		 * The number of characters in a text field. A character such as tab (\t) counts as one
		 * character.
		 */
		public function get charLength():int { return textField.length; }		
		
		/**
		 * The maximum number of characters that the text field can contain, as entered by a user.
		 * A script can insert more text than maxChars allows; the maxChars property
		 * indicates only how much text a user can enter. If the value of this property is 0,
		 * a user can enter an unlimited amount of text.
		 */
		public function get maxChars():int { return textField.length; }
		public function set maxChars(value:int):void {
			textField.maxChars = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * The maximum value of scrollH.
		 */
		public function get maxScrollH():int { return textField.maxScrollH; }		
		
		/**
		 * The maximum value of scrollV.
		 */
		public function get maxScrollV():int { return textField.maxScrollV; }	

		/**
		 * A Boolean value that indicates whether Flash Player automatically scrolls multiline
		 * text fields when the user clicks a text field and rolls the mouse wheel.
		 * By default, this value is true. This property is useful if you want to prevent
		 * mouse wheel scrolling of text fields, or implement your own text field scrolling.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 */
		public function get mouseWheelEnabled():Boolean { return textField.mouseWheelEnabled; }
		public function set mouseWheelEnabled(value:Boolean):void {
			textField.mouseWheelEnabled = value;			
		}
		
		/**
		 * Indicates whether field is a multiline text field. If the value is true,
		 * the text field is multiline; if the value is false, the text field is a single-line
		 * text field. In a field of type TextFieldType.INPUT, the multiline value
		 * determines whether the Enter key creates a new line (a value of false,
		 * and the Enter key is ignored).
		 * If you paste text into a TextField with a multiline value of false,
		 * newlines are stripped out of the text.
		 */
		public function get multiline():Boolean { return textField.multiline };
		public function set multiline(value:Boolean):void {
			textField.multiline = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Defines the number of text lines in a multiline text field. 
		 * If wordWrap property is set to true,
		 * the number of lines increases when text wraps.
		 */
		public function get numLines():int { return textField.numLines };		
		
		/**
		 * Indicates the set of characters that a user can enter into the text field. If the value of the
		 * restrict property is null, you can enter any character. If the value of
		 * the restrict property is an empty string, you cannot enter any character. If the value
		 * of the restrict property is a string of characters, you can enter only characters in
		 * the string into the text field. The string is scanned from left to right. You can specify a range by
		 * using the hyphen (-) character. Only user interaction is restricted; a script can put any text into the 
		 * text field. This property does not synchronize with the Embed font options
		 * in the Property inspector.If the string begins with a caret (^) character, all characters are initially accepted and 
		 * succeeding characters in the string are excluded from the set of accepted characters. If the string does 
		 * not begin with a caret (^) character, no characters are initially accepted and succeeding characters in the 
		 * string are included in the set of accepted characters.The following example allows only uppercase characters, spaces, and numbers to be entered into
		 * a text field:
		 * my_txt.restrict = "A-Z 0-9";
		 * The following example includes all characters, but excludes lowercase letters:
		 * my_txt.restrict = "^a-z";
		 * You can use a backslash to enter a ^ or - verbatim. The accepted backslash sequences are \-, \^ or \\.
		 * The backslash must be an actual character in the string, so when specified in ActionScript, a double backslash
		 * must be used. For example, the following code includes only the dash (-) and caret (^):
		 * my_txt.restrict = "\\-\\^";
		 * The ^ can be used anywhere in the string to toggle between including characters and excluding characters.
		 * The following code includes only uppercase letters, but excludes the uppercase letter Q:
		 * my_txt.restrict = "A-Z^Q";
		 * You can use the \u escape sequence to construct restrict strings.
		 * The following code includes only the characters from ASCII 32 (space) to ASCII 126 (tilde).
		 * my_txt.restrict = "\u0020-\u007E";
		 */
		public function get restrict():String { return textField.restrict; }
		public function set restrict(value:String):void {
			textField.restrict = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * The current horizontal scrolling position. If the scrollH property is 0, the text
		 * is not horizontally scrolled. This property value is an integer that represents the horizontal
		 * position in pixels.
		 * 
		 *   The units of horizontal scrolling are pixels, whereas the units of vertical scrolling are lines.
		 * Horizontal scrolling is measured in pixels because most fonts you typically use are proportionally
		 * spaced; that is, the characters can have different widths. Flash Player performs vertical scrolling by
		 * line because users usually want to see a complete line of text rather than a
		 * partial line. Even if a line uses multiple fonts, the height of the line adjusts to fit
		 * the largest font in use.Note: The scrollH property is zero-based, not 1-based like 
		 * the scrollV vertical scrolling property.
		 */
		public function get scrollH():int { return textField.scrollH; }
		public function set scrollH (value:int):void { 
			textField.scrollH = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * The vertical position of text in a text field. The scrollV property is useful for
		 * directing users to a specific paragraph in a long passage, or creating scrolling text fields.
		 * 
		 *   The units of vertical scrolling are lines, whereas the units of horizontal scrolling are pixels.
		 * If the first line displayed is the first line in the text field, scrollV is set to 1(not 0).
		 * Horizontal scrolling is measured in pixels because most fonts are proportionally
		 * spaced; that is, the characters can have different widths. Flash performs vertical scrolling by line
		 * because users usually want to see a complete line of text rather than a partial line.
		 * Even if there are multiple fonts on a line, the height of the line adjusts to fit the largest font in
		 * use.
		 */
		public function get scrollV():int { return textField.scrollV; }
		public function set scrollV(value:int):void	{
			textField.scrollV = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * A Boolean value that indicates whether the text field is selectable. The value true
		 * indicates that the text is selectable. The selectable property controls whether
		 * a text field is selectable, not whether a text field is editable. A dynamic text field can
		 * be selectable even if it is not editable. If a dynamic text field is not selectable, the user
		 * cannot select its text.
		 * 
		 *   If selectable is set to false, the text in the text field does not
		 * respond to selection commands from the mouse or keyboard, and the text cannot be copied with the
		 * Copy command. If selectable is set to true, the text in the text field
		 * can be selected with the mouse or keyboard, and the text can be copied with the Copy command. 
		 * You can select text this way even if the text field is a dynamic text field instead of an input text field.
		 */
		public function get selectable():Boolean { return textField.selectable; }
		public function set selectable(value:Boolean):void {
			textField.selectable = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}

		public function get selectedText():String { return textField.selectedText; }	
		
		/**
		 * The zero-based character index value of the first character in the current selection.
		 * For example, the first character is 0, the second character is 1, and so on. If no
		 * text is selected, this property is the value of caretIndex.
		 */
		public function get selectionBeginIndex():int { return textField.selectionBeginIndex; }

		/**
		 * The zero-based character index value of the last character in the current selection.
		 * For example, the first character is 0, the second character is 1, and so on. If no
		 * text is selected, this property is the value of caretIndex.
		 */
		public function get selectionEndIndex():int { return textField.selectionBeginIndex; }			
	
		/**
		 * The sharpness of the glyph edges in this text field. This property applies
		 * only if the flash.text.AntiAliasType property of the text field is set to
		 * flash.text.AntiAliasType.ADVANCED. The range for
		 * sharpness is a number from -400 to 400. If you attempt to set
		 * sharpness to a value outside that range, Flash sets the property to
		 * the nearest value in the range(either -400 or 400).
		 */
		public function get sharpness():Number { return textField.sharpness; }
		public function set sharpness(value:Number):void {
			textField.sharpness = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Attaches a style sheet to the text field. For information on creating style sheets, see the StyleSheet class
		 * and the ActionScript 3.0 Developer's Guide.
		 * 
		 *   You can change the style sheet associated with a text field at any time. If you change
		 * the style sheet in use, the text field is redrawn with the new style sheet. 
		 * You can set the style sheet to null or undefined 
		 * to remove the style sheet. If the style sheet in use is removed, the text field is redrawn without a style sheet. Note: If the style sheet is removed, the contents of both TextField.text and 
		 * TextField.htmlText change to incorporate the formatting previously applied by the style sheet. To preserve
		 * the original TextField.htmlText contents without the formatting, save the value in a variable before
		 * removing the style sheet.
		 */
		public function get styleSheet():flash.text.StyleSheet { return textField.styleSheet; }
		public function set styleSheet(value:StyleSheet):void {
			textField.styleSheet = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * A string that is the current text in the text field. Lines are separated by the carriage
		 * return character('\r', ASCII 13). This property contains unformatted text in the text
		 * field, without HTML tags.
		 */
		public function get text():String { return textField.text; }
		public function set text(value:String):void {
			textField.text = value;
			verticalAlign = _verticalAlign;
			updateTextFormat();
		}
		
		/**
		 * The line height of the text field. The line height is its ascent (font's height above baseline), 
		 * descent (font's height below baseline) and leading (space between lines) combined.
		 */
		public function get textHeight():Number { return textField.textHeight; }
		
		/**
		 * Pixel height of rendered text
		 */
		public function get pixelHeight():Number {
			var tbmd:BitmapData;
			var pHeight:Number; 
			
			if (b && b.bitmapData) {
				tbmd = b.bitmapData.clone();
			}
			else {
				try{
					tbmd = new BitmapData(textField.width, textField.height, true, 0x00ffffff);
					tbmd.draw(textField);
				}
				catch(e:Error) {
					return textHeight;
				}
			}
			
			var rect:Rectangle = tbmd.getColorBoundsRect(0xff000000, 0x00000000, false);
			pHeight = rect.height;
			tbmd.dispose();
			
			return pHeight;
		}
		
		/**
		 * The interaction mode property, Default value is TextInteractionMode.NORMAL. 
		 * On mobile platforms, the normal mode implies that the text can be scrolled but not selected.
		 * One can switch to the selectable mode through the in-built context menu on the text field.
		 * On Desktop, the normal mode implies that the text is in scrollable as well as selection mode.
		 */
		public function get textInteractionMode():String { return textField.textInteractionMode; }		

		/**
		 * The width of the text in pixels.
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		public function get textWidth():Number {
			return textField.textWidth;
		}
		
		/**
		 * The thickness of the glyph edges in this text field. This property applies only
		 * when flash.text.AntiAliasType is set to flash.text.AntiAliasType.ADVANCED.
		 * 
		 *   The range for thickness is a number from -200 to 200. If you attempt to
		 * set thickness to a value outside that range, the property is set to the
		 * nearest value in the range(either -200 or 200).
		 */
		public function get thickness():Number { return textField.thickness };
		public function set thickness(value:Number):void {
			textField.thickness = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * The type of the text field.
		 * Either one of the following TextFieldType constants: TextFieldType.DYNAMIC,
		 * which specifies a dynamic text field, which a user cannot edit, or TextFieldType.INPUT,
		 * which specifies an input text field, which a user can edit.
		 * @throws	ArgumentError The type specified is not a member of flash.text.TextFieldType.
		 */
		public function get type():String { return textField.type; }
		public function set type(value:String):void {
			if (value == "input") {
				textField.type = TextFieldType.INPUT;
				if (toBitmap) {
					toBitmap = false;
				}
			}
			else {
				textField.type = TextFieldType.DYNAMIC;
			}
			updateTextFormat();	
		}	
		
		/**
		 * Specifies whether to copy and paste the text formatting along with the text. When set to true,
		 * Flash Player copies and pastes formatting(such as alignment, bold, and italics) when you copy and paste between text fields. 
		 * Both the origin and destination text fields for the copy and paste procedure must have
		 * useRichTextClipboard set to true. The default value
		 * is false.
		 */
		public function get useRichTextClipboard():Boolean { return textField.useRichTextClipboard; }		
		
		/**
		 * A Boolean value that indicates whether the text field has word wrap. If the value of
		 * wordWrap is true, the text field has word wrap;
		 * if the value is false, the text field does not have word wrap. The default
		 * value is false.
		 */
		public function get wordWrap():Boolean { return textField.wordWrap; }
		public function set wordWrap(value:Boolean):void {
			textField.wordWrap = value;
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/////////////////////////////////
		// TextField Methods
		////////////////////////////////		
		
		
		/**
		 * Appends the string specified by the newText parameter to the end of the text 
		 * of the text field. This method is more efficient than an addition assignment(+=) on 
		 * a text property(such as someTextField.text += moreText),
		 * particularly for a text field that contains a significant amount of content.
		 * @param	newText	The string to append to the existing text.
		 */
		public function appendText(newText:String):void	{
			textField.appendText(newText);
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Returns a rectangle that is the bounding box of the character.
		 * @param	charIndex	The zero-based index value for the character(for example, the first
		 *   position is 0, the second position is 1, and so on).
		 * @return	A rectangle with x and y minimum and maximum values
		 *   defining the bounding box of the character.
		 */
		public function getCharBoundaries(charIndex:int):flash.geom.Rectangle {			
			return textField.getCharBoundaries(charIndex);
		}
		
		/**
		 * Returns the zero-based index value of the character at the point specified by the x
		 * and y parameters.
		 * @param	x	The x coordinate of the character.
		 * @param	y	The y coordinate of the character.
		 * @return	The zero-based index value of the character(for example, the first position is 0,
		 *   the second position is 1, and so on).  Returns -1 if the point is not over any character.
		 */
		public function getCharIndexAtPoint(x:Number, y:Number):int {
			return getCharIndexAtPoint(x, y);
		}
			
		/**
		 * Given a character index, returns the index of the first character in the same paragraph.
		 * @param	charIndex	The zero-based index value of the character(for example, the first character is 0,
		 *   the second character is 1, and so on).
		 * @return	The zero-based index value of the first character in the same paragraph.
		 * @throws	RangeError The character index specified is out of range.
		 */
		public function getFirstCharInParagraph(charIndex:int):int {
			return textField.getFirstCharInParagraph(charIndex);
		}
		
		/**
		 * Returns a DisplayObject reference for the given id, for an image or SWF file
		 * that has been added to an HTML-formatted text field by using an <img> tag.
		 * The <img> tag is in the following format:
		 * 
		 *   <img src = 'filename.jpg' id = 'instanceName' >
		 * @param	id	The id to match(in the id attribute of the 
		 *   <img> tag).
		 * @return	The display object corresponding to the image or SWF file with the matching id 
		 *   attribute in the <img> tag of the text field. For media loaded from an external source, 
		 *   this object is a Loader object, and, once loaded, the media object is a child of that Loader object. For media 
		 *   embedded in the SWF file, it is the loaded object. If no <img> tag with 
		 *   the matching id exists, the method returns null.
		 */
		public function getImageReference(id:String):flash.display.DisplayObject {
			return textField.getImageReference(id);
		}
		
		/**
		 * Returns the zero-based index value of the line at the point specified by the x
		 * and y parameters.
		 * @param	x	The x coordinate of the line.
		 * @param	y	The y coordinate of the line.
		 * @return	The zero-based index value of the line(for example, the first line is 0, the
		 *   second line is 1, and so on).  Returns -1 if the point is not over any line.
		 */
		public function getLineIndexAtPoint(x:Number, y:Number):int {
			return textField.getLineIndexAtPoint(x, y);
		}
		
		/**
		 * Returns the zero-based index value of the line containing the character specified 
		 * by the charIndex parameter.
		 * @param	charIndex	The zero-based index value of the character(for example, the first character is 0,
		 *   the second character is 1, and so on).
		 * @return	The zero-based index value of the line.
		 * @throws	RangeError The character index specified is out of range.
		 */
		public function getLineIndexOfChar(charIndex:int):int {
			return textField.getLineIndexOfChar(charIndex);
		}
		
		/**
		 * Returns the number of characters in a specific text line.
		 * @param	lineIndex	The line number for which you want the length.
		 * @return	The number of characters in the line.
		 * @throws	RangeError The line number specified is out of range.
		 */
		public function getLineLength(lineIndex:int):int {
			return textField.getLineLength(lineIndex);
		}

		/**
		 * Returns metrics information about a given text line.
		 * @param	lineIndex	The line number for which you want metrics information.
		 * @return	A TextLineMetrics object.
		 * @throws	RangeError The line number specified is out of range.
		 */
		public function getLineMetrics(lineIndex:int):flash.text.TextLineMetrics {
			return textField.getLineMetrics(lineIndex);
		}
		
		/**
		 * Returns the character index of the first character in the line that 
		 * the lineIndex parameter specifies.
		 * @param	lineIndex	The zero-based index value of the line(for example, the first line is 0,
		 *   the second line is 1, and so on).
		 * @return	The zero-based index value of the first character in the line.
		 * @throws	RangeError The line number specified is out of range.
		 */
		public function getLineOffset(lineIndex:int):int {
			return textField.getLineOffset(lineIndex);
		}
		
		/**
		 * Returns the text of the line specified by the lineIndex parameter.
		 * @param	lineIndex	The zero-based index value of the line(for example, the first line is 0,
		 *   the second line is 1, and so on).
		 * @return	The text string contained in the specified line.
		 * @throws	RangeError The line number specified is out of range.
		 */
		public function getLineText(lineIndex:int):String {
			return textField.getLineText(lineIndex);
		}
		

		/**
		 * Given a character index, returns the length of the paragraph containing the given character.
		 * The length is relative to the first character in the paragraph(as returned by
		 * getFirstCharInParagraph()), not to the character index passed in.
		 * @param	charIndex	The zero-based index value of the character(for example, the first character is 0,
		 *   the second character is 1, and so on).
		 * @return	Returns the number of characters in the paragraph.
		 * @throws	RangeError The character index specified is out of range.
		 */
		public function getParagraphLength(charIndex:int):int {
			return textField.getParagraphLength(charIndex);
		}
		public function getRawText():String {
			return textField.getRawText();
		}
		
		/**
		 * Returns a TextFormat object that contains formatting information for the range of text that the
		 * beginIndex and endIndex parameters specify. Only properties 
		 * that are common to the entire text specified are set in the resulting TextFormat object. 
		 * Any property that is mixed, meaning that it has different values
		 * at different points in the text, has a value of null.
		 * 
		 *   If you do not specify
		 * values for these parameters, this method is applied to all the text in the text field.  The following table describes three possible usages:UsageDescriptionmy_textField.getTextFormat()Returns a TextFormat object containing formatting information for all text in a text field.
		 * Only properties that are common to all text in the text field are set in the resulting TextFormat
		 * object. Any property that is mixed, meaning that it has different values at different
		 * points in the text, has a value of null.my_textField.getTextFormat(beginIndex:Number)Returns a TextFormat object containing a copy of the text format of the character at the
		 * beginIndex position.my_textField.getTextFormat(beginIndex:Number,endIndex:Number)Returns a TextFormat object containing formatting information for the span of
		 * text from beginIndex to endIndex-1. Only properties that are common
		 * to all of the text in the specified range are set in the resulting TextFormat object. Any property
		 * that is mixed(that is, has different values at different points in the range) has its value set to null.
		 * @param	beginIndex	Optional; an integer that specifies the starting location of a range of text within the text field.
		 * @param	endIndex	Optional; an integer that specifies the position of the first character after the desired
		 *   text span. As designed, if you specify beginIndex and endIndex values, 
		 *   the text from beginIndex to endIndex-1 is read.
		 * @return	The TextFormat object that represents the formatting properties for the specified text.
		 * @throws	RangeError The beginIndex or endIndex specified is out of range.
		 */
		public function getTextFormat(beginIndex:int = -1, endIndex:int = -1):flash.text.TextFormat {
			return textField.getTextFormat(beginIndex, endIndex);
		}
		public function getTextRuns(beginIndex:int = 0, endIndex:int = 2147483647):Array {
			return textField.getTextRuns(beginIndex, endIndex);
		}
		public function getXMLText(beginIndex:int = 0, endIndex:int = 2147483647):String {
			return textField.getXMLText(beginIndex, endIndex);
		}
		public function insertXMLText(beginIndex:int, endIndex:int, richText:String, pasting:Boolean = false):void {
			textField.insertXMLText(beginIndex, endIndex, richText, pasting);
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Returns true if an embedded font is available with the specified fontName and fontStyle
		 * where Font.fontType is flash.text.FontType.EMBEDDED.  Starting with Flash Player 10,
		 * two kinds of embedded fonts can appear in a SWF file.  Normal embedded fonts are only used with 
		 * TextField objects.
		 * CFF embedded fonts are only used with the flash.text.engine classes.  The two types are distinguished by the 
		 * fontType property of the Font class, as returned by the enumerateFonts() function.
		 * 
		 *   TextField cannot use a font of type EMBEDDED_CFF. If embedFonts is set to true 
		 * and the only font available at run time with the specified name and style is of type EMBEDDED_CFF, 
		 * Flash Player fails to render the text, as if no embedded font were available with the specified name and style.If both EMBEDDED and EMBEDDED_CFF fonts are available with the same name and style, the EMBEDDED
		 * font is selected and text renders with the EMBEDDED font.
		 * @param	fontName	The name of the embedded font to check.
		 * @param	fontStyle	Specifies the font style to check.  Use flash.text.FontStyle
		 * @return	true if a compatible embedded font is available, otherwise false.
		 * @langversion	3.0
		 * @playerversion	Flash 10
		 * @playerversion	AIR 1.5
		 * @playerversion	Lite 4
		 * @throws	ArgumentError The fontStyle specified is not a member of flash.text.FontStyle.
		 */
		public static function isFontCompatible(fontName:String, fontStyle:String):Boolean {
			return TextField.isFontCompatible(fontName, fontStyle);
		}
		
		/**
		 * Replaces the current selection with the contents of the value parameter.
		 * The text is inserted at the position of the current selection, using the current default character
		 * format and default paragraph format. The text is not treated as HTML.
		 * 
		 *   You can use the replaceSelectedText() method to insert and delete text without disrupting
		 * the character and paragraph formatting of the rest of the text.Note: This method does not work if a style sheet is applied to the text field.
		 * @param	value	The string to replace the currently selected text.
		 * @throws	Error This method cannot be used on a text field with a style sheet.
		 */
		public function replaceSelectedText(value:String):void {
			textField.replaceSelectedText(value);
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Replaces the range of characters that the beginIndex and
		 * endIndex parameters specify with the contents
		 * of the newText parameter. As designed, the text from 
		 * beginIndex to endIndex-1 is replaced.  
		 * Note: This method does not work if a style sheet is applied to the text field.
		 * @param	beginIndex	The zero-based index value for the start position of the replacement range.
		 * @param	endIndex	The zero-based index position of the first character after the desired
		 *   text span.
		 * @param	newText	The text to use to replace the specified range of characters.
		 * @throws	Error This method cannot be used on a text field with a style sheet.
		 */
		public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
			textField.replaceText(beginIndex, endIndex, newText);
			if (toBitmap) {
				updateTextFormat();
			}				
		}
		
		/**
		 * Sets as selected the text designated by the index values of the
		 * first and last characters, which are specified with the beginIndex
		 * and endIndex parameters. If the two parameter values are the same,
		 * this method sets the insertion point, as if you set the 
		 * caretIndex property.
		 * @param	beginIndex	The zero-based index value of the first character in the selection
		 *  (for example, the first character is 0, the second character is 1, and so on).
		 * @param	endIndex	The zero-based index value of the last character in the selection.
		 * @internal	Need to add an example.
		 */
		public function setSelection(beginIndex:int, endIndex:int):void {
			textField.setSelection(beginIndex, endIndex);
			if (toBitmap) {
				updateTextFormat();
			}				
		}		
		
		
		/////////////////////////////////
		// TextFormat 
		////////////////////////////////		
		
		/**
		 * Sets the color of the text in a text field.
		 * @default = 0x000000;
		 */
		public function get color():* { return textFormat.color; }
		public function set color(value:*):void { 
			textFormat.color = value;
			updateTextFormat();				
		}	
		
		/**
		 * Sets the color of the text in a text field.
		 * @default = 0x000000;
		 */
		public function get textColor():* { return color; }
		public function set textColor(value:*):void {
			color = value;
		}			
		
		/**
		 * Sets the font size of the text.
		 * @default 15;
		 */
		public function get fontSize():* { return textFormat.size; }
		public function set fontSize(value:*):void {
			textFormat.size = value;
			updateTextFormat();		
		}		
		
		/**
		 * Sets the font size of the text. Same as fontSize.
		 * @default 15;
		 */
		public function get textSize():* { return fontSize; }
		public function set textSize(value:*):void {
			fontSize = value;
		}
		
		/**
		 * Sets the font of the text.
		 * @default "OpenSansRegular";
		 */
		public function get font():String { return textFormat.font; }
		public function set font(value:String):void {
			textFormat.font = value;
			updateTextFormat();			
		}
		
		/**
		 * Sets the line spacing of text.
		 */
		public function get leading():Object { return textFormat.leading; }
		public function set leading(value:Object):void {
			textFormat.leading = value;
			updateTextFormat();			
		}
		
		/**
		 * Sets the number of additional pixels to appear between each character.
		 * @default 0;
		 */
		public function get letterSpacing():Object { return textFormat.letterSpacing; }
		public function set letterSpacing(value:Object):void {
			textFormat.letterSpacing = value;
			updateTextFormat();			
		}
		
		/**
		 * Indicates whether text is underlined.
		 */
		public function get underline():Boolean { return textFormat.underline; }
		public function set underline(value:Boolean):void {
			textFormat.underline = value;
			updateTextFormat();			
		}
		
		/**
		 * Sets the gap between certain character pairs.
		 */
		public function get kerning():Boolean { return textFormat.kerning; }
		public function set kerning(value:Boolean):void {
			textFormat.kerning = value;
			updateTextFormat();			
		}
		
		private var _textAlign:String;
		/**
		 * Sets the alignment of text in text field.
		 */
        public function get textAlign():String { return textFormat.align; }   
        public function set textAlign(value:String):void {
            textFormat.align = value;
			updateTextFormat();		
        }		

		
		///////////////////////
		// Custom Properties
		//////////////////////

		/**
		 * Returns TextField object.
		 */
		public function get textField():TextField {
			return _textField;
		}
		
		/**
		 * Returns TextFormat object.
		 */
		public function get textFormat():TextFormat {
			return _textFormat;
		}		
		
		/**
		 * Sets y position of text.
		 */
		override public function get y():Number { return super.y; }
		override public function set y(value:Number):void {
			super.y = value;
			setY = value;
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function set width(value:Number):void {
			super.width = value;
			textField.width = value;
			updateTextFormat();
		}
		
		/**
		 * @inheritDoc
		 */		
		override public function set height(value:Number):void {
			super.height = value;
			textField.height = value;
			verticalAlign = verticalAlign;	
			updateTextFormat();			
		}		
		
		/**
		 * Sets the vertical alignment of the text field.
		 * @default false;
		 */
		public function get verticalAlign():Boolean { return _verticalAlign; }
		public function set verticalAlign(value:Boolean):void {
			_verticalAlign = value;
			if (_verticalAlign) {
				var sum:Number = 0;
				var i:int;
				for (i = 0; i < textField.numLines; i++) {
					sum += textField.getLineMetrics(i).height;
				}
				super.y = setY + (this.height - sum) / 2;
			}
			updateTextFormat();
		}						

		/**
		 * Sets the horizontal center of the text field.
		 */
		public function get horizontalCenter():Number { return _horizontalCenter; }
		public function set horizontalCenter(value:Number):void {
			_horizontalCenter = value;
			if (parent) {
				x = ((parent.width - width) / 2) + value;
			}
			updateTextFormat();
		}
		
		/**
		 * Sets the vertical center of the text field.
		 */
		public function get verticalCenter():Number { return _verticalCenter; }
		public function set verticalCenter(value:Number):void {
			_verticalCenter = value;
			if (parent) {
				y = ((parent.height - height) / 2) + value;
			}
			updateTextFormat();
		}
					
		/**
		 * Sets whether the text is left to scale as vector or gets locked as a bitmap.
		 * Same as toBitmap.
		 */
		public function get textBitmap():Boolean { return _textBitmap; }
		public function set textBitmap(value:Boolean):void {
			_textBitmap = value;
			updateTextFormat();
		}
		
		/**
		 * Sets whether the text is drawn as a bitmap. Unlike cacheAsBitmap, this is a 
		 * permanant bitmap cache. This a critical performance optimization for text fields 
		 * that are frequently scaled and rotated. Optimally, set true when scaling 
		 * and rotating and then set false when the transfomations have stopped.
		 */
		override public function set toBitmap(value:Boolean):void {
			textBitmap = value;
		}
		
		/**
		 * Sets text string. Same as text.
		 */
		public function get str():String {
			return text;
		}
		
		public function set str(value:String):void {
			text = value;
		}
		
		/**
		 * 
		 */			
		//public function get scrollable():Boolean { return _scrollable; }
		//public function set scrollable(value:Boolean):void {
			//_scrollable = value;
			//updateTextFormat();			
		//}
		
		
		/////////////////////
		// Custom Methods
		/////////////////////
		
		/**
		 * Redraws text with new settings. Generally called automatically
		 * when a new property value is set.
		 */	
		public function updateTextFormat():void {
			textField.defaultTextFormat = textFormat;
			
			if (b && b.bitmapData) {
				b.bitmapData.dispose();
				textField.visible = true;
			}					
			
			if (textBitmap) {
				b = DisplayUtils.resampledBitmap(textField, textField.width, textField.height);
				if (contains(b)) {
					removeChild(b);
				}
				textField.visible = false;
				addChild(b);
			}
			
			//if (scrollable) {
				//textField.scrollRect = new Rectangle(0, 0, this.width, this.height);
			//}
			textField.text = this.text;
		}
		
		
		//////////////////
		// Clone
		//////////////////
		
		/**
		 * @inheritDoc
		 */
		override public function clone():* { 
			removeChild(textField);			
			var clone:Text = super.clone();	
			addChild(textField);
			return clone;
		}	
		
		//////////////////
		// Dispose
		//////////////////
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			_textField = null;
			_textFormat = null;
			state = null;
			b = null;
			if (bmd) {
				bmd.dispose();
				bmd = null;
			}
		}
		
	}
}