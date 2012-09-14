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

 public function CircleText(centerX:Number, centerY:Number, radius:Number, curveText:String, coverage:Number, startAngle:Number, stopAngle:Number)
		{	

			var letters:Array = curveText.split("");
			var rotation:Number = 45;
			var degrees:Number = 180;
			var total:Number = Math.abs(startAngle - stopAngle);
			
			var step:Number = degrees * coverage / (letters.length - 1);
			step = step * Math.PI / 180;
	
			for (var s:int = 0; s < letters.length; s++)
			{
				var letter:TextElement = letter(letters[s].toString());
				letter.x = radius * Math.cos(step * s);
				letter.y = radius * Math.sin(step * s);
				letter.rotation = (step * s) * 180 / Math.PI + 90;
				this.addChild(letter);
			}
			this.x = centerX;
            this.y = centerY;
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