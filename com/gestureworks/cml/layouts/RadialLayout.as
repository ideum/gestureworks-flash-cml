package com.gestureworks.cml.layouts {
	import com.gestureworks.cml.utils.DisplayUtils;
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
		private var _variation:Number;
		
		public function RadialLayout(radius:Number=100, minAngle:Number = 0, maxAngle:Number = 360, variation:Number = 0, scale:Number = 1) {
			super();
			this.radius = radius;
			this.minAngle = minAngle;
			this.maxAngle = maxAngle;
			this.variation = variation;
			this.scale = scale;
		}
		
		override public function layout(container:DisplayObjectContainer):void {
			var range:Number = _maxAngle-_minAngle;
			var len:int = container.numChildren;
			var angleIter:Number = range / len;
			var curAngle:Number = _minAngle;
			var variedAngle:Number;
			var child:DisplayObject;
			var dx:Number;
			var dy:Number;
			var matrix:Matrix;
			childTransformations.length = 0;
			var cnt:int;
			
			if (!children)
				children = DisplayUtils.getAllChildren(container);
			
			cnt = children.length;
			for (var i:int =0; i < cnt; i++) {
				child = children[i]
				if (child == null) {
					continue;
				}
				if(_variation!=0) {
					variedAngle = curAngle + Math.random() * _variation - _variation / 2;
				} else {
					variedAngle = curAngle;
				}
				dx = Math.cos(variedAngle) * _radius;
				dy = -Math.sin(variedAngle) * _radius;
				matrix = child.transform.matrix;
				translateTransform(matrix, originX + dx, originY + dy);
				scaleTransform(matrix, scale);
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
			return _minAngle * 360 / TAU;
		}
		
		public function set minAngle(value:Number):void {
			_minAngle = value * TAU / 360;
		}
		
		public function get maxAngle():Number {
			return _maxAngle * 360 / TAU;
		}
		
		public function set maxAngle(value:Number):void {
			_maxAngle = value * TAU / 360;
		}
		
		public function get variation():Number {
			return _variation * 360 / TAU;
		}
		
		public function set variation(value:Number):void {
			_variation = value * TAU / 360;
		}
	}

}