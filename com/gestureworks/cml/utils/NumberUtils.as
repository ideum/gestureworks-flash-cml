package com.gestureworks.cml.utils 
{
	/**
	 * ...
	 * @author Ideum (Charles Veasey)
	 */
	public class NumberUtils 
	{
		public function NumberUtils():void{}
		
		/**
		 * Linearly maps an incoming value from one range to another
		 * @param	num Incoming value to be mapped
		 * @param	min1 Incoming minimum range value
		 * @param	max1 Incoming maximum range value
		 * @param	min2 Outgoing minimum range value
		 * @param	max2 Outgoing maximum range value
		 * @param	round Whether the returned value is rounded to nearest integer
		 * @param	constrainMin Whether the returned value is constrained to the minumim value
		 * @param	constrainMax Whether the returned value is constrained to the maximum value
		 * @return	Mapped value
		 */
		public static function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
		 
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			if (round) return Math.round(num2);
			return num2;
		}


	}


}