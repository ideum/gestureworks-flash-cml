package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;

	/**
	 * The graphic element can draw many types of graphic types. It
	 * supports most of the properties of the AS3 Graphics class.
	 * 
	 * It supports the following shapes:
	 * <ul>
	 * 	<li>vector</li>
	 * 	<li>line</li>
	 * 	<li>rectangle</li>
	 * 	<li>roundRectangle</li>
	 * 	<li>roundRectangleComplex</li>
	 * 	<li>circle</li>
	 * 	<li>ellipse</li>
	 * 	<li>path</li>
	 * 	<li>triangle</li>
	 * 	<li>curve</li>
	 * </ul>
	 * 
	 * It supports the following fill types:
	 * <ul>
	 * 	<li>none</li>
	 * 	<li>color</li>
	 * 	<li>gradient</li>
	 * </ul>
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock "> 
		
		var g:Graphic = new Graphic();
		g.fill = "color";
		g.color = 0xFF0000;
		g.x = 100;
		g.y = 100;
		g.shape = "ellipse";
		g.width = 100;
		g.height = 50;
		addChild(g);
		
	 *	</codeblock> 
	 * 
	 * @author Ideum
	 */
	public class Graphic extends GraphicFactory
	{
		
		/**
		 * Constructor
		 */
		public function Graphic() 
		{			
			super();
		}		
		
		/**
		 * CML display callback Initialisation
		 */
		override public function displayComplete():void
		{			
			init();
		}
		
		/**
		 * Initialisation method
		 */
		public function init():void
		{ 
			updateGraphic();
		}
		
		/**
		 * Dispose method
		 */
		override public function dispose():void
		{
			super.dispose();
			matrix = null;
		}
		
		/**
		 * Graphics drawing method
		 */
		override public function updateGraphic():void
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
					graphics.drawRect(0, 0, width, height);
					break;
				}
				
				case "roundRectangle":
				{
					graphics.drawRoundRect(0, 0, width, height, cornerWidth, cornerHeight);
					break;
				}
				
				case "roundRectangleComplex":
				{
					graphics.drawRoundRectComplex(0, 0, width, height, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius); 	
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
				
				case "path":
				{
		            graphics.drawPath(pathCommandsVector, pathCoordinatesVector); 
					break;
				}
				
				case "triangle":
				{
		   			graphics.moveTo(height/2, 0);
                    graphics.lineTo(height, height);
                    graphics.lineTo(0, height);
                    graphics.lineTo(height/2, 0);
					break;
				}
				
				case "curve":
				{   
					graphics.moveTo(startX, startY);
					graphics.curveTo(controlX, controlY, anchorX, anchorY);
					break;
				}
				
				default:
				{
					// makes line unless radius is specified (makes circle), and
					// if width and height are specifed then makes rectangle
					
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