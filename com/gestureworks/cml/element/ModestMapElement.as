package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.*;
	import com.gestureworks.core.*;
	import com.modestmaps.extras.MapControls;
	import com.modestmaps.geo.Location;
	import com.modestmaps.Map;
	import com.modestmaps.mapproviders.microsoft.*;
	import com.modestmaps.mapproviders.yahoo.*;
	import flash.geom.Point;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	//import com.modestmaps.mapproviders.google.*;
	import com.modestmaps.mapproviders.*;
	import org.tuio.*;
	/**
	 * ...
	 * @author josh
	 */
	public class ModestMapElement extends ElementFactory
	{
		private var map:Map;
		
		private var p1:IMapProvider = new BlueMarbleMapProvider;
		private var p2:IMapProvider = new MicrosoftAerialMapProvider;
		private var p3:IMapProvider = new MicrosoftHybridMapProvider;
		private var p4:IMapProvider = new MicrosoftRoadMapProvider;
		private var p5:IMapProvider = new OpenStreetMapProvider;
		private var p6:IMapProvider = new YahooAerialMapProvider;
		private var p7:IMapProvider = new YahooHybridMapProvider;
		private var p8:IMapProvider = new YahooRoadMapProvider;
		
		private var providers:Array= [p1, p2, p3, p4, p5, p6, p7, p8];
		
		private var currentIndex:int = 0;
		
		private var lastLoc:Location;
		
		public function ModestMapElement() 
		{
			super();
		}
		
		private var _mapProvider:IMapProvider;
		/**
		 * This sets and retrieves the type of map the user will see. This is not case-sensitive.
		 * Types are: BlueMarbleMapProvider, MicrosoftAerialMapProvider, MicrosoftHybridMapProvder, 
		 * MicrosoftRoadMapProvider, OpenStreeMapProvider,   
		 * YahooAerialMapProvider, YahooHybridMapProvider, YahooRoadMapProvider.
		 */
		public function get mapprovider():String { return _mapProvider.toString(); }
		public function set mapprovider(value:String):void {
			value = value.toLowerCase();
			
			if (value == "bluemarblemapprovider") _mapProvider = new BlueMarbleMapProvider;
			else if (value == "microsoftaerialmapprovider") _mapProvider = new MicrosoftAerialMapProvider;
			else if (value == "microsofthybridmapprovider") _mapProvider = new MicrosoftHybridMapProvider;
			else if (value == "microsoftroadmapprovider") _mapProvider = new MicrosoftRoadMapProvider;
			else if (value == "openstreetmapprovider") _mapProvider = new OpenStreetMapProvider;
			//else if (value == "vanillamapprovider") _mapProvider = new VanillaMapProvider;
			else if (value == "yahooaerialmapprovider") _mapProvider = new YahooAerialMapProvider;
			else if (value == "yahoohybridmapprovider") _mapProvider = new YahooHybridMapProvider;
			//else if (value == "yahoooverlaymapprovider") _mapProvider = new YahooOverlayMapProvider;
			else if (value == "yahooroadmapprovider") _mapProvider = new YahooRoadMapProvider;
			else trace("Invalid MapProvider entered.");
			
			while (providers[currentIndex].toString() != _mapProvider.toString()) {
				trace(providers[currentIndex] + " " + _mapProvider);
				currentIndex++;
			}
		}
		
		private var _latitude:Number = 0;
		/**
		 * Sets and retrives the latitude of the starting location. Negative values are South of the Equator, positive values are North. For example, 1.2345 S would be -1.2345.
		 */
		public function get latitude():Number { return _latitude; }
		public function set latitude(value:Number):void {
			_latitude = value;
		}
		
		private var _longitude:Number = 0;
		/**
		 * Sets and retrives the longitude of the starting location. Negative values are West of the Prime Meridian, positive values are East. For example, 1.2345 W would be -1.2345.
		 */
		public function get longitude():Number { return _longitude; }
		public function set longitude(value:Number):void {
			_longitude = value;
		}
		
		private var _zoom:Number = 1;
		/**
		 * Sets and retrieves the Zoom at which the map will start. Must be a value of 1 or larger or no map will be seen at runtime.
		 * @default: 1
		 */
		public function get zoom():Number { return _zoom; }
		public function set zoom(value:Number):void {
			if (value < 1) {
				_zoom = 1;
			} else {
				_zoom = value;
			}
		}
		
		private var _draggable:Boolean = true;
		/**
		 * Sets the draggable property of the map.
		 * @default: true
		 */
		public function get draggable():Boolean { return _draggable; }
		public function set draggable(value:Boolean):void {
			_draggable = value;
		}
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded; }
		
		override public function displayComplete():void {
			super.displayComplete();
			
			createMap();
		}
		
		private function createMap():void {
			map = new Map(width, height, _draggable, _mapProvider);
			//map.addChild(new MapControls(map));
			lastLoc = new Location(_latitude, _longitude);
			map.setCenterZoom(lastLoc, _zoom);
			
			addChild(map);
			
			createEvents();
			
			_loaded = "loaded";
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _loaded));
		}
		
		private function createEvents():void {
			if (this.parent && this.parent is TouchContainer) {
				//this.parent.addEventListener(GWGestureEvent.DRAG, onDrag);
				//this.addEventListener(GWGestureEvent.SCALE, onScale);
				this.parent.addEventListener(GWTouchEvent.TOUCH_BEGIN, onTouch);
			}
		}
		
		private function onTouch(e:*):void {
			this.parent.addEventListener(GWGestureEvent.DRAG, onDrag);
			this.parent.addEventListener(GWTouchEvent.TOUCH_END, onRelease);
			map.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, e.value.localX, e.value.localY));
		}
		
		private function onDrag(e:GWGestureEvent):void {
			//this.parent.removeEventListener(GWGestureEvent.DRAG, onDrag);
			//trace("Event x: " + e.value.localX + ", " + e.value.localY);
			//trace("Event differential: " + e.value.drag_dx + ", " + e.value.drag_dy);
			//trace("Map pointLocation: " + map.pointLocation(new Point(e.value.localX, e.value.localY), this));
			//trace("Parent pointLocation: " + map.pointLocation(new Point(e.value.localX, e.value.localY), this.parent));
			//trace("Stage pointLocation: " + map.pointLocation(new Point(e.value.localX, e.value.localY), this.parent.stage));
			//var p:Point = new Point(e.value.localX, e.value.localY);
			//var newLoc:Location = map.pointLocation(p, this);
			//map.setCenter(newLoc);
			//trace("New loc: " + newLoc);
			//this.parent.addEventListener(GWGestureEvent.DRAG, onDrag);
			
			//Get new location from touch event.
			
			/*var p:Point = new Point(e.value.localX, e.value.localY);
			var newLoc:Location = map.pointLocation(p, this.parent.stage);
			
			trace("Stage pointLocation: " + map.pointLocation(new Point(e.value.localX, e.value.localY), this.parent.stage));
			trace("New loc: " + newLoc);
			trace("Map center: " + map.getCenter());
			trace("LastLoc: " + lastLoc);
			//If map != last location from previous event
			//Keep center going towards las location.
			var compLoc:Location = map.getCenter();
			if (lastLoc.lat != compLoc.lat && lastLoc.lon != compLoc.lon) {
				trace("I am an if statement that should be firing.");
				map.setCenter(newLoc);
				lastLoc = newLoc;
			}*/
			
			//Otherwise set new location to center.
			//set new location to old location.
			
			map.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, e.value.localX, e.value.localY));
		}
		
		private function onRelease(e:*):void {
			
		}
		
		private function onScale(e:GWGestureEvent):void {
			
		}
		
		public function switchMapProvider():void {
			trace("Switching map provider.");
			currentIndex++;
			if (currentIndex >= providers.length) currentIndex = 0;
			map.setMapProvider(providers[currentIndex]);
		}
		
		public function updateFrame():void {
			trace("Updating frame from ModestMapElement");
			width = map.width;
			height = map.height;
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (GestureWorks.supportsTouch){
				map.removeEventListener(TuioTouchEvent.DOUBLE_TAP, switchMapProvider);
				}
			else if (GestureWorks.activeTUIO){
				map.removeEventListener(GWGestureEvent.DOUBLE_TAP, switchMapProvider);
				}
			else {
				map.removeEventListener(MouseEvent.DOUBLE_CLICK, switchMapProvider);
				}
			
			while (this.numChildren > 0) {
				removeChildAt(0);
			}
			
			map = null;
		}
	}

}