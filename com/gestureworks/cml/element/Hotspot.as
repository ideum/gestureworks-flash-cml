package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.events.StateEvent;
	import com.modestmaps.geo.Location;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	/**
	 * A Hotspot is primarily a container for graphic objects that is set at an index local to a gigapixel scene.
	 * 
	 * @author josh
	 * @see Gigapixel
	 */
	public class Hotspot extends Container
	{
		/**
		 * Constructor
		 */
		public function Hotspot() 
		{
			super();
		}
		
		private var _sceneX:Number = 0;
		/**
		 * The relative _x coordinate to be attached to on the scene.
		 */
		public function get sceneX():Number { return _sceneX; }
		public function set sceneX(value:Number):void {
			_sceneX = value;
		}
		
		private var _sceneY:Number = 0;
		/**
		 * the relative _y coordinate to be attached to on the scene.
		 */
		public function get sceneY():Number { return _sceneY; }
		public function set sceneY(value:Number):void {
			_sceneY = value;
		}
		
		private var _component:DisplayObject;
		/**
		 * The component CSS id to attach this hotspot to. Attaching a component to a hotspot that is a button will toggle the component's visibility.
		 * It is recommended that you set all items attached to the hotspot to visible="false" as their initial state.
		 */
		public function get component():* { return _component; }
		public function set component(value:*):void {
			if (!value)
				return;
			else if (value is DisplayObject) {
				_component = value;
			}
			else {
				_component = CMLObjectList.instance.getId(value);
			}
			//if (!(contains(_component)))
				//addChild(_component);
		}
		
		/**
		 * CML callback Initialisation
		 */
		override public function displayComplete():void
		{			
			init();
		}
		
		
		/**
		 * Initialisation method
		 */
		public function init():void {
			addEventListener(StateEvent.CHANGE, onHotspot);
		}
		
		private function onHotspot(e:StateEvent):void {
			if (_component) {
				_component.visible = !_component.visible;
				
				var offsetX:Number = 0;
				var offsetY:Number = 0;
				
				for (var i:Number = 0; i < numChildren; i++) {
					if (getChildAt(i) != _component) {
						if ( getChildAt(i).x + getChildAt(i).width > offsetX)
							offsetX = getChildAt(i).x + getChildAt(i).width;
						if ( getChildAt(i).y + getChildAt(i).height > offsetY)
							offsetY = getChildAt(i).y + getChildAt(i).height;
					}
				}
				//var point:Point = new Point(this.x, this.y);
				//point = localToGlobal(point);
				_component.x = x;
				_component.x += offsetX;
				if (_component.x + _component.width > stage.stageWidth) {
					_component.x = x - _component.width;
					_component.x -= offsetX;
				}
				
				/*if (y + _component.height > stage.stageHeight) {
					_component.y = y + _component.height - this.height;
				} else ( */
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			removeEventListener(StateEvent.CHANGE, onHotspot);
			
			while (numChildren > 0) {
				removeChildAt(0);
			}
			
			component = null;
		}
	}

}