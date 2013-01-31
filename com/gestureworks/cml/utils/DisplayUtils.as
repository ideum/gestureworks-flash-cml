package com.gestureworks.cml.utils 
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;

	
	/**
	 * ...
	 * @author Ideum
	 */
	public class DisplayUtils 
	{
		
		public function DisplayUtils() {}
			

		/**
		 * Converts display object to bitmap data and return bitmap
		 * @param	obj		
		 * @param	smoothing
		 */
		public static function toBitmap(obj:DisplayObject, smoothing:Boolean=true):Bitmap 
		{
			var bmd:BitmapData = new BitmapData(obj.width, obj.height, true, 0xffffff);
			bmd.draw(DisplayObject(obj));
			
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = smoothing;
			return bitmap;
		}
		
		/**
		 *  Removes all children of a specific type from a container.
		 * 
		 * @example <listing version="3.0">
		 * var s:Sprite = new Sprite();
		 * s.addChild(new Shape());
		 * s.addChild(new Shape());
		 * s.addChild(new MovieClip());
		 * s.addChild(new Sprite());
		 * //trace(s.numChildren); // 4
		 * removeAllChildrenByType(s, Shape);
		 * //trace(s.numChildren); // 2
		 * </listing>
		 *   
		 * 	@param container Container to remove from
		 *  @param the type of children to remove
		 *  @author John Lindquist
		 */
		public static function removeAllChildrenByType(container:DisplayObjectContainer, type:Class):Array
		{
			var removed:Array = [];
			for (var i:int = container.numChildren - 1; i >= 0; i--)
			{
				if(container.getChildAt(i) is type)
				{
					removed.push(container.removeChildAt(i));
				}
			}
			return removed;
		}		
		
		/**
		 *   Removes all children from a container and leave the bottom few
		 *   @param container Container to remove from
		 *   @param leave (optional) Number of bottom children to leave
		 *   @author Jackson Dunstan
		 */
		public static function removeAllChildren(container:DisplayObjectContainer, leave:int = 0):Array
		{
			var removed:Array = [];
			while (container.numChildren > leave)
			{
				removed.push(container.removeChildAt(leave));
			}
			return removed;
		}	
		
		/**
		 *  Returns all children of a specific type from a container.
		 *   
		 * 	@param container Container to remove from
		 *  @param the type of children to remove
		 */
		public static function getAllChildrenByType(container:DisplayObjectContainer, type:Class):Array
		{
			var children:Array = [];
			for (var i:int = 0; i < container.numChildren; i++)
			{
				if(container.getChildAt(i) is type)
				{
					children.push(container.getChildAt(i));
				}
			}
			return children;
		}		
		
		/**
		 *   Returns all children of a container
		 *   @param container 
		 */
		public static function getAllChildren(container:DisplayObjectContainer):Array
		{
			var children:Array = [];
			for (var i:int = 0; i < container.numChildren; i++)
			{
				children.push(container.getChildAt(i));
			}
			return children;
		}			
		
		/**
		 * Add an array of children to a container
		 * @param	container Container to add to
		 * @param	children  the child array
		 */
		public static function addChildren(container:DisplayObjectContainer, children:Array):void
		{
			for each(var child:* in children)
				container.addChild(child);
		}
		
		/**
		 *	 Returns relative position as a point between two display objects  
		 *   @param obj1
		 *   @param obj2
		 *   @author Jackson Dunstan
		 */		
		public static function relativePos(obj1:DisplayObject, obj2:DisplayObject):Point
		{
			var pos:Point = new Point(0, 0);
			pos = obj1.localToGlobal(pos);
			pos = obj2.globalToLocal(pos);
			return pos;
		}
		
		
		/**
		 *   Check if a display object is visible. This checks all of its
		 *   parents' visibilities.
		 *   @param obj Display object to check
		 *   @author Jackson Dunstan
		 */
		public static function isVisible(obj:DisplayObject):Boolean
		{
			for (var cur:DisplayObject = obj; cur != null; cur = cur.parent)
			{
				if (!cur.visible)
					return false;
			}
			return true;
		}
		
		
		
		/**
		 * Wait for a next frame.
		 * Prevents high CPU state, when AVM doesn't send ENTER_FRAMES. It just simply waits until it gets one.
		 * @param callback Function to call once when next frame is displayed
		 * @author Vaclav Vancura (http://vancura.org, http://twitter.com/vancura)
		 */
		public static function scheduleForNextFrame(callback:Function):void {
			var obj:Shape = new Shape();

			obj.addEventListener(Event.ENTER_FRAME, function(ev:Event):void {
				obj.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				callback();
			});
		}
		
		
		/**
		 * Rotates an object around a spcecific point at a specific angle of rotation
		 * @param	obj  the object to rotate
		 * @param	angle  the angle of rotation
		 * @param	aroundX  the x coordinate of the point to rotate around
		 * @param	aroundY  the y coordinate of the point to rotate around
		 */
		public static function rotateAroundPoint(obj:*, angle:Number, aroundX:Number, aroundY:Number):void
		{		
			var m:Matrix = obj.transform.matrix;			 
			m = pointRotateMatrix(angle, aroundX, aroundY, m);
			obj.transform.matrix = m;
		}
		
		/**
		 * Rotates an object around it's center point at a specific angle of rotation
		 * @param	obj  the object to rotate
		 * @param	angle  the angle of rotation
		 */
		public static function rotateAroundCenter(obj:*, angle:Number):void
		{
			var center:Point = getCenterPoint(obj);
			rotateAroundPoint(obj, angle, center.x, center.y);
		}
		
		/**
		 * Returns a matrix rotated around a specific point at a specific angle
		 * @param	angle  the angle of rotation
		 * @param	aroundX  the x coordinate of the point to rotate around
		 * @param	aroundY  the y coordinate of the point to rotate around
		 * @param	m  the matrix to rotate
		 * @return
		 */
		public static function pointRotateMatrix(angle:Number, aroundX:Number, aroundY:Number, m:Matrix=null):Matrix
		{
			if (!m) m = new Matrix();
			m.translate( -aroundX, -aroundY );
			m.rotate(Math.PI * angle / 180);
			m.translate( aroundX, aroundY );
			return m; 
		}
		
		/**
		 * Returns the center point of the object
		 * @param	obj  the object 
		 * @return  the object's center point
		 */
		public static function getCenterPoint(obj:*):Point
		{
			var centerX:Number = obj.x + obj.width / 2;
			var centerY:Number = obj.y + obj.height / 2;
			return new Point(centerX, centerY);
		}
		
		/**
		 * Returns the first parent of the specified type
		 * @param	obj
		 * @return  the parent if the parent of type exists, null otherwise
		 */
		public static function getParentType(type:Class, obj:*):*
		{
			var parent:* = obj.parent;
			
			if (!parent)
				return null;
			else if (parent is type)
				return parent;
			else
				return getParentType(type,parent);			
		}		
		
	}

}