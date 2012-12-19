package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.interfaces.ILayout;	
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.core.tweens.ObjectTween;
	import org.libspark.betweenas3.easing.Exponential;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	
	/** 
	 * The LayoutFactory is the base class for all Layouts.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Charles and Shaun
	 * @see com.gestureworks.cml.factories.Container
	 * @see com.gestureworks.cml.factories.TouchContainer
	 * @see com.gestureworks.cml.factories.ElementFactory
	 * @see com.gestureworks.cml.factories.ObjectFactory
	 */	
	public class LayoutFactory extends ObjectFactory implements ILayout
	{
		protected var childTransformations:Array;
		private var layoutTween:ITweenGroup;
		private var tweenedObjects:Array;
		
		/**
		 * Constructor
		 */
		public function LayoutFactory() 
		{
			super();
			childTransformations = new Array();
		}
		
		private var _spacingX:Number = 100;
		/**
		 * Horizontal distance between the origins of two objects
		 * @default 100
		 */
		public function get spacingX():Number { return _spacingX; }
		public function set spacingX(s:Number):void
		{
			_spacingX = s;
		}
		
		private var _spacingY:Number = 100;		
		/**
		 * Vertical distance between the origins of two objects
		 * @default 100
		 */
		public function get spacingY():Number { return _spacingY; }
		public function set spacingY(s:Number):void
		{
			_spacingY = s;
		}
		
		/**
		 * Spacing added to the width of an object
		 * @default 10
		 */
		private var _marginX:Number = 10;
		public function get marginX():Number { return _marginX; }
		public function set marginX(m:Number):void
		{
			_marginX = m;
		}
		
		private var _marginY:Number = 10;		
		/**
		 * Spacing added to the height of an object
		 * @default 10
		 */
		public function get marginY():Number { return _marginY; }
		public function set marginY(m:Number):void
		{
			_marginY = m;
		}				
		
		private var _useMargins:Boolean = false;		
		/**
		 * Flag indicating the use of margins or spacing
		 * @default false
		 */
		public function get useMargins():Boolean { return _useMargins; }
		public function set useMargins(um:Boolean):void
		{
			_useMargins = um;
		}
		
		private var _centerColumn:Boolean = false;
		/**
		 * Flag indicating the alignment of the objects' centers with the center of the column. Column width is determined by greatest width
		 * of the display objects.
		 * @default false
		 */
		public function get centerColumn():Boolean { return _centerColumn; }
		public function set centerColumn(x:Boolean):void
		{
			_centerColumn = x;
		}
		
		private var _centerRow:Boolean = false;
		/**
		 * Flag indicating the alignment of the objects' centers with the center of the row. Row height is determined by greatest height
		 * of the display objects.
		 * @default false
		 */
		public function get centerRow():Boolean { return _centerRow; }
		public function set centerRow(x:Boolean):void
		{
			_centerRow = x;
		}		
				
		private var _type:String;		
		/**
		 * Specifies a layout subtype
		 * @default null
		 */
		public function get type():String { return _type; }
		public function set type(t:String):void
		{
			_type = t;
		}
		
		private var _alpha:Number = 1
		/**
		 * Specifies the alpha value of the display objects in the layout
		 * @default 1
		 */
		public function get alpha():Number { return _alpha; }
		public function set alpha(a:Number):void
		{
			_alpha = a > 1 ? 1 : a < 0 ? 0 : a;
		}
		
		private var _tween:Boolean = false;
		/**
		 * Flag indicating the display objects will animate to their layout positions. If false,
		 * the objects will be positioned at initialization.
		 * @default true
		 */
		public function get tween():Boolean { return _tween; }
		public function set tween(t:Boolean):void
		{
			_tween = t;
		}
		
		private var _tweenTime:Number = 500;
		/**
		 * The time(ms) the display objects will take to move into positions
		 * @default 500
		 */
		public function get tweenTime():Number { return _tweenTime; }
		public function set tweenTime(t:Number):void
		{
			_tweenTime = t;
		}
		
		private var _onComplete:Function;
		
		public function get onComplete():Function { return _onComplete; }
		public function set onComplete(f:Function):void
		{
			_onComplete = f;
		}
		
		private var _onUpdate:Function;
		
		public function get onUpdate():Function { return _onUpdate; }
		public function set onUpdate(f:Function):void
		{
			_onUpdate = f;
		}		
		
		/**
		 * The object distribution function. If tween is on, creates a tween for each child and applies the child transformations. If tween is off,
		 * assigns the child transformations to the corresponding children. 
		 * @param	container  
		 */
		public function layout(container:DisplayObjectContainer):void 
		{
			var childTweens:Array;
			
			if (tween)
			{
				if (layoutTween && layoutTween.isPlaying)
				{
					layoutTween.onUpdate = onUpdate;
					layoutTween.onComplete = onComplete;
					return;
				}
				
				childTweens = new Array();
				tweenedObjects = new Array();
				
				for (var i:int = 0; i < container.numChildren; i++) 
				{				
					var child:* = container.getChildAt(i);
					if (!child is DisplayObject) return;
					
					if (i < childTransformations.length)
					{
						childTweens.push(BetweenAS3.tween(child, { transform: getMatrixObj(childTransformations[i]), alpha:alpha }, null, tweenTime / 1000, Exponential.easeOut));
						tweenedObjects.push(child);
					}
				}
				layoutTween = BetweenAS3.parallel.apply(null, childTweens);
				layoutTween.onUpdate = onUpdate;
				layoutTween.onComplete = onComplete;				
				layoutTween.play();
			}
			else
			{
				for (var j:int = 0; j < container.numChildren; j++)
				{
					child = container.getChildAt(j);
					child.transform.matrix = childTransformations[j];
					child.alpha = alpha;
				}
				if (onComplete != null) onComplete.call();
				if (onUpdate != null) onUpdate.call();
			}
		}
		
		/**
		 * Stops the tweening of the provided child if corresponding tween is playing. If a child
		 * is not provided, the group tween is stopped.
		 * @param	child  the object to stop 
		 */
		public function stopTween(child:*=null):void
		{
			if (layoutTween && layoutTween.isPlaying)
			{
				if(!child)
					layoutTween.stop();
				else
				{ //TODO: need to investigate BetweenAS3 to figure out how to stop an indidual tween from a group tween
					layoutTween.getTweenAt(tweenedObjects.indexOf(child)).stop();
				}
			}
		}
		
		/**
		 * Generates a reandom number between min and max
		 * @param	min  the bottom limit
		 * @param	max  the top limit
		 * @return  a random number
		 */
		protected static function randomMinMax(min:Number, max:Number):Number
		{
			return min + Math.random() * (max - min);
		}
		
		/**
		 * Converts degrees to radians
		 * @param	degrees  value in degrees
		 * @return  value in radians
		 */
		protected static function degreesToRadians(degrees:Number):Number
		{
			return Math.PI * degrees / 180;
		}
		
		/**
		 * Rotates an object around a spcecific point at a specific angle of rotation
		 * @param	obj  the object to rotate
		 * @param	angle  the angle of rotation
		 * @param	aroundX  the x coordinate of the point to rotate around
		 * @param	aroundY  the y coordinate of the point to rotate around
		 */
		protected static function rotateAroundPoint(obj:*, angle:Number, aroundX:Number, aroundY:Number):void
		{		
			var m:Matrix = obj.transform.matrix;			 
			m = pointRotateMatrix(angle, aroundX, aroundY, m);
			obj.transform.matrix = m;
		}	
		
		/**
		 * Returns a matrix rotated around a specific point at a specific angle
		 * @param	angle  the angle of rotation
		 * @param	aroundX  the x coordinate of the point to rotate around
		 * @param	aroundY  the y coordinate of the point to rotate around
		 * @param	m  the matrix to rotate
		 * @return
		 */
		protected static function pointRotateMatrix(angle:Number, aroundX:Number, aroundY:Number, m:Matrix=null):Matrix
		{
			if (!m) m = new Matrix();
			m.translate( -aroundX, -aroundY );
			m.rotate(Math.PI * angle / 180);
			m.translate( aroundX, aroundY );
			return m;
		}
		
		/**
		 * Converts transformation matrix to BetweenAS3 syntax
		 * @param	mtx  transformation matrix
		 * @return  tween matrix
		 */
		protected static function getMatrixObj(mtx:Matrix):Object
        {
            return { matrix: { a:mtx.a, b:mtx.b, c:mtx.c, d:mtx.d, tx:mtx.tx, ty:mtx.ty }};
        }
		
		/**
		 * Returns the max width of the container's children
		 * @param	c the container
		 * @return  the max width
		 */
		protected static function getMaxWidth(c:DisplayObjectContainer):Number
		{
			var maxWidth:Number = 0;
			for (var i:int = 0; i < c.numChildren; i++)
				maxWidth = c.getChildAt(i).width > maxWidth ? c.getChildAt(i).width : maxWidth;
			return maxWidth;
		}				
		
		/**
		 * Returns the max height of the container's children
		 * @param	c the container
		 * @return  the max height
		 */
		protected static function getMaxHeight(c:DisplayObjectContainer):Number
		{
			var maxHeight:Number = 0;
			for (var i:int = 0; i < c.numChildren; i++)
				maxHeight = c.getChildAt(i).height > maxHeight ? c.getChildAt(i).height : maxHeight;
			return maxHeight;
		}	
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			childTransformations = null;
		}
	}

}