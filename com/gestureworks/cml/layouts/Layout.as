package com.gestureworks.cml.layouts 
{
	import com.gestureworks.cml.core.CMLObject;
	import com.gestureworks.cml.interfaces.ILayout;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.greensock.easing.Ease;
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.utils.getDefinitionByName;
	
	/** 
	 * The Layout is the base class for all Layouts.
	 * It is an abstract class that is not meant to be called directly.
	 *
	 * @author Charles and Shaun
	 * @see com.gestureworks.cml.elements.Container
	 * @see com.gestureworks.cml.elements.TouchContainer
	 */	
	public class Layout extends CMLObject implements ILayout
	{
		protected var childTransformations:Array;
		private var layoutTween:TimelineLite;
		private var tweenedObjects:Array;
		public var children:Array;
		
		/**
		 * Constructor
		 */
		public function Layout() 
		{
			super();
			childTransformations = new Array();
			TweenPlugin.activate([TransformMatrixPlugin]); 
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
		
		private var _tweenDelay:Number = 0;		
		/**
		 * Tween's initial delay which is the length of time in seconds before the animation should begin.
		 */
		public function get tweenDelay():Number { return _tweenDelay; }
		public function set tweenDelay(d:Number):void {
			_tweenDelay = d; 
		}

		private var _easing:Ease;
		/**
		 * Specifies the easing equation. Argument must be an Ease instance or a String defining the Ease class
		 * either by property syntax or class name (e.g. Expo.easeOut or ExpoOut). 
		 */
		public function get easing():* { return _easing; }
		public function set easing(e:*):void
		{
			if (!(e is Ease))
			{   
				var value:String = e.toString();				
				if (value.indexOf(".ease") != -1)
					value = value.replace(".ease", "");
				
				var easingType:Class = getDefinitionByName("com.greensock.easing." + value) as Class;
				e = new easingType();
			}
			if (e is Ease)
				_easing = e;
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
		
		private var _onCompleteParams:Array;
		/**
		 * Parameters for onComplete function
		 */
		public function get onCompleteParams():Array { return _onCompleteParams; }
		public function set onCompleteParams(value:Array):void {
			_onCompleteParams = value;
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
		
		private var _onUpdateParams:Array;
		/**
		 * Parameters for onUpdate function
		 */
		public function get onUpdateParams():Array { return _onUpdateParams; }
		public function set onUpdateParams(value:Array):void {
			_onUpdateParams = value;
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
			var transformation:Matrix;
			
			if (!children || !children.length)
				children = DisplayUtils.getAllChildren(container);
			
			if (tween)
			{				
				if (layoutTween && layoutTween._active)
				{
					layoutTween.eventCallback("onUpdate", onUpdate, onUpdateParams);
					layoutTween.eventCallback("onComplete", onComplete, onCompleteParams );
					return;
				}
				
				childTweens = new Array();
				tweenedObjects = new Array();
				
				for (var i:int = 0; i < children.length; i++) 
				{				
					var child:* = children[i];
					if(!validObject(child)) continue;
					
					if (tIndex < childTransformations.length)
					{
						transformation = childTransformations[tIndex];						
						if (!isNaN(rotation))
							rotateTransform(transformation, degreesToRadians(rotation));
						if (!isNaN(scale))
							scaleTransform(transformation, scale);
						childTweens.push(TweenLite.to(child, tweenTime / 1000, {transformMatrix: getMatrixObj(transformation), alpha:alpha, ease: easing}));
						tweenedObjects.push(child);
					}
					
					tIndex++;
				}
				
				layoutTween = new TimelineLite( { onComplete:onComplete, onCompleteParams:onCompleteParams, onUpdate:onUpdate, onUpdateParams:onUpdateParams, delay:tweenDelay } );
				layoutTween.appendMultiple(childTweens);
				layoutTween.play();
				
			}
			else
			{
				for (var j:int = 0; j < container.numChildren; j++)
				{
					child = container.getChildAt(j);
					if (!validObject(child)) continue;
					
					transformation = childTransformations[tIndex];;
					if (!isNaN(rotation))
						rotateTransform(transformation, degreesToRadians(rotation));
					if (!isNaN(scale))
						scaleTransform(transformation, scale);
					
					child.transform.matrix = transformation;
					child.alpha = alpha;
					tIndex++;
				}
				if (onComplete != null) onComplete.call(onCompleteParams);
				if (onUpdate != null) onUpdate.call(onUpdateParams);
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
		 * Kills the tweening of the provided child. If a child is not provided, the group tween is killed.
		 * @param	child  
		 */
		public function killTween(child:*=null):void
		{
			if (layoutTween)
			{
				if(!child)
					layoutTween.kill();
				else
					layoutTween.kill(null, child);
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
			m.rotate(degreesToRadians(angle));
			m.translate( aroundX, aroundY );
			return m;
		}
		
		/**
		 * Converts transformation matrix to TweenMax syntax
		 * @param	mtx  transformation matrix
		 * @return  tween matrix
		 */
		protected static function getMatrixObj(mtx:Matrix):Object
        {
			return { a:mtx.a, b:mtx.b, c:mtx.c, d:mtx.d, tx:mtx.tx, ty:mtx.ty };
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