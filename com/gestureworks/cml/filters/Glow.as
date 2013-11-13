package com.gestureworks.cml.filters
{
	import flash.filters.GlowFilter;

	/**
	 * The Glow class lets you apply a glow effect to display objects.
	 * You have several options for the style of the 
	 * glow, including inner or outer glow and knockout mode. 
	 * The glow filter is similar to the drop shadow filter with the <codeph class="+ topic/ph pr-d/codeph ">distance</codeph>
	 * and <codeph class="+ topic/ph pr-d/codeph ">angle</codeph> properties of the drop shadow filter set to 0. 
	 * You can apply the filter to any display object (that is, objects that inherit from the DisplayObject class), 
	 * such as MovieClip, SimpleButton, TextField, and Video objects, as well as to BitmapData objects.
	 * 
	 *   <p class="- topic/p ">The use of filters depends on the object to which you apply the filter:</p><ul class="- topic/ul "><li class="- topic/li ">To apply filters to display objects, use the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property (inherited from DisplayObject). Setting the <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> 
	 * property of an object does not modify the object, and you can remove the filter by clearing the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property. </li><li class="- topic/li ">To apply filters to BitmapData objects, use the <codeph class="+ topic/ph pr-d/codeph ">BitmapData.applyFilter()</codeph> method.
	 * Calling <codeph class="+ topic/ph pr-d/codeph ">applyFilter()</codeph> on a BitmapData object takes the source BitmapData object 
	 * and the filter object and generates a filtered image as a result.</li></ul><p class="- topic/p ">If you apply a filter to a display object, the <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> property of the 
	 * display object is set to <codeph class="+ topic/ph pr-d/codeph ">true</codeph>. If you clear all filters, the original value of 
	 * <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> is restored.</p><p class="- topic/p ">This filter supports Stage scaling. However, it does not support general scaling, rotation, and 
	 * skewing. If the object itself is scaled (if <codeph class="+ topic/ph pr-d/codeph ">scaleX</codeph> and <codeph class="+ topic/ph pr-d/codeph ">scaleY</codeph> are 
	 * set to a value other than 1.0), the filter is not scaled. It is scaled only when the user zooms
	 * in on the Stage.</p><p class="- topic/p ">A filter is not applied if the resulting image exceeds the maximum dimensions.
	 * In  AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in width or height, 
	 * and the total number of pixels cannot exceed 16,777,215 pixels. (So, if an image is 8,191 pixels 
	 * wide, it can only be 2,048 pixels high.) In Flash Player 9 and earlier and AIR 1.1 and earlier, 
	 * the limitation is 2,880 pixels in height and 2,880 pixels in width.
	 * For example, if you zoom in on a large movie clip with a filter applied, the filter is 
	 * turned off if the resulting image exceeds the maximum dimensions.</p>
	 * 
	 */
	public class Glow
	{
		/**
		 * Initializes a new Glow instance with the specified parameters.
		 * @param	color	The color of the glow, in the hexadecimal format 
		 *   0xRRGGBB. The default value is 0xFF0000.
		 * @param	alpha	The alpha transparency value for the color. Valid values are 0 to 1. For example,
		 *   .25 sets a transparency value of 25%.
		 * @param	blurX	The amount of horizontal blur. Valid values are 0 to 255 (floating point). Values
		 *   that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized 
		 *   to render more quickly than other values.
		 * @param	blurY	The amount of vertical blur. Valid values are 0 to 255 (floating point). 
		 *   Values that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized 
		 *   to render more quickly than other values.
		 * @param	strength	The strength of the imprint or spread. The higher the value, 
		 *   the more color is imprinted and the stronger the contrast between the glow and the background. 
		 *   Valid values are 0 to 255.
		 * @param	quality	The number of times to apply the filter. Use the BitmapFilterQuality constants:
		 *   BitmapFilterQuality.LOWBitmapFilterQuality.MEDIUMBitmapFilterQuality.HIGHFor more information, see the description of the quality property.
		 * @param	inner	Specifies whether the glow is an inner glow. The value  true specifies
		 *   an inner glow. The value false specifies an outer glow (a glow
		 *   around the outer edges of the object).
		 * @param	knockout	Specifies whether the object has a knockout effect. The value true
		 *   makes the object's fill transparent and reveals the background color of the document.
		 */
		public function Glow(color:uint = 16711680, alpha:Number = 1, blurX:Number = 6, blurY:Number = 6, strength:Number = 2, quality:int = 1, inner:Boolean = false, knockout:Boolean = false)
		{		
			_color = color;
			_alpha = alpha;
			_blurX = blurX
			_blurY = blurY;
			_strength = strength;
			_quality = quality;
			_inner = inner;
			_knockout = knockout;
		}
		
		
		public var _alpha:Number = 1;
		/**
		 * The alpha transparency value for the color. Valid values are 0 to 1. 
		 * For example,
		 * .25 sets a transparency value of 25%. The default value is 1.
		 */
		public function get alpha () : Number { return _alpha; }
		public function set alpha (value:Number) : void { _alpha = value };

		
		private var _blurX:Number = 6;
		/**
		 * The amount of horizontal blur. Valid values are 0 to 255 (floating point). The
		 * default value is 6. Values that are a power of 2 (such as 2, 4, 
		 * 8, 16, and 32) are optimized 
		 * to render more quickly than other values.
		 */
		public function get blurX () : Number { return _blurX; }
		public function set blurX (value:Number) : void { _blurX = value; }

		
		private var _blurY:Number = 6;		
		/**
		 * The amount of vertical blur. Valid values are 0 to 255 (floating point). The
		 * default value is 6. Values that are a power of 2 (such as 2, 4, 
		 * 8, 16, and 32) are optimized 
		 * to render more quickly than other values.
		 */
		public function get blurY () : Number { return _blurY; }
		public function set blurY (value:Number) : void { _blurY = value; }

		
		private var _color:uint = 0xFF0000;		
		/**
		 * The color of the glow. Valid values are in the hexadecimal format 
		 * 0xRRGGBB. The default value is 0xFF0000.
		 */
		public function get color () : uint { return _color; }
		public function set color (value:uint) : void { _color = value; }

		
		private var _inner:Boolean = false;		
		/**
		 * Specifies whether the glow is an inner glow. The value true indicates 
		 * an inner glow. The default is false, an outer glow (a glow
		 * around the outer edges of the object).
		 */
		public function get inner () : Boolean { return _inner; }
		public function set inner (value:Boolean) : void { _inner = value; }

		
		private var _knockout:Boolean = false;
		/**
		 * Specifies whether the object has a knockout effect. A value of true 
		 * makes the object's fill transparent and reveals the background color of the document. The 
		 * default value is false (no knockout effect).
		 */
		public function get knockout () : Boolean { return _knockout; }
		public function set knockout (value:Boolean) : void { _knockout = value; }

		
		private var _quality:int = 1;
		/**
		 * The number of times to apply the filter. The default value is BitmapFilterQuality.LOW, 
		 * which is equivalent to applying the filter once. The value BitmapFilterQuality.MEDIUM
		 * applies the filter twice; the value BitmapFilterQuality.HIGH applies it three times.
		 * Filters with lower values are rendered more quickly.
		 * 
		 *   For most applications, a quality value of low, medium, or high is sufficient. 
		 * Although you can use additional numeric values up to 15 to achieve different effects, 
		 * higher values are rendered more slowly. Instead of increasing the value of quality,
		 * you can often get a similar effect, and with faster rendering, by simply increasing the values 
		 * of the blurX and blurY properties.
		 */
		public function get quality () : int { return _quality; }
		public function set quality (value:int) : void { _quality = value };

		
		private var _strength:int = 2;
		/**
		 * The strength of the imprint or spread. The higher the value, 
		 * the more color is imprinted and the stronger the contrast between the glow and the background. 
		 * Valid values are 0 to 255. The default is 2.
		 */
		public function get strength () : Number { return _strength };
		public function set strength (value:Number) : void { _strength = value };


		/**
		 * Returns new glow filter
		 */
		public function getFilter():flash.filters.GlowFilter
		{
			return new flash.filters.GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}
	}
}
