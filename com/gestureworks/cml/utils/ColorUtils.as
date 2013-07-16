package com.gestureworks.cml.utils
{ 
	import flash.geom.ColorTransform;
	public class ColorUtils
	{
		/**
		 * Returns a random color as uint 
		 **/
		public static function randomColor():uint {
			return uint(Math.random() * 0xFFFFFF);
		}	
		
		
		/**
		 * RGBColorTransform Create an instance of the information.
		 * @param rgb RGB integer value that indicates (0x000000 - 0xFFFFFF)
		 * @param amount of fill adaptive value (0.0 - 1.0)
		 * @param alpha transparency (0.0 - 1.0)
		 * @return a new instance ColorTransform
		 * */
		public static function colorTransform (rgb: uint = 0, amount: Number = 1.0, 
                                alpha: Number = 1.0): ColorTransform
		{
			amount = (amount> 1)? 1: (amount <0)? 0: amount;
			alpha = (alpha> 1)? 1: (alpha <0)? 0: alpha;
			var r: Number = ((rgb>> 16) & 0xff) * amount;
			var g: Number = ((rgb>> 8) & 0xff) * amount;
			var b: Number = (rgb & 0xff) * amount;
			var a: Number = 1-amount;
			return new ColorTransform (a, a, a, alpha, r, g, b, 0);
		}


		public static function rgbSubtract(col1: uint, col2: uint): Array
		{
			var arr1:Array = ColorUtils.toRGB(col1);
			var arr2:Array = ColorUtils.toRGB(col2);
			return [arr1[0] - arr2[0], arr1[1] - arr2[1], arr1[2] - arr2[2]];
		}		
		
		
		/**
		 * Subtraction.  
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) is subtracted 
         * from the return numbers.
		 * @param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @return value subtracted Blend 
		 **/
		public static function subtract (col1: uint, col2: uint): uint
		{
			var colA: Array = toRGB (col1);
			var colB: Array = toRGB (col2);
			var r: uint = Math.max (Math.max (colB [0] - (256-colA [0]), 
                                                                colA [0] - (256-colB [0])), 0);
			var g: uint = Math.max (Math.max (colB [1] - (256-colA [1]), 
                                                                colA [1] - (256-colB [1])), 0);
			var b: uint = Math.max (Math.max (colB [2] - (256-colA [2]), 
                                                                colA [2] - (256-colB [2])), 0);
			return r <<16 | g <<8 | b;
		}
		
		/**
		 * Additive color. 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) Returns the value 
         * of the additive mixture.
		 * @param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @return the additive color
		 **/
		public static function sum (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.min (c1 [0] + c2 [0], 255);
			var g: uint = Math.min (c1 [1] + c2 [1], 255);
			var b: uint = Math.min (c1 [2] + c2 [2], 255);
			return r <<16 | g <<8 | b;
		}
		
		/**
		 * Subtractive. 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) Returns the value 
         * of the subtractive color.
		 * @param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @return the subtractive
		 **/
		public static function sub (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.max (c1 [0]-c2 [0], 0);
			var g: uint = Math.max (c1 [1]-c2 [1], 0);
			var b: uint = Math.max (c1 [2]-c2 [2], 0);
			return r <<16 | g <<8 | b;
		}
		
		/**
		 * Comparison (dark). 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) to compare,
         * RGB lower combined returns a numeric value for each number.
		 * @param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @return comparison (dark) values
		 **/
		public static function min (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.min (c1 [0], c2 [0]);
			var g: uint = Math.min (c1 [1], c2 [1]);
			var b: uint = Math.min (c1 [2], c2 [2]);
			return r <<16 | g <<8 | b;
		}
		
		/**
		 * Comparison (light). 
		 * 2 RGB single number that indicates (0x000000 0xFFFFFF up from) to compare, 
                 * RGB values combined with higher returns to their numbers.
		 * @param col1 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @param col2 RGB numbers show (0x000000 0xFFFFFF up from)
		 * @return comparison (light) value
		 **/
		public static function max (col1: uint, col2: uint): uint
		{
			var c1: Array = toRGB (col1);
			var c2: Array = toRGB (col2);
			var r: uint = Math.max (c1 [0], c2 [0]);
			var g: uint = Math.max (c1 [1], c2 [1]);
			var b: uint = Math.max (c1 [2], c2 [2]);
			return r <<16 | g <<8 | b;
		}
		
		/**
		 *	Values calculated from each RGB * RGB color value.
		 * @param r the red (R) indicating the number (0-255)
		 * @param g green (G) indicates the number (0-255)
		 * @param b blue (B) shows the number (0-255)
		 * @return obtained from the RGB color value for each indicating the number
		 **/
		public static function rgb (r: uint, g: uint, b: uint): uint
		{
			return r <<16 | g <<8 | b;
		}
	
		
		/**
		 * RGB figures show (0x000000 0xFFFFFF up from) the
		 * R, G, B returns an array divided into a number from 0 to 255, respectively.
		 *
		 * @param rgb RGB numbers show (0x000000 0xFFFFFF up from)
		 * @return array indicates the value of each color [R, G, B]
		 **/
		public static function toRGB (rgb: uint): Array
		{
			var r: uint = rgb>> 16 & 0xFF;
			var g: uint = rgb>> 8 & 0xFF;
			var b: uint = rgb & 0xFF;
			return [r, g, b];
		}
		

        /**
		 * RGB from the respective figures, HSV sequences in terms of returns.
		 * RGB values are as follows.
		 * R - a number from 0 to 255
		 * G - a number from 0 to 255
		 * B - a number from 0 to 255
		 *
		 * CMYK values are as follows.
		 * C - a number between 0 to 255 representing cyan
		 * M - number between 0 to 255 representing magenta
		 * Y - number between 0 to 255 representing yellow
		 * K - number between 0 to 255 representing black
		 *
		 * Can not compute, including alpha.
		 * @param r the red (R) indicating the number (0x00 to 0xFF to)
		 * @param g green (G) indicates the number (0x00 to 0xFF to)
		 * @param b blue (B) shows the number (0x00 to 0xFF to)
		 * @return CMYK values into an array of [H, S, V] 
		 **/
		public static function RGBtoCMYK( r:Number, g:Number, b:Number ):Array
		{
			var c:Number = 0;
			var m:Number = 0;
			var y:Number = 0;
			var k:Number = 0;
			var z:Number = 0;
			c = 255 - r;
			m = 255 - g;
			y = 255 - b;
			k = 255;
			
			if (c < k)
				k=c;
			if (m < k)
				k=m;
			if (y < k)
				k=y;
			if (k == 255)
			{
				c=0;
				m=0;
				y=0;
			}else
			{
				c=Math.round(255*(c-k)/(255-k));
				m=Math.round (255*(m-k)/(255-k));
				y=Math.round (255*(y-k)/(255-k));
			} 
			return [ c, m, y, k ];
		}
        
		/**
		 * RGB from each of the CMYK values to determine a return as an array.
		 * CMYK values are as follows.
		 * C - a number between 0 to 255 representing cyan
		 * M - number between 0 to 255 representing magenta
		 * Y - number between 0 to 255 representing yellow
		 * K - number between 0 to 255 representing black
		 * 
		 **/
		public static function CMYKtoRGB( c:Number, m:Number, y:Number, k:Number ):Array
        {
			c = 255 - c;
			m = 255 - m;
			y = 255 - y;
			k = 255 - k; 
			return [(255 - c) * (255 - k) / 255, 
						(255 - m) * (255 - k) / 255, (255 - y) * (255 - k) / 255];
        }
	
        /**
         * Sets the RGB value based on a hex/oct value hex as uint 
         * @param hex the hex/oct value of the RGB object.
         * 
         */
        public static function setByHex(hex:uint):Array 
		{ 
            var colorTransform:ColorTransform = new ColorTransform();
            colorTransform.color = hex;
            var r:uint = colorTransform.redOffset;
            var g:uint = colorTransform.greenOffset;
            var b:uint = colorTransform.blueOffset;
			var array:Array = new Array(3);
			array = [r, g, b];
			return array;
        }		
		
        /**
         * Gets the octal value of the RGB value as a string 
         * @return the octal value of the RGB object as a string
         * 
         */
        public static function getOctalString(rgb:Array):String
		{    
            return "0x"+getRGBHex(rgb);
        }
		
        /**
         * Gets the hex/oct value of the RGB object as uint 
         * @return the hex/oct value of the RGB object as uint 
         * 
         */
        public static function getUint(rgb:Array):uint
		{
            var colorTransform:ColorTransform = new ColorTransform();
            colorTransform.redOffset = rgb[0];
            colorTransform.greenOffset = rgb[1];
            colorTransform.blueOffset = rgb[2];
            return colorTransform.color;
        }		
		
       /**
         * Gets the 6 character string representing the RGB
         * @return a 6 character string representing the RGB
         * */
	   public static function getRGBHex(rgb:Array):String{
            var hexStr:String = convertChannelToHexStr(rgb[0])+convertChannelToHexStr(rgb[1])+convertChannelToHexStr(rgb[2]);
            var strLength:uint;
            
            strLength = hexStr.length;
               if (strLength < 6){
                   for (var j:uint; j < (6-strLength); j++){
                       hexStr += "0";
                   }
               }
               
            return hexStr;
        }
        
        /**
         * Gets a 6 character string representing the RGB
         * @param hex RGB hex/oct value as uint
         * @return a 6 character string representing the RGB hex/oct value in inputed in uint for as hex
         * 
         */
        public static function uintToRGBHex(hex:uint):String{
            var colorTransform:ColorTransform = new ColorTransform();
            colorTransform.color = hex;
            var rgb:Array = new Array(3);
			rgb = [colorTransform.redOffset, colorTransform.greenOffset, colorTransform.blueOffset];
            return ColorUtils.getRGBHex(rgb);
        }
        
        /**
         * Converts the uint chanel representation of a color to a hex string 
         * @param hex
         * @return the string representation of the hex, this does not return the RGB format of a hex 
         *              like 00ff00 use uintToRGBHex getting a string that is always 6  characters long
         */
        private static function convertChannelToHexStr(hex:uint):String {
            if (hex > 255){
                hex = 255;
            }
            
            var hexStr:String = hex.toString(16);
            
            if (hexStr.length < 2){
                hexStr = "0"+hexStr;
            }
               return hexStr;
        }		
		
		
	}
}