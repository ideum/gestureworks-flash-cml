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
	
	/**
	 * ...
	 * @author Shaun
	 */
	public class ColorPicker extends ElementFactory
	{
		private var _containerRec:Sprite;
		private var _colorRec:TouchSprite;
		private var _colorSelector:Sprite;
		private var _baseGradientRec:Sprite;
		private var _hueBar:TouchSprite;
		private var _hueSelector:Sprite;
		private var _hueBarBMD:BitmapData;
		private var _selectedColorRec:Sprite;
		private var _colorSelectionBMD:BitmapData;
		private var _colorSpecs:Sprite;
		private var _colorMatrix:Matrix;		
		private var _colors:Array;
		private var _alphas:Array;
		private var _ratios:Array;		
		private var _colorRecWidth:Number = 300;
		private var _colorRecHeight:Number = 300;
		private var _baseColor:uint;
		private var _selectedColor:uint;
		private var _selectedColorTransform:ColorTransform;	
		
		private var _colorX:Number = 235;
		private var _colorY:Number = 85;
		private var _hueY:Number = 200;
		
		private var _hexText:TextElement;
		private var _hText:TextElement;
		private var _sText:TextElement;
		private var _brText:TextElement;
		private var _rText:TextElement;
		private var _gText:TextElement;
		private var _bText:TextElement;
		
		private var hue:Number;
		private var saturation:Number;
		private var brightness:Number;
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		
		
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
		
		private function drawContainer():void
		{
			_containerRec = new Sprite();
			var g:Graphics = _containerRec.graphics;
			g.beginFill(0xE8E8E8);			
			g.drawRect(0, 0, 480, 375);
			g.endFill();
			addChild(_containerRec);
		}
		
		private function drawHueBar():void
		{		
			_hueBar = new TouchSprite();
			_hueBar.gestureList = { "n-drag":true };
			_hueBar.gestureReleaseInertia = false;
			_hueBar.addEventListener(GWGestureEvent.DRAG, hueBarHandler);
			_hueBar.addEventListener(TouchEvent.TOUCH_BEGIN, hueBarHandler);
			
			var barWidth:Number = 20;
			_hueBarBMD = new BitmapData(barWidth, _colorRecHeight);
			var g:Graphics = _hueBar.graphics;
			
			var rads:Number = 2 * Math.PI / 360;
			var interval:Number = _colorRecHeight / 360;			
			for (var i:int = 0; i < 360; i++)
			{
				var color:uint = angleToColor(rads * i); 
				g.beginFill(color, 1);
				g.drawRect(0, i*interval, barWidth, interval);
			}	
			_hueBar.x = 350;
			_hueBar.y = 25;
			_hueBarBMD.draw(_hueBar);
			_baseColor = _hueBarBMD.getPixel(0, _hueY);				
			
			var borderRec:Sprite = new Sprite();
			g = borderRec.graphics;
			g.lineStyle(1, 0x000000);
			g.drawRect(0, 0, barWidth, _colorRecHeight);
			borderRec.x = _hueBar.x;
			borderRec.y = _hueBar.y;
			
			if (_containerRec)
			{
				_containerRec.addChild(_hueBar);
				_containerRec.addChild(borderRec);
				drawHueSelector();
			}
		}
		
		private function drawColorRec():void
		{
			_colorRec = new TouchSprite();
			_baseGradientRec = new Sprite();
			_colorSelector = new Sprite();		
			_colorMatrix = new Matrix();			
			
			_colorRec.gestureList = { "n-drag":true };
			_colorRec.gestureReleaseInertia = false;
			_colorRec.addEventListener(GWGestureEvent.DRAG, colorSelectionHandler);
			_colorRec.addEventListener(TouchEvent.TOUCH_BEGIN, colorSelectionHandler);			

			_colors = [0x000000, 0x000000];
			_alphas = [0, 1];
			_ratios = [0, 255];			
			_colorMatrix.createGradientBox(_colorRecWidth, _colorRecHeight, Math.PI / 2, 0, 0); 
			
			var g:Graphics = _colorRec.graphics;
			g.lineStyle(1, 0x000000);
			g.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _ratios, _colorMatrix); 
			g.drawRect(0, 0, _colorRecWidth, _colorRecHeight);
			g.endFill();
			
			_colorRec.width = 300;
			_colorRec.height = 300;
			
			//trace(_colorRec.width, _colorRec.height, _colorRecWidth, _colorRecHeight);
			
			_colorRec.x = 25;
			_colorRec.y = 25;
			
			g = _colorSelector.graphics;
			g.lineStyle(1, 0x000000);
			g.drawCircle(_colorRec.x, _colorRec.y, 6);
			g.lineStyle(1, 0xFFFFFF);
			g.drawCircle(_colorRec.x, _colorRec.y, 5);					
			
			if (_containerRec)
			{
				_containerRec.addChild(_baseGradientRec);
				_containerRec.addChild(_colorRec);
				_containerRec.addChild(_colorSelector);
				updateBaseGradient();
			}
		}
		
		private function drawSelectedColorRec():void
		{
			var borderRec:Sprite = new Sprite();
			_selectedColorRec = new Sprite();
			_selectedColorTransform = new ColorTransform();
								
			var g:Graphics = _selectedColorRec.graphics;
			g.beginFill(_selectedColor);
			g.drawRect(0, 0, 60, 60);
			g.endFill();			
			_selectedColorRec.x = 395;
			_selectedColorRec.y = 25;
						
			g = borderRec.graphics;
			g.lineStyle(1, 0x000000);
			g.drawRect(0, 0, _selectedColorRec.width, _selectedColorRec.height);
			borderRec.x = _selectedColorRec.x;
			borderRec.y = _selectedColorRec.y;
			
			if (_containerRec)
			{
				_containerRec.addChild(_selectedColorRec);
				_containerRec.addChild(borderRec);
				updateSelectedColor();
			}
		}
		
		private function drawColorSpecs():void
		{
			var spacing:Number = 30;
			var _w:Number = 35;
			var xLoc:Number = _selectedColorRec.x;
			var yLoc:Number = _selectedColorRec.y + _selectedColorRec.height + 10;			
			
			_hText = createTextField("H:", _w, xLoc, yLoc, hue.toString(), 3);	
			_sText = createTextField("S:", _w, xLoc, yLoc += spacing, saturation.toString(), 3);
			_brText = createTextField("B:", _w, xLoc, yLoc += spacing, brightness.toString(), 3);
			_rText = createTextField("R:", _w, xLoc, yLoc += spacing, red.toString(), 3);
			_gText = createTextField("G:", _w, xLoc, yLoc += spacing, green.toString(), 3);
			_bText = createTextField("B:", _w, xLoc, yLoc += spacing, blue.toString(), 3);			
			_hexText = createTextField("#", 65, _colorRec.width / 2, _colorRec.y + _colorRecHeight + 10, getSelectedHexValue());	
			_brText.id = "Br:";
			
			if (_containerRec)
			{
				_containerRec.addChild(_hText);
				_containerRec.addChild(_sText);
				_containerRec.addChild(_brText);
				_containerRec.addChild(_rText);
				_containerRec.addChild(_gText);
				_containerRec.addChild(_bText);
				_containerRec.addChild(_hexText);			
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
			te.addEventListener(KeyboardEvent.KEY_DOWN, findColor);
			
			if (_containerRec)
				_containerRec.addChild(label);
						
			return te;
		}
		
		private function drawHueSelector():void 
		{
			var _x:Number = _hueBar.x, _y:Number = _hueBar.y;
			_hueSelector = new Sprite();
			var g:Graphics = _hueSelector.graphics;
			g.lineStyle(1, 0);
			g.beginFill(0x000000);
			g.moveTo(_x, _y);
			g.lineTo(_x-10, _y-6);
			g.lineTo(_x - 10, _y + 6);
			_x = _hueBar.x + _hueBar.width;
			g.moveTo(_x, _y);	
			g.lineTo(_x + 10, _y - 6);
			g.lineTo(_x + 10, _y + 6);
			g.endFill();
						
			if (_containerRec)
				_containerRec.addChild(_hueSelector);
		}
				
		protected function updateBaseGradient():void
		{		
			_colorMatrix = new Matrix();
			_colors = [_baseColor, _baseColor];
			_colorMatrix.createGradientBox(_colorRecWidth, _colorRecHeight, 0, 0, 0);
			
			var g:Graphics = _baseGradientRec.graphics;
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, _colors, _alphas, _ratios, _colorMatrix);
			g.drawRect(0, 0, _colorRecWidth, _colorRecHeight);
			g.endFill();			
			
			_colorSelectionBMD = new BitmapData(_colorRecWidth, _colorRecHeight);
			_colorSelectionBMD.draw(_baseGradientRec);
			_colorSelectionBMD.draw(_colorRec);
			
			_hueSelector.y = _hueY;
			
			_baseGradientRec.x = 25;
			_baseGradientRec.y = 25;
		}
		
		protected function updateSelectedColor(color:Number = -1):void
		{			
			_selectedColor = color != -1 ? color : _colorSelectionBMD.getPixel(_colorX, _colorY);
			_colorSelector.x = _colorX;
			_colorSelector.y = _colorY;						
			
			var rgb:Array = hexToRGB(_selectedColor);
			red = rgb[0];
			green = rgb[1];
			blue = rgb[2];						
			
			var hsb:Array = rgbToHSB(red, green, blue);
			hue = hsb[0];
			saturation = hsb[1];
			brightness = hsb[2];
			
			_selectedColorTransform.color = _selectedColor;
			_selectedColorRec.transform.colorTransform = _selectedColorTransform;															
		}
		
		private function updateSpecs():void
		{
			_hText.text = hue.toString();
			_sText.text= saturation.toString();
			_brText.text = brightness.toString();
			
			_rText.text = red.toString();
			_gText.text = green.toString();
			_bText.text = blue.toString();
			
			_hexText.text = getSelectedHexValue();
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
				_hueY = yVal;
				_baseColor =  _hueBarBMD.getPixel(0, _hueY);
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
				_colorX = xVal;
				_colorY = yVal;
				updateSelectedColor();
				updateSpecs();
			}
		}
		
		private function findColor(event:KeyboardEvent):void
		{
			if (event.keyCode != 13)
				return;
				
			var txt:TextElement = TextElement(event.target);
			var tgtId:String = txt.id;
			switch(tgtId)
			{
				case "#":
					updateSelectedColor(uint("0x"+txt.text));
					break;
				case "H:":
					hue = Number(txt.text);
					if (hue > 359 || hue < 0) hue = 0;
					break;
				case "S:":
					saturation = Number(txt.text);
					if (saturation > 100) saturation = 100;
					else if (saturation < 0) saturation = 0;
					break;	
				case "Br:":
					brightness = Number(txt.text);
					if (brightness > 100) brightness = 100;
					else if (brightness < 0) brightness = 0;
					break;
				case "R:":
					red = Number(txt.text);
					if (red > 255) red = 255;
					else if (red < 0) red = 0;
					var hsb:Array = rgbToHSB(red, green, blue);
					hue = hsb[0];
					saturation = hsb[1];
					brightness = hsb[2];
				case "G:":
					green = Number(txt.text);
					if (green > 255) green = 255;
					else if (green < 0) green = 0;
					var hsb:Array = rgbToHSB(red, green, blue);
					hue = hsb[0];
					saturation = hsb[1];
					brightness = hsb[2];
				case "B:":				
					blue = Number(txt.text);
					if (blue > 255) blue = 255;
					else if (blue < 0) blue = 0;
					var hsb:Array = rgbToHSB(red, green, blue);
					hue = hsb[0];
					saturation = hsb[1];
					brightness = hsb[2];
				default:
			}
			
			trace(hue, saturation, brightness);
			_hueY = hue * (_colorRecHeight / 360);
			_baseColor = _hueBarBMD.getPixel(0, _hueY);
			updateBaseGradient();
			trace(_hueY);
			//_colorX = saturation * (_colorRecWidth / 100);
			//_colorY = 300 - brightness * (_colorRecHeight / 100);
			//updateSelectedColor();
			//
			//updateSpecs();
		}
		
		public function getSelectedHexValue():String
		{
			return _selectedColor.toString(16).toUpperCase();
		}		
		
		public static function hexToRGB(hex:uint):Array
		{
			var rgb:Array = [
				Math.round((hex >> 16) & 0xFF),
				Math.round((hex >> 8) & 0xFF),
				Math.round(hex & 0xFF)
				]
				
			return rgb;
		}
		
		public static function rgbToHSB(r:Number, g:Number, b:Number):Array
		{
			var hue:Number, saturation:Number, brightness:Number;
			
			r /= 255;
			g /= 255;
			b /= 255;
			
			var max:Number = Math.max(r, g, b);
			var min:Number = Math.min(r, g, b);
			var delta:Number = max - min;
			
			hue = 0;
			brightness = max;
			saturation = max == 0 ? 0 : delta / max;
			
			if (delta != 0)
			{
				if (r == max)
					hue = (g - b) / delta;
				else
				{
					if (g == max)
						hue = 2 + (b - r) / delta;
					else
						hue = 4 + (r - g) / delta;
				}
				
				hue *= 60;
				if (hue < 0) hue += 360;
				
				hue = Math.round(hue);
				saturation =  Math.round(saturation *= 100);
				brightness = Math.round(brightness *= 100);				
			}
			
			return [hue, saturation, brightness];
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
		
	}

}