package com.gestureworks.cml.filters
{
	import flash.filters.BevelFilter;

	/**
	 * The Bevel class lets you add a bevel effect to display objects.
	 * A bevel effect gives objects such as buttons a three-dimensional look. You can customize
	 * the look of the bevel with different highlight and shadow colors, the amount
	 * of blur on the bevel, the angle of the bevel, the placement of the bevel, 
	 * and a knockout effect.
	 * You can apply the filter to any display object (that is, objects that inherit from the 
	 * DisplayObject class), such as MovieClip, SimpleButton, TextField, and Video objects, 
	 * as well as to BitmapData objects.
	 * 
	 *   <p class="- topic/p ">To create a new filter, use the constructor <codeph class="+ topic/ph pr-d/codeph ">new BevelFilter()</codeph>.
	 * The use of filters depends on the object to which you apply the filter:</p><ul class="- topic/ul "><li class="- topic/li ">To apply filters to movie clips, text fields, buttons, and video, use the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property (inherited from DisplayObject). Setting the <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> 
	 * property of an object does not modify the object, and you can remove the filter by clearing the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property. </li><li class="- topic/li ">To apply filters to BitmapData objects, use the <codeph class="+ topic/ph pr-d/codeph ">BitmapData.applyFilter()</codeph> method.
	 * Calling <codeph class="+ topic/ph pr-d/codeph ">applyFilter()</codeph> on a BitmapData object takes the source BitmapData object 
	 * and the filter object and generates a filtered image as a result.</li></ul><p class="- topic/p ">If you apply a filter to a display object, the value of the <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> property of the 
	 * object is set to <codeph class="+ topic/ph pr-d/codeph ">true</codeph>. If you remove all filters, the original value of 
	 * <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> is restored.</p><p class="- topic/p ">This filter supports Stage scaling. However, it does not support general scaling, rotation, and 
	 * skewing. If the object itself is scaled (if the <codeph class="+ topic/ph pr-d/codeph ">scaleX</codeph> and <codeph class="+ topic/ph pr-d/codeph ">scaleY</codeph> properties are 
	 * not set to 100%), the filter is not scaled. It is scaled only when the user zooms in on the Stage.</p><p class="- topic/p ">A filter is not applied if the resulting image exceeds the maximum dimensions.
	 * In  AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in width or height, 
	 * and the total number of pixels cannot exceed 16,777,215 pixels. (So, if an image is 8,191 pixels 
	 * wide, it can only be 2,048 pixels high.) In Flash Player 9 and earlier and AIR 1.1 and earlier, 
	 * the limitation is 2,880 pixels in height and 2,880 pixels in width.
	 * If, for example, you zoom in on a large movie clip with a filter applied, the filter is 
	 * turned off if the resulting image exceeds the maximum dimensions.</p>
	 */
	public class Bevel
	{
		/**
		 * Initializes a new Bevel instance with the specified parameters.
		 * @param	distance	The offset distance of the bevel, in pixels (floating point).
		 * @param	angle	The angle of the bevel, from 0 to 360 degrees.
		 * @param	highlightColor	The highlight color of the bevel, 0xRRGGBB.
		 * @param	highlightAlpha	The alpha transparency value of the highlight color. Valid values are 0.0 to 
		 *   1.0. For example,
		 *   .25 sets a transparency value of 25%.
		 * @param	shadowColor	The shadow color of the bevel, 0xRRGGBB.
		 * @param	shadowAlpha	The alpha transparency value of the shadow color. Valid values are 0.0 to 1.0. For example,
		 *   .25 sets a transparency value of 25%.
		 * @param	blurX	The amount of horizontal blur in pixels. Valid values are 0 to 255.0 (floating point).
		 * @param	blurY	The amount of vertical blur in pixels. Valid values are 0 to 255.0 (floating point).
		 * @param	strength	The strength of the imprint or spread. The higher the value, the more color is imprinted and the stronger the contrast between the bevel and the background. Valid values are 0 to 255.0.
		 * @param	quality	The quality of the bevel. Valid values are 0 to 15, but for most applications,
		 *   you can use BitmapFilterQuality constants:
		 *   BitmapFilterQuality.LOWBitmapFilterQuality.MEDIUMBitmapFilterQuality.HIGHFilters with lower values render faster. You can use
		 *   the other available numeric values to achieve different effects.
		 * @param	type	The type of bevel. Valid values are BitmapFilterType constants: 
		 *   BitmapFilterType.INNER, BitmapFilterType.OUTER, or 
		 *   BitmapFilterType.FULL.
		 * @param	knockout	Applies a knockout effect (true), which effectively 
		 *   makes the object's fill transparent and reveals the background color of the document.
		 */
		public function Bevel (distance:Number = 4, angle:Number = 45, highlightColor:uint = 16777215, highlightAlpha:Number = 1, shadowColor:uint = 0, shadowAlpha:Number = 1, 
			blurX:Number = 4, blurY:Number = 4, strength:Number = 1, quality:int = 1, type:String = "inner", knockout:Boolean = false)
		{
			_distance = distance;
			_angle = angle;
			_highlightColor = highlightColor;
			_highlightAlpha = highlightAlpha;
			_shadowColor = shadowColor;
			_shadowAlpha = _shadowAlpha;
			_blurX = blurX;
			_blurY = blurY;
			_strength = strength;
			_quality = quality;
			_type = type;
			_knockout = knockout;
		}
		
		
		private var _angle:Number = 45;
		/**
		 * The angle of the bevel. Valid values are from 0 to 360°. The default value is 45°.
		 * 
		 *   The angle value represents the angle of the theoretical light source falling on the object
		 * and determines the placement of the effect relative to the object. If the distance
		 * property is set to 0, the effect is not offset from the object and, therefore, 
		 * the angle property has no effect.
		 */
		public function get angle () : Number { return _angle; }
		public function set angle (value:Number) : void { _angle = value };

		
		private var _blurX:Number = 4.0;
		/**
		 * The amount of horizontal blur, in pixels. Valid values are from 0 to 255 (floating point). 
		 * The default value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32) are optimized 
		 * to render more quickly than other values.
		 */
		public function get blurX () : Number { return _blurX; }
		public function set blurX (value:Number) : void { _blurX = value; }

		
		private var _blurY:Number = 4.0;
		/**
		 * The amount of vertical blur, in pixels. Valid values are from 0 to 255 (floating point).
		 * The default value is 4. Values that are a power of 2 (such as 2, 4, 8, 16, and 32) are optimized 
		 * to render more quickly than other values.
		 */
		public function get blurY () : Number { return _blurY; }
		public function set blurY (value:Number) : void { _blurY = value; }

		
		private var _distance:Number = 4.0;	
		/**
		 * The offset distance of the bevel. Valid values are in pixels (floating point). The default is 4.
		 */
		public function get distance () : Number { return _distance; }
		public function set distance (value:Number) : void { _distance = value; }

		
		private var _highlightAlpha:Number = 1;
		/**
		 * The alpha transparency value of the highlight color. The value is specified as a normalized
		 * value from 0 to 1. For example,
		 * .25 sets a transparency value of 25%. The default value is 1.
		 */
		public function get highlightAlpha () : Number { return _highlightAlpha; }
		public function set highlightAlpha (value:Number) : void { _highlightAlpha = value; }

		
		private var _highlightColor:uint = 0xFFFFFF;
		/**
		 * The highlight color of the bevel. Valid values are in hexadecimal format, 
		 * 0xRRGGBB. The default is 0xFFFFFF.
		 */
		public function get highlightColor () : uint { return _highlightColor; }
		public function set highlightColor (value:uint) : void { _highlightColor = value; }

		
		private var _knockout:Boolean = false;								
		/**
		 * Applies a knockout effect (true), which effectively 
		 * makes the object's fill transparent and reveals the background color of the document. The 
		 * default value is false (no knockout).
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
		 * of the blurX and blurY properties.You can use the following BitmapFilterQuality constants to specify values of the quality property:
		 * BitmapFilterQuality.LOWBitmapFilterQuality.MEDIUMBitmapFilterQuality.HIGH
		 */
		public function get quality () : int { return _quality; }
		public function set quality (value:int) : void { _quality = value };

		
		private var _shadowAlpha:Number = 1.0;	
		/**
		 * The alpha transparency value of the shadow color. This value is specified as a normalized
		 * value from 0 to 1. For example,
		 * .25 sets a transparency value of 25%. The default is 1.
		 */
		public function get shadowAlpha () : Number { return _shadowAlpha; }
		public function set shadowAlpha (value:Number) : void { _shadowAlpha = value; }

		
		private var _shadowColor:uint = 0x000000;														
		/**
		 * The shadow color of the bevel. Valid values are in hexadecimal format, 0xRRGGBB. The default 
		 * is 0x000000.
		 */
		public function get shadowColor () : uint { return _shadowColor; }
		public function set shadowColor (value:uint) : void { _shadowColor; }

		
		private var _strength:Number = 1.0;														
		/**
		 * The strength of the imprint or spread. Valid values are from 0 to 255. The larger the value, 
		 * the more color is imprinted and the stronger the contrast between the bevel and the background.
		 * The default value is 1.
		 */
		public function get strength () : Number { return _strength };
		public function set strength (value:Number) : void { _strength = value };

		
		private var _type:String = "inner";														
		/**
		 * The placement of the bevel on the object. Inner and outer bevels are placed on
		 * the inner or outer edge; a full bevel is placed on the entire object.
		 * Valid values are the BitmapFilterType constants:
		 * BitmapFilterType.INNER, BitmapFilterType.OUTER, BitmapFilterType.FULL
		 */
		public function get type () : String { return _type };
		public function set type (value:String) : void { _type = value };
	
		
		/**
		 * Returns new bevel filter
		 */
		public function getFilter():flash.filters.BevelFilter
		{
			return new flash.filters.BevelFilter(distance, angle, highlightColor, highlightColor, shadowAlpha, shadowAlpha, blurX, blurY, strength, quality, type, knockout);	
		}
		
	}
}
