package com.gestureworks.cml.element
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.loaders.*;
	import com.gestureworks.cml.utils.CircleText;
	import com.gestureworks.cml.utils.NumberUtils;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.*;
	import flash.display.GradientType;
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.utils.Timer;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.*;
	import org.libspark.betweenas3.tweens.*;
	import org.tuio.TuioTouchEvent;
	import com.gestureworks.cml.events.StateEvent;
//	import com.google.maps.styles.ButtonStyle;
	
	/**
	 * The OrbMenu contains a list of Menus.
	 * It has the following parameters: orbRadius ,gradientType, gradientColorArray, gradientAlphaArray, gradientRatioArray, gradientHeight, gradientWidth, gradientRotation, gradientX, gradientY, shape1LineStoke, shape1OutlineColor, shape2LineStoke, shape2OutlineColor, backgroundColor, backgroundOutlineColor, backgroundLineStoke, repeatTime, attractMode.
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var ob:OrbMenu = new OrbMenu();
	   ob.x = 100;
	   ob.y = 100;
	   ob.init();
	   addChild(ob);
	
	 *
	 * </codeblock>
	 * @author Uma
	 */
	
	public class OrbMenu extends Menu
	{
		
		/**
		* OrbMenu constructor.
		*/
		public function OrbMenu()
		{
			super();
		}
		
		/**
		* Defines the OuterCircle which is a rectangle
		*/
		public var shape1:TouchSprite = new TouchSprite();
		
		/**
		* Defines the InnerCircle which is a rectangle
		*/
		public var shape2:TouchSprite = new TouchSprite();
		
		/**
		* Defines background in rectangle shape of orbMenu.
		*/
		public var background:Sprite = new Sprite();
		
		/**
		* Defines array of buttons.
		*/
		public var buttons:Array = [];
		
		/**
		* Defines intersection lines of background.
		*/
		public var line:Sprite = new Sprite();
		
		/**
		* Defines dropshadow filter for shape.
		*/
		public var dropShadow:DropShadowFilter = new DropShadowFilter();
		
		/**
		* Defines array for drop shadow filter.
		*/
		public var filtersArray:Array = new Array(dropShadow);
		
		private var _orbRadius:Number = 100;
		/**
		* Defines radius of orbmenu.
		*  @default = 100;
		*/
		public function get orbRadius():Number
		{
			return _orbRadius;
		}
		public function set orbRadius(value:Number):void
		{
			_orbRadius = value;
		}
		/**
		 * Defines to control gradient appearance of shapes.
		 */
		public var matrix:Matrix = new Matrix();
		
		private var _gradientType:String = GradientType.LINEAR;
		/**
		* Sets the gardient type for shapes
		* @default = GradientType.LINEAR;
		*/
		public function get gradientType():String
		{
		    if (_gradientType == GradientType.RADIAL)
			   return "radial";
			   return "linear";
		}
		public function set gradientType(value:String):void
		{
			if (value == "radial")
				_gradientType = GradientType.RADIAL;
			else
				_gradientType = GradientType.LINEAR;
		}
		
		private var gradientColorArray:Array = [0x404040, 0x404040];
		private var _gradientColors:String = "0x404040 , 0x404040";
		/**
		* Sets the array of color values of gradient for shapes
		* @default = [0x404040 , 0x404040];
		*/
		public function get gradientColors():String
		{
			return _gradientColors;
		}
		public function set gradientColors(value:String):void
		{
			_gradientColors = value;
			gradientColorArray = _gradientColors.split(",");
		}
		
		private var gradientAlphaArray:Array = [1, 1];
		private var _gradientAlphas:String = "1, 1";
		/**
		* Sets the alpha transparency of gradient for shapes
		* @default = [1, 1];
		*/
		public function get gradientAlphas():String
		{
			return _gradientAlphas;
		}
		public function set gradientAlphas(value:String):void
		{
			_gradientAlphas = value;
			gradientAlphaArray = _gradientAlphas.split(",");
		}
		
		private var gradientRatioArray:Array = [0, 255];
		private var _gradientRatios:String = "0, 255";
		/**
		* Sets the ratios of gradient for shapes
		* @default = [0, 255];
		*/
		public function get gradientRatios():String
		{
			return _gradientRatios;
		}
		public function set gradientRatios(value:String):void
		{
			_gradientRatios = value;
			gradientRatioArray = _gradientRatios.split(",");
		}
		
		private var _gradientWidth:Number = 50;
		/**
		* the width (in pixels) to which the gradient will spread
		* @default = 50;
		*/
		public function get gradientWidth():Number
		{
			return _gradientWidth;
		}
		public function set gradientWidth(value:Number):void
		{
			_gradientWidth = value;
		}
		
		private var _gradientHeight:Number = 100;
		/**
		* the width (in pixels) to which the gradient will spread
		* @default = 100;
		*/
		public function get gradientHeight():Number
		{
			return _gradientHeight;
		}
		public function set gradientHeight(value:Number):void
		{
			_gradientHeight = value;
		}
		
		private var _gradientRotation:Number = 0;
		/**
		* the rotation (in radians) that will be applied to the gradient
		* @default = 0;
		*/
		public function get gradientRotation():Number
		{
			return _gradientRotation;
		}
		public function set gradientRotation(value:Number):void
		{
			_gradientRotation = value;
		}
		
		private var _gradientX:Number = 25;
		/**
		* how far (in pixels) the gradient is shifted horizontally
		* @default = 25;
		*/
		public function get gradientX():Number
		{
			return _gradientX;
		}
		public function set gradientX(value:Number):void
		{
			_gradientX = value;
		}
		
		private var _gradientY:Number = 0;
		/**
		* how far (in pixels) the gradient is shifted horizontally
		* @default = 0;
		*/
		public function get gradientY():Number
		{
			return _gradientY;
		}
		public function set gradientY(value:Number):void
		{
			_gradientY = value;
		}
		
		private var _shape1LineStoke:Number = 5;
		/**
		* Defines linestoke of shape1.
		* @default = 5;
		*/
		public function get shape1LineStoke():Number
		{
			return _shape1LineStoke;
		}
		public function set shape1LineStoke(value:Number):void
		{
			_shape1LineStoke = value;
		}
		
		private var _shape1OutlineColor:uint = 0x000000;
		/**
		* Sets the  outline color of shape1
		*  @default = 0x000000;
		*/
		public function get shape1OutlineColor():uint
		{
			return _shape1OutlineColor;
		}
		public function set shape1OutlineColor(value:uint):void
		{
			_shape1OutlineColor = value;
		}
		
		private var _shape2LineStoke:Number = 5;
		/**
		* Defines linestoke of shape2.
		* @default = 4;
		*/
		public function get shape2LineStoke():Number
		{
			return _shape2LineStoke;
		}
		public function set shape2LineStoke(value:Number):void
		{
			_shape2LineStoke = value;
		}
		
		private var _shape2OutlineColor:uint = 0x000000;
		/**
		* Sets the  outline color of shape2
		*  @default = 0x000000;
		*/
		public function get shape2OutlineColor():uint
		{
			return _shape2OutlineColor;
		}
		public function set shape2OutlineColor(value:uint):void
		{
			_shape2OutlineColor = value;
		}
		
		private var _backgroundColor:uint = 0x808080;
		/**
		* Sets the background color
		*  @default = 0x666666;
		*/
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		private var _backgroundOutlineColor:uint = 0x000000;
		/**
		* Sets the background out line color
		*  @default = 0x000000;
		*/
		public function get backgroundOutlineColor():uint
		{
			return _backgroundOutlineColor;
		}
		public function set backgroundOutlineColor(value:uint):void
		{
			_backgroundOutlineColor = value;
		}
		
		private var _backgroundLineStoke:uint = 2;
		/**
		* Sets the background line stoke
		*  @default = 3;
		*/
		public function get backgroundLineStoke():uint
		{
			return _backgroundLineStoke;
		}
		public function set backgroundLineStoke(value:uint):void
		{
			_backgroundLineStoke = value;
		}
		
		private var _textX:Number = 90;
		/**
		* defines the centerX position of text
		*/
		public function get textX():Number
		{
			return _textX;
		}
		public function set textX(value:Number):void
		{
			_textX = value;
		}
		
		private var _textY:Number = 80;
		/**
		* Defines centerY position of text
		*/
		public function get textY():Number
		{
			return _textY;
		}
		public function set textY(value:Number):void
		{
			_textY = value;
		}
		
		private var _textRadius:Number = 100;
		/**
		* defines radius of text
		*/
		public function get textRadius():Number
		{
			return _textRadius;
		}
		public function set textRadius(value:Number):void
		{
			_textRadius = value;
		}
		
		private var _curveText:String = "MENU";
		/**
		* defines the text
		*/
		public function get curveText():String
		{
			return _curveText;
		}
		public function set curveText(value:String):void
		{
			_curveText = value;
		}
		
		private var _coverage:Number = 0.4;
		/**
		* defines the coverage of text
		*/
		public function get coverage():Number
		{
			return _coverage;
		}
		public function set coverage(value:Number):void
		{
			_coverage = value;
		}
		
		private var _startAngle:Number = 100;
		/**
		* defines start angle for text
		*/
		public function get startAngle():Number
		{
			return _startAngle;
		}
		public function set startAngle(value:Number):void
		{
			_startAngle = value;
		}
		
		private var _stopAngle:Number = 100;
		/**
		* defines stop angle for text
		*/
		public function get stopAngle():Number
		{
			return _stopAngle;
		}
		public function set stopAngle(value:Number):void
		{
			_stopAngle = value;
		}
		
		private var _attractMode:Boolean = true;
		/**
		* defines whether Orbmenu is floating or not
		*/
		public function get attractMode():Boolean
		{
			return _attractMode;
		}
		public function set attractMode(value:Boolean):void
		{
			_attractMode = value;
		}
		
		private var _repeatTimer:Number = 3;
		/**
		* number of times the timer will tick before the timer stops itself
		* @default = 1;
		*/
		public function get repeatTimer():Number
		{
			return _repeatTimer;
		}
		public function set repeatTimer(value:Number):void
		{
			_repeatTimer = value;
		}
		
		/**
		 * Initializes the configuration and display of orbMenu
		 */
		override public function init():void
		{
			//displayOrb();
			displayComplete();
		}
		
		/**
		 * creats OrbMenu Graphics and the curved text on OrbMenu.
		 */
		private function displayOrb():void
		{
			
			dropShadow.color = 0x000000;
			dropShadow.blurX = 300;
			dropShadow.blurY = 200;
			dropShadow.angle = 360;
			dropShadow.alpha = 1;
			dropShadow.distance = 15;
			
			matrix.createGradientBox(gradientWidth, gradientHeight, gradientRotation, gradientX, gradientY);
			
			shape1.graphics.lineStyle(shape1LineStoke, shape1OutlineColor);
			shape1.graphics.beginGradientFill(gradientType, gradientColorArray, gradientAlphaArray, gradientRatioArray, matrix);
			shape1.graphics.drawCircle(0, 0, orbRadius);
			shape1.x = 100;
			shape1.y = 70;
			
			shape2.graphics.lineStyle(shape2LineStoke, shape2OutlineColor);
			shape2.graphics.beginGradientFill(gradientType, gradientColorArray, gradientAlphaArray, gradientRatioArray, matrix);
			shape2.graphics.drawCircle(0, 0, (orbRadius/2));
			shape2.x = 0;
			shape2.y = 0;
			
			shape2.filters = filtersArray;
			
			background.graphics.lineStyle(backgroundLineStoke, backgroundOutlineColor);
			background.x = 170;
			background.y = 60;
			background.rotation = 45;
			background.visible = false;
						
			var c1:CircleText = new CircleText(textX, textY, textRadius, curveText, coverage, startAngle, stopAngle);
			//  var c1:CircleText = new CircleText(-10, 10, 100, "MENU", 0.4, 0, 0);
			
			shape1.gestureEvents = true;
			shape1.gestureList = {"n-drag": true, "n-tap": true};
			shape1.addEventListener(GWGestureEvent.DRAG, onDrag);
			//shape1.addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			
			if (GestureWorks.activeTUIO)
				this.addEventListener(TuioTouchEvent.TAP, onBegin);
			else if (GestureWorks.supportsTouch)
				this.addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			else
				this.addEventListener(MouseEvent.CLICK, onBegin);
			
			addChild(background);
			addChild(shape1);
			shape1.addChild(shape2);
			addChild(c1);
		
		}
		
		/**
		 * Floating stops when event happens.
		 * @param	event
		 */
		private function onDrag(event:GWGestureEvent):void
		{
			background.visible = true;
			
			if (attractMode && timer)
			{
				timer.reset();
				tweener.stop();
				tweener.onComplete = null;
				this.x += event.value.drag_dx;
				this.y += event.value.drag_dy;
			}
		}
		
		/**
		 * Floating stops when event happens.
		 * @param	event
		 */
		private function onBegin(event:TouchEvent):void
		{
			//background.visible = false;
			
			if (attractMode && timer)
			{
				timer.reset();
				tweener.stop();
				tweener.onComplete = null;
			}
    	}
		
		/**
		 * CML display initialization callback
		 * defines positions for buttons,lines and rectangle.
		 */
		override public function displayComplete():void
		{
			if (attractMode)
			{
				setTime();
			}
			
			//init();
			displayOrb();
			
			buttons = childList.getValueArray();
			height = 135;
			width = 100;
			
			for (var i:int = 0; i < buttons.length; i++)
			{
				line.graphics.lineStyle(0, 0x000000, 1);
				line.graphics.moveTo((width * i + orbRadius), 0);
				line.graphics.lineTo((width * i + orbRadius), height);
				
				buttons[i].x = orbRadius + width * i;
				buttons[i].y = 0;
				
				background.addChild(buttons[i]);
			}
			background.addChild(line);
			
			if (buttons.length > 1)
			{
				background.graphics.beginFill(backgroundColor);
				background.graphics.drawRoundRect(0 - width, 0, (orbRadius + width) + (width * buttons.length), 135, 25, 25);
			}
			else
			{
				background.graphics.drawRoundRect(0, 0, (orbRadius + width), 135, 25, 25);
			}
			
		}
		
		private var tweener:ITween;
		private var timer:Timer;
		
		/**
		 * tween method for floating - display object.
		 */
		private function tween():void
		{
			if (attractMode)
			{
				tweener = BetweenAS3.tween(this, {x: NumberUtils.randomNumber(0, (stage.stageWidth - orbRadius)), y: NumberUtils.randomNumber(0, (stage.stageHeight - orbRadius))}, null, 40, Elastic.easeOut);
				tweener.play();
				tweener.onComplete = tween;
			}
		}
		
		/**
		 * Starts floating after certain period of time.
		 */
		private function setTime():void
		{
			timer = new Timer(1000, repeatTimer);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerListener);
		}
		
		private function timerListener(e:TimerEvent):void
		{
			tween();
		}
		
		/**
		 * Dispose methods.
		 */
		override public function dispose():void
		{
			tweener = null;
			timer = null;
			matrix = null;
			dropShadow = null;
			filtersArray = null;
			line = null;
			buttons = null;
			background = null;
			shape2 = null;
			shape1 = null;
			shape1.removeEventListener(GWGestureEvent.DRAG, onDrag);
			shape1.removeEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerListener);
		}
	}
}