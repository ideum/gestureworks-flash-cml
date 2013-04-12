package com.gestureworks.cml.element 
{
	import com.modestmaps.geo.Location;
	
	/**
	 * A ModestMapMarker is primarily a container for graphic objects that gives the latitude and longitude of map.
	 * It has following parameters: longitude and longitude.
	 * 
	 * @author josh
	 * @see ModestMap
	 */
	public class ModestMapMarker extends Container
	{
		/**
		 * Constructor
		 */
		public function ModestMapMarker() 
		{
			super();
		}
		
		private var _longitude:Number;
		/**
		 * Specifies the longitude of map
		 */
		public function get longitude():Number { return _longitude; }
		public function set longitude(value:Number):void {
			_longitude = value;
		}
		
		private var _latitude:Number;
		/**
		 * Specifies the latitude of map
		 */
		public function get latitude():Number { return _latitude; }
		public function set latitude(value:Number):void {
			_latitude = value;
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void {
			super.dispose();
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void {}
		
		/**
		 * CML callback Initialisation
		 */
		override public function displayComplete():void
		{			
			init();
		}
	}

}