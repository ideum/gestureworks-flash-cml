package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.StateUtils;
	import com.greensock.TweenMax;
	import com.modestmaps.geo.Location;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A Hotspot is primarily a container for graphic objects that is set at an index local to a gigapixel scene.
	 * 
	 * @author Ideum
	 * @see Gigapixel
	 */
	public class Hotspot extends Container
	{
		protected var tetherSprite:Sprite;
		
		/**
		 * Constructor
		 */
		public function Hotspot() 
		{
			super();
		}

		

		public var compX:Number = 0;
		public var compY:Number = 0;
		public var compResetOnOpen:Boolean = false;
		public var compResetOnClose:Boolean = false;
		public var compCenterToStage:Boolean = false;
		public var compAbsPos:Boolean = false;	
		public var compTween:Boolean = false;
		public var compTweenTime:Number = .25;
		public var compAddOnOpen:Boolean = false;
		
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
		
		private var _tetherOffsetX:Number = 0;
		/**
		 * X offset to the source of the tether sprite
		 */
		public function get tetherOffsetX():Number { return _tetherOffsetX; }
		public function set tetherOffsetX(val:Number):void { 
			_tetherOffsetX = val; 
		}
		
		private var _tetherOffsetY:Number = 0;
		/**
		 * Y offset to the source of the tether sprite
		 */
		public function get tetherOffsetY():Number { return _tetherOffsetY; }
		public function set tetherOffsetY(val:Number):void { 
			_tetherOffsetY = val; 
		}
		
		private var _componentAnchorOffsetX:Number = 0;
		/**
		 *	X offset to where the tether sprite is anchored on the component 
		 */
		public function get componentAnchorOffsetX():Number { return _componentAnchorOffsetX; }
		public function set componentAnchorOffsetX(val:Number):void { 
			_componentAnchorOffsetX = val; 
		}
		
		private var _componentAnchorOffsetY:Number = 0;
		/**
		 * Y offset to where the tether sprite is anchored on the component
		 */
		public function get componentAnchorOffsetY():Number { return _componentAnchorOffsetY; }
		public function set componentAnchorOffsetY(val:Number):void { 
			_componentAnchorOffsetY = val;
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
		 * Initialisation method
		 */
		override public function init():void {
			addEventListener(StateEvent.CHANGE, onHotspot);
			if (_tether)
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (_component)
				_component.addEventListener(StateEvent.CHANGE, onComponentState);
		}
		
		private function onComponentState(e:StateEvent):void {
			if (e.value == "close" || e.value == "timeout") {
				_component.visible = false;
				if (tetherSprite)
					tetherSprite.visible = false;
					
				if (compResetOnClose) {
					StateUtils.loadState(_component, 0, false);	
					if (_component["front"] && _component["front"]["reset"]())
						_component["reset"]();
				}						
			}
		}
	
		private function tweenAlpha(obj:DisplayObject, val:Number):void {
			if (val) {		
				if (compResetOnOpen) {
					StateUtils.loadState(_component, 0, false);	
					if ("front" in _component && _component["front"]["reset"]())
						_component["reset"]();
				}						
				obj.visible = true;	
				updateComponent();
			}		
			TweenMax.to(obj, compTweenTime, { alpha:val, onComplete:hide } );
			function hide():void {
				if (!val) {
					obj.visible = false;
					updateComponent();
				}		
			}	
		}
		
		protected function onHotspot(e:StateEvent):void {
			if (_component) {				
				if (compTween) {
					if (_component.visible) {
						tweenAlpha(_component, 0);
						if (_tether && tetherSprite) {
							tweenAlpha(tetherSprite, 0);
						}
					}
					else { 
						_component.alpha = 0;
						tweenAlpha(_component, 1);
						if (_tether && tetherSprite) {
							tweenAlpha(tetherSprite, 1);
						}					
					}
				}
				else {
					if (compResetOnOpen) {
						StateUtils.loadState(_component, 0, false);	
						if ("front" in _component && _component["front"]["reset"]())
							_component["reset"]();
					}							
					_component.visible = !_component.visible;
					if (_tether && tetherSprite) {
						tetherSprite.visible = _component.visible;	
					}				
					updateComponent();
				}
				
				if (component.parent && compAddOnOpen)
					component.parent.addChild(_component);
			}
		}
		
		private function updateComponent():void
		{
				
				
			if (compCenterToStage) {
				_component.x = (stage.stageWidth - _component.width * _component.scaleX) / 2;
				_component.y = (stage.stageHeight - _component.height * _component.scaleY) / 2;
			}
			else if (!compAbsPos) {	
				var tempPoint:Point = localToGlobal(new Point(x1, y1));
				
				var x1:Number = tempPoint.x;
				var y1:Number = tempPoint.y;

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
			}

			
			if (compX) _component.x = compX;
			if (compY) _component.y = compY;
			
			_component.dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "hotspot", "visible", true));			
			
		}
		
		
		
		protected function onEnterFrame(e:Event):void {
			if (!_tether || !_component) return;
			
			if (!tetherSprite) {
				tetherSprite = new Sprite();
				addChildAt(tetherSprite, 0);
			}
			
			if (_component.visible){
				tetherSprite.x = _tetherOffsetX;
				tetherSprite.y = _tetherOffsetY;
				tetherSprite.graphics.clear();
				tetherSprite.graphics.lineStyle(_tetherStroke, _tetherColor, _tetherAlpha);
				
				var mat:Matrix = new Matrix();
				mat.identity();
				mat.rotate(_component.rotation*Math.PI/180);
			
				var anchor:Point = new Point(_component.x + _componentAnchorOffsetX, 
											  _component.y + _componentAnchorOffsetY);
				
				var nPoint:Point = DisplayUtils.getRotatedPoint(anchor, 
																  _component.rotation * Math.PI / 180,
																  new Point(_component.x, _component.y));
											  
				var point:Point = globalToLocal(new Point(nPoint.x, nPoint.y));

				tetherSprite.graphics.lineTo(point.x - _tetherOffsetX, 
											 point.y - _tetherOffsetY);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			tetherSprite = null;
			if (_component){
				_component.removeEventListener(StateEvent.CHANGE, onComponentState);						
				_component = null;
			}
		}
	}

}