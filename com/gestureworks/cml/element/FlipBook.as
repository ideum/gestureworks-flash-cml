package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.PageFlip;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import org.tuio.TuioTouchEvent;
	import com.greensock.*;
	
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
		private var trackPoint:Point = new Point(0, 0);
		
		private var pageContent:Array = new Array();
		private var shadows:Array = new Array();
		
		private var shape:Shape;
		private var bmpD1:BitmapData;
		private var bmpD2:BitmapData;
		private var shadow:Sprite;
		private var shadow2:Sprite;
		private var staticShadow:TouchSprite;
		private var staticShadow2:TouchSprite;
		
		
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
		
		private var _currentPage:Number = 0;
		/**
		 * Retrieves the current page. The page returned is the page on the right, not the left, and counting starts from 0, not 1.
		 * So if the _currentPage is 2, the page on the right is page 3 and the page on the left is page 2.
		 */
		public function get currentPage():Number { return _currentPage; }
		
		// public methods //
		
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
					trace("Actually, odd numbered content.");
					pageContent[i].x = _pw;
					pageShadow.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0.25, 0), new Array(0, 255), m);
					//pageShadow.graphics.beginFill(0xffffff);
					pageShadow.graphics.drawRect(0, 0, 100, _ph);
					pageShadow.graphics.endFill();
					pageContent[i].addChild(pageShadow);
				}
				else {
					// If it's even numbered content, it will start on the left, no repositioning needed,
					// but it's visibility will need to be false.
					
					pageContent[i].visible = false;
					pageShadow.graphics.beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(0, 0.25), new Array(0, 255), m);
					//pageShadow.graphics.beginFill(0xffffff);
					pageShadow.graphics.drawRect(0, 0, 100, _ph);
					pageShadow.graphics.endFill();
					pageContent[i].addChild(pageShadow);
					pageShadow.x = _pw - 100;
				}
			}
			
			for (var j:Number = 0; j < pageContent.length; j++) {
				if (j % 2) {
					trace("ID ordering:", pageContent[j].id);
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
			
			L_UPPERCORNER = new Point(_pw * 0.2, _pw * 0.2);
			L_LOWERCORNER = new Point(_pw * 0.2, _ph - (_pw * 0.2));
			L_MIDDLE = new Point( _pw * 0.1, (_ph - (L_UPPERCORNER.y * 2)) / 2 + L_UPPERCORNER.y);
			
			R_UPPERCORNER = new Point((_pw * 2) - (_pw * 0.2), (_pw * 0.2));
			R_LOWERCORNER = new Point((_pw * 2) - (_pw * 0.2), _ph - (_pw * 0.2));
			R_MIDDLE = new Point((_pw * 2) - (_pw * 0.1), (_ph - (R_UPPERCORNER.y * 2)) / 2 + R_UPPERCORNER.y)
			// No need to define the middle further, I suppose. ^This is the center point between upper and lower.
			
			//addEventListener(GWTouchEvent.TOUCH_BEGIN, onBegin, false);
			addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			addEventListener(StateEvent.CHANGE, onStateEvent);
			
		}
		
		private function onStateEvent(e:StateEvent):void {
			trace("E.value:", e.value);
		}
		
		private function onBegin(e:*):void {
			//trace(e.localX, e.localY);
			if (tweening) return;
			
			trackPoint = flipPoint(e.target, e.localX, e.localY, this);
			
			//trace("Trackpoint:", trackPoint);
			
			if (trackPoint.x < _pw * 2 && trackPoint.x > R_UPPERCORNER.x && _currentPage + 1 < pageContent.length) {
				if (trackPoint.y < R_UPPERCORNER.y && trackPoint.y > -1) {
					trace("I've found the upper RIGHT corner!");
					currentCorner = new Point(1, 0);
					forward = true;
				}
				else if (trackPoint.y < _ph && trackPoint.y > R_LOWERCORNER.y) {
					trace("I've found the lower RIGHT corner!");
					currentCorner = new Point(1, 1);
					forward = true;
				}
				
				else if (trackPoint.x < _pw * 2 && trackPoint.x > R_MIDDLE.x) {
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
				}
			}
			else if (OPEN && trackPoint.x < L_UPPERCORNER.x && trackPoint.x > 0) {
				if (trackPoint.y < L_UPPERCORNER.y && trackPoint.y > -1) {
					trace("I've found the upper LEFT corner!");
					currentCorner = new Point(1, 0);
					forward = false;
				}
				else if (trackPoint.y < _ph && trackPoint.y > L_LOWERCORNER.y) {
					trace("I've found the lower LEFT corner!");
					currentCorner = new Point(1, 1);
					forward = false;
				}
				
				else if (trackPoint.x < L_MIDDLE.x && trackPoint.x > 0) {
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
				}
			}
			else {
				currentCorner = null;
				return;
			}
			
			if (!hasEventListener(GWGestureEvent.COMPLETE))
				addEventListener(GWGestureEvent.COMPLETE, onTouchEnd);
			if (trackPoint && currentCorner)
				addEventListener(GWGestureEvent.DRAG, onPointMove);
			
			// Set up the bitmap data.
			if (forward && _currentPage + 1 < pageContent.length) {
				bmpD1 = new BitmapData(_pw, _ph);
				bmpD1.draw(pageContent[_currentPage]);
				bmpD2 = new BitmapData(_pw, _ph);
				bmpD2.draw(pageContent[_currentPage + 1]);
			} else if (!forward) {
				_currentPage -= 2;
				if (_currentPage < 0)
					_currentPage = 0;
				bmpD1 = new BitmapData(_pw, _ph);
				bmpD1.draw(pageContent[_currentPage]);
				bmpD2 = new BitmapData(_pw, _ph);
				bmpD2.draw(pageContent[_currentPage + 1]);
				
			}
		}
		
		private function onPointMove(e:GWGestureEvent):void {
			shape.graphics.clear();
			
			// Make current page invisible somehow.
			if (forward) {
				pageContent[_currentPage].visible = false;
				//shadows[_currentPage].visible = false;
			}
			else {
				pageContent[_currentPage + 1].visible = false;
			}
			
			if (_currentPage + 1 < pageContent.length) {
				setChildIndex(shape, getChildIndex(pageContent[_currentPage + 1]));
				
				if (getChildIndex(shadow2) < getChildIndex(pageContent[_currentPage + 1])) {
					setChildIndex(shadow, getChildIndex(pageContent[_currentPage + 1]));
					setChildIndex(shadow2, getChildIndex(pageContent[_currentPage + 1]));
				}
			}
			
			trackPoint = flipPoint(e.target, e.value.localX, e.value.localY, shape);
			//trace("Dragging!", trackPoint);
			
			obj = PageFlip.computeFlip(trackPoint, currentCorner, _pw, _ph, true, 1);
			if (!obj.cPoints || obj.cPoints.length < 3) return;
			
			PageFlip.drawBitmapSheet(obj, shape, bmpD1, bmpD2);
			placeShadow(obj.cPoints);
			
			// Repeat the flip point to restore original event values. This is to stabilize the Y value
			// to keep consistent on release since the computeFlip steps through and alters the point it's given.
			trackPoint = flipPoint(e.target, e.value.localX, e.value.localY, shape);
			
		}
		
		private function onTouchEnd(e:*):void {
			
			removeEventListener(GWGestureEvent.DRAG, onPointMove);
			removeEventListener(GWGestureEvent.COMPLETE, onTouchEnd);
			
			var duration:Number = 0.5;
			tweening = true;
			if (trackPoint.x < 0) {
				duration = (trackPoint.x + _pw) / _pw * 0.5;
				OPEN = true;
				//TweenMax.to(trackPoint, duration, { x: -_pw, y:currentCorner.y * _ph, onUpdate:tweenUpdate, onComplete:updatePages(true) } );
				TweenMax.to(trackPoint, duration, { x: -_pw, y:currentCorner.y * _ph, onUpdate:tweenUpdate } );
			}
			else {
				duration = _pw - trackPoint.x;
				duration = (duration / _pw) * 0.5;
				if (_currentPage == 0)
					OPEN = false;
				//TweenMax.to(trackPoint, duration, { x: _pw, y:currentCorner.y * _ph, onUpdate:tweenUpdate, onComplete:updatePages(false) } );
				TweenMax.to(trackPoint, duration, { x: _pw, y:currentCorner.y * _ph, onUpdate:tweenUpdate } );
			}
		}
		
		private function tweenUpdate():void {
			shape.graphics.clear();
			obj = PageFlip.computeFlip(trackPoint, currentCorner, _pw, _ph, true, 1);
			
			PageFlip.drawBitmapSheet(obj, shape, bmpD1, bmpD2);
			placeShadow(obj.cPoints);
			
			if (trackPoint.x == _pw) {
				trace("Complete?");
				updatePages(false);
			}
			else if (trackPoint.x == -_pw) {
				updatePages(true);
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
			//var sPoint:Point = new Point(lastX, 0);
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
			
			if (forward && complete) {
				pageContent[_currentPage + 1].visible = true;
				shadows[_currentPage + 1].visible = true;
				_currentPage += 2;
				setChildIndex(shape, getChildIndex(pageContent[_currentPage]) - 1);
			}
			else if (!forward && complete)
				_currentPage += 2;
			else if (!forward && !complete) {
				
			}
			trace("Current page:", _currentPage);
			pageContent[_currentPage].visible = true;
			shadows[_currentPage].visible = true;
			
			tweening = false;
		}
		
		private function decreasePages():void {
			
		}
		
		/**
		 * CML initialization method
		 * @internal do not call super here
		 */
		override public function displayComplete():void
		{			
			init();
		}
	}
}