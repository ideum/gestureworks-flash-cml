package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.events.StateEvent;
	import com.modestmaps.geo.Location;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A Hotspot is primarily a container for graphic objects that is set at an index local to a gigapixel scene.
	 * 
	 * @author josh
	 * @see Gigapixel
	 */
	public class Hotspot extends Container
	{
		private var tetherSprite:Sprite;
		
		/**
		 * Constructor
		 */
		public function Hotspot() 
		{
			super();
		}
		
		private var _tether:Boolean = true;
		/**
		 * Whether or not a tethering line will be drawn from the hotspot graphic to the component.
		 */
		public function get tether():Boolean { return _tether; }
		public function set tether(value:Boolean):void {
			_tether = value;
		}
		
		private var _tetherColor:uint = 0xffffff;
		/**
		 * The color of the tethering line if set to true.
		 */
		public function get tetherColor():uint { return _tetherColor; }
		public function set tetherColor(value:uint):void {
			_tetherColor = value;
		}
		
		private var _tetherStroke:Number = 1;
		/**
		 * The stroke of the tethering line.
		 */
		public function get tetherStroke():Number { return _tetherStroke; }
		public function set tetherStroke(value:Number):void {
			_tetherStroke = value;
		}
		
		private var _tetherAlpha:Number = 1;
		/**
		 * The alpha of the tethering line.
		 */
		public function get tetherAlpha():Number { return _tetherAlpha; }
		public function set tetherAlpha(value:Number):void {
			_tetherAlpha = value;
		}
		
		private var _sceneX:Number = 0;
		/**
		 * The relative _x coordinate to be attached to on the scene of an object that does not use regular stage coordinates (ie: gigapixel).
		 */
		public function get sceneX():Number { return _sceneX; }
		public function set sceneX(value:Number):void {
			_sceneX = value;
		}
		
		private var _sceneY:Number = 0;
		/**
		 * the relative _y coordinate to be attached to on the scene of an object that does not use regular stage coordinates (ie: gigapixel).
		 */
		public function get sceneY():Number { return _sceneY; }
		public function set sceneY(value:Number):void {
			_sceneY = value;
		}
		
		private var _component:DisplayObject
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
			if (_tether)
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (_component)
				_component.addEventListener(StateEvent.CHANGE, onComponentState);
		}
		
		private function onComponentState(e:StateEvent):void {
			if (e.value == "close") {
				_component.visible = false;
				if (tetherSprite)
					tetherSprite.visible = false;
			}
		}
		
		private function onHotspot(e:StateEvent):void {
			if (_component) {
				var tempPoint:Point = localToGlobal(new Point(x1, y1));
				
				var x1:Number = tempPoint.x;
				var y1:Number = tempPoint.y;
				
				_component.visible = !_component.visible;
				if (_tether && tetherSprite)
					tetherSprite.visible = _component.visible;
				
				var offsetX:Number = 0;
				var offsetY:Number = 0;
				
				for (var i:Number = 0; i < numChildren; i++) {
					if (getChildAt(i) is Button) {
						if (getChildAt(i).width > offsetX)
							offsetX = getChildAt(i).width;
						if (getChildAt(i).height > offsetY)
							offsetY = getChildAt(i).height;
					}
				}
				//var point:Point = new Point(this.x, this.y);
				//point = localToGlobal(point);
				_component.x = x1;
				_component.x += offsetX;
				if (_component.x + _component.width > stage.stageWidth) {
					_component.x = x1 - _component.width;
					//_component.x -= offsetX;
				}
				
				
				if (y1 + _component.height < stage.stageHeight) {
					_component.y = y1;
				} else if (y1 - _component.height + offsetY > 0) { 
					_component.y = y1 - _component.height + offsetY; 
				} else {
					var diffY:Number = 0;
					if (y1 + _component.height > stage.stageHeight) {
						diffY = (y1 + _component.height - stage.stageHeight);
						_component.y = y1 - diffY;
					} else if (y1 - _component.height + offsetY < 0) {
						diffY = (y1 - _component.height + offsetY) * -1;
						_component.y = y1 - _component.height + offsetY + diffY;
					}
				}
				
				//trace("Setting component:", _component.x, _component.y);
			}
		}
		
		private function onEnterFrame(e:Event):void {
			if (!_tether || !_component) return;
			
			if (!tetherSprite) {
				tetherSprite = new Sprite();
				addChildAt(tetherSprite, 0);
			}
			
			if (_component.visible){
				tetherSprite.x = 18;
				tetherSprite.y = 12;
				tetherSprite.graphics.clear();
				tetherSprite.graphics.lineStyle(_tetherStroke, _tetherColor, _tetherAlpha);
				var point:Point = globalToLocal(new Point(_component.x, _component.y));
				tetherSprite.graphics.lineTo(point.x, point.y);
			}
			//addChild(tether);
			
			//trace("Component:", _component.x, _component.y);
			
		}
		
		override public function dispose():void {
			super.dispose();
			
			removeEventListener(StateEvent.CHANGE, onHotspot);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if (_component)
				_component.removeEventListener(StateEvent.CHANGE, onComponentState);
			
			while (numChildren > 0) {
				removeChildAt(0);
			}
			
			component = null;
		}
	}

}