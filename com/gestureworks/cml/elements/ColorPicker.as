package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * The ColorPicker element provides color selection capability by moving graphical indicators or adjusting color 
	 * properties to select hue and color variants. This class supports the drag gesture. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 			
		var cp:ColorPicker = new ColorPicker();
		cp.x = 100;
		cp.y = 100;
		cp.scaleX = cp.scaleX + 1;
		cp.scaleY = cp.scaleY + 1;
		cp.addEventListener(StateEvent.CHANGE, colorSelected);
		addChild(cp);
		

		function colorSelected(event:StateEvent):void
		{
			trace(event.value);
		}		
	 * </codeblock>
	 * 
	 * @author Shaun
	 * @see DatePicker
	 */
	public class ColorPicker extends TouchContainer
	{
		
		/**
		 * The main container for color picker components
		 */
		private var containerRec:Sprite;
		/**
		 * The sprite containing black and white gradient fill overlayed over baseGradientRec to create the dark to light versions of the color
		 */
		private var colorRec:TouchSprite;
		/**
		 * The circlular indicator marking the location of the currently selected color in the colorRec
		 */
		private var colorSelector:Sprite;
		/**
		 * The sprite containing the gradient fill of the base color selected in the hueBar
		 */
		private var baseGradientRec:Sprite;
		/**
		 * A sprite containing an RGB spectrum to choose a base color from
		 */
		private var hueBar:TouchSprite;
		/**
		 * The arrows indicator pin pointing the currently selected base color in the hueBar
		 */
		private var hueSelector:Sprite;
		/**
		 * The BitmapData of the hueBar to retrieve the currently selected pixel (hue)
		 */
		private var hueBarBMD:BitmapData;
		/**
		 * The rec containing the currently selected color 
		 */
		private var selectedColorRec:Sprite;
		/**
		 * The BitmapData of the colorRec to retireve the currently selected pixel (selectedColor)
		 */
		private var colorSelectionBMD:BitmapData;
		/**
		 * The matrix used for the gradient fills of the colorRec and baseGradientRec
		 */		
		private var colorMatrix:Matrix;		
		/**
		 * Array to hold graident values for gradient fills
		 */
		private var colors:Array;
		/**
		 * Array to hold alpha values for gradient fills
		 */
		private var alphas:Array;
		/**
		 * Array to hold ratio values for gradient fills
		 */
		private var ratios:Array;		
		/**
		 * The width of the colorRec and baseGradientRec
		 */		
		private var colorRecWidth:Number = 300;
		/**
		 * The height of the colorRec, baseGradientRec, and hueBar
		 */
		private var colorRecHeight:Number = 300;
		/**
		 * The base color of the gradient selected in the hueBar
		 */
		private var baseColor:uint;
		/**
		 * The currently selected color in the colorRec 
		 */
		private var selectedColor:uint;
		/**
		 * The color transform of the selected color
		 */
		private var selectedColorTransform:ColorTransform;	
		
		/**
		 * The x coordinate of the selectedColor in the colorRec
		 */
		private var colorX:Number = 235;
		/**
		 * The y coordinate of the selectedColor in the colorRec
		 */
		private var colorY:Number = 85;
		/**
		 * The y coordinate of the selected hue in the hueBar
		 */
		private var hueY:Number = 200;
		
		/**
		 * Displays the hexidecimal representation of the selectedColor
		 */
		private var hexText:Text;
		/**
		 * Displays the value of the base gradient in the hueBar
		 */
		private var hText:Text;
		/**
		 * Displays the selected color's saturation value
		 */
		private var sText:Text;
		/**
		 * Displays the selected color's brightness value
		 */
		private var brText:Text;
		/**
		 * Displays the selected color's red value
		 */
		private var rText:Text;
		/**
		 * Displays the selected color's green value
		 */
		private var gText:Text;
		/**
		 * Displays the selected color's blue value
		 */
		private var bText:Text;
		
		/**
		 * The selected base gradient in the hueBar
		 */
		private var hue:Number;
		/**
		 * The selected color's saturation
		 */
		private var saturation:Number;
		/**
		 * The selected color's brightness
		 */
		private var brightness:Number;
		/**
		 * The selected color's red value
		 */
		private var red:Number;
		/**
		 * The selected color's green value
		 */
		private var green:Number;
		/**
		 * The selected color's blue value
		 */
		private var blue:Number;
		
		/**
		 * The color of the containerRec
		 */
		private var _skin:uint = 0xE8E8E8;	
		
		/**
		 * The color of the labels
		 */
		private var _labelColor:uint = 0x000000;
		
		private static const HEX_RANGE:Number = Math.PI / 3;
			
		/**
		 * Constructor
		 */
		public function ColorPicker() 
		{
			super();
			mouseChildren = true;
			init();			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
		   super.dispose();
		   hueBarBMD = null;
		   colorSelectionBMD = null;
		   colorMatrix = null;
		   colors = null;
		   alphas = null;
		   ratios = null;
		   hexText = null;
		   hText = null;
		   sText = null;
		   sText = null;
		   brText = null;
		   rText = null;
		   gText = null;
		   bText = null;
		   selectedColorTransform = null;
		   selectedColorRec = null;
		   hueBarBMD = null;
		   hueSelector = null;
		   hueBar = null;
		   baseGradientRec = null;
		   colorSelector = null;
		   colorRec = null;
		   containerRec = null;
		}	
		   
		
		/**
		 * Initializes the components
		 */
		override public function init():void
		{
			drawContainer();
			drawHueBar();
			drawColorRec();
			drawSelectedColorRec();
			drawColorSpecs();
		}	
		
		/**
		 * Draw the container sprite to add all of the components to
		 */
		private function drawContainer():void
		{
			containerRec = new Sprite();
			var g:Graphics = containerRec.graphics;
			g.beginFill(skin);			
			g.drawRect(0, 0, 480, 375);
			g.endFill();
			addChild(containerRec);
		}
		
		/**
		 * Draw the hueBar to select the base color
		 */
		private function drawHueBar():void
		{		
			//use the drag and touch events to select hue
			hueBar = new TouchSprite();
			hueBar.gestureList = { "n-drag":true };
			hueBar.addEventListener(GWGestureEvent.DRAG, hueBarHandler);
			hueBar.addEventListener(GWTouchEvent.TOUCH_BEGIN, hueBarHandler);
			
			var barWidth:Number = 20;
			hueBarBMD = new BitmapData(barWidth, colorRecHeight);
			var g:Graphics = hueBar.graphics;
						
			//add spectrum to hueBar
			var rads:Number = 2 * Math.PI / 360;
			var interval:Number = colorRecHeight / 360;			
			for (var i:int = 0; i < 360; i++)
			{
				var color:uint = angleToColor(rads * i); 
				g.beginFill(color, 1);
				g.drawRect(0, i*interval, barWidth, interval);
			}	
			hueBar.x = 350;
			hueBar.y = 25;
			hueBarBMD.draw(hueBar);			
			
			var borderRec:Sprite = new Sprite();
			g = borderRec.graphics;
			g.lineStyle(1, 0x000000);
			g.drawRect(0, 0, barWidth, colorRecHeight);
			borderRec.x = hueBar.x;
			borderRec.y = hueBar.y;
			
			if (containerRec)
			{
				containerRec.addChild(hueBar);
				containerRec.addChild(borderRec);
				drawHueSelector();
			}
		}
		
		/**
		 * Draw indicator (arrows) for hue selection
		 */
		private function drawHueSelector():void 
		{
			var _x:Number = hueBar.x, _y:Number = hueBar.y;
			hueSelector = new Sprite();
			var g:Graphics = hueSelector.graphics;
			g.lineStyle(1, 0);
			g.beginFill(0x000000);
			g.moveTo(_x, _y);
			g.lineTo(_x-10, _y-6);
			g.lineTo(_x - 10, _y + 6);
			_x = hueBar.x + hueBar.width;
			g.moveTo(_x, _y);	
			g.lineTo(_x + 10, _y - 6);
			g.lineTo(_x + 10, _y + 6);
			g.endFill();
						
			if (containerRec)
				containerRec.addChild(hueSelector);
		}
		
		/**
		 * Draw the rectangle for selecting the color
		 */
		private function drawColorRec():void
		{
			var bkg:Sprite = new Sprite();
			colorRec = new TouchSprite();
			baseGradientRec = new Sprite();
			colorSelector = new Sprite();		
			colorMatrix = new Matrix();			
			
			//add drag and touch events to select color
			colorRec.gestureList = { "n-drag":true };
			colorRec.gestureReleaseInertia = false;
			colorRec.addEventListener(GWGestureEvent.DRAG, colorSelectionHandler);
			colorRec.addEventListener(GWTouchEvent.TOUCH_BEGIN, colorSelectionHandler);			
			
			colors = [0x000000, 0x000000];
			alphas = [0, 1];
			ratios = [0, 255];			
			colorMatrix.createGradientBox(colorRecWidth, colorRecHeight, Math.PI / 2, 0, 0); 
				
			//black gradient fill overlay
			var g:Graphics = colorRec.graphics;			
			g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, colorMatrix); 
			g.drawRect(0, 0, colorRecWidth, colorRecHeight);
			g.endFill();						
			colorRec.x = 25;
			colorRec.y = 25;
			
			//static white background
			g = bkg.graphics;
			g.lineStyle(1, 0x000000);
			g.beginFill(0xFFFFFF);
			g.drawRect(0, 0, colorRecWidth, colorRecHeight);
			g.endFill();
			bkg.x = colorRec.x;
			bkg.y = colorRec.y;
			
			//draw the circular inidicator to mark the location of the currently selected color
			g = colorSelector.graphics;
			g.lineStyle(1, 0x000000);
			g.drawCircle(colorRec.x, colorRec.y, 6);
			g.lineStyle(1, 0xFFFFFF);
			g.drawCircle(colorRec.x, colorRec.y, 5);					
			
			if (containerRec)
			{
				containerRec.addChild(bkg);
				containerRec.addChild(baseGradientRec);
				containerRec.addChild(colorRec);
				containerRec.addChild(colorSelector);
				updateBaseGradient();
			}
		}
		
		/**
		 * Draw the component containing the currently selected color
		 */
		private function drawSelectedColorRec():void
		{
			var borderRec:Sprite = new Sprite();
			selectedColorRec = new Sprite();
			selectedColorTransform = new ColorTransform();
								
			var g:Graphics = selectedColorRec.graphics;
			g.beginFill(selectedColor);
			g.drawRect(0, 0, 60, 60);
			g.endFill();			
			selectedColorRec.x = 395;
			selectedColorRec.y = 25;
						
			g = borderRec.graphics;
			g.lineStyle(1, 0x000000);
			g.drawRect(0, 0, selectedColorRec.width, selectedColorRec.height);
			borderRec.x = selectedColorRec.x;
			borderRec.y = selectedColorRec.y;
			
			if (containerRec)
			{
				containerRec.addChild(selectedColorRec);
				containerRec.addChild(borderRec);
				updateSelectedColor();
			}
		}
		
		/**
		 * Draw the text elements containing the hexadecimal, HSB, and RGB values of the selected color
		 */
		private function drawColorSpecs():void
		{
			var spacing:Number = 30;
			var _w:Number = 35;
			var xLoc:Number = selectedColorRec.x;
			var yLoc:Number = selectedColorRec.y + selectedColorRec.height + 10;			
			
			hText = createTextField("H:", _w, xLoc, yLoc, hue.toString(), 3);	
			sText = createTextField("S:", _w, xLoc, yLoc += spacing, Math.round(saturation*100).toString(), 3);
			brText = createTextField("B:", _w, xLoc, yLoc += spacing, Math.round(brightness*100).toString(), 3);
			rText = createTextField("R:", _w, xLoc, yLoc += spacing, red.toString(), 3);
			gText = createTextField("G:", _w, xLoc, yLoc += spacing, green.toString(), 3);
			bText = createTextField("B:", _w, xLoc, yLoc += spacing, blue.toString(), 3);			
			hexText = createTextField("#", 65, colorRec.width / 2, colorRec.y + colorRecHeight + 10, getSelectedHexValue());	
			brText.id = "Br:";
			
			if (containerRec)
			{
				containerRec.addChild(hText);
				containerRec.addChild(sText);
				containerRec.addChild(brText);
				containerRec.addChild(rText);
				containerRec.addChild(gText);
				containerRec.addChild(bText);
				containerRec.addChild(hexText);			
			}
		}
		
		/**
		 * Creates an editable textfield and associated label based on the provided arguments
		 * @param	lab  the label name
		 * @param	_width  the width of the text field
		 * @param	_x  the x location of the text field
		 * @param	_y  the y location of the text field
		 * @param	_text  the content of the text field
		 * @param	_maxChar  the character limit of the text field
		 * @return  the resulting text element
		 */
		protected function createTextField(lab:String, _width:Number, _x:Number, _y:Number, _text:String = null, _maxChar:Number = 6):Text
		{
			var label:Text = new Text();
			label.autoSize = "left";
			label.color = labelColor;
			label.text = lab;
			label.selectable = false;
			label.x = _x;
			label.y = _y;
			
			var te:Text = new Text();
			te.id = lab;
			te.width = _width;
			te.height = label.height;
			te.text = _text;
			te.x = label.x + 25;
			te.y = label.y;
			te.background = true;
			te.border = true;
			te.type = "input";
			te.maxChars = _maxChar;
			te.scrollH = 0;		
			te.selectable = true;
			te.addEventListener(KeyboardEvent.KEY_DOWN, updateColorByEntry);
			
			if (containerRec)
				containerRec.addChild(label);
						
			return te;
		}	
				
		/**
		 * Retrieve the selected hue from the hueBar and update the base color of the colorRec
		 */
		protected function updateBaseGradient():void
		{		
			colorMatrix = new Matrix();			
			hueSelector.y = hueY;
			baseColor = hueBarBMD.getPixel(0, hueY);	
			colors = [baseColor, baseColor];
			colorMatrix.createGradientBox(colorRecWidth, colorRecHeight, 0, 0, 0);
			
			var g:Graphics = baseGradientRec.graphics;
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, colorMatrix);
			g.drawRect(0, 0, colorRecWidth, colorRecHeight);
			g.endFill();			
			
			colorSelectionBMD = new BitmapData(colorRecWidth, colorRecHeight);
			colorSelectionBMD.draw(baseGradientRec);
			colorSelectionBMD.draw(colorRec);			
			
			baseGradientRec.x = 25;
			baseGradientRec.y = 25;
		}
		
		/**
		 * The primary update function called each time a change event occurs. Assigns the selectedColor value by argument or by retrieving the pixel 
		 * currently selected in the colorRec, updates the color specs and adjusts the location of the colorSelector accordingly.  
		 * @param	color  the color to assign as the selectedColor
		 */
		protected function updateSelectedColor(color:Number = -1):void
		{			
			selectedColor = color != -1 ? color : colorSelectionBMD.getPixel(colorX, colorY);												
			
			calculateRGBFromHex();
			calculateHSBFromRGB();
			
			colorSelector.x = saturation * 300;
			colorSelector.y = (1 - brightness) * 300;			
			
			selectedColorTransform.color = selectedColor;
			selectedColorRec.transform.colorTransform = selectedColorTransform;	
			
			//dispatches a state event with the hexadecimal of the selected color
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "selectedColor", "0x"+getSelectedHexValue(), true))
		}
		
		/**
		 * Update the text fields of the color properties
		 */
		private function updateSpecs():void
		{
			hText.text = Math.round(hue).toString();
			sText.text= Math.round(saturation*100).toString();
			brText.text = Math.round(brightness*100).toString();
			
			rText.text = red.toString();
			gText.text = green.toString();
			bText.text = blue.toString();
			
			hexText.text = getSelectedHexValue();
		}
		
		/**
		 * Handles the hue change events from the hueBar
		 * @param	event  occurs when the hueBar is touched or dragged
		 */
		private function hueBarHandler(event:*):void
		{
			var yVal:Number;
			if (event is GWGestureEvent)
				yVal = event.value.localY;
			else
				yVal = event.localY;
		
			if (yVal >= 0 && yVal < event.target.height)
			{		
				hueY = yVal;
				updateBaseGradient();
				updateSelectedColor();
				updateSpecs();
			}
		}
		
		/**
		 * Handles the color change events from the colorRec
		 * @param	event  occurs when the colorRec is touched or dragged
		 */
		private function colorSelectionHandler(event:*):void
		{
			var xVal:Number, yVal:Number;
			if (event is GWGestureEvent)
			{
				xVal = event.value.localX;
				yVal = event.value.localY;
			}
			else
			{
				xVal = event.localX;
				yVal = event.localY;
			}
			if (xVal > 0 && xVal < event.target.width && yVal > 0 && yVal < event.target.height)
			{					
				colorX = xVal;
				colorY = yVal;
				updateSelectedColor();
				updateSpecs();
			}
		}
		
		/**
		 * Updates the hue, selected color, and other color property text fields when a custom spec is
		 * submitted
		 * @param	event  occurs when a text element changes
		 */
		private function updateColorByEntry(event:KeyboardEvent):void
		{
			//requires 'ENTER' key to submit change
			if (event.keyCode != 13)
				return;
				
			var txt:Text = DisplayUtils.getParentType(Text, event.target) as Text; 
			var tgtId:String = txt.id;
			var hsb:Array;
			switch(tgtId)
			{
				case "#":
					updateSelectedColor(uint("0x"+txt.text));
					break;
				case "H:":
					hue = Number(txt.text);
					if (hue > 359 || hue < 0) hue = 0;
					calculateRGBFromHSB();
					updateSelectedColor(uint(calculateHexFromRGB()));
					break;
				case "S:":
					saturation = Number(txt.text)/100;
					saturation = saturation > 1 ? 1 : (saturation < 0) ?  0 : saturation;
					calculateRGBFromHSB();
					updateSelectedColor(uint(calculateHexFromRGB()));
					break;	
				case "Br:":
					brightness = Number(txt.text) / 100;
					brightness = brightness > 1 ? 1 : (brightness < 0) ? 0 : brightness;
					calculateRGBFromHSB();
					updateSelectedColor(uint(calculateHexFromRGB()));
					break;
				case "R:":
					red = Number(txt.text);
					red = red > 255 ? 255 : (red < 0) ? 0 : red;
					updateSelectedColor(uint(calculateHexFromRGB()));
					break;
				case "G:":
					green = Number(txt.text);
					green = green > 255 ? 255 : (green < 0) ? 0 : green;
					updateSelectedColor(uint(calculateHexFromRGB()));
					break;
				case "B:":				
					blue = Number(txt.text);
					blue = blue > 255 ? 255 : (blue < 0) ? 0 : blue;
					updateSelectedColor(uint(calculateHexFromRGB()));
					break;
			}
			
			hueY = hue * (colorRecHeight / 359.99);
			updateBaseGradient();						
			updateSpecs();
		}
		
		/**
		 * Returns the hex representation of the selectedColor as a String
		 * @return  the hex representation of the selectedColor
		 */
		public function getSelectedHexValue():String
		{
			var hexStr:String = selectedColor.toString(16).toUpperCase();
			var temp:String = hexStr;
			for (var l:int = hexStr.length; l < 6; l++)
				temp = "0" + temp;
				
			hexStr = temp;
			return hexStr;
		}		
		
		/**
		 * Calculates the selectedColor's RGB values
		 */
		public function calculateRGBFromHex():void
		{
			red = Math.round((selectedColor >> 16) & 0xFF);
			green = Math.round((selectedColor >> 8) & 0xFF);
			blue = Math.round(selectedColor & 0xFF);
		}
		
		/**
		 * Calculates the color's RGB values from its HSB values
		 */
		public function calculateRGBFromHSB():void
		{
			 red = brightness;
			 green = brightness;
			 blue = brightness;			 
			 
			  var tHue:Number = (hue / 60);
			  var i:Number = Math.floor(tHue);
			  var f:Number = tHue - i;
			  var p:Number = brightness * (1 - saturation);
			  var q:Number = brightness * (1 - saturation * f);
			  var t:Number = brightness * (1 - saturation * (1 - f));
			  switch(i)
			  {
				case 0:
				  red = brightness; green = t; blue = p;
				  break;
				case 1:
				  red = q; green = brightness; blue = p;
				  break;
				case 2:
				  red = p; green = brightness; blue = t;
				  break;
				case 3:
				  red = p; green = q; blue = brightness;
				  break;
				case 4:
				  red = t; green = p; blue = brightness;
				  break;
				default:
				  red = brightness; green = p; blue = q;
				  break;
			  }
			  
			  red = Math.round(red * 255);
			  green = Math.round(green * 255);
			  blue = Math.round(blue * 255);
		}
		
		/**
		 * Calculates the color's HSB values from its RGB values
		 */
		public function calculateHSBFromRGB():void
		{
			  var r:Number = red / 255;
			  var g:Number = green / 255;
			  var b:Number = blue / 255;
			  
		      var max:Number = Math.max(Math.max(r, g), b);
			  var min:Number = Math.min(Math.min(r, g), b);
			 
			  brightness = max;
			 
			  saturation = 0;
			  if(max != 0)
				saturation = 1 - min/max;
			   
			  hue = 0;
			  if(min == max)
				return;
			 
			  var delta:Number = (max - min);
			  if (r == max)
				hue = (g - b) / delta;
			  else if (g == max)
				hue = 2 + ((b - r) / delta);
			  else
				hue = 4 + ((r - g) / delta);
			  hue = hue * 60;
			  if(hue <0)
				hue += 360;						
		}		
		
		/**
		 * Calculates the color's hex value from its RGB values
		 * @return  a hexadecimal String
		 */
		private function calculateHexFromRGB():String
		{
		  var rStr:String = red.toString(16);
		  if (rStr.length == 1)
			rStr = "0"+ rStr;
		  var gStr:String = green.toString(16);
		  if (gStr.length == 1)
			gStr = "0" + gStr;
		  var bStr:String = blue.toString(16);
		  if (bStr.length == 1)
			bStr = "0" + bStr;
		  return ("0x" + rStr + gStr + bStr).toUpperCase();				
		}
		
		/**
		 * Returns a 24-bit colour from an angle in radians.  The brightness
		 * value is just a multiplier that can darken the final colour as the
		 * value of brightness aproaches 0.
		 */
		private static function angleToColor(angle:Number, brightness:Number = 1):uint {
			angle %= 2*Math.PI;
			
			var r:Number, g:Number, b:Number;
			var hex_area:uint = Math.floor(angle / HEX_RANGE);
			
			switch (hex_area) {
				case 0: r = 1; b = 0; break;
				case 1: g = 1; b = 0; break;
				case 2: r = 0; g = 1; break;
				case 3: r = 0; b = 1; break;
				case 4: g = 0; b = 1; break;
				case 5: r = 1; g = 0; break;
			}
			
			if (isNaN(r)) r = magnitudeFromHexArea(angle, hex_area);
			else if (isNaN(g)) g = magnitudeFromHexArea(angle, hex_area);
			else if (isNaN(b)) b = magnitudeFromHexArea(angle, hex_area);
			
			return ((r * brightness * 255) << 16) | ((g * brightness * 255) << 8) | (b * brightness * 255);
		}
		
		/**
		 * Returns a value 0..1 indicating the magnitude of the location.
		 */
		private static function magnitudeFromHexArea(angle:Number, hex_area:uint):Number {
			angle -= (hex_area * HEX_RANGE);
			if ((hex_area % 2) != 0) angle = HEX_RANGE - angle;// odd hex areas need their slope inverted
			return (angle / HEX_RANGE);
		}
		
		/**
		 * The skin color of the containerRec
		 */
		public function get skin():uint { return _skin; }
		public function set skin(s:uint):void
		{
			_skin = s;
		}
		
		/**
		 * The color of the labels
		 */
		public function get labelColor():uint { return _labelColor; }
		public function set labelColor(c:uint):void
		{
			_labelColor = c;
		}
		
	}

}