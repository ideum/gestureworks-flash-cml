package com.gestureworks.cml.filters
{
	import flash.filters.BlurFilter;

	/**
	 * The Blur class lets you apply a blur visual effect to display objects.
	 * A blur effect softens the details of an image. You can produce blurs that
	 * range from a softly unfocused look to a Gaussian blur, a hazy
	 * appearance like viewing an image through semi-opaque glass. When the <codeph class="+ topic/ph pr-d/codeph ">quality</codeph> property
	 * of this filter is set to low, the result is a softly unfocused look.
	 * When the <codeph class="+ topic/ph pr-d/codeph ">quality</codeph> property is set to high, it approximates a Gaussian blur
	 * filter.  You can apply the filter to any display object (that is, objects that inherit 
	 * from the DisplayObject class), 
	 * such as MovieClip, SimpleButton, TextField, and Video objects, as well as to BitmapData objects.
	 * 
	 *   <p class="- topic/p ">To create a new filter, use the constructor <codeph class="+ topic/ph pr-d/codeph ">new BlurFilter()</codeph>. 
	 * The use of filters depends on the object to which you apply the filter:</p><ul class="- topic/ul "><li class="- topic/li ">To apply filters to movie clips, text fields, buttons, and video, use the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property (inherited from DisplayObject). Setting the <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> 
	 * property of an object does not modify the object, and you can remove the filter by clearing the
	 * <codeph class="+ topic/ph pr-d/codeph ">filters</codeph> property. </li><li class="- topic/li ">To apply filters to BitmapData objects, use the <codeph class="+ topic/ph pr-d/codeph ">BitmapData.applyFilter()</codeph> method.
	 * Calling <codeph class="+ topic/ph pr-d/codeph ">applyFilter()</codeph> on a BitmapData object takes the source BitmapData object 
	 * and the filter object and generates a filtered image as a result.</li></ul><p class="- topic/p ">If you apply a filter to a display object, the <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> property of the 
	 * display object is set to <codeph class="+ topic/ph pr-d/codeph ">true</codeph>. If you remove all filters, the original value of 
	 * <codeph class="+ topic/ph pr-d/codeph ">cacheAsBitmap</codeph> is restored.</p><p class="- topic/p ">This filter supports Stage scaling. However, it does not support general scaling, 
	 * rotation, and skewing. If the object itself is scaled (<codeph class="+ topic/ph pr-d/codeph ">scaleX</codeph> and <codeph class="+ topic/ph pr-d/codeph ">scaleY</codeph> are not set to 100%), the 
	 * filter effect is not scaled. It is scaled only when the user zooms in on the Stage.</p><p class="- topic/p ">A filter is not applied if the resulting image exceeds the maximum dimensions.
	 * In  AIR 1.5 and Flash Player 10, the maximum is 8,191 pixels in width or height, 
	 * and the total number of pixels cannot exceed 16,777,215 pixels. (So, if an image is 8,191 pixels 
	 * wide, it can only be 2,048 pixels high.) In Flash Player 9 and earlier and AIR 1.1 and earlier, 
	 * the limitation is 2,880 pixels in height and 2,880 pixels in width.
	 * If, for example, you zoom in on a large movie clip with a filter applied, the filter is 
	 * turned off if the resulting image exceeds the maximum dimensions.</p>
	 */
	public class Blur
	{
		/**
		 * Initializes the filter with the specified parameters.
		 * 
		 *   The default values create a soft, unfocused image.
		 * @param	blurX	The amount to blur horizontally. Valid values are from 0 to 255.0 (floating-point 
		 *   value).
		 * @param	blurY	The amount to blur vertically. Valid values are from 0 to 255.0 (floating-point 
		 *   value).
		 * @param	quality	The number of times to apply the filter. You can specify the quality using
		 *   the BitmapFilterQuality constants:
		 *   flash.filters.BitmapFilterQuality.LOWflash.filters.BitmapFilterQuality.MEDIUMflash.filters.BitmapFilterQuality.HIGHHigh quality approximates a Gaussian blur. 
		 *   For most applications, these three values are sufficient.  
		 *   Although you can use additional numeric values up to 15 to achieve different effects, be aware
		 *   that higher values are rendered more slowly.
		 */
		public function Blur (blurX:Number = 4, blurY:Number = 4, quality:int = 1)
		{
			_blurX = blurX;
			_blurY = blurY;
			_quality = quality;
		}
		
		
		private var _blurX:Number = 4.0;
		/**
		 * The amount of horizontal blur. Valid values are from 0 to 255 (floating point). The
		 * default value is 4. Values that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized 
		 * to render more quickly than other values.
		 */
		public function get blurX () : Number { return _blurX; }
		public function set blurX (value:Number) : void { _blurX = value; }

		
		private var _blurY:Number = 4.0;		
		/**
		 * The amount of vertical blur. Valid values are from 0 to 255 (floating point). The
		 * default value is 4. Values that are a power of 2 (such as 2, 4, 8, 16 and 32) are optimized 
		 * to render more quickly than other values.
		 */
		public function get blurY () : Number { return _blurY; }
		public function set blurY (value:Number) : void { _blurY = value; }

		
		private var _quality:int = 1;
		/**
		 * The number of times to perform the blur. The default value is BitmapFilterQuality.LOW, 
		 * which is equivalent to applying the filter once. The value BitmapFilterQuality.MEDIUM
		 * applies the filter twice; the value BitmapFilterQuality.HIGH applies it three times
		 * and approximates a Gaussian blur. Filters with lower values are rendered more quickly.
		 * 
		 *   For most applications, a quality value of low, medium, or high is sufficient. 
		 * Although you can use additional numeric values up to 15 to increase the number of times the blur
		 * is applied, 
		 * higher values are rendered more slowly. Instead of increasing the value of quality,
		 * you can often get a similar effect, and with faster rendering, by simply increasing the values 
		 * of the blurX and blurY properties.You can use the following BitmapFilterQuality constants to specify values of the
		 * quality property:BitmapFilterQuality.LOWBitmapFilterQuality.MEDIUMBitmapFilterQuality.HIGH
		 */
		public function get quality () : int { return _quality; }
		public function set quality (value:int) : void { _quality = value };


		/**
		 * Returns new blur filter
		 */
		public function getFilter():flash.filters.BlurFilter
		{
			return new flash.filters.BlurFilter(blurX, blurY, quality);
		}

	}
}
