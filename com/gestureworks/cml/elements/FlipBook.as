package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.PageFlip;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.*;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * The FlipBook element is designed to take a series of display objects, and arrange them to be sorted through with a "flip" animation for each one.
	 */
	public class FlipBook extends TouchContainer
	{
		private var R_UPPERCORNER:Point;
		private var R_LOWERCORNER:Point;
		private var R_MIDDLE:Point;
		
		private var L_UPPERCORNER:Point;
		private var L_LOWERCORNER:Point;
		private var L_MIDDLE:Point;
		
		private var OPEN:Boolean = false;
		
		private var obj:Object;
		
		private var currentCorner:Point = new Point(1, 0);
		private var forward:Boolean = true;
		private var tweening:Boolean = false;
		private var cornerFlashing:Boolean = false;
		private var isPageDragging:Boolean = false;
		private var trackPoint:Point = new Point(0, 0);
		private var idToTrack:int = 0;
		private var pageToTurn:int = 0;
		
		protected var pageContent:Array = new Array();
		private var shadows:Array = new Array();
		private var pageCorners:Array = new Array();
		
		private var shape:Shape;
		private var bmpD1:BitmapData;
		private var bmpD2:BitmapData;
		private var shadow:Sprite;
		private var shadow2:Sprite;
		
		private var _pw:Number = 0;
		private var _ph:Number = 0;
		
		private var oldX:Number;
		
		/**
		 * Constructor
		 */
		public function FlipBook() 
		{
			super();
		}	
		
		//{ region properties
		
		/**
		 * The width is overridden. Any width given is assumed to be the "page" width for the desired content.
		 * The actual width of this container will be twice whatever is input.
		 */
		override public function set width(value:Number):void {
			_pw = value;
			super.width = value * 2;
		}
		
		/**
		 * The height remains the same, but is used to also keep track of the page height for coding consistency.
		 */
		override public function set height(value:Number):void {
			_ph = value;
			super.height = value;
		}
		
		private var _backgroundColor:uint = 0xffffff;
		/**
		 * The color seen if the page backgrounds are exposed.
		 */
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
		}
		
		private var _singlePageView:Boolean = false;
		/**
		 * Sets whether the flipbook is a spread (like a book), or a single page
		 */
		public function get singlePageView():Boolean { return _singlePageView; }
		public function set singlePageView(value:Boolean):void {
			_singlePageView = value;
		}
		
		private var _cornerIndicators:Boolean = false;
		/**
		 * Sets whether or not to show cornerIndicators
		 */
		public function get cornerIndicators():Boolean { return _cornerIndicators; }
		public function set cornerIndicators(value:Boolean):void {
			_cornerIndicators = value;
		}
		
		private var _indicatorColor:uint = 0xff0000;
		/**
		 * Sets the color of the corner indicators
		 */
		public function get indicatorColor():uint { return _indicatorColor; }
		public function set indicatorColor(value:uint):void {
			_indicatorColor = value;
		}
		
		private var _indicatorAlpha:Number = 0.5;
		/**
		 * Sets the highest alpha of the corner indicators
		 */
		public function get indicatorAlpha():Number { return _indicatorAlpha; }
		public function set indicatorAlpha(value:Number):void {
			_indicatorAlpha = value;
		}
		
		private var _cornerGlow:Boolean = false;
		/**
		 * Sets whether or not there is a glow with the corner indicators
		 */
		public function get cornerGlow():Boolean { return _cornerGlow; }
		public function set cornerGlow(value:Boolean):void {
			_cornerGlow = value;
		}
		
		private var _cornerGlowColor:uint = 0xffff00;
		/**
		 * Sets the corner glow color
		 */
		public function get cornerGlowColor():uint { return _cornerGlowColor; }
		public function set cornerGlowColor(value:uint):void {
			_cornerGlowColor = value;
		}
		
		private var _transformParent:Boolean = false;
		/**
		 * A variation of targetParent, this is to inform the flipbook to target the parent for native transformations
		 */
		public function get transformParent():Boolean { return _transformParent; }
		public function set transformParent(value:Boolean):void {
			_transformParent = value;
		}
		
		private var _hitAreaSize:Number = 0.4;
		/**
		 * The a percentage based on page-width that will determine how wide the hit area in the corners and edges will be. For example, 
		 * for a 200 px wide page (thus a 400 px wide Flipbook), a value of 0.2 will create an area 40 pixels wide x 40 pixels tall in the corners for hit,
		 * and 20 pixels wide along the edges between the corners. This property is set on initialization and changing it aftewards will not change the hit 
		 * area size.
		 */
		public function get hitAreaSize():Number { return _hitAreaSize; }
		public function set hitAreaSize(value:Number):void {
			_hitAreaSize = value;
		}
		
		
		private var _currentPage:Number = 0;
		/**
		 * Retrieves the current page. The page returned is the page on the right, not the left, and counting starts from 0, not 1.
		 * So if the _currentPage is 2, the page on the right is page 3 and the page on the left is page 2.
		 */
		public function get currentPage():Number { return _currentPage; }
		
		//} endregion
		
		//{ region Initialization
		
		/**
		 * Initialization method
		 */
		override public function init():void
		{
			
			while (numChildren > 0) {
				pageContent.push(getChildAt(0));
				
				removeChildAt(0);
			}
			
			var bg:Graphic = new Graphic();
			bg.shape = "rectangle";
			bg.width = width;
			bg.height = height;
			bg.alpha = 0;
			bg.color = 0x000000;
			bg.init();
			addChild(bg);
			
			// Graphical setup now that the stage is empty.
			
			shape = new Shape();
			shape.graphics.beginFill(_backgroundColor, 1);
			shape.graphics.drawRect(0, 0, _pw, _ph);
			shape.graphics.endFill();
			//addChild(shape);
			shape.x = _pw;
			
			// Add children back in reverse order, all except the first item.
			for (var i:Number = pageContent.length - 1; i > -1; i-- ) {
				
				var pageShadow:TouchSprite = new TouchSprite();
				//pageShadow = new TouchSprite();
				shadows.push(pageShadow);
				var m:Matrix = new Matrix();
				m.createGradientBox(100, _ph);
				
				// If it's odd numbered content (keep in mind, odd/even will be reversed in the array order)
				// make sure to position it to the right so it's the "right" page.
				if ( !(i % 2)) {
					addChild(pageContent[i]);
					//trace("Actually, odd numbered content.");
					pageContent[i].x = _pw;
					pageShadow.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0.25, 0), new Array(0, 255), m);
					pageShadow.graphics.drawRect(0, 0, 100, _ph);
					pageShadow.graphics.endFill();
					
					if (!_singlePageView)
						pageContent[i].addChild(pageShadow);
					
					if (cornerIndicators) {
						var rightCorner:Sprite = createRightCorner();
						rightCorner.y = _ph;
						rightCorner.x = _pw;
						pageContent[i].addChild(rightCorner);
						pageCorners[i]= rightCorner;
					}
				}
				else {
					// If it's even numbered content, it will start on the left, no repositioning needed,
					// but it's visibility will need to be false.
					
					pageContent[i].visible = false;
					pageShadow.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0, 0.25), new Array(0, 255), m);
					//pageShadow.graphics.beginFill(0xffffff);
					pageShadow.graphics.drawRect(0, 0, 100, _ph);
					pageShadow.graphics.endFill();
					
					if (!_singlePageView)
						pageContent[i].addChild(pageShadow);
					pageShadow.x = _pw - 100;
					
					if (cornerIndicators) {
						var leftCorner:Sprite = createLeftCorner();
						leftCorner.y = _ph;
						pageContent[i].addChild(leftCorner);
						pageCorners[i] = leftCorner;
					}
				}
			}
			
			for (var j:Number = 0; j < pageContent.length; j++) {
				if (j % 2) {
					addChild(pageContent[j]);
				}
			}
			
			// Add the shape, whose bitmapData will be used as soon as a flip event is started.
			addChild(shape);
			
			// Add the first page, whose content we can see and interact with now. This will immediately be set invisible upon page flip.
			addChild(pageContent[0]);
			pageContent[0].x = _pw;
			
			bmpD1 = new BitmapData(_pw, _ph);
			bmpD1.draw(pageContent[0]);
			bmpD2 = new BitmapData(_pw, _ph);
			bmpD2.draw(pageContent[1]);
			
			shadow = new Sprite();
			shadow2 = new Sprite();
			
			addChild(shadow2);
			addChild(shadow);
			
			L_UPPERCORNER = new Point(_pw * _hitAreaSize, _pw * _hitAreaSize);
			L_LOWERCORNER = new Point(_pw * _hitAreaSize, _ph - (_pw * _hitAreaSize));
			L_MIDDLE = new Point( _pw * (_hitAreaSize/2), (_ph - (L_UPPERCORNER.y * 2)) / 2 + L_UPPERCORNER.y);
			
			R_UPPERCORNER = new Point((_pw * 2) - (_pw * _hitAreaSize), (_pw * _hitAreaSize));
			R_LOWERCORNER = new Point((_pw * 2) - (_pw * _hitAreaSize), _ph - (_pw * _hitAreaSize));
			R_MIDDLE = new Point((_pw * 2) - (_pw * (_hitAreaSize/2)), (_ph - (R_UPPERCORNER.y * 2)) / 2 + R_UPPERCORNER.y)
			// No need to define the middle further, I suppose. ^This is the center point between upper and lower.
			
			addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			//addEventListener(StateEvent.CHANGE, onStateEvent);
			
		}
		
		private function createLeftCorner():Sprite 
		{
			var sprite:Sprite = new Sprite();
			var base:Number = _pw * _hitAreaSize;
			
			sprite.graphics.lineStyle(1, _indicatorColor, 1);
			sprite.graphics.beginFill(_indicatorColor, 1);
			sprite.graphics.lineTo(0, -base);
			sprite.graphics.lineTo(base, 0);
			sprite.graphics.lineTo(0,0);
			sprite.graphics.endFill();
			sprite.alpha = 0;
			
			if (_cornerGlow){
				var blur:int = 8;
				var cornerShadow:DropShadowFilter = new DropShadowFilter();
				cornerShadow.distance = 4;
				cornerShadow.angle = 135;
				cornerShadow.blurX = blur;
				cornerShadow.blurY = blur;
				cornerShadow.color = _cornerGlowColor;
				cornerShadow.strength = 0.5;
				
				sprite.filters = [cornerShadow];
			}
			
			return sprite;
		}
		
		private function createRightCorner():Sprite 
		{
			var sprite:Sprite = new Sprite();
			var base:Number = _pw * _hitAreaSize;
			
			sprite.graphics.lineStyle(1, _indicatorColor, 1);
			sprite.graphics.beginFill(_indicatorColor, 1);
			sprite.graphics.lineTo(-base, 0);
			sprite.graphics.lineTo(0, -base);
			sprite.graphics.lineTo(0,0);
			sprite.graphics.endFill();
			sprite.alpha = 0;
			
			
			if (_cornerGlow){
				var blur:int = 8;
				var cornerShadow:DropShadowFilter = new DropShadowFilter();
				cornerShadow.distance = 4;
				cornerShadow.angle = 45;
				cornerShadow.blurX = blur;
				cornerShadow.blurY = blur;
				cornerShadow.color = _cornerGlowColor;
				cornerShadow.strength = 0.5;
				
				sprite.filters = [cornerShadow];
			}
			return sprite;
		}
		
		//} endregion
		
		private function onStateEvent(e:StateEvent):void {
			//trace("E.value:", e.value);
		}
		
		//{ region TouchEvent begin
		
		private function onBegin(e:*):void {
			
			if (tweening || isPageDragging) return;
			
			//trace("onBegin:", e.target);
			
			// This is to allow button and other events to occur. When the page is not being turned, this is true so 
			// child items that have touch can be accessed, like buttons.
			this.touchChildren = false;
			
			shape.visible = true;
			
			for (var i:int = 0; i < pageContent.length; i++) 
			{
				if ("stop" in pageContent[i]) {
					pageContent[i]["stop"]();
				}
			}
			
			if (e.target != this) {
				
				//var localPoint:Point = flipPoint(e.target, e.localX, e.localY, this);
				var localPoint:Point = this.globalToLocal(new Point(e.stageX, e.stageY));
				this.dispatchEvent(new TouchEvent(e.type, e.bubbles, e.cancelable, e.touchPointID, e.isPrimaryTouchPoint, localPoint.x, localPoint.y, e.sizeX, e.sizeY, e.pressure, 
					e.relatedObject, false, false, false));
				return;
				
			}
			
			//trackPoint = flipPoint(e.target, e.localX, e.localY, this);
			trackPoint = this.globalToLocal(new Point(e.stageX, e.stageY));
			
			// Have our trackPoint, check if it's in a corner.
			checkCurrentCorner();
			
			if (currentCorner) {
				// Track the id of the touchPoint that triggered the right corner.
				idToTrack = e.touchPointID;
				trackPoint.x -= _pw;
				
				// Dump unnecessary listeners.
				clearStandardEvents();
			}
			else {
				
				this.touchChildren = true;
				
				if (!hasEventListener(GWGestureEvent.SCALE))
					addEventListener(GWGestureEvent.SCALE, onRegularScale);
				if (!hasEventListener(GWGestureEvent.DRAG))
					addEventListener(GWGestureEvent.DRAG, onRegularDrag);
				if (!hasEventListener(GWGestureEvent.ROTATE))
					addEventListener(GWGestureEvent.ROTATE, onRegularRotate);
				if (!hasEventListener(GWGestureEvent.COMPLETE))
					addEventListener(GWGestureEvent.COMPLETE, onRegularComplete);
				
				if (_cornerIndicators)
					flashPageCorners();
				//removeEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
				return;
			}
			
			
			if (!hasEventListener(GWGestureEvent.COMPLETE))
				addEventListener(GWGestureEvent.COMPLETE, onTouchEnd);
			if (trackPoint && currentCorner && !hasEventListener(GWGestureEvent.DRAG))
				addEventListener(GWGestureEvent.DRAG, onPointMove);
			
			// Set up the bitmap data.
			if (forward && _currentPage + 1 < pageContent.length) {
				pageToTurn = _currentPage;
				bmpD1 = new BitmapData(_pw, _ph);
				bmpD1.draw(pageContent[_currentPage]);
				bmpD2 = new BitmapData(_pw, _ph);
				bmpD2.draw(pageContent[_currentPage + 1]);
			} else if (!forward) {
				pageToTurn = _currentPage - 2;
				if (pageToTurn < 0)
					pageToTurn = 0;
				bmpD1 = new BitmapData(_pw, _ph);
				bmpD1.draw(pageContent[pageToTurn]);
				bmpD2 = new BitmapData(_pw, _ph);
				bmpD2.draw(pageContent[pageToTurn + 1]);
				
			}
		}
		
		private function flashPageCorners():void 
		{
			if (cornerFlashing) return;
			var tween:TweenMax;
			
			if (_currentPage == 0) {
				// First page, only show right flash.
				tween = new TweenMax(pageCorners[_currentPage], 0.5, { alpha:_indicatorAlpha, onComplete:reverse, 
													onReverseComplete:function():void { cornerFlashing = false;} } );
				cornerFlashing = true;
				
				function reverse():void {
					tween.reverse();
				}
			}
			else if (_currentPage >= pageContent.length - 1) {
				// If it's the last page we can't flip any more, only show left flash.
				tween = new TweenMax(pageCorners[_currentPage-1], 0.5, { alpha:_indicatorAlpha, onComplete:reverse2, 
													onReverseComplete:function():void { cornerFlashing = false;} } );
				cornerFlashing = true;
				
				function reverse2():void {
					tween.reverse();
				}
			}
			else {
				var tweens:Array = [];
				var timeline:TimelineLite = new TimelineLite({onComplete:multiReverse, onReverseComplete:function():void { cornerFlashing = false;}});
				tweens.push(new TweenMax(pageCorners[_currentPage], 0.5, { alpha: _indicatorAlpha } ));
				tweens.push(new TweenMax(pageCorners[_currentPage - 1], 0.5, { alpha: _indicatorAlpha } ));
				timeline.appendMultiple(tweens);
				timeline.play();
				cornerFlashing = true;
				
				function multiReverse():void {
					timeline.reverse();
				}
			}
		}
		
		private function checkCurrentCorner():void 
		{
			if (trackPoint.x < _pw * 2 && trackPoint.x > R_UPPERCORNER.x && _currentPage + 1 < pageContent.length) {
				if (trackPoint.y < R_UPPERCORNER.y && trackPoint.y > -1) {
					//trace("I've found the upper RIGHT corner!");
					currentCorner = new Point(1, 0);
					forward = true;
				}
				else if (trackPoint.y < _ph && trackPoint.y > R_LOWERCORNER.y) {
					//trace("I've found the lower RIGHT corner!");
					currentCorner = new Point(1, 1);
					forward = true;
				}
				// How to find middle - Keep in, this will be useful once we're ready to use the middle as a hit area.
				/*else if (trackPoint.x < _pw * 2 && trackPoint.x > R_MIDDLE.x) {
					if (trackPoint.y < R_MIDDLE.y) {
						trace("Found upper middle.");
						currentCorner = new Point(1, 0);
						forward = true;
					}
					else {
						trace("Found lower middle.");
						currentCorner = new Point(1, 1);
						forward = true;
					}
				}*/
			}
			else if (OPEN && trackPoint.x < L_UPPERCORNER.x && trackPoint.x > 0) {
				if (trackPoint.y < L_UPPERCORNER.y && trackPoint.y > -1) {
					//trace("I've found the upper LEFT corner!");
					currentCorner = new Point(1, 0);
					forward = false;
				}
				else if (trackPoint.y < _ph && trackPoint.y > L_LOWERCORNER.y) {
					//trace("I've found the lower LEFT corner!");
					currentCorner = new Point(1, 1);
					forward = false;
				}
				// How to find middle - Keep in, this will be useful once we're ready to use the middle as a hit area.
				/*else if (trackPoint.x < L_MIDDLE.x && trackPoint.x > 0) {
					if (trackPoint.y < L_MIDDLE.y) {
						trace("Found upper LEFT middle.");
						currentCorner = new Point(1, 0);
						forward = false;
					}
					else {
						trace("Found lower LEFT middle.");
						currentCorner = new Point(1, 1);
						forward = false;
					}
				}*/
			}
			else {
				currentCorner = null;
			}
		}
		
		//} endregion
		
		//{ region standard transformations 
		
		protected function onRegularComplete(e:GWGestureEvent):void 
		{
			touchChildren = true;
			
			this.pointArray.length = 0;
			if (this.parent && this.parent is TouchSprite){
				TouchSprite(this.parent).pointArray.length = 0;
			}
			
			removeEventListener(GWGestureEvent.SCALE, onRegularScale);
			removeEventListener(GWGestureEvent.DRAG, onRegularDrag);
			removeEventListener(GWGestureEvent.ROTATE, onRegularRotate);
			removeEventListener(GWGestureEvent.COMPLETE, onRegularComplete);
			
			//addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
		}
		
		protected function onRegularRotate(e:GWGestureEvent):void 
		{
			touchChildren = false;
			if (_transformParent && this.parent) {
				DisplayUtils.rotateAroundPoint(this.parent, e.value.rotate_dtheta, e.value.stageX, e.value.stageY);
			}
		}
		
		protected function onRegularDrag(e:GWGestureEvent):void 
		{
			touchChildren = false;
			//trace("On regular drag.", e.target);
			if (_transformParent && this.parent){
				this.parent.x += e.value.drag_dx;
				this.parent.y += e.value.drag_dy;
			}
		}
		
		protected function onRegularScale(e:GWGestureEvent):void 
		{
			touchChildren = false;
			//trace("On regular scale", e.target);
			if (_transformParent && this.parent) {
				DisplayUtils.scaleFromPoint(this.parent, e.value.scale_dsx, e.value.scale_dsy, e.value.stageX, e.value.stageY);
			}
			
		}
		
		//} endregion
		
		
		private function onPointMove(e:GWGestureEvent):void {
			//removeEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			clearStandardEvents();
			isPageDragging = true;
			//trace("Page is dragging.");
			
			shape.graphics.clear();
			setChildIndex(shape, numChildren - 1);
			
			// Make current page invisible somehow.
			if (forward) {
				pageContent[pageToTurn].visible = false;
				//trace("Removing page visibility.");
				//shadows[_currentPage].visible = false;
			}
			else {
				pageContent[pageToTurn + 1].visible = false;
			}
			
			if (pageToTurn + 1 < pageContent.length) {
				setChildIndex(shape, getChildIndex(pageContent[pageToTurn + 1]));
				
				if (getChildIndex(shadow2) < getChildIndex(pageContent[pageToTurn + 1])) {
					setChildIndex(shadow, getChildIndex(pageContent[pageToTurn + 1]));
					setChildIndex(shadow2, getChildIndex(pageContent[pageToTurn + 1]));
				}
			}
			
			// Original
			//trackPoint = flipPoint(e.target, e.value.localX, e.value.localY, shape);
			// New
			var pointToTrack:Point; 
			var objToTrack:*;
			for (var j:int = 0; j < this.pointArray.length; j++) 
			{
				if (pointArray[j].touchPointID == idToTrack) {
					pointToTrack = new Point(pointArray[j].x, pointArray[j].y); // Store the point in a separate point so computeFlip doesn't alter it.
				}
			}
			
			if (!pointToTrack) {
				// else if no point to track, the point has been released, it's time to force the animation complete.
				onTouchEnd(e);
				return;
			}
			// Flip the pointToTrack, which is in stageX/Y values to local.
			trackPoint = shape.globalToLocal(pointToTrack);
			
			if (!trackPoint || !currentCorner || !_pw || !_ph) return;
			obj = PageFlip.computeFlip(trackPoint, currentCorner, _pw, _ph, true, 1);
			if (!obj.cPoints || obj.cPoints.length < 3) return;
			
			PageFlip.drawBitmapSheet(obj, shape, bmpD1, bmpD2);
			placeShadow(obj.cPoints);
			
			// Repeat the flip point to restore original event values. This is to stabilize the Y value
			// to keep consistent on release since the computeFlip steps through and alters the point it's given.
			// Original
			//trackPoint = flipPoint(e.target, e.value.localX, e.value.localY, shape);
			// New
			trackPoint = shape.globalToLocal(pointToTrack);
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "pageEvent", "flipping"));
		}
		
		private function onTouchEnd(e:*):void {
			//addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			removeEventListener(GWGestureEvent.DRAG, onPointMove);
			removeEventListener(GWGestureEvent.COMPLETE, onTouchEnd);
			
			if (this.parent && this.parent is TouchSprite){
				TouchSprite(this.parent).pointArray.length = 0;
			}
			this.pointArray.length = 0;
			
			isPageDragging = false;
			idToTrack = 0;
			
			this.touchChildren = true;
			if (!currentCorner) return;
			
			var duration:Number = 0.5;
			tweening = true;
			if (trackPoint.x < 0) {
				duration = (trackPoint.x + _pw) / _pw * 0.5;
				OPEN = true;
				
				TweenMax.to(trackPoint, duration, { x: -_pw, y:currentCorner.y * _ph, onUpdate:tweenUpdate } );
			}
			else {
				duration = _pw - trackPoint.x;
				duration = (duration / _pw) * 0.5;
				if (_currentPage == 0)
					OPEN = false;
				
					TweenMax.to(trackPoint, duration, { x: _pw, y:currentCorner.y * _ph, onUpdate:tweenUpdate } );
			}
		}
		
		private function tweenUpdate():void {
			shape.graphics.clear();
			obj = PageFlip.computeFlip(trackPoint, currentCorner, _pw, _ph, true, 1);
			
			PageFlip.drawBitmapSheet(obj, shape, bmpD1, bmpD2);
			placeShadow(obj.cPoints);
			
			if (forward) {
				if (trackPoint.x == _pw)
					updatePages(false);
				else if (trackPoint.x == -_pw)
					updatePages(true);
			}
			else if (!forward) {
				if (trackPoint.x == _pw)
					updatePages(true);
				else if (trackPoint.x == -_pw)
					updatePages(false);
			}
		}
		
		private function placeShadow(pointArray:Array):void {
			
			if (!pointArray || pointArray.length < 3) return;
			
			var lastX:Number = pointArray[pointArray.length - 1].x;
			var notLastX:Number = pointArray[pointArray.length - 2].x;
			var tan:Number = 0;
			var sPoint:Point;
			if (currentCorner.y == 0) {
				if (lastX > notLastX) {
					tan = Math.atan((lastX - notLastX) / pointArray[pointArray.length - 2].y);
				}
				else {
					tan = Math.atan((notLastX - lastX) / pointArray[pointArray.length - 2].y) * -1;
				}
				sPoint = new Point(lastX, 0);
			} else {
				if (notLastX > lastX) {
					tan = Math.atan((notLastX - lastX) / (_ph - pointArray[pointArray.length - 2].y));
				}
				else {
					tan = Math.atan((lastX - notLastX) / pointArray[pointArray.length - 1].y) * -1;
				}
				sPoint = new Point(notLastX, pointArray[pointArray.length - 2].y);
			}
			
			var m:Matrix = new Matrix();
			m.createGradientBox(100, _ph);
		
			m.rotate(tan);
			
			sPoint = flipPoint(shape, sPoint.x, sPoint.y, this);
			m.tx = sPoint.x;
			m.ty = sPoint.y;
			
			shadow2.graphics.clear();
			
			shadow2.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0, 0.25), new Array(0, 255), m);
			//shadow2.graphics.beginFill(0x550055); //Keep this line in for debugging.
			var p:Point;
			for (var i:Number = 0; i < pointArray.length; i++) {
				p = flipPoint(shape, pointArray[i].x, pointArray[i].y, this);
				if (i == 0) {
					shadow2.graphics.moveTo(p.x, p.y);
				}
				else
					shadow2.graphics.lineTo(p.x, p.y);
					
			}
			
			p = flipPoint(shape, pointArray[0].x, pointArray[0].y, this);
			shadow2.graphics.lineTo(p.x, p.y);
			shadow2.graphics.endFill();
			
			var m2:Matrix = new Matrix();
			m2.createGradientBox(100, _ph);
			
			m2.tx = sPoint.x;
			m2.rotate(tan);
			
			
			shadow.graphics.clear();
			if (pointArray[0].x == -_pw) {
				shadow.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0.25, 0), new Array(0, 255), m2);
				shadow.graphics.drawRect(_pw, 0, _pw, _ph);
				shadow.graphics.endFill();
				return;
			}
			
			shadow.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0.25, 0), new Array(0, 255), m2);
			//shadow.graphics.beginFill(0x005500); //Keep this line in for debuggin.
			
			p = flipPoint(shape, pointArray[pointArray.length - 2].x, pointArray[pointArray.length - 2].y, this);
			
			shadow.graphics.lineTo(p.x, p.y);
			if (p.x != _pw && currentCorner.y == 0) {
				shadow.graphics.lineTo(_pw * 2, _ph);
				shadow.graphics.lineTo(_pw * 2, 0);
			}
			else if (p.x != _pw && currentCorner.y == 1) {
				shadow.graphics.lineTo(_pw * 2, 0);
				shadow.graphics.lineTo(_pw * 2, _ph);
			}
			
			p = flipPoint(shape, pointArray[pointArray.length - 1].x, pointArray[pointArray.length - 1].y, this);
			if (p.x != _pw)
				shadow.graphics.lineTo(p.x, p.y);
			p = flipPoint(shape, pointArray[pointArray.length - 2].x, pointArray[pointArray.length - 2].y, this);
			shadow.graphics.lineTo(p.x, p.y);
			shadow.graphics.endFill();
		}
		
		private function flipPoint(from:*, point_X:Number, point_Y:Number, to:*):Point {
			var p:Point = from.localToGlobal(new Point(point_X, point_Y));
			p = to.globalToLocal(p);
			
			return p;
		}
		
		private function updatePages(c:Boolean):void {
			var complete:Boolean = c;
			shape.graphics.clear();
			shape.visible = false;
			shadow.graphics.clear();
			shadow2.graphics.clear();
			
			// Flip this back so users can access nested items such as buttons.
			this.touchChildren = true;
			//trace("Forward:", forward, "& complete:", complete);
			if (forward && complete) {
				pageContent[_currentPage + 1].visible = true;
				shadows[_currentPage + 1].visible = true;
				_currentPage += 2;
				
				setChildIndex(shape, 0);
			}
			else if (!forward && complete) {
				_currentPage -= 2;
				if (_currentPage < 0)
					_currentPage = 0;
			}
			else if (!forward && !complete) {
				if (_currentPage > 0) {
					pageContent[_currentPage - 1].visible = true;
					if (!_singlePageView)
						shadows[_currentPage - 1].visible = true;
				}
				
			}
			
			if(_currentPage < pageContent.length){
				pageContent[_currentPage].visible = true;
				if (!_singlePageView)
					shadows[_currentPage].visible = true;
			}
			
			if (_currentPage == 0) {
				OPEN = false;
			}
			
			//trace("Current page.", _currentPage);
			currentCorner = null;
			tweening = false;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "pageEvent", "complete"));
		}
		
		public function reset():void {
			
			if (tweening || cornerFlashing) {
				TweenMax.killAll();
				tweening = false;
				cornerFlashing = false;
			}
			
			shape.graphics.clear();
			shadow.graphics.clear();
			shadow2.graphics.clear();
			
			this.touchChildren = true;
			
			// reset events
			removeEventListener(GWGestureEvent.DRAG, onPointMove);
			removeEventListener(GWGestureEvent.RELEASE, onTouchEnd);
			
			removeEventListener(GWGestureEvent.SCALE, onRegularScale);
			removeEventListener(GWGestureEvent.DRAG, onRegularDrag);
			removeEventListener(GWGestureEvent.ROTATE, onRegularRotate);
			removeEventListener(GWGestureEvent.COMPLETE, onRegularComplete);
			
			for (var i:int = 0; i < pageContent.length; i++) {
				
				// Turn left sided pages invisible (odd numbered in the array, they'll have a remainder for i % 2)
				// Turn right sided pages visible
				if ( i % 2)
					pageContent[i].visible = false;
				else
					pageContent[i].visible = true;
				
				if (!_singlePageView && shadows[i]) {
					shadows[i].visible = true;
				}
				
				if (pageCorners[i]) {
					pageCorners[i].alpha = 0;
				}
			}
			
			_currentPage = 0;
			pageContent[_currentPage].visible = true;
			if (!_singlePageView) {
				shadows[_currentPage].visible = true;
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "pageEvent", "reset"));
		}
		
		
		private function clearStandardEvents():void 
		{
			if (hasEventListener(GWGestureEvent.SCALE))
				removeEventListener(GWGestureEvent.SCALE, onRegularScale);
			if (hasEventListener(GWGestureEvent.DRAG))
				removeEventListener(GWGestureEvent.DRAG, onRegularDrag);
			if (hasEventListener(GWGestureEvent.ROTATE))
				removeEventListener(GWGestureEvent.ROTATE, onRegularRotate);
			if (hasEventListener(GWGestureEvent.COMPLETE))
				removeEventListener(GWGestureEvent.COMPLETE, onRegularComplete);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {									
			super.dispose();
			R_UPPERCORNER = null;
			R_LOWERCORNER = null;
			R_MIDDLE = null;
			L_UPPERCORNER = null;
			L_LOWERCORNER = null;
			L_MIDDLE = null;			
			currentCorner = null;
			trackPoint = null;
			pageContent = null;
			shadows = null;
			pageCorners = null;
			shape = null;
			shadow = null;
			shadow2 = null;			
			bmpD1.dispose();
			bmpD2.dispose();
			bmpD1 = null;
			bmpD2 = null;			
			obj = null;
		}
	}
}