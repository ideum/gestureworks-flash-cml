package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class GraphicElement extends GraphicFactory
	{
		
		public function GraphicElement() 
		{			
			super();
			layoutUI();

		}		
		
		override protected function layoutUI():void
		{	
			graphics.clear();
			
			if (lineStroke > 0)
			{				
				graphics.lineStyle(lineStroke, lineColor, lineAlpha, linePixelHinting, _lineScaleMode, _lineCaps, _lineJoints, _lineMiterLimit);			

				if (line == "gradient")
				{	
					matrix = new Matrix;
					matrix.createGradientBox(lineGradientWidth, lineGradientHeight, _lineGradientRotation, lineGradientX, lineGradientY);			
					graphics.lineGradientStyle(_lineGradientType, lineGradientColorArray, lineGradientAlphaArray, lineGradientRatioArray, 
						matrix, _lineGradientSpread, _lineGradientInterpolation, lineGradientFocalPointRatio);
					matrix = null;						
				}
			}
			
			
			// fills
			// currently "color" for solid color and "gradient"
			// TODO: implement bitmap and shader fills
			
			switch(fill)
			{
				case "none":
				{
					break;
				}
				
				case "color":
				{
					graphics.beginFill(color, fillAlpha);		
					break;
				}
				case "gradient":
				{
					matrix = new Matrix;
					matrix.createGradientBox(gradientWidth, gradientHeight, _gradientRotation, gradientX, gradientY);			
					graphics.beginGradientFill(_gradientType, gradientColorArray, gradientAlphaArray, gradientRatioArray, 
						matrix, _gradientSpread, _gradientInterpolation, gradientFocalPointRatio);
					matrix = null;					
					break;
				}					
				default: //color
				{
					graphics.beginFill(color, fillAlpha);		
					break;
				}
			}
			
			
			// shapes
			// add custom shapes here
			// TODO: path type as ordered string list
			
			switch(shape)
			{
				
				case "vector":
					{
						// for lines that a niether horizontal nor vertical
						graphics.lineTo(width, height);
						break;
					}
				
				case "line":
				{
					// setting width makes horizontal line
					// setting height makes vertical line
					
					if (width > height)
						graphics.lineTo(width, 0);
					else	
						graphics.lineTo(0, height);
					
					break;	
				}
					
				case "rectangle":
				{
					//trace(width, height);
					
					graphics.drawRect(0, 0, width, height);
					break;
				}
				
				case "roundRectangle":
				{
					graphics.drawRoundRect(0, 0, width, height, cornerWidth, cornerHeight);
					break;
				}
				
				case "circle":
				{
					graphics.drawCircle(radius, radius, radius);
					break;
				}
				
				case "ellipse":
				{
					graphics.drawEllipse(0, 0, width, height);
					break;
				}
				
				default:
				{
					// makes line unless radius is specified (makes circle), and
					// if width and height are specifed then makes square
					
					if (radius == 0 && width > 0 && height > 0) 
						graphics.drawRect(0, 0, width, height);
					else if (radius > 0) 
						graphics.drawCircle(0, 0, radius);
					else 
						graphics.lineTo(0, height);
					
					break;
				}					
			}			
		
			
			// end fill
			graphics.endFill();			
			dispatchEvent(new Event(Event.COMPLETE));
		}
				

	}
}