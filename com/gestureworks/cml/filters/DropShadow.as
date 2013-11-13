package com.gestureworks.cml.filters
{
	import flash.filters.DropShadowFilter;

	/**
	 * The DropShadow class lets you add a drop shadow to display objects.
	 * The shadow algorithm is based on the same box filter that the blur filter uses. You have 
	 * several options for the style of the drop shadow, including inner or outer shadow and knockout mode.
	 * You can apply the filter to any display object (that is, objects that inherit from the DisplayObject class), 
	 * such as MovieClip, SimpleButton, TextField, and Video objects, as well as to BitmapData objects.
	 * 
	 * <p class="- topic/p ">The use of filters depends on the object to which you apply the filter:</p><ul class="- topic/ul "><li class="- topic/li ">To apply filters to display objects use the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property (inherited from DisplayObject). Setting the <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> 
	 * property of an object does not modify the object, and you can remove the filter by clearing the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property. </li><li class="- topic/li ">To apply filters to BitmapData objects, use the <codeph class="+ topic/ph pr-d/codeph ">BitmapData.applyFilter()</codeph> method.
	 * Calling <codeph class="+ topic/ph pr-d/codeph ">applyFilter()</codeph> on a BitmapData object takes the source BitmapData object 
	 * and the filter object and generates a filtered image as a result.</li></ul><p class="- topic/p ">If you apply a filter to a display object, the value of the <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> property of the 
	 * display object is set to <codeph class="+ topic/ph pr-d/codeph ">true</codeph>. If you clear all filters, the original value of 
	 * <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> is restored.</p><p class="- topic/p ">This filter supports Stage scaling. However, it does not support general scaling, rotation, and 
	 * skewing. If the object itself is scaled (if <codeph class="+ topic/ph pr-d/codeph ">scaleX</codeph> and <codeph class="+ topic/ph pr-d/codeph ">scaleY</codeph> are 
	 * set to a value other than 1.0), the filter is not scaled. It is scaled only when 
	 * the user zooms in on the Stage.</p><p class="- topic/p ">A filter is not applied if the resulting image exceeds the maximum dimensions.
	 * In  AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in width or height, 
	 * and the total number of pixels cannot exceed 16,777,215 pixels. (So, if an image is 8,191 pixels 
	 * wide, it can only be 2,048 pixels high.) In Flash Player 9 and earlier and AIR 1.1 and earlier, 
	 * the limitation is 2,880 pixels in height and 2,880 pixels in width.
	 * If, for example, you zoom in on a large movie clip with a filter applied, the filter is 
	 * turned off if the resulting image exceeds the maximum dimensions.</p>
	 * 
	 */
	public class DropShadow
	{
		/**
		 * Creates a new DropShadow instance with the specified parameters.
		 * @param	distance	Offset distance for the shadow, in pixels.
		 * @param	angle	Angle of the shadow, 0 to 360 degrees (floating point).
		 * @param	color	Color of the shadow, in hexadecimal format 
		 *   0xRRGGBB. The default value is 0x000000.
		 * @param	alpha	Alpha transparency value for the shadow color. Valid values are 0.0 to 1.0. 
		 *   For example,
		 *   .25 sets a transparency value of 25%.
		 * @param	blurX	Amount of horizontal blur. Valid values are 0 to 255.0 (floating point).
		 * @param	blurY	Amount of vertical blur. Valid values are 0 to 255.0 (floating point).
		 * @param	strength	The strength of the imprint or spread. The higher the value, 
		 *   the more color is imprinted and the stronger the contrast between the shadow and the background. 
		 *   Valid values are 0 to 255.0.
		 * @param	quality	The number of times to apply the filter. Use the BitmapFilterQuality constants:
		 *   BitmapFilterQuality.LOWBitmapFilterQuality.MEDIUMBitmapFilterQuality.HIGHFor more information about these values, see the quality property description.
		 * @param	inner	Indicates whether or not the shadow is an inner shadow. A value of true specifies
		 *   an inner shadow. A value of false specifies an outer shadow (a
		 *   shadow around the outer edges of the object).
		 * @param	knockout	Applies a knockout effect (true), which effectively 
		 *   makes the object's fill transparent and reveals the background color of the document.
		 * @param	hideObject	Indicates whether or not the object is hidden. A value of true 
		 *   indicates that the object itself is not drawn; only the shadow is visible.
		 */
		public function DropShadow (distance:Number = 4, angle:Number = 45, color:uint = 0, alpha:Number = 1, blurX:Number = 4, blurY:Number = 4, 
			strength:Number = 1, quality:int = 1, inner:Boolean = false, knockout:Boolean = false, hideObject:Boolean = false)
		{
			super();
			_distance = distance;
			_angle = angle;
			_color = color;
			_alpha = alpha;
			_blurX = blurX;
			_blurY = blurY;
			_strength = strength;
			_quality = quality;
			_inner = inner;
			_knockout = knockout;
			_hideObject = hideObject;
		}
		
		
		private var _alpha:Number = 1.0;
		/**
		 * The alpha transparency value for the shadow color. Valid values are 0.0 to 1.0. 
		 * For example,
		 * .25 sets a transparency value of 25%. The default value is 1.0.
		 */
		public function get alpha () : Number { return _alpha; }
		public function set alpha (value:Number) : void { _alpha = value; }

		
		private var _angle:Number = 45;
		/**
		 * The angle of the shadow. Valid values are 0 to 360 degrees (floating point). The
		 * default value is 45.
		 */
		public function get angle () : Number { return _angle; }
		public function set angle (value:Number) : void { _angle = value };

		
		private var _blurX:Number = 4.0;
		/**
		 * The amount of horizontal blur. Valid values are 0 to 255.0 (floating point). The
		 * default value is 4.0.
		 */
		public function get blurX () : Number { return _blurX; }
		public function set blurX (value:Number) : void { _blurX = value; }

		
		private var _blurY:Number = 4.0;
		/**
		 * The amount of vertical blur. Valid values are 0 to 255.0 (floating point). The
		 * default value is 4.0.
		 */
		public function get blurY () : Number { return _blurY; }
		public function set blurY (value:Number) : void { _blurY = value; }

		
		private var _color:uint = 0x000000;		
		/**
		 * The color of the shadow. Valid values are in hexadecimal format 0xRRGGBB. The 
		 * default value is 0x000000.
		 */
		public function get color () : uint { return _color; }
		public function set color (value:uint) : void { _color = value; }

		
		private var _distance:Number = 4.0;		
		/**
		 * The offset distance for the shadow, in pixels. The default
		 * value is 4.0 (floating point).
		 */
		public function get distance () : Number { return _distance; }
		public function set distance (value:Number) : void { _distance = value; }

		
		private var _hideObject:Boolean = false;				
		/**
		 * Indicates whether or not the object is hidden. The value true 
		 * indicates that the object itself is not drawn; only the shadow is visible.
		 * The default is false (the object is shown).
		 */
		public function get hideObject () : Boolean { return _hideObject; }
		public function set hideObject (value:Boolean) : void { _hideObject = value; }

		
		private var _inner:Boolean = false;						
		/**
		 * Indicates whether or not the shadow is an inner shadow. The value true indicates
		 * an inner shadow. The default is false, an outer shadow (a
		 * shadow around the outer edges of the object).
		 */
		public function get inner () : Boolean { return _inner; }
		public function set inner (value:Boolean) : void { _inner = value; }

		
		private var _knockout:Boolean = false;								
		/**
		 * Applies a knockout effect (true), which effectively 
		 * makes the object's fill transparent and reveals the background color of the document. The 
		 * default is false (no knockout).
		 */
		public function get knockout () : Boolean { return _knockout; }
		public function set knockout (value:Boolean) : void { _knockout = value; }


		private var _quality:int = 1;										
		/**
		 * The number of times to apply the filter. 
		 * The default value is BitmapFilterQuality.LOW, which is equivalent to applying
		 * the filter once. The value BitmapFilterQuality.MEDIUM applies the filter twice;
		 * the value BitmapFilterQuality.HIGH applies it three times. Filters with lower values
		 * are rendered more quickly.
		 * 
		 *   For most applications, a quality value of low, medium, or high is sufficient. 
		 * Although you can use additional numeric values up to 15 to achieve different effects,
		 * higher values are rendered more slowly. Instead of increasing the value of quality,
		 * you can often get a similar effect, and with faster rendering, by simply increasing
		 * the values of the blurX and blurY properties.
		 */
		public function get quality () : int { return _quality; }
		public function set quality (value:int) : void { _quality = value };


		private var _strength:Number = 1.0;												
		/**
		 * The strength of the imprint or spread. The higher the value, 
		 * the more color is imprinted and the stronger the contrast between the shadow and the background. 
		 * Valid values are from 0 to 255.0. The default is 1.0.
		 */
		public function get strength () : Number { return _strength };
		public function set strength (value:Number) : void { _strength = value };

		
		/**
		 * Returns new drop shadow filter
		 */
		public function getFilter():flash.filters.DropShadowFilter
		{
			return new flash.filters.DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
		}
		
	}
}
