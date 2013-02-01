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
		
		private var _originX:Number = 0;		
		/**
		 * Starting x coordinate of layout relative to the container
		 * @default 0
		 */
		public function get originX():Number { return _originX; }
		public function set originX(x:Number):void
		{
			_originX = x;
		}
		
		public var _originY:Number = 0;
		/**
		 * Starting y coordinate of layout relative to the container
		 * @default 0
		 */
		public function get originY():Number { return _originY; }
		public function set originY(y:Number):void
		{
			_originY = y;
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
		
		private var _scale:Number;
		/**
		 * Specifies the scale value of the display objects in the layout
		 */
		public function get scale():Number { return _scale; }
		public function set scale(s:Number):void
		{
			_scale = s;
		}
		
		private var _rotation:Number;
		/**
		 * Specifies the rotation value of the display objects in the layout
		 */
		public function get rotation():Number { return _rotation; }
		public function set rotation(r:Number):void
		{
			_rotation = r;
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
		/**
		 * Function to call on layout complete
		 */
		public function get onComplete():Function { return _onComplete; }
		public function set onComplete(f:Function):void
		{
			_onComplete = f;
		}
		
		private var _onUpdate:Function;
		/**
		 * Function to call on layout update
		 */
		public function get onUpdate():Function { return _onUpdate; }
		public function set onUpdate(f:Function):void
		{
			_onUpdate = f;
		}
		
		private var _continuousTransform:Boolean = true;	
		/**
		 * Flag indicating the application of a transform relative to the current transform. If this flag is turned off, the transformation is 
		 * reset with the principle layout attributes. (e.g. Given an object with a rotation of 45 degrees, applying a rotation of 10 in continuous mode
		 * will set the object's rotation to 55. In non-continuous mode, applying a rotation of 10 degrees will set the object's rotation to 10).
		 * @default true;
		 */
		public function get continuousTransform():Boolean { return _continuousTransform; }
		public function set continuousTransform(c:Boolean):void
		{
			_continuousTransform = c;
		}
		
		private var _exclusions:Array = new Array();		
		/**
		 * An array of objects to exclude from the layout application
		 */
		public function get exclusions():Array { return _exclusions; }
		public function set exclusions(e:Array):void
		{
			_exclusions = e;
		}
		
		private var _cacheTransforms:Boolean = true;
		/**
		 * Flag indicating the childTransformations are to be cached and reapplied for convenience. If this flag is disabled, the transformations
		 * will need to be recreated for each child. 
		 * @default true
		 */
		public function get cacheTransforms():Boolean { return _cacheTransforms; }
		public function set cacheTransforms(c:Boolean):void
		{
			_cacheTransforms = c;
		}
		
		/**
		 * The object distribution function. If tween is on, creates a tween for each child and applies the child transformations. If tween is off,
		 * assigns the child transformations to the corresponding children. 
		 * @param	container  
		 */
		public function layout(container:DisplayObjectContainer):void 
		{
			var childTweens:Array;
			var tIndex:int = 0;
			
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
					if(!validObject(child)) continue;
					
					if (tIndex < childTransformations.length)
					{
						var transformation:Matrix = childTransformations[tIndex];						
						if (!isNaN(rotation))
							rotateTransform(transformation, degreesToRadians(rotation));
						if (!isNaN(scale))
							scaleTransform(transformation, scale);
							
						childTweens.push(BetweenAS3.tween(child, { transform: getMatrixObj(transformation), alpha:alpha }, null, tweenTime / 1000, Exponential.easeOut));
						tweenedObjects.push(child);
					}
					
					tIndex++;
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
					if (!validObject(child)) continue;
					
					var transformation:Matrix = childTransformations[tIndex];;
					if (!isNaN(rotation))
						rotateTransform(transformation, degreesToRadians(rotation));
					if (!isNaN(scale))
						scaleTransform(transformation, scale);
					
					child.transform.matrix = transformation;
					child.alpha = alpha;
					tIndex++;
				}
				if (onComplete != null) onComplete.call();
				if (onUpdate != null) onUpdate.call();
			}
			
			if (!cacheTransforms)
				childTransformations = new Array();
		}
		
		/**
		 * Determines if an object meets the criteria to be included in the layout 
		 * @param	obj  the object to check
		 * @return  true if valid, false otherwise
		 */
		protected function validObject(obj:*):Boolean
		{
			return obj && obj is DisplayObject && (exclusions.indexOf(obj) == -1);
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
		 * Apply a translation to the provided transformation matrix
		 * @param	m  the transformation matrix
		 * @param	x  the x value of the translation
		 * @param	y  the y value of the translation
		 */
		protected function translateTransform(m:Matrix, x:Number, y:Number):void
		{
			if (continuousTransform)
				m.translate(x, y);
			else
			{
				m.tx = x;
				m.ty = y;
			}			
		}
		
		/**
		 * Apply a rotation to the provided transformation matrix
		 * @param	m  the transformation matrix
		 * @param	rot  the rotation (in radians) to apply
		 */
		protected function rotateTransform(m:Matrix, rot:Number):void
		{
			if (continuousTransform)
				m.rotate(rot);
			else
			{
				m.a = Math.cos(rot);
				m.b = Math.sin(rot);
				m.c = -Math.sin(rot);
				m.d = Math.cos(rot);								
			}
		}	
		
		/**
		 * Apply a scale to the provided transformation matrix
		 * @param	m  the transformation matrix
		 * @param	s  the scale to apply
		 */
		protected function scaleTransform(m:Matrix, s:Number):void
		{
			if (continuousTransform)
				m.scale(s, s);
			else
			{
				m.a = s;
				m.d = s;
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
			layoutTween = null;
			tweenedObjects = null;
			onComplete = null;
			onUpdate = null;
			exclusions = null;
		}
	}

}