package com.gestureworks.cml.utils
{
	import flash.display.*;
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.factories.*;
	import com.gestureworks.cml.utils.*;
	import flash.text.*;
    
	/**
	 * CircleText defines the text in curve shape.
	 * @author Uma
	 */
		
 public class CircleText extends ElementFactory
	{

		/**
		 * constructor
		 * @param	textX x position of text
		 * @param	textY y position of text
		 * @param	textRadius radius of the text
		 * @param	curveText name of the text
		 * @param	coverage coverage area of the text
		 * @param	startAngle start angle of the text
		 * @param	stopAngle stop angle of the text
		 */
 public function CircleText(textX:Number, textY:Number, textRadius:Number, curveText:String, coverage:Number, startAngle:Number, stopAngle:Number)
		{	

			var letters:Array = curveText.split("");
			var rotation:Number = 200;
			var degrees:Number = 180;
			var total:Number = Math.abs(startAngle - stopAngle);
			
			var step:Number = degrees * coverage / (letters.length - 1);
			step = step * Math.PI / 180;
	
			for (var s:int = 0; s < letters.length; s++)
			{
				var letter:TextElement = letter(letters[s].toString());
				letter.x = textRadius * Math.cos(step * s);
				letter.y = textRadius * Math.sin(step * s);
				letter.rotation = (step * s) * 180 / Math.PI + 90;
				this.addChild(letter);
			}
			this.x = textX;
            this.y = textY;
			this.rotation = total - 90;
		}

		/**
		 * return letter.
		 */
		private function letter(value:String):TextElement
		{
			var format:TextFormat = new TextFormat();
			var letter:TextElement = new TextElement();
			format.color = 0x000000;
			format.size = 25;
			format.font = "ArialFont";
			letter.defaultTextFormat = format;
			letter.embedFonts = true;
			letter.text = value;
			letter.selectable = false;
			return letter;
		}
	}
}