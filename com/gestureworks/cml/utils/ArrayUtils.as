package com.gestureworks.cml.utils 
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;

	
	/**
	 * ...
	 * @author Ideum
	 */
	public class ArrayUtils 
	{
		/**
		 * Fisher-Yates shuffle
		 * http://bost.ocks.org/mike/shuffle/
		 * @param	array
		 */
		public static function shuffle(array:Array):Array
		{
		  var m = array.length, t, i;

		  // While there remain elements to shuffle…
		  while (m) {

			// Pick a remaining element…
			i = Math.floor(Math.random() * m--);

			// And swap it with the current element.
			t = array[m];
			array[m] = array[i];
			array[i] = t;
		  }

		  return array;
		}
	}

}