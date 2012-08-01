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
		private var _hexText:TextElement = new TextElement();
		private var _rText:TextElement = new TextElement();
		private var _gText:TextElement = new TextElement();
		private var _bText:TextElement = new TextElement();
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
			g.lineStyle(1, 0x000000);
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
			
			var rads:Number = 2 * Math.PI / _colorRecHeight;
			for (var i:int = 0; i < _colorRecHeight; i++)
			{
				var color:uint = angleToColor(rads * i); 
				g.beginFill(color, 1);
				g.drawRect(0, i, barWidth, 1);
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
				updateSelectedColorRec();
			}
		}
		
		private function drawColorSpecs():void
		{		
			var rgb:Array = hexToRGB(uint(getSelectedHexValue()));	
			
			var hexLabel:TextElement = new TextElement();
			hexLabel.autoSize = "left";
			hexLabel.text = "#";
			hexLabel.selectable = false;
			hexLabel.height = 27;
			hexLabel.x = _colorRec.width/2;
			hexLabel.y = _colorRec.y + _colorRec.height + 10;
			hexLabel.selectable = false;
			
			_hexText.width = 65;
			_hexText.text = getSelectedHexValue().substr(2);
			_hexText.maxChars = 6;
			_hexText.height = hexLabel.height;
			_hexText.x = hexLabel.x + hexLabel.width;
			_hexText.y = hexLabel.y;
			_hexText.background = true;
			_hexText.border = true;
			_hexText.type = "input";
			_hexText.scrollH = 0;
			_hexText.addEventListener(KeyboardEvent.KEY_DOWN, moveToPixel);
			
			var rLabel:TextElement = new TextElement();
			rLabel.autoSize = "left";
			rLabel.text = "R:";
			rLabel.selectable = false;
			rLabel.fontSize = 14;
			rLabel.x = _selectedColorRec.x;
			rLabel.y = _selectedColorRec.y + _selectedColorRec.height + 40;
			
			_rText.maxChars = 3;
			_rText.height = rLabel.height;
			_rText.width = 35;
			_rText.fontSize = rLabel.fontSize;
			_rText.text = rgb[0].toString();
			_rText.x = rLabel.x + rLabel.width+2;
			_rText.y = rLabel.y;
			_rText.border = true;
			_rText.background = true;
			
			var gLabel:TextElement = new TextElement();
			gLabel.autoSize = "left";
			gLabel.text = "G:";
			gLabel.selectable = false;
			gLabel.fontSize = 14;
			gLabel.x = rLabel.x;
			gLabel.y = rLabel.y + rLabel.height + 10;
			
			_gText.maxChars = 3;
			_gText.height = gLabel.height;
			_gText.width = 35;
			_gText.fontSize = gLabel.fontSize;
			_gText.text = rgb[1].toString();
			_gText.x = gLabel.x + gLabel.width+2;
			_gText.y = gLabel.y;
			_gText.border = true;
			_gText.background = true;
			
			var bLabel:TextElement = new TextElement();
			bLabel.autoSize = "left";
			bLabel.text = "B:";
			bLabel.selectable = false;
			bLabel.fontSize = 14;
			bLabel.x = gLabel.x;
			bLabel.y = gLabel.y + gLabel.height + 10;
			
			_bText.maxChars = 3;
			_bText.height = bLabel.height;
			_bText.width = 35;
			_bText.fontSize = bLabel.fontSize;
			_bText.text = rgb[2].toString();
			_bText.x = bLabel.x + bLabel.width+2;
			_bText.y = bLabel.y;
			_bText.border = true;
			_bText.background = true;									
									
			if (_containerRec)
			{
				_containerRec.addChild(hexLabel);
				_containerRec.addChild(_hexText);
				_containerRec.addChild(rLabel);
				_containerRec.addChild(_rText);
				_containerRec.addChild(gLabel);
				_containerRec.addChild(_gText);
				_containerRec.addChild(bLabel);
				_containerRec.addChild(_bText);
			}
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
		
		protected function updateSelectedColorRec():void
		{			
			_selectedColor = _colorSelectionBMD.getPixel(_colorX, _colorY);
			_selectedColorTransform.color = _selectedColor;
			_selectedColorRec.transform.colorTransform = _selectedColorTransform;
			_colorSelector.x = _colorX;
			_colorSelector.y = _colorY;			
						
			var rgb:Array = hexToRGB(uint(getSelectedHexValue()));
			_hexText.text = getSelectedHexValue().substr(2);
			_rText.text = rgb[0].toString();
			_gText.text = rgb[1].toString();
			_bText.text = rgb[2].toString();				
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
				updateSelectedColorRec();
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
				updateSelectedColorRec();
			}
		}
		
		private function moveToPixel(event:KeyboardEvent):void
		{
			if (event.keyCode != 13)
				return;
				
			var point:Point;
			if (event.target.text.length == 6)
			{
				_hueY = hueYVal(uint("0x" + event.target.text.toUpperCase()));
				_hexText.text = event.target.text.toUpperCase();
				_baseColor =  _hueBarBMD.getPixel(0, _hueY);
				updateBaseGradient();
				
				point = pixelLocation(uint("0x" + event.target.text.toUpperCase()));
				if (point)
				{
					_colorX = point.x;
					_colorY = point.y;
					trace("point", _colorX, _colorY);
					updateSelectedColorRec();
				}
			}
		}
		
		private function pixelLocation(hex:uint):Point
		{		
			var hsb:Array = getHSB(hex);
			var hue:Number = hsb[0];
			var saturation:Number = hsb[1];
			var brightness:Number = hsb[2];
			
			var _x:int = saturation * (300 / 100);
			var _y:int = 300 - brightness * (300 / 100);
			
			return new Point(_x, _y);
		}
		
		private function hueYVal(hex:uint):int
		{
			var hsb:Array = getHSB(hex);
			var hue:Number = hsb[0];
			var saturation:Number = hsb[1];
			var brightness:Number = hsb[2];
						
			
			trace("hsb",hue, saturation, brightness);
			return hue * (300 / 360);
		}
		
		public function getSelectedHexValue():String
		{
			return "0x"+_selectedColor.toString(16).toUpperCase();
		}
		
		public static function hexToRGB(hex:uint):Array
		{
			var rgb:Array = [
				(hex >> 16) & 0xFF,
				(hex >> 8) & 0xFF,
				hex & 0xFF
				]
				
			return rgb;
		}
		
		public static function getHue(hex:uint):Number
		{
			var rgb:Array = hexToRGB(hex);
			var r:Number = rgb[0];
			var g:Number = rgb[1];
			var b:Number = rgb[2];
			
			r /= 255;
			g /= 255;
			b /= 255;
			
			var max:Number = Math.max(r, g, b);
			var min:Number = Math.min(r, g, b);
			var h:Number, s:Number, l:Number = (max + min) / 2;
			
			if (max == min)
			{
				h = s = 0;
			}
			else
			{
				var d:Number = max - min;				
				switch(max)
				{
					case r: h = (g - b) / d + (g < b ? 6 : 0);break;
					case g: h = (b - r) / d + 2; break;
					case b: h = (r - g) / d + 4; break;
				}
				h /= 6;
				h = Math.round(h * 360);
			}
			trace(h, s, l);
			return h;
		}
		
		public static function getHSB(hex:uint):Array
		{
			var hue:Number, saturation:Number, brightness:Number;
			var rgb:Array = hexToRGB(hex);
			var r:Number = rgb[0];
			var g:Number = rgb[1];
			var b:Number = rgb[2];
			
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
				
				hue = hue;
				saturation = saturation *= 100;
				brightness = brightness *= 100;
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