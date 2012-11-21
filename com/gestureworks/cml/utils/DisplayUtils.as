package com.gestureworks.cml.utils 
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
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
		 * trace(s.numChildren); // 4
		 * removeAllChildrenByType(s, Shape);
		 * trace(s.numChildren); // 2
		 * </listing>
		 *   
		 * 	@param container Container to remove from
		 *  @param the type of children to remove
		 *  @author John Lindquist
		 */
		public static function removeAllChildrenByType(container:DisplayObjectContainer, type:Class):void
		{
			for each(var child:DisplayObject in container)
			{
				if(child is type)
				{
					container.removeChild(child);
				}
			}
		}		
		
		/**
		 *   Removes all children from a container and leave the bottom few
		 *   @param container Container to remove from
		 *   @param leave (optional) Number of bottom children to leave
		 *   @author Jackson Dunstan
		 */
		public static function removeAllChildren(container:DisplayObjectContainer, leave:int = 0):void
		{
			while (container.numChildren > leave)
			{
				container.removeChildAt(leave);
			}
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
		
	}

}