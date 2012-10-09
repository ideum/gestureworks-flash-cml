package com.gestureworks.cml.element 
{
	import com.modestmaps.geo.Location;
	
	/**
	 * A ModestMapMarker is primarily a container for graphic objects that gives the latitude and longitude of map.
	 * It has following parameters: longitude and longitude.
	 * @author josh
	 */
	public class ModestMapMarker extends Container
	{
		/**
		 * constructor
		 */
		public function ModestMapMarker() 
		{
			super();
		}
		
		private var _longitude:Number;
		/**
		 * specifies the longitude of map
		 */
		public function get longitude():Number { return _longitude; }
		public function set longitude(value:Number):void {
			_longitude = value;
		}
		
		private var _latitude:Number;
		/**
		 * specifies the latitude of map
		 */
		public function get latitude():Number { return _latitude; }
		public function set latitude(value:Number):void {
			_latitude = value;
		}
		
		/**
		 * dispose method
		 */
		override public function dispose():void {
			super.dispose();
		}
		
		/**
		 * initialisation method
		 */
		public function init():void
		{
			trace("modest map marker---------------------------------------------------",this.id);
		}
		
		/**
		 * CML callback initialisation
		 */
		override public function displayComplete():void
		{			
			init();
		}
	}

}