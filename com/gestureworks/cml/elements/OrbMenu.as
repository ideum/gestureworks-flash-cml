package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;
	import org.tuio.*;

	/**
	 * The OrbMenu element creates a free-floating menu that optionally randomly floats around
	 * the stage in a screen-saver mode.
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
		var orb:OrbMenu = new OrbMenu();
		
		 // listen to orb menu's state event for button presses
		addEventListener(StateEvent.CHANGE, changeBkg);
		
		bkg = new Graphic();
		bkg.shape = "rectangle"; 
		bkg.width = stage.width;
		bkg.height = stage.height;
		bkg.color = 0x000000;
		addChild(bkg);			 
		 
		 //can set the timer and attract mode of orbmenu
		 orb.repeatTimer = 1;
		 orb.attractMode = true;
		 
		 //curve text location of orbmenu
		 orb.textX = 90;
		 orb.textY = 80;
		 orb.textRadius = 100;
		 orb.curveText = "MENU";
		 orb.coverage = 0.4;
		 orb.startAngle = 100;
		 orb.stopAngle = 100;
		 
		 //circle radius
		 orb.orbRadius = 100;
		 
		 //gradient matrix graphics
		 orb.gradientType = "linear";
		 orb.gradientColors = "0x404040, 0x404040";
		 orb.gradientAlphas = "1,1";
		 orb.gradientRatios = "0,255";
		 orb.gradientHeight = 100;
		 orb.gradientWidth = 50;
		 orb.gradientRotation = 0;
		 orb.gradientX = 25;
		 orb.gradientY = 0;
		 
		 //outer circle graphics
		 orb.shape1LineStoke = 3;
		 orb.shape1OutlineColor = 0x000000;
		 
		 //inner circle graphics
		 orb.shape2LineStoke = 3;
		 orb.shape2OutlineColor = 0x000000;
		 
		 //background(rectangle) graphics
		 orb.backgroundColor = 0x808080;
		 orb.backgroundOutlineColor = 0x000000;
		 orb.backgroundLineStoke = 3;
	
		 //background(rectangle) graphics				
		 background = new Graphic();
		 background.visible = false;
		 orb.addChild(background);
	
	
		 var numberOfButtons:int = 3;
		 var width:Number = 100;
		 var height:Number = 135;
		 var orbRadius:Number = 100;
					
		 buttons = new Array(numberOfButtons);
		
		// position of buttons,lines,background
		 <!-- for (var i:int = 0; i < numberOfButtons; i++) -->
		  {
			var line:Sprite = new Sprite();
			line.graphics.lineStyle(0, 0x000000, 1);
			line.graphics.moveTo((width * i + orbRadius), 0);
			line.graphics.lineTo((width * i + orbRadius), height);
			
			buttons[i] = new Button();
							
			if (i==0)
				buttons[i] = createButton(buttons[i], "btn0", "grey");
			else if (i == 1)
				buttons[i] = createButton(buttons[i], "btn1","purple");
			else if (i == 2)
				buttons[i] = createButton(buttons[i], "btn2", "pink");
			
			buttons[i].x = 100 + width * i;
			buttons[i].y = 0;
			
			background.addChild(buttons[i]);
			buttons[i].init();
										
			background.addChild(line);
		  }
		  
		if (numberOfButtons > 1)
		{
			background.graphics.beginFill(0x808080);
			background.graphics.drawRoundRect(0- width , 0, (orbRadius + width) + (width * numberOfButtons), 135, 25, 25);
		}
		else
		{
			background.graphics.drawRoundRect(0, 0, (orbRadius + width), 135, 25, 25);
		}
		
		 orb.buttons = buttons;
		 orb.init();
		 addChild(orb);		

		 
		function createButton(b:Button, type:String, value:String):Button
		{
			var btnUp:Container = new Container();
			btnUp.id = type + "-up";
						
	        var text:Text = new Text();
			text.text = value;
			text.x = 17;
			text.y = 45;
			text.selectable = false;
			text.color = 0x151B54;
			text.fontSize = 20;
			text.visible = true;
			text.multiline = true;
			text.font = "OpenSansRegular";
			btnUp.addChild(text);
						
			var btnDown:Container = new Container();
			btnDown.id = "btn-down";
					
			var btnHit:Container = new Container();
			btnHit.id = type + "-hit";
			
			var hitBg:Graphic = new Graphic();
			hitBg.shape = "rectangle";
			hitBg.id = type + "HitBg";
			hitBg.alpha = 0;
			hitBg.width = 100;
			hitBg.height = 100;
			hitBg.lineStroke = 1.5;
			hitBg.color = 0xCCCCCC;
			
			btnHit.addChild(hitBg);
			btnHit.childToList(type + "HitBg", hitBg);
			
			b.addChild(btnUp);
			b.childToList(type + "-up", btnUp);
			
			b.addChild(btnDown);
			b.childToList(type + "-down", btnDown);
			
			b.addChild(btnHit);
			b.childToList(type + "-hit", btnHit);
			
			b.initial = type + "-up";
						
			b.up = type + "-up";
			b.out = type + "-up";
			b.down = type + "-down";
			b.hit = type + "-hit";
			
			b.dispatch = "down:" + type;
						
			return b;
		}
		
		
		//background color changes on state event.
		function changeBkg(event:StateEvent):void
		{
			if (event.value == "btn0")
			{
				bkg.visible = true;
				bkg.color = 0x817679;
			}
			else if (event.value == "btn1")
			{
				bkg.visible = true;	
				bkg.color = 0x5E5A80;
			}
	        else if (event.value == "btn2")
			{
				bkg.visible = true;
				bkg.color = 0xC48189;
			}
		}
	
	 *
	 * </codeblock>
	 * @author Uma
	 */
	
	public class OrbMenu extends Menu
	{
		
		/**
		* Constructor.
		*/
		public function OrbMenu()
		{
			super();
		}
		
		/**
		* Defines the OuterCircle which is a rectangle
		*/
		public var shape1:Sprite = new Sprite();
		
		/**
		* Defines the InnerCircle which is a rectangle
		*/
		public var shape2:Sprite = new Sprite();
		
		/**
		* Defines background in rectangle shape of orbMenu.
		*/
		public var background:Sprite = new Sprite();
		
		/**
		* Defines array of buttons.
		*/
		public var buttons:Array;
		
		/**
		* Defines intersection lines of background.
		*/
		public var line:Sprite = new Sprite();
		
		/**
		* Defines dropshadow filter for shape.
		*/
		public var dropshadow:DropShadowFilter = new DropShadowFilter();
		
		/**
		* Defines array for drop shadow filter.
		*/
		public var filtersArray:Array = new Array(dropshadow);
		
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
		
		private var _curveText:String;
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
		 * creats OrbMenu Graphics and the curved text on OrbMenu.
		 */
		private function displayOrb():void
		{
			
			dropshadow.color = 0x000000;
			dropshadow.blurX = 300;
			dropshadow.blurY = 200;
			dropshadow.angle = 360;
			dropshadow.alpha = 1;
			dropshadow.distance = 15;
			
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
			
		//	shape2.filters = filtersArray;
			
			//width = 100;
			
			background.graphics.lineStyle(backgroundLineStoke, backgroundOutlineColor);
			background.graphics.beginFill(0x808080);
			//background.graphics.drawRoundRect(0, 0, 400, 135, 25, 25);
			//background.graphics.drawRoundRect(0, 0, (orbRadius + width) + (width * buttons.length), 135, 25, 25);
			background.graphics.endFill();
			background.x = 170;
			background.y = 60;
			background.rotation = 45;
			background.visible = false;
							
			addChild(background);
			addChild(shape1);
			shape1.addChild(shape2);
			
			if(curveText){
				var c1:CircleText = new CircleText(textX, textY, textRadius, curveText, coverage, startAngle, stopAngle);			
				addChild(c1);
			}			
			
			var hitShape:TouchSprite = new TouchSprite;
			hitShape.graphics.lineStyle(shape1LineStoke, shape1OutlineColor);
			hitShape.graphics.beginGradientFill(gradientType, gradientColorArray, gradientAlphaArray, gradientRatioArray, matrix);
			hitShape.graphics.drawCircle(0, 0, orbRadius);
			hitShape.graphics.endFill();
			hitShape.x = 100;
			hitShape.y = 70;
			hitShape.alpha = 0;
			
			
			hitShape.gestureEvents = true;
			hitShape.nativeTransform = false;			
			hitShape.gestureList = {"n-drag-inertia": true, "n-tap": true};
			hitShape.addEventListener(GWGestureEvent.DRAG, onDrag);
			hitShape.addEventListener(GWGestureEvent.TAP, onTap);
			hitShape.gestureReleaseInertia = true;			
			addChild(hitShape);
		}
		
		
		/**
		 * Floating stops when event happens.
		 * @param	event
		 */
		private function onDrag(event:GWGestureEvent):void
		{			
			if (attractMode && timer)
			{
				timer.reset();
				
				if (tweener) {
					tweener.kill();
					tweener.eventCallback("onComplete");
				}
			}		
			this.x += event.value.drag_dx;
			this.y += event.value.drag_dy;			
		}
		
		/**
		 * Floating stops when event happens.
		 * @param	event
		 */
		private function onTap(event:GWGestureEvent):void
		{
			background.visible = !background.visible;
						
			if (attractMode && timer)
			{
				timer.reset();
				if (tweener){
					tweener.kill();
					tweener.eventCallback("onComplete");
				}
			}
    	}
		
		/**
		 * CML display initialization callback
		 * defines positions for buttons,lines and rectangle.
		 */
		override public function init():void
		{
			if (attractMode)
			{
				setTime();
			}
			
			 if (!buttons)
			 {
				buttons = searchChildren(Button, Array);
			 }
			 
			 //init();
			 displayOrb();
			
					
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
		
		private var tweener:TweenLite;
		private var timer:Timer;
		
		/**
		 * tween method for floating - display object.
		 */
		private function tween():void
		{
			if (attractMode)
			{
				tweener = TweenLite.to(this, 40, { x: NumberUtils.randomNumber(0, (stage.stageWidth - orbRadius)), y: NumberUtils.randomNumber(0, (stage.stageHeight - orbRadius)), ease:Elastic.easeOut, onComplete:tween } );
				tweener.play();
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
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			tweener = null;
			matrix = null;
			dropshadow = null;
			filtersArray = null;
			line = null;
			buttons = null;
			background = null;
			shape2 = null;
			shape1 = null;
			gradientColorArray = null;
			gradientAlphaArray = null;
			gradientRatioArray = null;
			
			if(timer){
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerListener);
				timer = null;
			}
		}
	}
}