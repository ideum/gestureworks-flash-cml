package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.*;
	import com.greensock.TweenLite;
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.text.*;
	
	/**
	 * The Dial element provides a list of text elements in rotary selection tool. 
	 * 
	 * <p>The text can be moved from top to bottom or bottom to top through the drag event. 
	 * The Dial has two different modes - Continous and Non-Continous. In continous dial mode 
	 * the text elements move continously without stopping at the end or beginning through 
	 * the drag event.In non-continous dial the motion stops when the first element or the 
	 * last element reaches the center line. The text element closest to the center snaps to 
	 * the center line and also changes its color.</p>
	 * 
	 * <p>It allows the user to set the dial mode from continous to non-continous or non-continous 
	 * to continous by setting the continous flag to true or false. The number of elements on 
	 * dial can be increased or decreased by setting the maxItemsOnScreen attribute. </p>
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
			// continuous dial
			var dial1:Dial = new Dial();
			
			// can add any text, increase or decrease the max items to the dial, can change the text color and selected color
			dial1.text = "Collection 1,Collection 2,Collection 3,Collection 4,Collection 5,Collection 6,Collection 7,Collection 8,Collection 9,Collection 10";
			dial1.maxItemsOnScreen = 5;
			dial1.continuous = true;
			dial1.textColor = 0xDDDDDD;
			dial1.selectedTextColor = 0x000000;
			dial1.x = 500;
			dial1.y = 250;
			
			// gradient matrix graphics 
			dial1.gradientType = "linear";
			dial1.gradientColors = "0x111111,0xDDDDDD,0x111111";
			dial1.gradientAlphas = "1,1,1";
			dial1.gradientRatios = "0,127.5,255";
			dial1.gradientWidth = 300;
			dial1.gradientHeight = 200;
			dial1.gradientX = 25;
			dial1.gradientY = 0;
			dial1.gradientRotation = 1.57;
			
			// background graphics
			dial1.backgroundLineStroke = 3;
			dial1.backgroundAlpha = 5;
			
			// triangles graphics
			dial1.leftTriangleColor = 0x303030;
			dial1.rightTriangleColor = 0x303030;
			
			// center line graphics
			dial1.centerLineLineStroke = 1;
			dial1.centerLineOutlineColor = 0xAAAAAAA;
			dial1.centerLineOutlineAlpha = 0.4;
			dial1.centerLineColor = 0x666666;
			dial1.centerLineAlpha = 0.2;
			
			// text
			var text:Text = new Text();
			text.x = 590;
			text.y = 200;
			text.text = "Dial-Continous";
			text.width = 3000;
			text.color = 0xCC0099;
			text.selectable = false;
			text.font = "OpenSansBold";
			addChild(text);
			
			// initialise method for dial
			dial1.init();			
			addChild(dial1);
		
			
			// non-continuous dial
			var dial2:Dial = new Dial();
			
			//can add any text, increase or decrease the max items to the dial, can change the text color and selected color
			dial2.text = "Collection 1,Collection 2,Collection 3,Collection 4,Collection 5,Collection 6,Collection 7,Collection 8,Collection 9,Collection 10";
			dial2.maxItemsOnScreen = 5;
			dial2.continuous = false;
			dial2.textColor = 0xDDDDDD;
			dial2.selectedTextColor = 0x000000;
			dial2.x = 900;
			dial2.y = 250;
			
			//gradient matrix graphics 
			dial2.gradientType = "linear";
			dial2.gradientColors = "0x111111,0xDDDDDD,0x111111";
			dial2.gradientAlphas = "1,1,1";
			dial2.gradientRatios = "0,127.5,255";
			dial2.gradientWidth = 300;
			dial2.gradientHeight = 200;
			dial2.gradientX = 25;
			dial2.gradientY = 0;
			dial2.gradientRotation = 1.57;
			
			//background graphics
			dial2.backgroundLineStroke = 3;
			dial2.backgroundAlpha = 5;
			
			//triangles graphics
			dial2.leftTriangleColor = 0x303030;
			dial2.rightTriangleColor = 0x303030;
			
			//center line graphics
			dial2.centerLineLineStroke = 1;
			dial2.centerLineOutlineColor = 0xAAAAAAA;
			dial2.centerLineOutlineAlpha = 0.4;
			dial2.centerLineColor = 0x666666;
			dial2.centerLineAlpha = 0.2;
			
			var text1:Text = new Text();
			text1.x = 980;
			text1.y = 200;
			text1.text = "Dial-NonContinous";
			text1.width = 3000;
			text1.color = 0xCC0099;
			text1.font = "OpenSansBold";
			text1.selectable = false;
			addChild(text1);
			
			dial2.init();
			addChild(dial2);
	 *
	 * </codeblock>
	 * 
	 * @author Uma
	 * @see Menu
	 * @see DropDownMenu
	 * @see OrbMenu
	 */
	   
	public class Dial extends TouchContainer
	{
		private var touchSprite:TouchSprite;
		private var textFieldArray:Array;		
		private var textSpacing:int;
		private var minPos:Number;		
		private var maxPos:Number;
		private var centerPos:Number;
		private var _filterDial:Dial;
		private var filterMap:Object;
		private const NO_FILTER:String = "no_filter";
		
		/**
		 * Contructor
		 */
		public function Dial():void
		{
			super();
			mouseChildren = true;
		}
			
		/**
		 * Defines the background which is a rectangle
		 */
		public var background:Sprite = new Sprite();
		
		/**
		 * Defines the left triangle of background
		 */
		public var leftTriangle:Graphic = new Graphic();
		
		/**
		 * Defines the right triangle of background
		 */
		public var rightTriangle:Graphic = new Graphic();
		
		/**
		 * Defines the center line of background
		 */
		public var centerLine:Sprite = new Sprite();
		
		/**
		 * Defines the mask for background
		 */
		public var mymask:Sprite = new Sprite();
		
		/**
		 * Defines the matrix to control gradient appearance of background
		 */
		public var matrix:Matrix = new Matrix();
		
		/**
		 * Defines the text container
		 */
		public var textContainer:Sprite = new Sprite();
		
		private var _textColor:uint = 0xDDDDDD;// 0x000000;
		/**
		 * Sets the default text Color 
		 * @default 0x000000
		 */
		public function get textColor():uint
		{
			return _textColor;
		}
		public function set textColor(value:uint):void
		{
			_textColor = value;
		}  
		
		private var _selectedTextColor:uint = 0x000000;// 0xFFFFFF;  
		/**
		 * Sets the text Color for selected text
		 * @default 0xFFFFFF
		 */
		public function get selectedTextColor():uint
		{
			return _selectedTextColor;
		}
		public function set selectedTextColor(value:uint):void
		{
			_selectedTextColor = value;
		}  
		
		private var _maxItemsOnScreen:int = 5;
		/**
		 * Sets the maximum Text Elements on dial
		 * @default 5
		 */
		public function get maxItemsOnScreen():int
		{
			return _maxItemsOnScreen;
		}
		public function set maxItemsOnScreen(value:int):void
		{
			_maxItemsOnScreen = value;
		}
		
		private var textArray:Array = []; 
		private var _text:String = "Collection 1, Collection 2, Collection 3, Collection 4, Collection 5, Collection 6, Collection 7, Collection 8, Collection 9, Collection 10";
		/**
		 * Sets array of text elements
		 * @default 10
		 */
		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			var rex:RegExp = /(\t|\n|\r)/gi;
			_text = value.replace(rex, '');
			textArray = _text.split(",");
		}
		
		private var _fontSize:Number = 20;
		/**
		 * Sets the font size.
		 * @default 20
		 */
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(value:Number):void {
			_fontSize = value;
		}
		
		private var _gradientType:String = GradientType.LINEAR;
		/**
		 * Sets the gardient type for background
		 * @default GradientType.LINEAR
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
	
		private var gradientColorArray:Array = [0x111111, 0xDDDDDD, 0x111111];
		private var _gradientColors:String = "0x111111, 0xDDDDDD, 0x111111";
		/**
		 * Sets the array of color values of gradient for background
		 * @default [0x111111, 0xDDDDDD, 0x111111]
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
		
		private var gradientAlphaArray:Array = [1, 1, 1];
		private var _gradientAlphas:String = "1, 1, 1";
		/**
		 * Sets the alpha transparency of gradient for background
		 * @default [1, 1, 1]
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
		
		private var gradientRatioArray:Array = [0, 127.5, 255];
		private var _gradientRatios:String = "0, 127.5, 255";
		/**
		 * Sets the ratios of gradient for background
		 * @default [0, 127.5, 255]
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
		
		private var _gradientWidth:Number = 300;
		[Deprecated(replacement="width")]
		/**
		 * the width (in pixels) of the dial
		 */
		public function get gradientWidth():Number { return _gradientWidth; }
		public function set gradientWidth(value:Number):void
		{
			_gradientWidth = value;
			width = value;
		}
		
		private var _gradientHeight:Number = 200;
		[Deprectated(replacement="height")]
		/**
		 * the height (in pixels) of the dial
		 */
		public function get gradientHeight():Number { return _gradientHeight; }
		public function set gradientHeight(value:Number):void
		{
			_gradientHeight = value;
			height = value;
		}
		
		private var _gradientX:Number = 25;
		/**
		 * how far (in pixels) the gradient is shifted horizontally
		 * @default 25
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
		 * how far (in pixels) the gradient is shifted vertically
		 * @default 0
		 */
		
		public function get gradientY():Number
		{
			return _gradientY;
		}
		
		public function set gradientY(value:Number):void
		{
			_gradientY = value;
		}
		
		private var _gradientRotation:Number = Math.PI / 2;
		/**
		 * the rotation (in radians) that will be applied to the gradient
		 * @default Math.PI / 2
		 */
		
		public function get gradientRotation():Number
		{
			return _gradientRotation;
		}
		
		public function set gradientRotation(value:Number):void
		{
			_gradientRotation = value;
		}
		
		private var _backgroundLineStroke:Number = 3;
		
		/**
		 * Sets the background Line Stoke
		 *  @default 1
		 */
		public function get backgroundLineStroke():Number
		{
			return _backgroundLineStroke;
		}
		
		public function set backgroundLineStroke(value:Number):void
		{
			_backgroundLineStroke = value;
		}
		
		private var _backgroundAlpha:Number = 5;
		
		/**
		 * Sets the background Transparency
		 *  @default 0
		 */
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
		}
		
		private var _leftTriangleColor:Number = 0x303030;
		
		/**
		 * Sets the left triangle color of background
		 *  @default 0x303030
		 */
		public function get leftTriangleColor():Number
		{
			return _leftTriangleColor;
		}
		
		public function set leftTriangleColor(value:Number):void
		{
			_leftTriangleColor = value;
		}
		
		private var _leftTriangleAlpha:Number = 1;
		
		/**
		 * Sets the left triangle Transparency of background
		 *  @default 1
		 */
		public function get leftTriangleAlpha():Number
		{
			return _leftTriangleAlpha;
		}
		
		public function set leftTriangleAlpha(value:Number):void
		{
			_leftTriangleAlpha = value;
		}
		
		private var _leftTriangleScale:Number = 1;
		/**
		 * Sets the scale of the left triangle
		 * @default 1
		 */
		public function get leftTriangleScale():Number 
		{
			return _leftTriangleScale;
		}
		
		public function set leftTriangleScale(value:Number):void
		{
			_leftTriangleScale = value;
		}
		
		private var _rightTriangleColor:Number = 0x303030;
		
		/**
		 * Sets the right triangle color of background
		 *  @default 0x303030
		 */
		public function get rightTriangleColor():Number
		{
			return _rightTriangleColor;
		}
		
		public function set rightTriangleColor(value:Number):void
		{
			_rightTriangleColor = value;
		}
		
		private var _rightTriangleAlpha:Number = 1;
		
		/**
		 * Sets the right triangle Transparency of background
		 *  @default 1
		 */
		public function get rightTriangleAlpha():Number
		{
			return _rightTriangleAlpha;
		}
		
		public function set rightTriangleAlpha(value:Number):void
		{
			_rightTriangleAlpha = value;
		}
		
		private var _rightTriangleScale:Number = 1;
		
		/**
		 * Sets the scale of the right triangle
		 * @default 1
		 */
		public function get rightTriangleScale():Number 
		{
			return _rightTriangleScale;
		}
		
		public function set rightTriangleScale(value:Number):void
		{
			_rightTriangleScale = value;
		}
		
		private var _centerLineLineStroke:Number = 1;
		
		/**
		 * Sets the center line line stroke of background
		 *  @default 1
		 */
		public function get centerLineLineStroke():Number
		{
			return _centerLineLineStroke;
		}
		
		public function set centerLineLineStroke(value:Number):void
		{
			_centerLineLineStroke = value;
		}
		
		private var _centerLineOutlineColor:uint = 0xAAAAAAA;
		
		/**
		 * Sets the center line outline color of background
		 *  @default 0xAAAAAAA
		 */
		public function get centerLineOutlineColor():uint
		{
			return _centerLineOutlineColor;
		}
		
		public function set centerLineOutlineColor(value:uint):void
		{
			_centerLineOutlineColor = value;
		}
		
		private var _centerLineOutlineAlpha:Number = 0.4;
		
		/**
		 * Sets the outline transparency of center line of background
		 *  @default 0.4
		 */
		public function get centerLineOutlineAlpha():Number
		{
			return _centerLineOutlineAlpha;
		}
		
		public function set centerLineOutlineAlpha(value:Number):void
		{
			_centerLineOutlineAlpha = value;
		}
		
		private var _centerLineColor:uint = 0x666666;
		
		/**
		 * Sets the center line color of background
		 *  @default 0x666666
		 */
		public function get centerLineColor():uint
		{
			return _centerLineColor;
		}
		
		public function set centerLineColor(value:uint):void
		{
			_centerLineColor = value;
		}
		
		private var _centerLineAlpha:Number = 0.2;
		
		/**
		 * Sets the center line transparency of background
		 *  @default 0.2
		 */
		public function get centerLineAlpha():Number
		{
			return _centerLineAlpha;
		}
		
		public function set centerLineAlpha(value:Number):void
		{
			_centerLineAlpha = value;
		}
		
		private var _continuous:Boolean = true;
		/**
		 * Specifies whether the dial is continuous or not
		 */		
		public function get continuous():Boolean
		{
			return _continuous;
		}
		public function set continuous(value:Boolean):void 
		{			
			_continuous = value;
		}
		
		/**
		 * The <code>Dial</code> object used to filter the text values of this <code>Dial</code> based on
		 * its current selection.
		 */
		public function get filterDial():* { return _filterDial; }
		public function set filterDial(obj:*):void
		{
			if (!(obj is Dial))
				obj = CMLObjectList.instance.getId(obj.toString());
			if (obj is Dial)
			{
				_filterDial = obj;
				_filterDial.addEventListener(StateEvent.CHANGE, applyFilter);
			}
		}
		
		/**
		 * Initializes the configuration and display of dial elements
		 */
		override public function init():void
		{
			displayDial();
		}
		
		/**
		 * creats dial with text Elements.
		 */
		private function displayDial():void
		{
			matrix.createGradientBox(width, height, gradientRotation, gradientX, gradientY);
			
			background.graphics.clear();
			background.graphics.lineStyle(backgroundLineStroke, selectedTextColor, backgroundAlpha);
			background.graphics.beginGradientFill(gradientType, gradientColorArray, gradientAlphaArray, gradientRatioArray, matrix);
			background.graphics.drawRect(0, 0, width, height);
			
			var dropShadow:DropShadowFilter = new DropShadowFilter();
			var filtersArray:Array = new Array(dropShadow);
			dropShadow.color = 0x000000;
			dropShadow.blurX = 5;
			dropShadow.blurY = 5;
			dropShadow.angle = 45;
			dropShadow.alpha = 1;
			dropShadow.distance = 0.4;
			
			if(background.filters.length < 1)
				background.filters = filtersArray;
			
			leftTriangle.shape = "triangle";
			leftTriangle.height = 27;			
			leftTriangle.scale = leftTriangleScale;			
			DisplayUtils.rotateAroundCenter(leftTriangle, 90);			
			leftTriangle.color = leftTriangleColor;
			leftTriangle.alpha = leftTriangleAlpha;
			leftTriangle.lineStroke = 0;
			leftTriangle.x = leftTriangle.height * leftTriangle.scale;
			leftTriangle.y = height / 2 - leftTriangle.height * leftTriangle.scale / 2;
			
			rightTriangle.shape = "triangle";
			rightTriangle.height = 27;			
			rightTriangle.scale = rightTriangleScale;			
			DisplayUtils.rotateAroundCenter(rightTriangle, -90);			
			rightTriangle.color = rightTriangleColor;
			rightTriangle.alpha = rightTriangleAlpha;
			rightTriangle.lineStroke = 0;
			rightTriangle.x = width - rightTriangle.height * rightTriangle.scale;
			rightTriangle.y = height / 2 + rightTriangle.height*rightTriangle.scale / 2;			
			
			centerLine.graphics.clear();
			centerLine.graphics.lineStyle(centerLineLineStroke, centerLineOutlineColor, centerLineOutlineAlpha);
			centerLine.graphics.beginFill(centerLineColor, centerLineAlpha);
			centerLine.graphics.drawRect(width * 0.01, (this.height / 2) - 4, this.width * 0.98, 8);
			centerLine.graphics.endFill();
			
			mymask.graphics.clear();
			mymask.graphics.beginFill(0xFF0000);
			mymask.graphics.drawRect(0, 0, background.width - 3, background.height - 3);
			mymask.graphics.endFill();

			
			touchSprite = new TouchSprite();
			touchSprite.gestureList = {"n-drag": true};
			touchSprite.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			touchSprite.addEventListener(GWGestureEvent.COMPLETE, onEnd);			
		    touchSprite.releaseInertia = true;
			touchSprite.graphics.clear();
			touchSprite.graphics.lineStyle(0, 0);
			touchSprite.graphics.drawRect(0, 0, width, height);
			touchSprite.graphics.endFill();
			
			
			var gradAlphas:Array = [1, 0, 1];
			var gradColors:Array = [0x000000, 0xFFFFFF, 0x000000];
			
			
			var grad:Sprite	= new Sprite;	
			grad.graphics.lineStyle(0, 0);
			grad.graphics.beginGradientFill(gradientType, gradColors, gradAlphas, gradientRatioArray, matrix);
			grad.graphics.drawRect(0, 0, width, height);
				
			
			if(!(touchSprite.contains(background)))
				touchSprite.addChild(background);

			if (!(touchSprite.contains(mymask)))
				touchSprite.addChild(mymask);
			
			if (!(touchSprite.contains(centerLine)))
				touchSprite.addChild(centerLine);
				
			textContainer.mask = mymask;
			
			if(!(touchSprite.contains(textContainer)))
				touchSprite.addChild(textContainer);
				
			
			if (!(touchSprite.contains(leftTriangle)))
				touchSprite.addChild(leftTriangle);
			if (!(touchSprite.contains(rightTriangle)))
				touchSprite.addChild(rightTriangle);			
			
			
			if(!(contains(touchSprite)))
				addChild(touchSprite);
			
			maxPos = background.height;
			minPos = background.y;
			centerPos = background.height / 2;
			
			configFilters();			
			updateTextFields();
			textContainer.addChild(grad);
			onEnd();
		}
		
		private function updateTextFields():void
		{
			textFieldArray = new Array();
			
			for (var i:int = textContainer.numChildren-1; i >= 0; i--)
			{
				if (textContainer.getChildAt(i) is Text)
					textContainer.removeChildAt(i);
			}
							
			for (i = 0; i < textArray.length; i++)
			{	
				if (continuous && i == maxItemsOnScreen)
					break;	
				
				var txt:Text = new Text();
				txt.x = 20;
				txt.y = 50;
				txt.fontSize = _fontSize;
				txt.wordWrap = true;
				txt.text = textArray[i];
				txt.font = "OpenSansBold";
				textContainer.addChildAt(txt,0);
				txt.width = centerLine.width;
				txt.border = false;
				txt.height = 35;
				textSpacing = (background.height - (txt.textHeight * maxItemsOnScreen)) / (maxItemsOnScreen - 1);	
				txt.y = textSpacing * i + txt.textHeight * i;
				//trace(txt.y);
				txt.color = textColor;
				textFieldArray.push(txt);				
			}
		}
		
		/**
		 * Associates filters of the <code>filterDial</code> to this dial's values by parsing the user-defined text values. Filter assignment, means the filtered 
		 * value will not display unless its associated filter is the current value of the <code>filterDial</code>. A colon character in a String value denotes 
		 * the assignment of a filter (or multiple filters) to a value of the dial. The syntax is "filter:value" for a single filter and "filter1:filter2:value"
		 * for multiple filters. If no colon exists in the String, the value will not be filtered and always be displayed. For more complex filtering, a pipe (|) 
		 * character denotes a combination of filters. For example, given dial1 is a filter of dial2 and dial 2 is a filter of dial3, the following filter assignment 
		 * "dial1Filter|dial2Filter:value" means the specified value will not display on dial3 unless the combination of dial1 and dial2 matches the criteria.
		 */
		private function configFilters():void
		{
			if (!filterDial) return;
			
			filterMap = new Object();
			
			for each(var txt:String in textArray)
			{			
				if (txt.search(":") > -1)
				{
					var keys:Array = txt.split(":");
					var value:String = keys.pop();
					for each(var key:String in keys)
						filterMap = addFilter(filterMap, filterDial, key, value);
				}
				else
				{
					addFilter(filterMap, filterDial, NO_FILTER, txt);				
				}
			}

			processFilters(filterDial.currentString);
		}
		
		/**
		 * Maps filter to arrays of values. Parses and handles combination filters.
		 * @param   map  the filter map
		 * @param   dial  the filter dial
		 * @param	filter  the value of the <code>filterDial</code>
		 * @param	value  the value to filter
		 */
		private function addFilter(map:Object, dial:Dial, filter:String, value:String):Object
		{
			var delimter:int = filter.indexOf("|");
			var head:String = filter.substring(0, delimter);
			var tail:String = filter.substring(delimter+1);
			
			//recursively construct combination filters
			if (delimter > -1 && dial["filterDial"])
			{
				if (!map[head])
					map[head] = new Object();
				map[head] = addFilter(map[head], dial["filterDial"], tail, value);
			}
			//map values to filter assignment
			else {
				if(!map[tail])
					map[tail] = new Array();				
				map[tail].push(value);	
			}
			
			return map;
		}
		
		/**
		 * Triggered by the state change event of the <code>filterDial</code>. Applies the currently selected filter 
		 * of the <code>filterDial</code> to the text fields. Nothing changes, if the current selection is not a filter.
		 * @param	e
		 */
		private function applyFilter(e:StateEvent):void
		{
			if (!filterMap) return;		
									
			processFilters(e.value);
			updateTextFields();
			onEnd(e.id);
		}
		
		/**
		 * Searches values associated with provided key
		 * @param	key
		 */
		private function processFilters(key:String):void
		{
			textArray = new Array();
			var filters:Array = [key];
			var dial:Dial = filterDial;
			while (dial["filterDial"]) 
			{
				dial = dial.filterDial;
				filters.push(dial.currentString);
			}
				
			textArray = validValues(filterMap, filters);
			textArray = filterMap[NO_FILTER] ? textArray.concat(filterMap[NO_FILTER]) : textArray;			
		}
		
		/**
		 * Recursively evaluates filters or combination filters and returns the associated
		 * array of values.
		 * @param	map  the filter map
		 * @param	filters  the filters to evaluate
		 * @return
		 */
		private function validValues(map:Object, filters:Array):Array
		{
			var values:Array = new Array();
			
			var filter:String = filters.pop();
			if (map[filter] && map[filter] is Array)
				values =  map[filter];
			else if (map[filter])  //combination filter search
				values = validValues(map[filter], filters);
			else if (!map[filter] && filters.length)  //not a combination check the next filter
				values = validValues(map, filters);
				
			return values;
		}
		
		public var invertDrag:Boolean = false;
		
	    /**
		 * defines drag functionality for dial boundary and defines the dial mode. 
		 */
		private function gestureDragHandler(event:GWGestureEvent):void
		{
			var tf:Text;
			
			//if (textFieldArray.length < 2)
			//	return;
			
			// re-map drag data
			var dy:Number;
			
			if (invertDrag)
				dy = map(event.value.drag_dy, -20, 20, 10, -10, false, true, true);						
			else
				dy = map(event.value.drag_dy, -20, 20, -10, 10, false, true, true);			
			
		
			// stop on very small values
			var abs:Number = Math.abs(dy);			
			if (abs < 0.001) {
				//onEnd();
				//return;
			}
			
			
			// check max and min bounds
			if (!continuous) {
				if ( (textFieldArray[0].y + textFieldArray[0].height + dy > maxPos-40) || (textFieldArray[textFieldArray.length-1].y + dy < minPos+40) ) {
					return; 
				}
			} 
			
			// change position and text
			for (var j:int = 0; j < textFieldArray.length; j++)
			{
				tf = textFieldArray[j];
				
				if (continuous) {
					// drag down
					if (dy > 0) {					
						// past bottom
						if (tf.y + dy > maxPos - textSpacing) {
							var str:String = textArray.pop();
							tf.text = str;
							textArray.unshift(str);
						
							if (j == textFieldArray.length - 1)
									tf.y = textFieldArray[0].y - textSpacing - textFieldArray[0].height; // dy already added	
							else
								tf.y = textFieldArray[j + 1].y - textSpacing - textFieldArray[j + 1].height + dy;
								
						}
						else {
							tf.y += dy;
						}	
					}
					// drag up
					else if (dy < 0) {
						//past top
						if (tf.y + dy < minPos - tf.height + textSpacing) {
							textFieldArray[j].text = textArray[maxItemsOnScreen];
							textArray.push(textArray.shift());						
							
							if (j == 0)
								tf.y = textFieldArray[textFieldArray.length-1].y + textSpacing + textFieldArray[textFieldArray.length-1].height + dy;
							else
								tf.y = textFieldArray[j-1].y + textSpacing + textFieldArray[j-1].height; // dy already added								
						}
						else {
							tf.y += dy;
						}
					} 
				}
				else {
					tf.y += dy;
				} 
				
				var halfHeight:Number = textFieldArray[j].height / 2;
				
				// change color if center is within height of text field
				if ((textFieldArray[j].y + halfHeight) >= centerPos - halfHeight &&
				   (textFieldArray[j].y + halfHeight) <= centerPos + halfHeight)
					textFieldArray[j].textColor = selectedTextColor;
				else
					textFieldArray[j].textColor = textColor; 
			}
			//if (event.value.localY < minPos || event.value.localY > maxPos)
				//onEnd();
		}
		
		
		public var currentIndex:int = 0;
		public var currentString:String;		
		
		
		/**
		 * Finds the closest value and snaps to the center with change in text color
		 */
		private function onEnd(event:* = null):void
		{	
			// difference to closest and center
			var diff:Number = 0;
			var diffArray:Array = [];
			
			// absolute difference between closest and center
			var absDiff:Number = 0;
			
			// used to find closest absolute difference
			var closest:Number = 999999;
			
			// closest textfield array index
			var closestIndex:int = -1;

			// find closest textfield array index to center
			for (var i:int = 0; i < textFieldArray.length; i++)
			{				
				diff = centerPos - (textFieldArray[i].y + textFieldArray[i].height / 2);
				absDiff = Math.abs(diff);
				
				if (absDiff < closest)
				{
					closest = absDiff;
					closestIndex = i;
				}
			}
			if (j == closestIndex)
					textFieldArray[j].textColor = selectedTextColor;
				else
					textFieldArray[j].textColor = textColor;
			
			// update to closest difference from center
			diff = centerPos - (textFieldArray[closestIndex].y + textFieldArray[closestIndex].height / 2);			
			
			var tf:Text;
			
			// apply difference to all textfields
			for (var j:int=0; j < textFieldArray.length; j++)
			{
				tf = textFieldArray[j];
				
				if (continuous) {
					// snap down
					if (diff > 0) {
											
						// past bottom
						if (tf.y + diff >= maxPos - textSpacing) {
								var str:String = textArray.pop();
								tf.text = str;
								textArray.unshift(str);

							if (j == textFieldArray.length-1)
								tf.y = textFieldArray[0].y - textSpacing - textFieldArray[0].height; // dy already added
							else
								tf.y = textFieldArray[j+1].y - textSpacing - textFieldArray[j+1].height + diff;
						}
						else {
							tf.y += diff;
						}
						
					}
					
					// snap up
					else if (diff < 0) {
						
						// past top
						if (tf.y + diff <= minPos - tf.height + textSpacing) {						
							tf.text = textArray[maxItemsOnScreen];
							textArray.push(textArray.shift());						
							
							if (j == 0)
								tf.y = textFieldArray[textFieldArray.length-1].y + textSpacing + textFieldArray[textFieldArray.length-1].height + diff;
							else
								tf.y = textFieldArray[j - 1].y + textSpacing + textFieldArray[j - 1].height; // dy already added
						}  
						else {
							tf.y += diff;
						}	
					} 
				}
				else {
					//tf.y += diff;
							
					var tween:TweenLite = TweenLite.to(tf, .25, { y:(tf.y + diff) } );
					tween.play();					
				}
				
				// change color
				if (j == closestIndex)
					textFieldArray[j].textColor = selectedTextColor;
				else
					textFieldArray[j].textColor = textColor;
			}

			
			currentIndex = closestIndex;
			
			if (textFieldArray[currentIndex].text != currentString) {
				var dispatchID:String = event is String ? event : this.id;
				currentString = textFieldArray[currentIndex].text;				
				dispatchEvent(new StateEvent(StateEvent.CHANGE, dispatchID, "currentString", currentString));
			}	
		}
		
		/**
		 * maps range of values
		 */
		private function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
		 
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
		
			if (round) return Math.round(num2);
			return num2;
		}		
	
		/**
		 * @inheritDoc
		 */
		override public function dispose(): void
		{
			super.dispose();
			textFieldArray = null;
			background = null;
			leftTriangle = null;
			rightTriangle = null;
			centerLine = null;
			mymask = null;
			matrix = null;
			textContainer = null;
			touchSprite = null;
			filterMap = null;
			gradientAlphaArray = null;
			gradientColorArray = null;
			gradientRatioArray = null;
			
			if (_filterDial) _filterDial.addEventListener(StateEvent.CHANGE, applyFilter);
			_filterDial = null;
		}
		
		public function clear():void {
			while (textContainer.numChildren > 0) {
				textContainer.removeChildAt(0);
			}
		}
	}
	
}