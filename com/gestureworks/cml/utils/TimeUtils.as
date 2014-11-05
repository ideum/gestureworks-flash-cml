package com.gestureworks.cml.utils 
{
	/**
	 * The TimeUtils utility is a collection of static methods for working with time. 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		var t:TimeStamp = new TimeStamp();
		trace(t.getDateTime());
		trace(t.getHrsMinSec());
	 
	 * </codeblock>
	 * @author Ideum
	 */	 
	public class TimeUtils 
	{
		private static var date:Date;		
		/**
		 * Constructor
		 */
		public function TimeUtils():void {}
		
		/**
		 * Returns the current full date
		 * @return full date
		 */		
		public static function getDateTime():String
		{
			date = new Date;
			return date.toString();
		}
		
		/**
		 * Returns the current time in hrs:min:sec 
		 * @return time
		 */		
		public static function getHrsMinSec():String
		{
			date = new Date;
			
			var hrs:String = date.hours.toString();
			var min:String = date.minutes.toString();
			var sec:String = date.seconds.toString();
			
			if (hrs.length < 2)
				hrs = 0 + hrs;
			if (min.length < 2)
				min = 0 + min;			
			if (sec.length < 2)
				sec = 0 + sec;
			
			return hrs + ":" + min + ":" + sec;
		}
		
		/**
		 * Converts provided millisecond value into formatted string (min:sec)
		 * @param	t time in ms
		 */
		public static function msToMinSec(t:int):String {
			return secToMinSec(t / 1000);
		}
		
		/**
		 * Converts provided second value into formatted string (min:sec)
		 * @param t time in seconds
		 */
		public static function secToMinSec(t:int):String {
			var s:int=Math.round(t);
			var m:int=0;
			if (s>0)
			{
				while (s > 59)
				{
					m++;
					s-=60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			}
			else return "00:00";				
		}
		
		/**
		 * Returns the month abbreviation for a given month index
		 * @param	num
		 * @return
		 */
		public static function getMonthAbbreviation(num:int):String
		{
			var month:String = "";
			
			switch (num) 
			{
				case 0: month = "JAN"; break;
				case 1: month = "FEB"; break;
				case 2: month = "MAR"; break;
				case 3: month = "APR"; break;
				case 4: month = "MAY"; break;
				case 5: month = "JUN"; break;
				case 6: month = "JUL"; break;
				case 7: month = "AUG"; break;
				case 8: month = "SEP"; break;
				case 9: month = "OCT"; break;
				case 10: month = "NOV"; break;
				case 11: month = "DEC"; break;					
			}
			
			return month;
		}
		
		/**
		 * Returns the number suffix (st, nd, rd, stc) for a given number
		 * @param	num
		 * @return
		 */
		public static function getNumberSuffix(num:int):String
		{
			if (num == 0) return "";
			if (Math.floor(num / 10) % 10 === 1) return "th";
			
			num %= 10;
			if (num > 3 || num === 0) return "th";
			if (num === 1) return "st";
			if (num === 2) return "nd";
			return "rd";
		}		
				
	}
}