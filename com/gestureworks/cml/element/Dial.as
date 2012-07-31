package
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.*;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	
	public class Dial extends ElementFactory
	{
		private var array:Array = ["Collection 1", "Collection 2", "Collection 3", "Collection 4", "Collection 5", "Collection 6", "Collection 7", "Collection 8"];
		private var continuous:Boolean = false;
		private var mymask:Sprite;
		private var touchSprite:TouchSprite;
		private var textFieldArray:Array = new Array();		
		private var textSpacing:int;
		private var minPos:Number;		
		private var maxPos:Number;
		private var centerPos:Number;
		private var maxItemsOnScreen:int = 5;
		
		private var textColor:uint = 0x222222;
		private var selectedTextColor:uint = 0x000000;
		
		public function Dial():void
		{
			super();
			init();
		}
		
		private function init():void
		{
			displayDial();
		}
		
		private function displayDial():void
		{
			var type:String = GradientType.LINEAR;
			var colors:Array = [0x111111, 0xDDDDDD, 0x111111];
			var alphas:Array = [1, 1, 1];
			var ratios:Array = [0, 127.5, 255];
			
			var matrix:Matrix = new Matrix();
			var boxWidth:Number = 300;
			var boxHeight:Number = 200;
			var boxRotation:Number = Math.PI / 2;
			var tx:Number = 25;
			var ty:Number = 0;
			matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty);
			
			var square:Sprite = new Sprite;
			square.graphics.lineStyle(3, 0);
			square.graphics.beginGradientFill(type, colors, alphas, ratios, matrix);
			square.graphics.drawRect(0, 0, 300, 200);
			
			var triangle1:Sprite = new Sprite();
			triangle1.graphics.beginFill(0x303030, 1);
			triangle1.graphics.moveTo(0, 80);
			triangle1.graphics.lineTo(20, 100);
			triangle1.graphics.lineTo(0, 120);
			triangle1.graphics.endFill();
			
			var triangle2:Sprite = new Sprite();
			triangle2.graphics.beginFill(0x303030, 1);
			triangle2.graphics.moveTo(300, 80);
			triangle2.graphics.lineTo(280, 100);
			triangle2.graphics.lineTo(300, 120);
			triangle2.graphics.endFill();
			
			var shape:Sprite = new Sprite();
			shape.graphics.lineStyle(1, 0xAAAAAAA, .4);
			shape.graphics.beginFill(0x666666, .2);
			shape.graphics.drawRect(15, 96, 270, 8);
			shape.graphics.endFill();
			
			mymask = new Sprite();
			mymask.graphics.beginFill(0xFF0000);
			mymask.graphics.drawRect(0, 0, square.width - 3, square.height - 3);
			
			var textContainer:Sprite = new Sprite();
			
			touchSprite = new TouchSprite();
			touchSprite.gestureList = {"n-drag": true};
			touchSprite.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
			touchSprite.gestureReleaseInertia = true;
			touchSprite.addEventListener(GWGestureEvent.COMPLETE, onEnd);
			//touchSprite.addEventListener(TouchEvent.TOUCH_END, onEnd);
			//touchSprite.addEventListener(MouseEvent.MOUSE_UP, onEnd);
			
			touchSprite.addChild(square);
			touchSprite.addChild(shape);
			touchSprite.addChild(triangle1);
			touchSprite.addChild(triangle2);
			touchSprite.addChild(mymask);
				
			for (var i:int = 0; i < array.length; i++)
			{	
				if (continuous && i == maxItemsOnScreen)
					break;	
				
				var txt:TextElement = new TextElement();
				txt.x = 20;
				txt.y = 50;
				txt.fontSize = 20;
				txt.wordWrap = true;
				txt.text = array[i];
				txt.font = "OpenSansBold";
				textContainer.addChild(txt);
				txt.width = shape.width;
				txt.border = false;
				txt.autoSize = "left";
				textSpacing = (square.height - (txt.height * maxItemsOnScreen)) / (maxItemsOnScreen - 1);				
				txt.y = textSpacing * i + txt.height * i ;
				txt.color = textColor;
				textFieldArray.push(txt);				
			}

			textContainer.mask = mymask;
			
			touchSprite.addChild(textContainer);
			addChild(touchSprite);
			
			maxPos = square.height;
			minPos = square.y;
			centerPos = square.height / 2;
		}
	
		
		private function gestureDragHandler(event:GWGestureEvent):void
		{
			var tf:TextElement;
			
			// re-map drag data
			var dy:Number = map(event.value.dy, -20, 20, -10, 10, false, true, true);			
			
			// stop on very small values
			var abs:Number = Math.abs(dy);			
			if (abs < 0.001) {
				onEnd();
				return;
			}
			
			// check max and min bounds
			if (!continuous) {
				if ( (textFieldArray[0].y+textFieldArray[0].height + dy > maxPos) || (textFieldArray[textFieldArray.length-1].y + dy < minPos) )
					return;
			}
			
			// change position and text
			for (var j:int = 0; j < textFieldArray.length; j++)
			{
				tf = textFieldArray[j];
				
				if (continuous) {
					// drag down
					if (dy > 0) {					
						// past bottom
						if (tf.y + dy > maxPos - 8) {
							var str:String = array.pop();
							tf.text = str;
							array.unshift(str);
							
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
						if (tf.y + dy < minPos - tf.height + 8) {
							textFieldArray[j].text = array[maxItemsOnScreen];
							array.push(array.shift());						
							
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
		}
		
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

			// update to closest difference from center
			diff = centerPos - (textFieldArray[closestIndex].y + textFieldArray[closestIndex].height / 2);			
			
			var tf:TextElement;
			
			// apply difference to all textfields
			for (var j:int=0; j < textFieldArray.length; j++)
			{
				tf = textFieldArray[j];
				
				if (continuous) {
					// snap down
					if (diff > 0) {
											
						// past bottom
						if (tf.y + diff >= maxPos - 8) {
								var str:String = array.pop();
								tf.text = str;
								array.unshift(str);

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
						if (tf.y + diff <= minPos - tf.height + 8) {						
							tf.text = array[maxItemsOnScreen];
							array.push(array.shift());						
							
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
					tf.y += diff;
				}
				
				// change color
				if (j == closestIndex)
					textFieldArray[j].textColor = selectedTextColor;
				else
					textFieldArray[j].textColor = textColor;
			}
		}
		

		private function map(num:Number, min1:Number, max1:Number, min2:Number, max2:Number, round:Boolean = false, constrainMin:Boolean = true, constrainMax:Boolean = true):Number
		{
			if (constrainMin && num < min1) return min2;
			if (constrainMax && num > max1) return max2;
		 
			var num1:Number = (num - min1) / (max1 - min1);
			var num2:Number = (num1 * (max2 - min2)) + min2;
			if (round) return Math.round(num2);
			return num2;
		}				
		
	}
	
}