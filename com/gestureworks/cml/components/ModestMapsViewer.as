//commented out line 374 and 394 b/c Error undefined property View

package com.gestureworks.cml.components
{
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.*;
	import flash.ui.Mouse;
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	
	import com.gestureworks.cml.core.TouchContainerDisplay;
	import com.gestureworks.events.DisplayEvent;
	import com.gestureworks.cml.core.ComponentKitDisplay;
	import com.gestureworks.cml.element.TouchContainer
	import com.gestureworks.cml.element.ImageElement;
	import com.gestureworks.cml.kits.ComponentKit;
	
	import com.gestureworks.events.GWEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTransformEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.core.DisplayList;
	
	import com.gestureworks.core.GestureWorks;
	
	/*
	import com.google.maps.LatLng;
	import com.google.maps.Map;
  	import com.google.maps.Map3D;
 	import com.google.maps.MapEvent;
 	import com.google.maps.MapOptions;
 	import com.google.maps.MapType;
 	import com.google.maps.View;
	import com.google.maps.geom.Attitude; 
	 */
	
	import com.modestmaps.Map;
    //import com.modestmaps.TweenMap;
    import com.modestmaps.events.MapEvent;
    import com.modestmaps.extras.MapControls;
    //import com.modestmaps.extras.MapCopyright;
    //import com.modestmaps.extras.ZoomSlider;
	import com.modestmaps.geo.Location;
	import com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider;
    import com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider;
	import com.modestmaps.mapproviders.microsoft.MicrosoftAerialMapProvider;
	import com.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
	
	
	public class ModestMapsViewer extends ComponentKit
	{
		private var _id:int;
		private var _intialize:Boolean;
		
		private var map:*;
		private var map2:*;
		private var map_mask:Boolean = true;;
		//private var map_holder:TouchSprite;
		private var frame:TouchSprite;
		private var screen:TouchSprite;
		
		//------ map settings ------//
		private var mapApiKey:String = "";
		private var stageWidth:Number;
		private var stageHeight:Number;
		private var currLat:Number = -73.992062;
		private var currLng:Number = 40.736072;
		private var currType:Number = 2;
		private var currTypeMask:Number = 0;
		private var currSc:Number = 0;
		private var currAng:Number = 0;
		private var currtiltAng:Number = 0;
		private var stepSc:Number = 1;
		private var mapWidth:Number = 100;
		private var mapHeight:Number = 100;
		private var mapRotation:Number = 0;
		
		//---------frame settings--//
		private var frameDraw:Boolean = true;
		private var frameMargin:Number = 50;
		private var frameRadius:Number = 20;
		private var frameFillColor:Number = 0xFFFFFF;
		private var frameFillAlpha:Number = 0.5;
		private var frameOutlineColor:Number = 0xFFFFFF;
		private var frameOutlineStroke:Number = 2;
		private var frameOutlineAlpha:Number = 1;
		
		// ---map gestures---//
		private var mapDoubleTapGesture:Boolean = true;
		private var mapDragGesture:Boolean = true;
		private var mapFlickGesture:Boolean = true;
		private var mapScaleGesture:Boolean = true;
		private var mapRotateGesture:Boolean = true;
		private var mapTiltGesture:Boolean = true;
		
		//-- map gesture properties --//
		private var drag_factor:Number = 1;
		private var scale_factor:Number = 1;
		private var rotate_factor:Number = 1;
		private var flick_factor:Number = 1;
		private var tilt_factor:Number = 1; 
		private var scale_lim:Number;
		private var scale_out_factor:Number
		
		//----frame gestures---//
		private var frameDragGesture:Boolean = true;
		private var frameScaleGesture:Boolean = true;
		private var frameRotateGesture:Boolean = true;
		
		private var map_holder:TouchSprite;
		private var mShape:Sprite;
		private var mShapeHit:TouchSprite;
		private var mShapeOutline:Sprite;
		
		private var frame_thickness:Number = 50*0.5;
		private var frame_color:Number = 0x999999;
		private var frame_alpha:Number = 0.3;
				 
	
		public function ModestMapsViewer()
		{
			super();
			//blobContainerEnabled=true;
			//visible=false;
			displayComplete();
		}

		public function dipose():void
		{
			parent.removeChild(this);
		}

		override protected function displayComplete():void
		{			
			//trace("google map viewer complete");
			
			createUI();
			commitUI();
		}

		override protected function createUI():void
		{
			//trace("createUI");
			
			//--Map Settings--//
			mapApiKey = ""//MapParser.settings.GlobalSettings.apiKey;
			//stageWidth = 500//ApplicationGlobals.application.stage.stageWidth;
			//stageHeight = 500//ApplicationGlobals.application.stage.stageHeight;
			
			currLng = -73.992062;//MapParser.settings.Content.Source[id].longitude;//
			currLat = 40.736072;//MapParser.settings.Content.Source[id].latitude;//
			stepSc = 1//MapParser.settings.Content.Source[id].zoomStep; //1;
			currType = 0//MapParser.settings.Content.Source[id].initialType; //1;
			currTypeMask = 2;
			currSc = 10//MapParser.settings.Content.Source[id].initialZoom; //10;
			currAng = 0//MapParser.settings.Content.Source[id].initialAttitude; //0;
			currtiltAng = 0//MapParser.settings.Content.Source[id].initialTilt; //0;
			mapWidth = 500//MapParser.settings.Content.Source[id].mapWidth;
			mapHeight = 500//MapParser.settings.Content.Source[id].mapHeight;
			mapRotation = 0//MapParser.settings.Content.Source[id].mapRotation;
		
			//--Frame Style--//
			frameDraw = true//MapParser.settings.FrameStyle.frameDraw == "true"?true:false;
			frameMargin = 100//MapParser.settings.FrameStyle.padding;
			frameRadius = 5//MapParser.settings.FrameStyle.cornerRadius;
			frameFillColor = 0xFFFFFF//MapParser.settings.FrameStyle.fillColor1;
			frameFillAlpha = 0.6//MapParser.settings.FrameStyle.fillAlpha;
			frameOutlineColor = 0xFFFFFF//MapParser.settings.FrameStyle.outlineColor;
			frameOutlineStroke = 2//MapParser.settings.FrameStyle.outlineStroke;
			frameOutlineAlpha = 0.5//MapParser.settings.FrameStyle.outlineAlpha;
			
			//---Map Gestures--//
			mapDoubleTapGesture = true//MapParser.settings.MapGestures.doubleTap == "true" ?true:false;
			mapDragGesture = true//MapParser.settings.MapGestures.drag == "true" ?true:false;
			mapFlickGesture = false//MapParser.settings.MapGestures.flick == "true" ?true:false;
			mapScaleGesture = true//MapParser.settings.MapGestures.scale == "true" ?true:false;
			mapRotateGesture = true//MapParser.settings.MapGestures.rotate == "true" ?true:false;
			
			////////////////////////////////////////////////
			// SLOWS DOWN THE APP APPRECIABLY WHEN MAP 3D
			mapTiltGesture = false//MapParser.settings.MapGestures.tilt == "true" ?true:false;
			//////////////////////////////////////////////////
			
			
			//-- Map Gestures Properties --//
			//drag_factor = MapParser.settings.MapGestures.drag_factor;
			//scale_factor = MapParser.settings.MapGestures.scale_factor;
			//rotate_factor  = MapParser.settings.MapGestures.rotate_factor;
			//flick_factor = MapParser.settings.MapGestures.flick_factor;
			//tilt_factor = MapParser.settings.MapGestures.tilt_factor;
			//scale_out_factor = MapParser.settings.MapGestures.scale_out_factor;
			//scale_lim = MapParser.settings.MapGestures.scale_lim;
			
			//--Frame Gestures--//
			frameDragGesture= true//MapParser.settings.FrameGestures.drag == "true" ?true:false;
			frameScaleGesture=true//MapParser.settings.FrameGestures.scale == "true" ?true:false;
			frameRotateGesture=true//MapParser.settings.FrameGestures.rotate == "true" ?true:false;
			
			
			map_holder = new TouchSprite();
			
				map_holder.targeting = true;
				map_holder.gestureEvents = true;
				map_holder.nestedTransform = true;
				map_holder.disableNativeTransform = false;
				map_holder.disableAffineTransform = false;
				map_holder.mouseChildren = true;
				map_holder.gestureList = { "n-drag":true, "n-scale":true, "n-rotate":true };
			
			addChild(map_holder);
			
			
			//---------- build frame ------------------------//
			if(frameDraw)
			{							
				frame = new TouchSprite();
					frame.targetParent = true;
				map_holder.addChild(frame);
			}
			
			//---------- build map ------------------------//
			
			map = new Map(mapWidth,mapHeight,true, new MicrosoftHybridMapProvider())
			map.addChild(new MapControls(map));
			map.setCenterZoom(new Location( 40.668903, -111.680145), 6);
            //map.addEventListener(MouseEvent.DOUBLE_CLICK, map.onDoubleClick);
			
			map2 = new Map(mapWidth,mapHeight, true, new MicrosoftRoadMapProvider());
			map2.setCenterZoom(new Location( 40.668903, -111.680145), 6);
			
			
			//_map.zoomIn();
			//_map.getZoom();
			//_map.zoomOut();
			//_map.getRotation();
			//rotateByAbout(angle - rotation, targetPoint);   
			//_map.getCenter();
			//_map.targetPoint();
			
			//if(mapTiltGesture){
				//map = new Map3D();
			//}
			//else{
				//map = new Map();
			//}
			
			
			//if (map_mask) {
				//map2 = new Map();
			//}
			
			
			map_holder.addChild(map);
			
			if (map_mask) map_holder.addChild(map2);
			
			//////////////////////////////////////////////////
			//
			/////////////////////////////////////////////////
			
			var maskSize:Number = 200;
			
			mShape = new Sprite();
				mShape.graphics.beginFill(0xFFFFFF,1);
				mShape.graphics.drawRect(-maskSize/2,-maskSize/2,maskSize,maskSize);
				mShape.graphics.endFill();
				mShape.x = maskSize//2;
				mShape.y = maskSize // 2;
			map_holder.addChild(mShape);
			
			mShapeHit = new TouchSprite();
				//mShapeHit.graphics.lineStyle(2,0xFFFFFF,1);
				mShapeHit.graphics.beginFill(0xFFFFFF,0);
				mShapeHit.graphics.drawRect(-maskSize/2,-maskSize/2,maskSize,maskSize);
				mShapeHit.graphics.endFill();
				mShapeHit.x = maskSize//2;
				mShapeHit.y = maskSize // 2;
				
				mShapeHit.nestedTransform = true;
				mShapeHit.mouseChildren = true;
				mShapeHit.gestureEvents = true;
				mShapeHit.gestureList = {"n-drag":true, "n-scale":true,"4-finger-scale":true, "n-rotate":true,"double_tap":true};
				mShapeHit.disableNativeTransform = true;
				mShapeHit.disableAffineTransform = true;
				mShapeHit.addEventListener(GWGestureEvent.DRAG, gestureMaskDragHandler);
				mShapeHit.addEventListener(GWGestureEvent.SCALE, gestureMaskScaleHandler);
				mShapeHit.addEventListener(GWGestureEvent.ROTATE, gestureMaskRotateHandler);
				mShapeHit.addEventListener(GWGestureEvent.DOUBLE_TAP, doubleMaskTapHandler);
		
			map2.mask = mShape;
			
			
			mShapeOutline = new Sprite();
				mShapeOutline.graphics.lineStyle(3,0xFFFFFF,1);
				//mShapeOutline.graphics.beginFill(0xFFFFFF,0);
				mShapeOutline.graphics.drawRect(-maskSize/2,-maskSize/2,maskSize,maskSize);
				//mShapeOutline.graphics.endFill();
				mShapeOutline.x = maskSize//2;
				mShapeOutline.y = maskSize // 2;
			map_holder.addChild(mShapeOutline);
			
			var mapShape:Sprite = new Sprite();
				mapShape.graphics.beginFill(0xFFFFFF, 1);
				mapShape.graphics.drawRect(0,0,mapWidth,mapHeight);
				mapShape.graphics.endFill();
			map_holder.addChild(mapShape);
			
			mShapeOutline.mask = mapShape;
			
			/////////////////////////////////////////////////////
			
			//-- center map --//
			x = -mapWidth/2;
			y = -mapHeight/2
			
			//-- Add Event Listeners----------------------------------//
			//map.addEventListener(MapEvent.MAP_PREINITIALIZE, onMapPreInt);
			
			
			screen = new TouchSprite();
			
				screen.nestedTransform = true;
				screen.mouseChildren = true;
				screen.gestureEvents = true;
				screen.gestureList = {"n-drag":true, "n-scale":true,"4-finger-scale":true, "n-rotate":true,"double_tap":true};
				screen.disableNativeTransform = true;
				screen.disableAffineTransform = true;
				screen.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
				screen.addEventListener(GWGestureEvent.SCALE, gestureScaleHandler);
				screen.addEventListener(GWGestureEvent.ROTATE, gestureRotateHandler);
				screen.addEventListener(GWGestureEvent.DOUBLE_TAP, doubleTapHandler);
			
			//map_holder.addChild(screen);
			map_holder.addChild(mShapeHit);
			
		}

		override protected function commitUI():void
		{	
			trace("commit");
			
			width=mapWidth;
			height=mapHeight;
			
			if(!frameMargin)
			{
				frameMargin=0;
			}
			
			if(frameDraw)
			{		
				frame.graphics.lineStyle(2*frame_thickness, frame_color, frame_alpha);
				frame.graphics.drawRect( -frame_thickness, -frame_thickness, mapWidth + 2 * frame_thickness, mapHeight + 2 * frame_thickness);
				frame.graphics.lineStyle(2, frame_color,frame_alpha+0.5);
				frame.graphics.drawRoundRect( -2 * frame_thickness, -2 * frame_thickness, mapWidth + 4 * frame_thickness, mapHeight + 4 * frame_thickness, 2 * frame_thickness, 2 * frame_thickness);
				frame.graphics.lineStyle(4, frame_color,0.8);
				frame.graphics.drawRect(-2, -2, mapWidth + 4, mapHeight + 4);

				width=mapWidth+frameMargin;
				height=mapHeight+frameMargin;
			}
			
			//map.key = mapApiKey;
			//map.setSize(new Point(mapWidth,mapHeight));
			//map.sensor = "false"
			/*
			if (map_mask) {
				map2.key = mapApiKey;
				map2.setSize(new Point(mapWidth,mapHeight));
				map2.sensor = "false"
			}
			*/
			
			screen.graphics.beginFill(0xFFFFFF,0);
			screen.graphics.drawRoundRect(0,0,mapWidth,mapHeight,0,0);
			screen.graphics.endFill();
			//screen.blobContainerEnabled = true;
			
			rotation = mapRotation;
			
			if (! _intialize)
			{
				_intialize=true;
				visible=true;
			}
		}
		
		/*
		override protected function updateUI():void
		{
			if( (x-(frameMargin/2)>stageWidth) || (x+width-(frameMargin/2)<0) || (y-(frameMargin/2)>stageHeight) || (y+height-(frameMargin/2)<0) )
			{
				Dispose();
			}
		}
		*/
		/*
		private function onMapPreInt(event:MapEvent):void
		{	
			
 			var mOptions:MapOptions = new MapOptions();
			mOptions.zoom = currSc;
			mOptions.center = new LatLng(currLat,currLng);
			mOptions.continuousZoom = false;
			
			if(mapTiltGesture){
				//mOptions.viewMode = View.VIEWMODE_PERSPECTIVE; 
				mOptions.attitude = new Attitude(currtiltAng,currAng,0);
			}
			
			if(currType == 0)mOptions.mapType = MapType.SATELLITE_MAP_TYPE;  
			else if(currType == 1) mOptions.mapType = MapType.HYBRID_MAP_TYPE;
			else if(currType == 2) mOptions.mapType = MapType.NORMAL_MAP_TYPE;
			else if(currType == 3) mOptions.mapType = MapType.PHYSICAL_MAP_TYPE;
				
			map.setInitOptions(mOptions);
			
			
			if (map_mask) 
			{
				var mOptions2:MapOptions = new MapOptions();
				mOptions2.zoom = currSc;
				mOptions2.center = new LatLng(currLat,currLng);
				mOptions2.continuousZoom = false;
				
				if(mapTiltGesture){
					//mOptions2.viewMode = View.VIEWMODE_PERSPECTIVE; 
					mOptions2.attitude = new Attitude(currtiltAng,currAng,0);
				}

				if (currTypeMask == 0)mOptions2.mapType = MapType.SATELLITE_MAP_TYPE;  
				else if(currTypeMask == 1) mOptions2.mapType = MapType.HYBRID_MAP_TYPE;
				else if(currTypeMask == 2) mOptions2.mapType = MapType.NORMAL_MAP_TYPE;
				else if(currTypeMask == 3) mOptions2.mapType = MapType.PHYSICAL_MAP_TYPE;
				map2.setInitOptions(mOptions2);
			}
			
		}*/
		private function objectDragHandler(event:GWGestureEvent):void
		{
			x += event.value.dx;
			y += event.value.dy;
		}
		
		private function objectScaleHandler(event:GWGestureEvent):void
		{
			scaleX += event.value.dsx;
			scaleY += event.value.dsy;
		}
		
		private function objectRotateHandler(event:GWGestureEvent):void
		{
			rotation += event.value.dtheta;
		}
		
		private function doubleMaskTapHandler(event:GWGestureEvent):void
		{
			/*
			currTypeMask +=1;
			if (currTypeMask > 3) currTypeMask = 0;
			//trace("dtap mask",currTypeMask);
			
				if(currTypeMask == 0) map2.setMapType(MapType.SATELLITE_MAP_TYPE)  
				else if(currTypeMask == 1) map2.setMapType(MapType.HYBRID_MAP_TYPE);
				else if(currTypeMask == 2) map2.setMapType(MapType.NORMAL_MAP_TYPE)
				else if(currTypeMask == 3) map2.setMapType(MapType.PHYSICAL_MAP_TYPE);
			*/
			
		}
		
		private function gestureMaskDragHandler(event:GWGestureEvent):void 
		{
			var ang2:Number = map_holder.rotation * (Math.PI / 180);
			var COS2:Number = Math.cos(ang2);
			var SIN2:Number = Math.sin(ang2);
			var x_:Number = mShape.x + event.value.dx;
			var y_:Number = mShape.y + event.value.dy;
			
			if ((x_ > 0) && (x_ < mapWidth))
			{
				mShape.x += (event.value.dy * SIN2 + event.value.dx * COS2);
				mShapeHit.x +=(event.value.dy * SIN2 + event.value.dx * COS2);
				mShapeOutline.x +=(event.value.dy * SIN2 + event.value.dx * COS2);
			}
			if ((y_ > 0) && (y_ < mapHeight))
			{
				mShape.y += (event.value.dy * COS2 - event.value.dx * SIN2);
				mShapeHit.y += (event.value.dy * COS2 - event.value.dx * SIN2);
				mShapeOutline.y += (event.value.dy * COS2 - event.value.dx * SIN2);
			}
		}
		private function gestureMaskScaleHandler(event:GWGestureEvent):void
		{
			mShapeHit.scaleX += event.value.dsx;
			mShapeHit.scaleY += event.value.dsy;
			
			mShape.scaleX += event.value.dsx;
			mShape.scaleY += event.value.dsy;
			
			mShapeOutline.scaleX += event.value.dsx;
			mShapeOutline.scaleY += event.value.dsy;
			
		}
		private function gestureMaskRotateHandler(event:GWGestureEvent):void
		{
			mShapeHit.rotation += event.value.dtheta;
			mShape.rotation += event.value.dtheta;
			mShapeOutline.rotation += event.value.dtheta;
		}
		
		private function gestureDragHandler(event:GWGestureEvent):void 
		{	
			/*
			if(mapTiltGesture){
				map.cancelFlyTo();
				if (map_mask) map2.cancelFlyTo();
			}
			
			var point:Point = map.fromLatLngToPoint(map.getCenter());
			var ang:Number = map_holder.rotation * (Math.PI / 180);
			var COS:Number = Math.cos(ang);
			var SIN:Number = Math.sin(ang);
			var pdx:Number = (point.x - (event.value.dy * SIN + event.value.dx * COS));
			var pdy:Number = (point.y - (event.value.dy * COS - event.value.dx * SIN));
			
			var newPoint:Point = new Point(drag_factor*pdx,drag_factor*pdy);
			var newLatLng:LatLng = map.fromPointToLatLng(newPoint);
			
			map.setCenter(newLatLng);
			if (map_mask) map2.setCenter(newLatLng);
			*/
		}
		
		private function doubleTapHandler(event:GWGestureEvent):void
		{
			//trace("d tap", x, y);
			var localx:Number = event.value.x - x; ////////////////////////// need local coordinates for gestures
			var localy:Number = event.value.y - y; ////////////////////////// need local coordinates for gestures
			
			//var newPoint:Point = new Point(event.localX, event.localY);
			var newPoint:Point = new Point(localx,localy);
			
			/*
			//var nLatLng:LatLng = map.fromViewportToLatLng(newPoint, true);
			//currSc += stepSc;
			
			if(mapTiltGesture){
				map.cancelFlyTo();
				map.flyTo(nLatLng, currSc, new Attitude(currAng, currtiltAng, 0), 2); 
				
				if (map_mask) {
					map2.cancelFlyTo();
					map2.flyTo(nLatLng, currSc, new Attitude(currAng, currtiltAng, 0), 2);
				}
			}
			*/
		}

		private function gestureScaleHandler(event:GWGestureEvent):void
		{
			var dsc:Number = event.value.dsx;
			/*
			if(mapTiltGesture){
				map.cancelFlyTo();
				
				if (map_mask)map2.cancelFlyTo();
			}
			if((Math.abs(dsc)<scale_lim)&&(dsc<0)){
			 		currSc += scale_out_factor*scale_factor*dsc;
				}
				else{
					currSc += scale_factor*dsc;
				}
			
			map.setZoom(currSc, true);
			
			if (map_mask)map2.setZoom(currSc, true);
			*/
		}
		
		private function gestureRotateHandler(event:GWGestureEvent):void
		{
			currAng -= rotate_factor*event.value.dtheta;
			
			/*
			if(mapTiltGesture){
				map.cancelFlyTo();
				map.setAttitude(new Attitude(currAng, currtiltAng, 0));
				
				if (map_mask) {
					map2.cancelFlyTo();
					map2.setAttitude(new Attitude(currAng, currtiltAng, 0));
				}
			}*/
		}
		
		private function gestureTiltHandler(event:GWGestureEvent):void 
		{
			/*
			currtiltAng += tilt_factor*event.tiltY;
			if(mapTiltGesture){
				map.cancelFlyTo();
				map.setAttitude(new Attitude(currAng,currtiltAng,0));
			}
			*/
		}
		
		
	}
}