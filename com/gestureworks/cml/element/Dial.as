package
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import com.gestureworks.core.TouchSprite;
	import flash.events.TouchEvent;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	
	/**
	 * The Dial element provides list of text elements with drag , snap and dial mode functionality.
	 * It has the following parameters: gradienttype, gradientcolors, gradientalphas, gradientratios, gradientWidth, gradientHeight, gradientX, gradientY, gradientRotation, backgroundLineStoke, backgroundAlpha, leftTriangleColor, rightTriangleColor, centerLineLineStoke, centerLineOutlineColor, centerLineOutlineAlpha, centerLineColor, centerLineAlpha,textarray, maxItemsOnScreen, textColor, selectedTextColor .
	 *
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 *
	   var dial:Dial = new Dial();
	   addChild(dial);
	   dial.x = 100;
	   dial.y = 100;
	 *
	 * </codeblock>
	 * @author Uma
	 */
	
	public class Dial extends ElementFactory
	{
		private var textarray:Array = ["Collection 1", "Collection 2", "Collection 3", "Collection 4", "Collection 5", "Collection 6", "Collection 7", "Collection 8", "Collection 9", "Collection 10"];
		private var continuous:Boolean = true;
		private var touchSprite:TouchSprite;
		private var textFieldArray:Array = new Array();
		private var textSpacing:int;
		private var minPos:Number;
		private var maxPos:Number;
		private var centerPos:Number;
		
		/**
		 * Dial constructor.
		 */
		public function Dial():void
		{
			super();
		}
		
		/**
		 * CML display initialization callback
		 */
		public override function displayComplete():void
		{
			super.displayComplete();
			init();
		}
		
		/**
		 * Defines the background which is a rectangle
		 */
		public var background:Sprite = new Sprite();
		
		/**
		 * Defines the left triangle of background
		 */
		public var leftTriangle:Sprite = new Sprite();
		
		/**
		 * Defines the right triangle of background
		 */
		public var rightTriangle:Sprite = new Sprite();
		
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
		
		private var _textColor:uint = 0x000000;
		
		/**
		 * Sets the default text Color
		 * @default = 0x000000;
		 */
		public function get textColor():uint
		{
			return _textColor;
		}
		
		public function set textColor(value:uint):void
		{
			_textColor = value;
		}
		
		private var _selectedTextColor:uint = 0xFFFFFF;
		
		/**
		 * Sets the text Color for selected text
		 * @default = 0xFFFFFF;
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
		 * @default = 5;
		 */
		public function get maxItemsOnScreen():int
		{
			return _maxItemsOnScreen;
		}
		
		public function set maxItemsOnScreen(value:int):void
		{
			_maxItemsOnScreen = value;
		}
		
		//	private var _textarray:Array = "Collection 1,Collection 2,Collection 3,Collection 4,Collection 5,Collection 6,Collection 7,Collection 8,Collection 9,Collection 10";
		/**
		 * Sets array of text elements
		 * @default = 10;
		 */ /*	public function get textarray():int
		   {
		   return _textarray;
		   }
		   public function set textarray(value:Array):void
		   {
		   _textarray = value;
		 }  */
		
		private var _gradienttype:String = GradientType.LINEAR;
		
		/**
		 * Sets the gardient type for background
		 * @default = GradientType.LINEAR;
		 */
		public function get gradienttype():String
		{
			return _gradienttype;
			displayDial();
		}
		
		public function set gradienttype(value:String):void
		{
			_gradienttype = value;
			displayDial();
		}
		
		//	private var _gradientcolors:Array = "0x111111,0xDDDDDD,0x111111";
		/**
		 * Sets the array of color values of gradient for background
		 * @default = [0x111111, 0xDDDDDD, 0x111111];
		 */ /*	public function get gradientcolors():Array
		   {
		   return _gradientcolors;
		   }
		
		   public function set gradientcolors(value:Array):void
		   {
		   value = gradientcolors.split(",");
		   _gradientcolors = value;
		   displayDial();
		 } */
		
		private var _gradientalphas:Array = [1, 1, 1];
		
		/**
		 * Sets the alpha transparency of gradient for background
		 * @default = [1, 1, 1];
		 */
		public function get gradientalphas():Array
		{
			return _gradientalphas;
		}
		
		public function set gradientalphas(value:Array):void
		{
			_gradientalphas = value;
			displayDial();
		}
		
		private var _gradientratios:Array = [0, 127.5, 255];
		
		/**
		 * Sets the ratios of gradient for background
		 * @default = [0, 127.5, 255];
		 */
		public function get gradientratios():Array
		{
			return _gradientratios;
		}
		
		public function set gradientratios(value:Array):void
		{
			_gradientratios = value;
			displayDial();
		}
		
		private var _gradientWidth:Number = 300;
		
		/**
		 * the width (in pixels) to which the gradient will spread
		 * @default = 300;
		 */
		
		public function get gradientWidth():Number
		{
			return _gradientWidth;
		}
		
		public function set gradientWidth(value:Number):void
		{
			_gradientWidth = value;
			displayDial();
		}
		
		private var _gradientHeight:Number = 200;
		
		/**
		 * the height (in pixels) to which the gradient will spread
		 * @default = 200;
		 */
		
		public function get gradientHeight():Number
		{
			return _gradientHeight;
		}
		
		public function set gradientHeight(value:Number):void
		{
			_gradientHeight = value;
			displayDial();
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
			displayDial();
		}
		
		private var _gradientY:Number = 0;
		
		/**
		 * how far (in pixels) the gradient is shifted vertically
		 * @default = 0;
		 */
		
		public function get gradientY():Number
		{
			return _gradientY;
		}
		
		public function set gradientY(value:Number):void
		{
			_gradientY = value;
			displayDial();
		}
		
		private var _gradientRotation:Number = Math.PI / 2;
		
		/**
		 * the rotation (in radians) that will be applied to the gradient
		 * @default = Math.PI / 2;
		 */
		
		public function get gradientRotation():Number
		{
			return _gradientRotation;
		}
		
		public function set gradientRotation(value:Number):void
		{
			_gradientRotation = value;
			displayDial();
		}
		
		private var _backgroundLineStoke:Number = 3;
		
		/**
		 * Sets the background Line Stoke
		 *  @default = 1;
		 */
		public function get backgroundLineStoke():Number
		{
			return _backgroundLineStoke;
		}
		
		public function set backgroundLineStoke(value:Number):void
		{
			_backgroundLineStoke = value;
			displayDial();
		}
		
		private var _backgroundAlpha:Number = 5;
		
		/**
		 * Sets the background Transparency
		 *  @default = 0;
		 */
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
			displayDial();
		}
		
		private var _leftTriangleColor:Number = 0x303030;
		
		/**
		 * Sets the left triangle color of background
		 *  @default = 0x303030;
		 */
		public function get leftTriangleColor():Number
		{
			return _leftTriangleColor;
		}
		
		public function set leftTriangleColor(value:Number):void
		{
			_leftTriangleColor = value;
			displayDial();
		}
		
		private var _leftTriangleAlpha:Number = 1;
		
		/**
		 * Sets the left triangle Transparency of background
		 *  @default = 1;
		 */
		public function get leftTriangleAlpha():Number
		{
			return _leftTriangleAlpha;
		}
		
		public function set leftTriangleAlpha(value:Number):void
		{
			_leftTriangleAlpha = value;
			displayDial();
		}
		
		private var _rightTriangleColor:Number = 0x303030;
		
		/**
		 * Sets the right triangle color of background
		 *  @default = 0x303030;
		 */
		public function get rightTriangleColor():Number
		{
			return _rightTriangleColor;
		}
		
		public function set rightTriangleColor(value:Number):void
		{
			_rightTriangleColor = value;
			displayDial();
		}
		
		private var _rightTriangleAlpha:Number = 1;
		
		/**
		 * Sets the right triangle Transparency of background
		 *  @default = 1;
		 */
		public function get rightTriangleAlpha():Number
		{
			return _rightTriangleAlpha;
		}
		
		public function set rightTriangleAlpha(value:Number):void
		{
			_rightTriangleAlpha = value;
			displayDial();
		}
		
		private var _centerLineLineStoke:Number = 1;
		
		/**
		 * Sets the center line line stroke of background
		 *  @default = 1;
		 */
		public function get centerLineLineStoke():Number
		{
			return _centerLineLineStoke;
		}
		
		public function set centerLineLineStoke(value:Number):void
		{
			_centerLineLineStoke = value;
			displayDial();
		}
		
		private var _centerLineOutlineColor:uint = 0xAAAAAAA;
		
		/**
		 * Sets the center line outline color of background
		 *  @default = 0xAAAAAAA;
		 */
		public function get centerLineOutlineColor():uint
		{
			return _centerLineOutlineColor;
		}
		
		public function set centerLineOutlineColor(value:uint):void
		{
			_centerLineOutlineColor = value;
			displayDial();
		}
		
		private var _centerLineOutlineAlpha:Number = 0.4;
		
		/**
		 * Sets the outline transparency of center line of background
		 *  @default = 0.4;
		 */
		public function get centerLineOutlineAlpha():Number
		{
			return _centerLineOutlineAlpha;
		}
		
		public function set centerLineOutlineAlpha(value:Number):void
		{
			_centerLineOutlineAlpha = value;
			displayDial();
		}
		
		private var _centerLineColor:uint = 0x666666;
		
		/**
		 * Sets the center line color of background
		 *  @default = 0x666666;
		 */
		public function get centerLineColor():uint
		{
			return _centerLineColor;
		}
		
		public function set centerLineColor(value:uint):void
		{
			_centerLineColor = value;
			displayDial();
		}
		
		private var _centerLineAlpha:Number = 0.2;
		
		/**
		 * Sets the center line transparency of background
		 *  @default = 0.2;
		 */
		public function get centerLineAlpha():Number
		{
			return _centerLineAlpha;
		}
		
		public function set centerLineAlpha(value:Number):void
		{
			_centerLineAlpha = value;
			displayDial();
		}
		
		/**
		 * Initializes the configuration and display of dial elements
		 */
		public function init():void
		{
			displayDial();
		}
		
		/**
		 * creats dial with text Elements.
		 */
		private function displayDial():void
		{
			var gradientcolors:Array = [0x111111, 0xDDDDDD, 0x111111];
			matrix.createGradientBox(gradientWidth, gradientHeight, gradientRotation, gradientX, gradientY);

			background.graphics.lineStyle(backgroundLineStoke, backgroundAlpha);
			background.graphics.beginGradientFill(gradienttype, gradientcolors, gradientalphas, gradientratios, matrix);
			background.graphics.drawRect(0, 0, 300, 200);

			leftTriangle.graphics.beginFill(leftTriangleColor, leftTriangleAlpha);
			leftTriangle.graphics.moveTo(0, 80);
			leftTriangle.graphics.lineTo(20, 100);
			leftTriangle.graphics.lineTo(0, 120);
			leftTriangle.graphics.endFill();

			rightTriangle.graphics.beginFill(rightTriangleColor, rightTriangleAlpha);
			rightTriangle.graphics.moveTo(300, 80);
			rightTriangle.graphics.lineTo(280, 100);
			rightTriangle.graphics.lineTo(300, 120);
			rightTriangle.graphics.endFill();

			centerLine.graphics.lineStyle(centerLineLineStoke, centerLineOutlineColor, centerLineOutlineAlpha);
			centerLine.graphics.beginFill(centerLineColor, centerLineAlpha);
			centerLine.graphics.drawRect(15, 96, 270, 8);
			centerLine.graphics.endFill();

			mymask.graphics.beginFill(0xFF0000);
			mymask.graphics.drawRect(0, 0, background.width - 3, background.height - 3);
				
			touchSprite = new TouchSprite();
			touchSprite.gestureList = {"n-drag": true};
			touchSprite.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			touchSprite.gestureReleaseInertia = true;
			touchSprite.addEventListener(GWGestureEvent.COMPLETE, onEnd);
			touchSprite.addEventListener(TouchEvent.TOUCH_END, onEnd);
			
			touchSprite.addChild(background);
			touchSprite.addChild(centerLine);
			touchSprite.addChild(leftTriangle);
			touchSprite.addChild(rightTriangle);
			touchSprite.addChild(mymask);
			
			for (var i:int = 0; i < textarray.length; i++)
			{
				if (continuous && i == maxItemsOnScreen)
					break;
				
				var txt:TextElement = new TextElement();
				txt.x = 20;
				txt.y = 50;
				txt.fontSize = 20;
				txt.wordWrap = true;
				txt.text = textarray[i];
				txt.font = "OpenSansBold";
				textContainer.addChild(txt);
				txt.width = centerLine.width;
				txt.border = false;
				txt.autoSize = "left";
				textSpacing = (background.height - (txt.height * maxItemsOnScreen)) / (maxItemsOnScreen - 1);
				txt.y = textSpacing * i + txt.height * i;
				txt.color = textColor;
				textFieldArray.push(txt);
			}
			
			textContainer.mask = mymask;
			
			touchSprite.addChild(textContainer);
			addChild(touchSprite);
			
			maxPos = background.height;
			minPos = background.y;
			centerPos = background.height / 2;
		}
		
		/**
		 * defines dial boundary for drag functionality and defines the dial mode.
		 */
		private function gestureDragHandler(event:GWGestureEvent):void
		{
			var tf:TextElement;
			var dy:Number = map(event.value.dy, -20, 20, -10, 10, false, true, true);
			var abs:Number = Math.abs(dy);
			if (abs < 0.001)
			{
				onEnd();
				return;
			}

			if (!continuous)
			{
				if ((textFieldArray[0].y + textFieldArray[0].height + dy > maxPos) || (textFieldArray[textFieldArray.length - 1].y + dy < minPos))
					return;
			}

			for (var j:int = 0; j < textFieldArray.length; j++)
			{
				tf = textFieldArray[j];
				
				if (continuous)
				{
					if (dy > 0)
					{
						if (tf.y + dy > maxPos - textSpacing)
						{
							var str:String = textarray.pop();
							tf.text = str;
							textarray.unshift(str);
							
							if (j == textFieldArray.length - 1)
								tf.y = textFieldArray[0].y - textSpacing - textFieldArray[0].height; // dy already added	
							else
								tf.y = textFieldArray[j + 1].y - textSpacing - textFieldArray[j + 1].height + dy;
						}
						else
						{
							tf.y += dy;
						}
					}
					else if (dy < 0)
					{
						if (tf.y + dy < minPos - tf.height + textSpacing)
						{
							textFieldArray[j].text = textarray[maxItemsOnScreen];
							textarray.push(textarray.shift());
							
							if (j == 0)
								tf.y = textFieldArray[textFieldArray.length - 1].y + textSpacing + textFieldArray[textFieldArray.length - 1].height + dy;
							else
								tf.y = textFieldArray[j - 1].y + textSpacing + textFieldArray[j - 1].height; // dy already added								
						}
						else
						{
							tf.y += dy;
						}
					}
				}
				else
				{
					tf.y += dy;
				}
				
				var halfHeight:Number = textFieldArray[j].height / 2;

				if ((textFieldArray[j].y + halfHeight) >= centerPos - halfHeight && (textFieldArray[j].y + halfHeight) <= centerPos + halfHeight)
					textFieldArray[j].textColor = selectedTextColor;
				else
					textFieldArray[j].textColor = textColor;
			}
			if (event.value.localY < minPos || event.value.localY > maxPos)
				onEnd();
		}
		
		/**
		 * Finds the closest value and snaps to the center with change in text color
		 */
		private function onEnd(event:* = null):void
		{
			var diff:Number = 0;
			var diffArray:Array = [];

			var absDiff:Number = 0;
			
			var closest:Number = 999999;
			
			var closestIndex:int = -1;
			
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

			diff = centerPos - (textFieldArray[closestIndex].y + textFieldArray[closestIndex].height / 2);
			
			var tf:TextElement;
			
			for (var j:int = 0; j < textFieldArray.length; j++)
			{
				tf = textFieldArray[j];
				
				if (continuous)
				{
					if (diff > 0)
					{
						
						if (tf.y + diff >= maxPos - textSpacing)
						{
							var str:String = textarray.pop();
							tf.text = str;
							textarray.unshift(str);
							
							if (j == textFieldArray.length - 1)
								tf.y = textFieldArray[0].y - textSpacing - textFieldArray[0].height; // dy already added
							else
								tf.y = textFieldArray[j + 1].y - textSpacing - textFieldArray[j + 1].height + diff;
						}
						else
						{
							tf.y += diff;
						}
						
					}
					
					else if (diff < 0)
					{
						
						if (tf.y + diff <= minPos - tf.height + textSpacing)
						{
							tf.text = textarray[maxItemsOnScreen];
							textarray.push(textarray.shift());
							
							if (j == 0)
								tf.y = textFieldArray[textFieldArray.length - 1].y + textSpacing + textFieldArray[textFieldArray.length - 1].height + diff;
							else
								tf.y = textFieldArray[j - 1].y + textSpacing + textFieldArray[j - 1].height; // dy already added
						}
						else
						{
							tf.y += diff;
						}
					}
				}
				else
				{
					tf.y += diff;
				}

				if (j == closestIndex)
					textFieldArray[j].textColor = selectedTextColor;
				else
					textFieldArray[j].textColor = textColor;
			}
		}
		
		/**
		 * maps
		 */
		private function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1)
				return min2;
			if (constrainMax && num > max1)
				return max2;
			
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			
			if (round)
				return Math.round(num2);
			return num2;
		}
	
	}

}