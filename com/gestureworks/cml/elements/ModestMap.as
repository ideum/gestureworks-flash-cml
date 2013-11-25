package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import com.gestureworks.events.GWGestureEvent;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.*;
	import com.modestmaps.mapproviders.microsoft.*;
	import com.modestmaps.mapproviders.yahoo.*;
	import com.modestmaps.TweenMap;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import org.tuio.*;
	
	
	/**
	 * The ModestMap element uses the ModestMaps API to generate an interactive map that can be touched and zoomed. Optionally ModestMapMarkers can be included with it to
	 * give points of interest. A ModestMapMarker is primarily a container for graphic objects that attaches itself to a map point, so it is invisible until display
	 * objects are added to its display list.
	 * 
	 * <p>When declaring a map, the important parts are latitude, longitude, zoom, and the mapprovider, which is the style of map that will be seen.</p>
	 * 
	 * <p>When declaring latitude, negative values are west of the Prime Meridian, and for longitude, negative values are south of the equator.</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
		var map1:ModestMapElement = new ModestMapElement;
		map1.latitude = 51.1789;
		map1.longitude = -1.8624;
		map1.zoom = 7;
		map1.mapprovider = "MicrosoftRoadMapProvider";
	 *
	 * </codeblock>
	 * @author Ideum
	 */
	public class ModestMap extends TouchContainer
	{
		public var map:TweenMap;
		
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
		
		private var zoomFactor:Number = 0;
		private var mapMarkers:Array;
		
		/**
		 * Constructor
		 */
		public function ModestMap() 
		{
			super();
			mapMarkers = new Array();
			mouseChildren = true;
			this.clusterBubbling = true;
		}
		
		private var _mapProvider:IMapProvider;
		/**
		 * This sets and retrieves the type of map the user will see. This is not case-sensitive.
		 * Types are: BlueMarbleMapProvider, MicrosoftAerialMapProvider, MicrosoftHybridMapProvder, 
		 * MicrosoftRoadMapProvider, OpenStreeMapProvider,   
		 * YahooAerialMapProvider, YahooHybridMapProvider, YahooRoadMapProvider.
		 */
		public function get mapprovider():String { return _mapProvider ? _mapProvider.toString() : null; }
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
		 * @default 1
		 */
		public function get zoom():Number { return _zoom; }
		public function set zoom(value:Number):void {
			if (value < 1) {
				_zoom = 1;
			} else {
				_zoom = value;
			}
		}

		private var _scaleFactor:Number = 15.0;
		/**
		 * Sets how fast the map scales in
		 * @default 15.0
		 */
		public function get scaleFactor():Number { return _scaleFactor; }
		public function set scaleFactor(value:Number):void {
			_scaleFactor = value;
		}
		
		private var _scaleable:Boolean = true;
		/**
		 * Sets if the map is scaleable
		 * @default true
		 */
		public function get scaleable():Boolean { return _scaleable; }
		public function set scaleable(value:Boolean):void {
			_scaleable = value;
		}
		
		private var _loaded:String = "";
		/**
		 * Read-only property indicating if the element is loaded or not.
		 */
		public function get loaded():String { return _loaded; }
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{
			while (this.numChildren > 0) {
				if (this.getChildAt(this.numChildren - 1) is DisplayObject) {
					mapMarkers.push(this.getChildAt(this.numChildren - 1));
				}
				removeChildAt(this.numChildren - 1);
			}
			createMap();
		}
		
		private function createMap():void {
			map = new TweenMap(width, height, false, _mapProvider);
			
			lastLoc = new Location(_latitude, _longitude);
			map.setCenterZoom(lastLoc, _zoom);
			
			map.zoomDuration = 0.5;
			
			addChild(map);
			
			if (mapMarkers.length > 0) {
				for (var i:Number = 0; i < mapMarkers.length; i++) {
					var mapLoc:Location = new Location(mapMarkers[i].latitude, mapMarkers[i].longitude);
					map.putMarker(mapLoc, mapMarkers[i]);
				}
			}
			
			createEvents();
			
			_loaded = "loaded";
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "value", _loaded, true));
		}
		
		private function createEvents():void {
			
			gestureList = { "n-double_tap":true, "n-scale":true, "n-drag":true };
			
			addEventListener(GWGestureEvent.DOUBLE_TAP, switchMapProvider);
			addEventListener(GWGestureEvent.SCALE, onScale);
			addEventListener(GWGestureEvent.DRAG, onDrag);
			addEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin);
			addEventListener(GWTouchEvent.TOUCH_END, onEnd);
			nativeTransform = false;
		}
		
		private function onScale(e:GWGestureEvent):void {
			
			if (!scaleable) {
				return;
			}
			
			var scaleX:Number = e.value.scale_dsx;
			var scaleY:Number = e.value.scale_dsy;
			
			var scaleDelta:Number = Math.max(scaleX, scaleY);
			
			map.zoomByAbout(scaleDelta * scaleFactor, new Point(e.value.localX, e.value.localY));
		}
		
		private function onDrag(e:GWGestureEvent):void {
			if (e.value.n > 1) return;
			map.grid.prepareForPanning(true);
			map.grid.dragMap(new Point(e.value.stageX, e.value.stageY));
		}
		
		private function onBegin(e:GWTouchEvent):void {
			map.grid.pmouse = new Point(e.stageX, e.stageY);
		}
		
		private function onEnd(e:GWTouchEvent):void {
			map.grid.donePanning();
			map.grid.doneZooming();
			map.grid.onRender();
		}

		/**
		 * Sets the current index value
		 * @param	e
		 */
		public function switchMapProvider(e:*):void {
			currentIndex++;
			if (currentIndex >= providers.length) currentIndex = 0;
			map.setMapProvider(providers[currentIndex]);
		}
		
		/**
		 * Updates the frame of Modest Map
		 */
		public function updateFrame():void {
			width = map.width;
			height = map.height;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();	
			removeEventListener(GWGestureEvent.DOUBLE_TAP, switchMapProvider);
			removeEventListener(GWGestureEvent.SCALE, onScale);
			map = null;
			p1 = p2 = p3 = p4 = p5 = p6 = p7 = p8 = null;
			providers = null;
			lastLoc = null;
			mapMarkers = null;
			_mapProvider = null;
		}
	}

}