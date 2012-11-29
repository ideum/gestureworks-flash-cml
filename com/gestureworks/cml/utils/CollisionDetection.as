package com.gestureworks.cml.utils
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

    /** 
	 * The CollisionDetection utility tests for a collision between two sprites.
	 * 
	 * <p>Use the isColliding method to test for a collision. The class provides 
	 * an optional pixel perfect test, which requires more resources</p>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
		
	   var g1:Graphic = new Graphic();
	   g1.x = 0;
	   g1.shape = "circle";
	   g1.radius = "100:
	
	   var g2:Graphic = new Graphic();
	   g2.x = 50;
	   g2.shape = "circle";
	   g2.radius = "100:
	
	   addChild(g1);
	   addChild(g2)
	   
	   //trace(CollisionDetection.isColliding(g1, g2));
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @author Troy Gilbert
     * @author Alexander Schearer
     */
	public class CollisionDetection
	{
		/** 
		 * Returns the collision rectangle between two display objects. 
		 **/
		public static function getCollisionRect(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Boolean = false, tolerance:Number = 0):Rectangle
		{
			// get bounding boxes in common parent's coordinate space
			var rect1:Rectangle = target1.getBounds(commonParent);
			var rect2:Rectangle = target2.getBounds(commonParent);
			// find the intersection of the two bounding boxes
			var intersectionRect:Rectangle = rect1.intersection(rect2);
			if (intersectionRect.size.length> 0)
			{
				if (pixelPrecise)
				{
					// size of rect needs to integer size for bitmap data
					intersectionRect.width = Math.ceil(intersectionRect.width);
					intersectionRect.height = Math.ceil(intersectionRect.height);
					// get the alpha maps for the display objects
					var alpha1:BitmapData = getAlphaMap(target1, intersectionRect, BitmapDataChannel.RED, commonParent);
					var alpha2:BitmapData = getAlphaMap(target2, intersectionRect, BitmapDataChannel.GREEN, commonParent);
					// combine the alpha maps
					alpha1.draw(alpha2, null, null, BlendMode.LIGHTEN);
					// calculate the search color
					var searchColor:uint;
					if (tolerance <= 0)
					{
						searchColor = 0x010100;
					}
					else
					{
						if (tolerance> 1) tolerance = 1;
						var byte:int = Math.round(tolerance * 255);
						searchColor = (byte <<16) | (byte <<8) | 0;
					}
					// find color
					var collisionRect:Rectangle = alpha1.getColorBoundsRect(searchColor, searchColor);
					collisionRect.x += intersectionRect.x;
					collisionRect.y += intersectionRect.y;
					return collisionRect;
				}
				else
				{
					return intersectionRect;
				}
			}
			else
			{
				// no intersection
				return null;
			}
		}

		/** 
		 * Returns the alpha map of the display object and places it in the specified channel. 
		 **/
		private static function getAlphaMap(target:DisplayObject, rect:Rectangle, channel:uint, commonParent:DisplayObjectContainer):BitmapData
		{
			// calculate the transform for the display object relative to the common parent
			var parentXformInvert:Matrix = commonParent.transform.concatenatedMatrix.clone();
			parentXformInvert.invert();
			var targetXform:Matrix = target.transform.concatenatedMatrix.clone();
			targetXform.concat(parentXformInvert);
			// translate the target into the rect's space
			targetXform.translate(-rect.x, -rect.y);
			// draw the target and extract its alpha channel into a color channel
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bitmapData.draw(target, targetXform);
			var alphaChannel:BitmapData = new BitmapData(rect.width, rect.height, false, 0);
			alphaChannel.copyChannel(bitmapData, bitmapData.rect, new Point(0, 0), BitmapDataChannel.ALPHA, channel);
			return alphaChannel;
		}

		/** 
		 * Get the center of the collision's bounding box. 
		 **/
		public static function getCollisionPoint(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Boolean = false, tolerance:Number = 0):Point
		{
			var collisionRect:Rectangle = getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
			if (collisionRect != null && collisionRect.size.length> 0)
			{
				var x:Number = (collisionRect.left + collisionRect.right) / 2;
				var y:Number = (collisionRect.top + collisionRect.bottom) / 2;
				return new Point(x, y);
			}
			return null;
		}

		/** 
		 * Returns whether the two display objects are colliding or overlapping
		 **/
		public static function isColliding(target1:DisplayObject,
                target2:DisplayObject,
                commonParent:DisplayObjectContainer,
                pixelPrecise:Boolean = false,
                tolerance:Number = 0):Boolean
		{
			var collisionRect:Rectangle = getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
			if (collisionRect != null && collisionRect.size.length> 0) return true;
			else return false;
		}
	}
}