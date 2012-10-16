package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.layouts.ListLayout;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.events.TouchEvent;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Exponential;
	import org.libspark.betweenas3.tweens.ITween;
	
	/**
	 * The Album element provides a list of display objects that can be 
	 * scrolled horizontally or vertically using a drag gesture. It 
	 * supports tweening and item snapping.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
		// horizontal album
		var h_album:AlbumElement = new AlbumElement();
		h_album.addChild(getImageElement("assets/wb3.jpg"));
		h_album.addChild(getImageElement("assets/USS_Macon_over_Manhattan.png"));
		h_album.addChild(getImageElement("assets/wb3.jpg"));
		h_album.init();

		// vertical album
		var v_album:AlbumElement = new AlbumElement();
		v_album.horizontal = false;			
		v_album.addChild(getImageElement("assets/wb3.jpg"));
		v_album.addChild(getImageElement("assets/USS_Macon_over_Manhattan.png"));						
		v_album.addChild(getImageElement("assets/wb3.jpg"));			
		v_album.init();
	
	// the supporting method getImageElement("src"), returns a Image display
	// object.
			
	 * </codeblock>
	 * 
	 * @author Shaun
	 * @see TouchContainer
	 */
	public class Album extends TouchContainer
	{	
		private var _applyMask:Boolean = true;
		private var _horizontal:Boolean = true;
		private var _margin:Number = 1;
		private var _dragAngle:Number = 0;
		
		private var belt:TouchContainer;
		private var snapPoints:Array;
		private var albumMask:Graphic;
		private var snapTween:ITween;
		private var boundary1:Number;
		private var boundary2:Number;
		private var isLoaded:Boolean = false;		
		private var released:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function Album() 
		{
			mouseChildren = true;
			albumMask = new Graphic();
			albumMask.shape = "rectangle";
		}
				
		/**
		 * CML initialization
		 */
		override public function displayComplete():void 
		{
			init();
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void
		{	
			sizeAlbumToContent();
			initBelt();
			checkMask();
			isLoaded = true;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "isLoaded", isLoaded, true));	
		}
		
		/**
		 * Flag indicating whether the contents are masked
		 * @default true
		 */
		public function get applyMask():Boolean { return _applyMask; }
		public function set applyMask(m:Boolean):void
		{
			_applyMask = m;
		}
		
		/**
		 * Flag indicating the scroll axis
		 * @default true
		 */
		public function get horizontal():Boolean { return _horizontal; }
		public function set horizontal(h:Boolean):void
		{
			_horizontal = h;
		}
		
		/**
		 * Sets the margin between the child display objects
		 * @default 1
		 */
		public function get margin():Number { return _margin; }
		public function set margin(m:Number):void
		{
			_margin = m;
		}	
		
		/**
		 * Intended to account for the rotation of the parent object to apply to
		 * drag transformations. This value does NOT set the rotation of the
		 * AlbumElement. The rotation must be set through the rotation attribute(s).
		 */
		public function get dragAngle():Number { return _dragAngle; }
		public function set dragAngle(a:Number):void
		{
			_dragAngle = Math.PI * a / 180;
		}			
		
		/**
		 * Sets the width of the container and associated mask
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;	
			if (albumMask) albumMask.width = value;
		}
		
		/**
		 * Sets the height of the container and associated mask
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (albumMask) albumMask.height = value;
		}
		
		/**
		 * The album element is intended for a ListLayout only. The layout axis can be
		 * set by the "horizontal" attribute and the spacing can be adjusted through the
		 * "margin" attribute. 
		 */
		override public function set layout(value:*):void {}
		
		/**
		 * The album element is intended for a ListLayout only. The layout axis can be
		 * set by the "horizontal" attribute and the spacing can be adjusted through the
		 * "margin" attribute. 
		 */
		override public function applyLayout(value:* = null):void { }
		
		/**
		 * Synchronize the drag angle with the album's rotation
		 */
		override public function set rotation(value:Number):void 
		{
			dragAngle = value;
			super.rotation = value;
		}

		/**
		 * Synchronize the drag angle with the album's rotation
		 */		
		override public function set rotationX(value:Number):void 
		{
			dragAngle = value;
			super.rotationX = value;
		}
		
		/**
		 * Synchronize the drag angle with the album's rotation
		 */		
		override public function set rotationY(value:Number):void 
		{
			dragAngle = value;
			super.rotationY = value;
		}		
			
		/**
		 * Initializes the the belt container which is the nested container of the album that handles
		 * the scrolling of the child objects. All children are transferred from the album container
		 * to the belt. 
		 */
		private function initBelt():void
		{
			belt = new TouchContainer();
			belt.gestureReleaseInertia = true;
			belt.disableNativeTransform = true;
			belt.gestureList = { "n-drag-inertia":true };
			belt.disableAffineTransform = true;
			
			var scrollType:Function = horizontal ? scrollH : scrollV;
			belt.addEventListener(GWGestureEvent.DRAG, scrollType);
			belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
			belt.addEventListener(GWGestureEvent.COMPLETE, snap);
			belt.addEventListener(TouchEvent.TOUCH_BEGIN, resetDrag);
			
			//transfer children to belt
			for (var i:int = numChildren-1; i >= 0; i--)
				belt.addChild(getChildAt(i));
		
			//set belt layout
			belt.layout = new ListLayout();
			belt.layout.useMargins = true;
		    belt.layout.marginX = margin;
			belt.layout.marginY = margin;
			belt.layout.type = horizontal ? "horizontal" : "vertical";
			belt.applyLayout();
		
			addChild(belt);
			
			storeSnapPoints();
			setBoundaries();
		}
		
		/**
		 * Generates a default list layout when one is not provided
		 * @return  horizontal list layout
		 */
		private function defaultLayout():ListLayout
		{
			var lLayout:ListLayout = new ListLayout();
			lLayout.useMargins = true;
			lLayout.marginX = 1;
			return lLayout;
		}
		
		/**
		 * Sets the dimesions of the container based on the greatest width and height of
		 * the child dimensions.
		 */
		private function sizeAlbumToContent():void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				width = width < child.width ? child.width : width;								
				height = height < child.height ? child.height : height;				
			}
		}
		
		/**
		 * Stores the additive inverse of the x or y coordinates of the children based on the horizontal
		 * flag. These points will drive the snap tweeining. 
		 */
		private function storeSnapPoints():void
		{
			snapPoints = new Array;
			var axis:String = horizontal ? "x" : "y";
			
			for (var i:int = 0; i < belt.numChildren; i++)
				snapPoints.push( -belt.getChildAt(i)[axis]);						
		}
		
		/**
		 * Set the drag boundaries for the belt container based on the horiztonal state
		 * and album dimensions.
		 */
		private function setBoundaries():void
		{
			var frame:Number = horizontal ? width: height;
			if (snapPoints.length > 0)
			{
				boundary1 = snapPoints[0] + frame / 2;
				boundary2 = snapPoints[snapPoints.length - 1] - frame / 2;
			}
		}
		
		/**
		 * Apply the mask
		 */
		private function checkMask():void
		{
			if (applyMask)
			{
				addChild(albumMask);
				mask = albumMask;
			}
		}
		
		/**
		 * Animates a snaping action to the snap point closest to the current belt location.
		 * @param	e  the drag complete event
		 */
		private function snap(e:*=null):void
		{	
			if (snapTween && snapTween.isPlaying)
				return;
			if(horizontal)
				snapTween = BetweenAS3.tween(belt, { x:getClosestSnapPoint(belt.x) }, null, .4, Exponential.easeOut);
			else
				snapTween = BetweenAS3.tween(belt, { y:getClosestSnapPoint(belt.y) }, null, .4, Exponential.easeOut);
			snapTween.play();
		}
		
		/**
		 * Determines the snap point closest to the current belt location
		 * @param	n  the belt location
		 * @return  the closest snap point
		 */
		private function getClosestSnapPoint(n:Number):Number
		{
			var minDiff:Number = Number.MAX_VALUE;
			var diff:Number;
			var point:Number;
			
			if (n > 0)
				point = snapPoints[0];
			else if (n < snapPoints[snapPoints.length - 1])
				point = snapPoints[snapPoints.length - 1];
			else
			{
				for each(var p:Number in snapPoints)
				{
					diff = Math.abs(n - p);
					if (diff < minDiff)
					{
						minDiff = diff;
						point = p;
					}
				}
			}	
			return point;
		}
		
		/**
		 * Reactivates the drag handler, enables release inertia, and resets the released
		 * flag to indicate the belt is being touched. 
		 * @param	e  the touch event
		 */
		private function resetDrag(e:TouchEvent):void
		{
			var scrollType:Function = horizontal ? scrollH : scrollV;
			belt.addEventListener(GWGestureEvent.DRAG, scrollType);	
			belt.gestureReleaseInertia = true;
			released = false;
		}
		
		/**
		 * Turns the released flag on to indicate the belt is not being touched
		 * @param	e the release event
		 */
		private function onRelease(e:GWGestureEvent):void
		{
			released = true;
		}		
		
		/**
		 * Drag the belt horizontally within the boundaries. If boundaries are exceeded and the
		 * belt is not being touched, the drag is disabled and the snaps into place.
		 * @param	e the drag event
		 */
		private function scrollH(e:GWGestureEvent):void
		{							
			var COS:Number = Math.cos(dragAngle);
			var SIN:Number = Math.sin(dragAngle);
			var dx:Number = e.value.drag_dy * SIN + e.value.drag_dx * COS;			
			
			if (belt.x + dx < boundary1 && belt.x + dx > boundary2)			
				belt.x += dx;				
			else if(released)
			{
				belt.removeEventListener(GWGestureEvent.DRAG, scrollH);
				belt.gestureReleaseInertia = false;
				snap();				
			}
		}
				
		/**
		 * Drag the belt vertically within the boundaries
		 * @param	e the drag event
		 */
		private function scrollV(e:GWGestureEvent):void
		{
			var COS:Number = Math.cos(dragAngle);
			var SIN:Number = Math.sin(dragAngle);
			var dy:Number = e.value.drag_dy * COS - e.value.drag_dx * SIN;			
			
			if (belt.y+dy < boundary1 && belt.y+dy > boundary2)
				belt.y += dy;
			else if(released)
			{
				belt.removeEventListener(GWGestureEvent.DRAG, scrollV);
				belt.gestureReleaseInertia = false;
				snap();				
			}
		}		
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			
			belt.addEventListener(GWGestureEvent.DRAG, scrollH);
			belt.addEventListener(GWGestureEvent.DRAG, scrollV);
			belt.addEventListener(GWGestureEvent.RELEASE, onRelease);
			belt.addEventListener(GWGestureEvent.COMPLETE, snap);
			belt.addEventListener(TouchEvent.TOUCH_BEGIN, resetDrag);
			
			belt = null;
			snapPoints = null;
			albumMask = null;
			snapTween = null;
		}
				
	}

}