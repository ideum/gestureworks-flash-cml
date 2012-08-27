package com.gestureworks.cml.element 
{
	import com.modestmaps.geo.Location;
	
	/**
	 * ...
	 * @author josh
	 */
	public class ModestMapMarker extends Container
	{
		public function ModestMapMarker() 
		{
			super();
		}
		
		private var _longitude:Number;
		public function get longitude():Number { return _longitude; }
		public function set longitude(value:Number):void {
			_longitude = value;
		}
		
		private var _latitude:Number;
		public function get latitude():Number { return _latitude; }
		public function set latitude(value:Number):void {
			_latitude = value;
		}
	}

}