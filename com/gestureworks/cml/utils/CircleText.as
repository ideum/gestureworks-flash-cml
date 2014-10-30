package com.gestureworks.cml.utils
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.utils.*;
	import flash.display.*;
	import flash.text.TextFormat;
	
	/**
	 * The CircleText utility creates text in curved shape.
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 
		var c1:CircleText = new CircleText(-10, 10, 100, "MENU", 0.4, 0, 0);
		addChild(c1);
		
	 * </codeblock>
	 * 
	 * @author Ideum
	 * @see com.gestureworks.cml.elements.Text
	 * @see com.gestureworks.cml.elements.TLF
	 */
	public class CircleText extends Sprite
	{
		/**
		 * Constructor
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
				var letter:Text = createText(letters[s].toString());
				letter.x = textRadius * Math.cos(step * s);
				letter.y = textRadius * Math.sin(step * s);
				letter.rotation = (step * s) * 180 / Math.PI + 90;
				this.addChild(letter);
			}
			this.x = textX;
			this.y = textY;
			this.rotation = total - 90;
			
			
			function createText(value:String):Text
			{
				var letter:Text = new Text();
				letter.color = 0x000000;
				letter.fontSize = 25;
				letter.font = "OpenSansRegular";
				letter.embedFonts = true;
				letter.text = value;
				letter.selectable = false;
				return letter;
			}			
			
		}		
	}
}