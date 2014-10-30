package com.gestureworks.cml.utils 
{	
	import com.gestureworks.core.TouchSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	/**
	 * ...
	 * @author Ideum
	 */
	public class DisplayUtils 
	{
		
		public function DisplayUtils() {}
			
		/**
		 * Recursively traces display list from input container
		 * @param	container		
		 * @param	indentString
		 */		
		public static function traceDisplayList(container:DisplayObjectContainer, indentString:String=""):void 
		{ 
			var child:DisplayObject; 
			for (var i:int=0; i < container.numChildren; i++) 
			{ 
				child = container.getChildAt(i); 
				trace(indentString, child, child.name, i);  
				if (container.getChildAt(i) is DisplayObjectContainer) 
				{ 
					traceDisplayList(DisplayObjectContainer(child), indentString + "    ");
				} 
			} 
		}	

		/**
		 * Generate Bitmap instance of the provided object. Setting one of the dimensions to zero (or NaN), maintains the aspect ratio relative
		 * to the non-zero dimension.
		 * @param	source  source object to convert to bitmap
		 * @param	width  width to resample to
		 * @param	height  height to resample to
		 * @param	smoothing  determines whether a BitmapData object is smoothed when scaled or rotated
		 * @return  the resulting bitmap
		 */
		public static function resampledBitmap(source:IBitmapDrawable, width:Number, height:Number, smoothing:Boolean = true):Bitmap {
			var bmp:Bitmap = new Bitmap(resampledBitmapData(source, width, height, smoothing), PixelSnapping.NEVER, smoothing);
			return bmp; 
		}
		
		/**
		 * Generate BitmapData instance of the provided object. Setting one of the dimensions to zero (or NaN), maintains the aspect ratio relative
		 * to the non-zero dimension.
		 * @param	source source object to convert to bitmap data
		 * @param	width  width to resample to
		 * @param	height  height to resample to
		 * @param	smoothing  determines whether a BitmapData object is smoothed when scaled or rotated
		 * @return  the resulting bitmap data
		 */
		public static function resampledBitmapData(source:IBitmapDrawable, width:Number, height:Number, smoothing:Boolean = true):BitmapData {
			var bmd:BitmapData;		
			
			//retrieve source bitmap data
			if (source is DisplayObject) {
				bmd = displayObjectBitmapData(DisplayObject(source));				
			}
			else if (source is BitmapData) {
				bmd = source as BitmapData;
			}
			else {
				return null; 
			}
			
			//dimension scale percentages
			var percentX:Number = 1; 
			var percentY:Number = 1; 			
			if (width && height) {
				percentX = width / bmd.width;
				percentY = height / bmd.height;
			}
			else if (width) {
				percentX = percentY = width / bmd.width;				
			}
			else if (height) {
				percentY = percentX = height / bmd.height;
			}
			
			//set scale for the draw operation
			var matrix:Matrix = new Matrix();
			matrix.scale(percentX, percentY);
			
			//resampled bitmap data
			var rbmd:BitmapData = new BitmapData(bmd.width * percentX, bmd.height * percentY, true, 0x00000000);
			rbmd.draw(bmd, matrix, null, null, null, smoothing);
			
			//dispose of temporary bitmap
			if (source is DisplayObject) {
				bmd.dispose();
			}
			
			return rbmd; 
		}
		
		/**
		 * Generate BitmapData instance from provided display object.
		 * @param	source  source object
		 * @param	smoothing  determines whether a BitmapData object is smoothed when scaled or rotated
		 * @return  the resulting bitmap data
		 */
		protected static function displayObjectBitmapData(source:DisplayObject, smoothing:Boolean = true):BitmapData {
			var rect:Rectangle = source.getBounds(source);
			var bmd:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
			var matrix:Matrix = new Matrix();
			matrix.translate( -rect.x, -rect.y);
			bmd.draw(source, matrix, null, null, null, smoothing);
			return bmd;			
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
		 * trace(s.numChildren); // 4
		 * removeAllChildrenByType(s, Shape);
		 * trace(s.numChildren); // 2
		 * </listing>
		 *   
		 * 	@param container Container to remove from
		 *  @param the type(s) of children to remove
		 */
		public static function removeAllChildrenByType(container:DisplayObjectContainer, types:Array):Array
		{
			var removed:Array = [];
			for each(var type:Class in types) {
				for (var i:int = container.numChildren -1; i >= 0; i--) {
					if (container.getChildAt(i) is type) {
						removed.push(container.removeChildAt(i));
					}
				}
			}
			return removed;
		}		
		
		/**
		 *   Removes all children from a container and leave the bottom few
		 *   @param container Container to remove from
		 *   @param leave (optional) Number of bottom children to leave
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
		 * 	@param container Container 
		 *  @param the type of children 
		 */
		public static function getAllChildrenByType(container:DisplayObjectContainer, type:Class, recursive:Boolean=false):Array
		{
			var children:Array = [];
			
			recursiveSearch(container, type, recursive)
			
			function recursiveSearch(container:DisplayObjectContainer, type:Class, recursive:Boolean):void {
				for (var i:int = 0; i < container.numChildren; i++) {
					if (container.getChildAt(i) is type)
						children.push(container.getChildAt(i));
					if (recursive && container.getChildAt(i) is DisplayObjectContainer && DisplayObjectContainer(container.getChildAt(i)).numChildren > 0)
						recursiveSearch(container.getChildAt(i), type, recursive);
				}
			}

			return children;
		}
		
		/**
		 * Returns a list of all gesture-active children
		 * @param	container
		 * @param	recursive
		 * @return
		 */
		public static function getAllActiveChildren(container:DisplayObjectContainer, recursive:Boolean=false):Vector.<TouchSprite>
		{
			var children:Vector.<TouchSprite> = new Vector.<TouchSprite>();
			
			recursiveSearch(container, recursive)
			
			function recursiveSearch(container:DisplayObjectContainer, recursive:Boolean):void {
				for (var i:int = 0; i < container.numChildren; i++) {
					if (container.getChildAt(i) is TouchSprite && TouchSprite(container.getChildAt(i)).active)
						children.push(container.getChildAt(i) as TouchSprite);
					if (recursive && container.getChildAt(i) is DisplayObjectContainer && DisplayObjectContainer(container.getChildAt(i)).numChildren > 0)
						recursiveSearch(container.getChildAt(i), recursive);
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
		 * Scales an object by the amount given from a point given.
		 * @param	obj			The object to scale
		 * @param	scaleX		The amount to scale its X-dimensions by
		 * @param	scaleY		The amount to scale its Y-dimensions by
		 * @param	pointX		The x coordinate of the point to scale from
		 * @param	pointY		The y coordinate of the point to scale from
		 */
		public static function scaleFromPoint(obj:*, scaleX:Number, scaleY:Number, pointX:Number, pointY:Number):void {
			// Get the difference between the point given and the actual position of the content is.
			var x_diff:Number = pointX - obj.x;
			var y_diff:Number = pointY - obj.y;
			
			// Multiply the vector values by the scale.
			x_diff *= scaleX;
			y_diff *= scaleY;
			
			// Scale the object
			obj.scaleX += scaleX;
			obj.scaleY += scaleY;
			
			// Reposition by the products of the scaled vectors
			obj.x -= x_diff;
			obj.y -= y_diff;
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
		 * Returns a rotated point
		 * @param	point The original point
		 * @param	rotation The rotation in radians
		 * @param	center The center of rotation point
		 * @return 
		 */
		public static function getRotatedPoint(point:Point, rotation:Number, center:Point):Point {
			var rotX:Number = (point.x-center.x) * Math.cos(rotation) - (point.y-center.y) * Math.sin(rotation);
			var rotY:Number = (point.y - center.y) * Math.cos(rotation) + (point.x - center.x) * Math.sin(rotation);			
			rotX += center.x;
			rotY += center.y;	
			return new Point(rotX, rotY);
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
		
		/**
		 * Returns an array of ancestors of the specified type
		 * @param	type The type to search the object hierarchy for
		 * @param	obj The object to search
		 * @return
		 */
		public static function getAncestorsOfType(type:Class, obj:*):Array {
			var ancestors:Array = new Array();
			var parent:*;
			
			if (!obj)
				return ancestors;	
				
			parent = getParentType(type, obj);
			if (parent) {
				ancestors.push(parent);
				ancestors = ancestors.concat(getAncestorsOfType(type, parent));
			}
			
			return ancestors;
		}
		
		/**
		 * Recursively initializes container and all children
		 * @param	container
		 */
		public static function initAll(container:*):void {
			
			if ("init" in container) {
				try{
					container.init();
				}
				catch(e:Error){}
			}	
			
			if (!("numChildren" in container))
				return;
				
			for (var i:int = 0; i < container.numChildren; i++ ) {
				initAll(container.getChildAt(i));
			}
		}
		
	}

}