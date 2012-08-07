package com.gestureworks.cml.element 
{
	import com.codeazur.utils.HexUtils;
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.events.GWGestureEvent;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import com.gestureworks.core.TouchSprite;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.GradientType;
	import flash.utils.Dictionary;
	import unit_test.Main_3drotate;
	import flash.events.KeyboardEvent;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * ...
	 * @author Shaun
	 */
	public class ColorPicker extends ElementFactory
	{
		private var containerRec:Sprite;
		private var colorRec:TouchSprite;
		private var colorSelector:Sprite;
		private var baseGradientRec:Sprite;
		private var hueBar:TouchSprite;
		private var hueSelector:Sprite;
		private var hueBarBMD:BitmapData;
		private var selectedColorRec:Sprite;
		private var colorSelectionBMD:BitmapData;
		private var colorSpecs:Sprite;
		private var colorMatrix:Matrix;		
		private var colors:Array;
		private var alphas:Array;
		private var ratios:Array;		
		private var colorRecWidth:Number = 300;
		private var colorRecHeight:Number = 300;
		private var baseColor:uint;
		private var selectedColor:uint;
		private var selectedColorTransform:ColorTransform;	
		
		private var colorX:Number = 235;
		private var colorY:Number = 85;
		private var hueY:Number = 200;
		
		private var hexText:TextElement;
		private var hText:TextElement;
		private var sText:TextElement;
		private var brText:TextElement;
		private var rText:TextElement;
		private var gText:TextElement;
		private var bText:TextElement;
		
		private var hue:Number;
		private var saturation:Number;
		private var brightness:Number;
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		
		private var _skin:uint = 0xE8E8E8;			
		private static const HEX_RANGE:Number = Math.PI / 3;
				
		public function ColorPicker() 
		{
			super();
			init();			
		}
		
		public function init():void
		{
			drawContainer();
			drawHueBar();
			drawColorRec();
			drawSelectedColorRec();
			drawColorSpecs();
		}
		
		/**
		 * CML display initialization callback
		 */
		public override function displayComplete():void
		{
			super.displayComplete();
			init();
		}
		
		private function drawContainer():void
		{
			containerRec = new Sprite();
			var g:Graphics = containerRec.graphics;
			g.beginFill(_skin);			
			//g.beginFill(0xAC985F);
			g.drawRect(0, 0, 480, 375);
			g.endFill();
			addChild(containerRec);
		}
		
		private function drawHueBar():void
		{		
			hueBar = new TouchSprite();
			hueBar.gestureList = { "n-drag":true };
			hueBar.gestureReleaseInertia = false;
			hueBar.addEventListener(GWGestureEvent.DRAG, hueBarHandler);
			hueBar.addEventListener(TouchEvent.TOUCH_BEGIN, hueBarHandler);
			
			var barWidth:Number = 20;
			hueBarBMD = new BitmapData(barWidth, colorRecHeight);
			var g:Graphics = hueBar.graphics;
						
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
		
		private function drawColorRec():void
		{
			var bkg:Sprite = new Sprite();
			colorRec = new TouchSprite();
			baseGradientRec = new Sprite();
			colorSelector = new Sprite();		
			colorMatrix = new Matrix();			
			
			colorRec.gestureList = { "n-drag":true };
			colorRec.gestureReleaseInertia = false;
			colorRec.addEventListener(GWGestureEvent.DRAG, colorSelectionHandler);
			colorRec.addEventListener(TouchEvent.TOUCH_BEGIN, colorSelectionHandler);			

			colors = [0x000000, 0x000000];
			alphas = [0, 1];
			ratios = [0, 255];			
			colorMatrix.createGradientBox(colorRecWidth, colorRecHeight, Math.PI / 2, 0, 0); 
			
			var g:Graphics = colorRec.graphics;			
			g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, colorMatrix); 
			g.drawRect(0, 0, colorRecWidth, colorRecHeight);
			g.endFill();						
			colorRec.x = 25;
			colorRec.y = 25;
			
			g = bkg.graphics;
			g.lineStyle(1, 0x000000);
			g.beginFill(0xFFFFFF);
			g.drawRect(0, 0, colorRecWidth, colorRecHeight);
			g.endFill();
			bkg.x = 25;
			bkg.y = 25;
			
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
		
		private function createTextField(lab:String, _width:Number, _x:Number, _y:Number, _text:String = null, _maxChar:Number = 6):TextElement
		{
			var label:TextElement = new TextElement();
			label.autoSize = "left";
			label.text = lab;
			label.selectable = false;
			label.x = _x;
			label.y = _y;
			
			var te:TextElement = new TextElement();
			te.id = lab;
			te.width = _width;
			te.height = label.height;
			te.text = _text;
			te.x = label.x + label.width;
			te.y = label.y;
			te.background = true;
			te.border = true;
			te.type = "input";
			te.maxChars = _maxChar;
			te.scrollH = 0;		
			te.addEventListener(KeyboardEvent.KEY_DOWN, updateColor);
			
			if (containerRec)
				containerRec.addChild(label);
						
			return te;
		}	
				
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
		
		private function updateSelectedColor(color:Number = -1):void
		{			
			selectedColor = color != -1 ? color : colorSelectionBMD.getPixel(colorX, colorY);												
			
			getRGBFromHex();
			getHSBFromRGB();
			
			colorSelector.x = saturation * 300;
			colorSelector.y = (1 - brightness) * 300;			
			
			selectedColorTransform.color = selectedColor;
			selectedColorRec.transform.colorTransform = selectedColorTransform;															
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "selectedColor", "0x"+getSelectedHexValue()))
		}
		
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
		
		private function updateColor(event:KeyboardEvent):void
		{
			if (event.keyCode != 13)
				return;
				
			var txt:TextElement = TextElement(event.target);
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
					getRGBFromHSB();
					updateSelectedColor(uint(getHexFromRGB()));
					break;
				case "S:":
					saturation = Number(txt.text)/100;
					saturation = saturation > 1 ? 1 : (saturation < 0) ?  0 : saturation;
					getRGBFromHSB();
					updateSelectedColor(uint(getHexFromRGB()));
					break;	
				case "Br:":
					brightness = Number(txt.text) / 100;
					brightness = brightness > 1 ? 1 : (brightness < 0) ? 0 : brightness;
					getRGBFromHSB();
					updateSelectedColor(uint(getHexFromRGB()));
					break;
				case "R:":
					red = Number(txt.text);
					red = red > 255 ? 255 : (red < 0) ? 0 : red;
					updateSelectedColor(uint(getHexFromRGB()));
					break;
				case "G:":
					green = Number(txt.text);
					green = green > 255 ? 255 : (green < 0) ? 0 : green;
					updateSelectedColor(uint(getHexFromRGB()));
					break;
				case "B:":				
					blue = Number(txt.text);
					blue = blue > 255 ? 255 : (blue < 0) ? 0 : blue;
					updateSelectedColor(uint(getHexFromRGB()));
					break;
				default:
			}
			
			hueY = hue * (colorRecHeight / 359.99);
			updateBaseGradient();						
			updateSpecs();
		}
		
		public function getSelectedHexValue():String
		{
			var hexStr:String = selectedColor.toString(16).toUpperCase();
			var temp:String = hexStr;
			for (var l:int = hexStr.length; l < 6; l++)
				temp = "0" + temp;
				
			hexStr = temp;
			return hexStr;
		}		
		
		public function getRGBFromHex():void
		{
			red = Math.round((selectedColor >> 16) & 0xFF);
			green = Math.round((selectedColor >> 8) & 0xFF);
			blue = Math.round(selectedColor & 0xFF);
		}
		
		public function getRGBFromHSB():void
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
		
		public function getHSBFromRGB():void
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
		
		private function getHexFromRGB():String
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
		
		public function get skin():uint { return _skin; };
		public function set skin(s:uint):void
		{
			_skin = s;
		}
		
	}

}