package com.gestureworks.cml.layouts {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Ideum
	 */
	public class RadialLayout extends Layout {
		public static const TAU:Number = Math.PI * 2;
		
		private var _radius:Number;
		private var _minAngle:Number;
		private var _maxAngle:Number;
		
		public function RadialLayout(radius:Number=100, minAngle:Number = 0, maxAngle:Number = TAU) {
			super();
			_radius = radius;
			_minAngle = minAngle;
			_maxAngle = maxAngle;
		}
		
		override public function layout(container:DisplayObjectContainer):void {
			var range:Number = _maxAngle-_minAngle;
			var len:int = container.numChildren;
			var angleIter:Number = range / len;
			var curAngle:Number = _minAngle;
			var child:DisplayObject;
			var dx:Number;
			var dy:Number;
			var matrix:Matrix;
			for (var i:int = childTransformations.length; i < len; i++) {
				child = container.getChildAt(i);
				if (child == null) {
					continue;
				}
				dx = Math.cos(curAngle) * _radius;
				dy = -Math.sin(curAngle) * _radius;
				matrix = child.transform.matrix;
				translateTransform(matrix, originX + dx, originY + dy);
				childTransformations.push(matrix);
				curAngle += angleIter;
			}
			super.layout(container);
		}
		
		public function get radius():Number {
			return _radius;
		}
		
		public function set radius(value:Number):void {
			_radius = value;
		}
		
		public function get minAngle():Number {
			return _minAngle;
		}
		
		public function set minAngle(value:Number):void {
			_minAngle = value;
		}
		
		public function get maxAngle():Number {
			return _maxAngle;
		}
		
		public function set maxAngle(value:Number):void {
			_maxAngle = value;
		}
	}

}