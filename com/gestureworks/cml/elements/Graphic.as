package com.gestureworks.cml.elements 
{	
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.utils.CloneUtils;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	

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
	public class Graphic extends TouchContainer
	{
		/**
		 * Constructor
		 */
		public function Graphic() 
		{ 
			super();
			mouseChildren = true;
		}
		
		/**
		 * Initialisation method
		 */
		override public function init():void
		{ 
			updateGraphic();
		}		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			matrix = null;
			lineGradientAlphaArray = null;
			lineGradientColorArray = null;
			lineGradientRatioArray = null;
			pathCommandsVector = null;
			pathCoordinatesVector = null;
		}
		
		
		/**
		 * Graphics drawing method
		 */
		public function updateGraphic():void
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
				
				case "circleSegment":
				{
					drawCircleSector();
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
		}
		
		private function drawCircleSector():void
		{	
			var angle:Number = startAngle;
			
			var numOfSegs:Number = Math.ceil(Math.abs(angleLength) / 45.0);
			var segmentAngle:Number = -angleLength / numOfSegs;
			segmentAngle = clockwise ? -segmentAngle : segmentAngle;
            
			// Convert angles to radians
			var pi:Number = Math.PI;
			angle = (angle / 180.0) * pi;
			segmentAngle = (segmentAngle / 180.0) * pi;
            
			var offset:Number = radius;
			
			graphics.beginFill(color);
			
			var initialInnerPointX:Number = Math.cos(angle) * innerRadius + offset;
			var initialInnerPointY:Number = Math.sin(angle) * innerRadius + offset;
			
			graphics.moveTo(initialInnerPointX, initialInnerPointY);
			graphics.lineTo(Math.cos(angle) * radius + offset, 
							Math.sin(angle) * radius + offset);
			
			var i:int;
			for (i = 0; i < numOfSegs; i++) 
			{
				angle += segmentAngle;
				drawCircleSegment(angle, segmentAngle, radius, offset);
			}
            
			graphics.lineTo(Math.cos(angle) * innerRadius + offset,
							Math.sin(angle) * innerRadius + offset);
							
			for (i = 0; i < numOfSegs; i++) 
			{
            	angle -= segmentAngle;
				drawCircleSegment(angle, -segmentAngle, innerRadius, offset);
            }
							
			graphics.lineTo(initialInnerPointX, initialInnerPointY);
			graphics.endFill();
		}
		
		private function drawCircleSegment(angle:Number, segmentAngle:Number, arcRadius:Number, offset:Number):void
		{
			var angleMid:Number;
			var anchorX:Number;
			var anchorY:Number;
			var controlX:Number;
			var controlY:Number;
			var midPoint:Number;
		
			angleMid = angle - (segmentAngle / 2);
			midPoint = arcRadius / Math.cos(segmentAngle / 2);
			anchorX = Math.cos(angle) * arcRadius + offset;
			anchorY = Math.sin(angle) * arcRadius + offset;
			controlX = Math.cos(angleMid) * midPoint + offset;
			controlY = Math.sin(angleMid) * midPoint + offset;
			graphics.curveTo(controlX, controlY, anchorX, anchorY);
		}
		
		/**
		 * Returns clone of self
		 */
		override public function clone():* 
		{
			var clone:Graphic = CloneUtils.clone(this, this.parent);
			clone.updateGraphic();
			return clone;
		}
		
		
		// matrix, currently using for gradients
		// can also use for bitmap and shader fills
		// see: http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7dd7.html
		protected var matrix:Matrix;
		

		
		//////////////////////
		// WIDTH AND HEIGHT //
		//////////////////////
		
		
		
		protected var _width:Number=0;
		/**
		 * Sets graphics width.
		 * @default 0
		 */		
		override public function get width():Number{return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			updateGraphic();
		}
		
		
		protected var _height:Number=0;
		/**
		 * Sets graphics height.
		 * @default 0
		 */			
		override public function get height():Number{return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
			updateGraphic();
		}
		
		/**
		 * Sets the width relative to the parent container.
		 */
		override public function get widthPercent():Number { return super.widthPercent; }
		override public function set widthPercent(value:Number):void
		{
			super.widthPercent = value;
			updateGraphic();
		}
		
		/**
		 * Sets the height relative to the parent container.
		 */
		override public function get heightPercent():Number { return super.heightPercent; }
		override public function set heightPercent(value:Number):void
		{
			super.heightPercent = value;
			updateGraphic();
		}			
		
       		
		///////////////////////////////
		// LINE TYPES AND PROPERTIES //
		///////////////////////////////
		
		private var _line:String = "color";
		/**
		 * Sets line type, choose: color, gradient
		 * todo: implement shader and bitmap lines
		 * @default color
		 */		
		public function get line():String { return _line; }
		public function set line(value:String):void 
		{ 
			_line = value;
			updateGraphic();			
		}		
		
		
		private var _lineStroke:Number = 0;
		/**
		 * Sets the width of the line stroke (in pixels)
		 * @default 0
		 */		
		public function get lineStroke():Number{return _lineStroke;}
		public function set lineStroke(value:Number):void
		{
			_lineStroke = value;
			updateGraphic();
		}
		
		
		private var _linePixelHinting:Boolean = false;
		/**
		 * Specifies whether to hint strokes to full pixels. 
		 * This affects both the position of anchors of a curve and the line stroke size itself. 
		 * With pixelHinting set to true, line widths are adjusted to full pixel widths. 
		 * With pixelHinting set to false, disjoints can appear for curves and straight lines. 
		 * Note: Not supported in Flash Lite 4 
		 * @default false 
		 */		
		public function get linePixelHinting():Boolean { return _linePixelHinting; }
		public function set linePixelHinting(value:Boolean):void 
		{ 
			_linePixelHinting = value;
			updateGraphic();			
		}
		
		
		protected var _lineScaleMode:String = LineScaleMode.NORMAL;
		/**
		 * Specifies how the line stroke size changes when graphic is scaled
		 * Choose: normal, none, or vertical
		 * 
		 * normal - Always scale the line thickness when the object is scaled (the default).
		 * none - Never scale the line thickness.
		 * horizontal - Do not scale the line thickness if the object is scaled horzontal only. 
		 * vertical - Do not scale the line thickness if the object is scaled vertically only. 
		 * @default normal 
		 */		
		public function get lineScaleMode():String 
		{ 
			switch(_lineScaleMode)
			{
				case LineScaleMode.NONE: return "none";
				case LineScaleMode.HORIZONTAL: return "horizontal";
				case LineScaleMode.VERTICAL: return "vertical";
				default: return "normal"; 
			}
		}
		public function set lineScaleMode(value:String):void 
		{ 
			switch(value)
			{
				case "none": _lineScaleMode = LineScaleMode.NONE;
				case "horizontal": _lineScaleMode = LineScaleMode.HORIZONTAL;
				case "vertical": _lineScaleMode = LineScaleMode.VERTICAL;
				default: _lineScaleMode = LineScaleMode.NORMAL; 
			}
			updateGraphic();				
		}
		
		
		
		protected var _lineCaps:String = CapsStyle.NONE;
		/**
		 * Specifies the type of cap on the line ends
		 * Choose: none, round, or square
		 *
		 * @default none 
		 */		
		public function get lineCaps():String 
		{ 
			switch(_lineCaps)
			{
				case CapsStyle.ROUND: return "round";
				case CapsStyle.SQUARE: return "square";
				default: return "none"; 
			}
		}
		public function set lineCaps(value:String):void 
		{ 
			switch(value)
			{
				case "round": _lineCaps = CapsStyle.ROUND;
				case "square": _lineCaps = CapsStyle.SQUARE;
				default: _lineCaps = CapsStyle.NONE; 
			}
			updateGraphic();						
		}
		
		
		protected var _lineJoints:String = JointStyle.MITER;
		/**
		 * Specifies the type of joint on the line ends
		 * Choose: miter, round, or bevel
		 *
		 * @default miter 
		 */		
		public function get lineJoints():String 
		{ 
			switch(_lineJoints)
			{
				case JointStyle.ROUND: return "round";
				case JointStyle.BEVEL: return "bevel";
				default: return "miter"; 
			}
		}
		public function set lineJoints(value:String):void 
		{ 
			switch(value)
			{
				case "round": _lineJoints = JointStyle.ROUND;
				case "bevel": _lineJoints = JointStyle.BEVEL;
				default: _lineJoints = JointStyle.MITER; 
			}
			updateGraphic();						
		}		
		
		
		protected var _lineMiterLimit:Number = 3;
		/**
		 * Specifies the limit at which the miter is cut off
		 * @default 3 
		 */		
		public function get lineMiterLimit():Number { return _lineMiterLimit; }
		public function set lineMiterLimit(value:Number):void 
		{ 
			_lineMiterLimit = value; 
			updateGraphic();									
		}
		
		
		
		//////////////////////
		// LINE TYPE: COLOR //
		//////////////////////		
		
		private var _lineColor:uint = 0xFFFFFF;
		/**
		 * Sets the color of the line 
		 * Line type must be color
		 * @default 0xFFFFFF 
		 */		
		public function get lineColor():uint{return _lineColor;}
		public function set lineColor(value:uint):void
		{
			_lineColor = value;
			updateGraphic();
		}
		
		
		private var _lineAlpha:Number = 1;
		/**
		 * Sets the alpha of the line
		 * @default 1
		 */		
		public function get lineAlpha():Number{return _lineAlpha;}
		public function set lineAlpha(value:Number):void
		{
			_lineAlpha = value;
			updateGraphic();
		}
		
		
		
		/////////////////////////
		// LINE TYPE: GRADIENT //
		/////////////////////////
		
		protected var _lineGradientType:String = GradientType.LINEAR;		
		/**
		 * Sets lineGradient type when line type is gradient.
		 * Choose: linear or radial 
		 */		
		public function get lineGradientType():String 
		{ 
			if (_lineGradientType == GradientType.RADIAL)
				return "radial";			
			return "linear"; 
		}
		public function set lineGradientType(value:String):void 
		{ 			
			if (value == "radial")
				_lineGradientType = GradientType.RADIAL;
			else
				_lineGradientType = GradientType.LINEAR;
			updateGraphic();
		}
		
		
		protected var lineGradientColorArray:Array = [0x333333, 0xAAAAAA];
		private var _lineGradientColors:String = "0x333333, 0xAAAAAA";
		/**
		 * Sets lineGradient colors when line type is gradient
		 * Ordered list, max 12 (ex: 0x000000, 0x555555, 0xFFFFFF)
		 * @default 0x333333, 0xAAAAAA
		 */		
		public function get lineGradientColors():String { return _lineGradientColors; }
		public function set lineGradientColors(value:String):void 
		{ 
			_lineGradientColors = value;
			lineGradientColorArray = _lineGradientColors.split(",")
			updateGraphic();
		}
		
		
		protected var lineGradientAlphaArray:Array = [1, 1];
		private var _lineGradientAlphas:String = "1, 1";		
		/**
		 * Sets lineGradient alphas when line type is gradient
		 * Alpha values corespond to the colors in the gradient color list
		 * Ordered list, max 12 (ex: 1, 1, 1)
		 * @default 1, 1
		 */			
		public function get lineGradientAlphas():String { return _lineGradientAlphas; }
		public function set lineGradientAlphas(value:String):void 
		{ 
			_lineGradientAlphas = value;
			lineGradientAlphaArray = _lineGradientAlphas.split(",")			
			updateGraphic();
		}
		
		
		protected var lineGradientRatioArray:Array = [0, 255];
		private var _lineGradientRatios:String = "0, 255";		
		/**
		 * Color distribution ratios; valid values are 0-255. 
		 * This value defines the percentage of the width where the color is sampled at 100%. 
		 * The value 0 represents the left position in the gradient box, 
		 * and 255 represents the right position in the gradient box.
		 * 
		 * Line type must be gradient.
		 * 
		 * The values must increase sequentially; for example, "0, 63, 127, 190, 255".
		 * Ordered list, (ex: 0, 255)
		 * @default 0, 255
		 */		
		public function get lineGradientRatios():String { return _lineGradientRatios; }
		public function set lineGradientRatios(value:String):void 
		{ 
			_lineGradientRatios = value;
			lineGradientRatioArray = _lineGradientRatios.split(",")						
			updateGraphic();
		}
		

		private var _lineGradientWidth:Number = 100;		
		/**
		 * Sets the width (in pixels) to which the gradient will spread. 
		 * Line type must be gradient.
		 * @default 100
		 */		
		public function get lineGradientWidth():Number { return _lineGradientWidth; }
		public function set lineGradientWidth(value:Number):void 
		{ 
			_lineGradientWidth = value; 
			updateGraphic();
		}
		
		
		private var _lineGradientHeight:Number = 100;
		/**
		 * The height (in pixels) to which the gradient will spread. 
		 * Line type must be lineGradient.
		 * @default 100
		 */			
		public function get lineGradientHeight():Number { return _lineGradientHeight; }
		public function set lineGradientHeight(value:Number):void 
		{ 
			_lineGradientHeight = value;
			updateGraphic();
		}
		
		
		protected var _lineGradientRotation:Number = 0; //holds value in radians
		/**
		 * Sets the rotation (in degrees) that will be applied to the gradient.
		 * Line type must be lineGradient.
		 * @default 0
		 */			
		public function get lineGradientRotation():Number 
		{ 
			return _lineGradientRotation*180/Math.PI; //convert radians to degrees
		}
		public function set lineGradientRotation(value:Number):void 
		{ 			
			_lineGradientRotation = value*Math.PI/180; //convert degrees to radians
			updateGraphic();
		}
		
		
		private var _lineGradientX:Number = 0;
		/**
		 * Sets how far (in pixels) the gradient is shifted horizontally. 
		 * Line type must be lineGradient.
		 * @default 0
		 */			
		public function get lineGradientX():Number { return _lineGradientX; }
		public function set lineGradientX(value:Number):void 
		{ 
			_lineGradientX = value; 
			updateGraphic();
		}
		
		
		private var _lineGradientY:Number = 0;
		/**
		 * Sets how far (in pixels) the gradient is shifted vertically. 
		 * Line type must be lineGradient.
		 * @default 0
		 */			
		public function get lineGradientY():Number { return _lineGradientY; }
		public function set lineGradientY(value:Number):void 
		{ 
			_lineGradientY = value; 
			updateGraphic();
		}
		
		
		protected var _lineGradientSpread:String = SpreadMethod.PAD;
		/**
		 * Specifies which gradient spread method to use.
		 * Choose: pad, reflect, or repeat.
		 * Line type must be gradient.
		 * @default pad
		 */	
		public function get lineGradientSpread():String
		{ 
			if (_lineGradientSpread == SpreadMethod.REFLECT)
				return "reflect"
			else if (_lineGradientSpread == SpreadMethod.REPEAT)
				return "repeat";
			else
				return "pad";
		}
		public function set lineGradientSpread(value:String):void 
		{ 
			if (value == "reflect")
				_lineGradientSpread = SpreadMethod.REFLECT;
			else if (value == "repeat")
				_lineGradientSpread = SpreadMethod.REPEAT;
			else 
				_lineGradientSpread = SpreadMethod.PAD;
			updateGraphic();		
		}
		
		
		protected var _lineGradientInterpolation:String = InterpolationMethod.RGB;
		/**
		 * Specifies which interpolation value to use: RGB or linearRGB
		 * @default RGB
		 */		
		public function get lineGradientInterpolation():String 
		{ 
			if (_lineGradientInterpolation == InterpolationMethod.LINEAR_RGB)
				return "linearRGB"
			else
				return "RGB";
		}
		public function set lineGradientInterpolation(value:String):void 
		{ 
			if (value == "linearRGB")
				_lineGradientInterpolation = InterpolationMethod.LINEAR_RGB;
			else 
				_lineGradientInterpolation = InterpolationMethod.RGB;
			updateGraphic();				
		}
		
		
		private var _lineGradientFocalPointRatio:Number = 0.0;
		/**
		 * A number that controls the location of the focal point of the lineGradient. 
		 * A value of 0 sets the focal point in the center. 
		 * A value of 1 sets the focal point at one border of the lineGradient circle.
		 * A value of -1 sets the focal point at the other border of the lineGradient circle. 
		 * A value less than -1 or greater than 1 is rounded to -1 or 1, respectively.
		 * @default 0.0
		 */		
		public function get lineGradientFocalPointRatio():Number { return _lineGradientFocalPointRatio; }
		public function set lineGradientFocalPointRatio(value:Number):void 
		{ 
			_lineGradientFocalPointRatio = value; 
			updateGraphic();
		}		
		
		
		
		////////////////
		// FILL TYPES //
		////////////////
		
		private var _fill:String = "color";
		/**
		 * Sets fill type, choose: color, gradient
		 * todo: implement shader and bitmap fills
		 * @default color
		 */		
		public function get fill():String { return _fill; }
		public function set fill(value:String):void 
		{ 
			_fill = value;
			updateGraphic();
			
		}
		
		
		
		//////////////////////
		// FILL TYPE: COLOR //
		//////////////////////

		private var _color:uint=0x333333;
		/**
		 * Sets fill color when fill type is color
		 * @default 0x333333
		 */				
		public function get color():uint{return _color;}
		public function set color(value:uint):void
		{
			_color = value;
			updateGraphic();
		}
		
	
		private var _fillAlpha:Number=1;
		/**
		 * Sets fill alpha when fill type is color
		 * @default 1
		 */			
		public function get fillAlpha():Number { return _fillAlpha;}
		public function set fillAlpha(value:Number):void
		{
			_fillAlpha = value;
			updateGraphic();
		}		
		
						
		
		/////////////////////////
		// FILL TYPE: GRADIENT //
		/////////////////////////
		
		
		protected var _gradientType:String = GradientType.LINEAR;		
		/**
		 * Sets gradient type when fill type is gradient.
		 * Choose: linear or radial 
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
			updateGraphic();
		}
		
		
		protected var gradientColorArray:Array = [0x333333, 0xAAAAAA];
		private var _gradientColors:String = "0x333333, 0xAAAAAA";
		/**
		 * Sets gradient colors when fill type is gradient
		 * Ordered list, max 12 (ex: 0x000000, 0x555555, 0xFFFFFF)
		 * @default 0x333333, 0xAAAAAA
		 */		
		public function get gradientColors():String { return _gradientColors; }
		public function set gradientColors(value:String):void 
		{ 
			_gradientColors = value;
			gradientColorArray = _gradientColors.split(",")
			updateGraphic();
		}
		
		
		protected var gradientAlphaArray:Array = [1, 1];
		private var _gradientAlphas:String = "1, 1";		
		/**
		 * Sets gradient alphas when fill type is gradient
		 * Alpha values corespond to the colors in the gradientColors array
		 * Ordered list, max 12 (ex: 1, 1, 1)
		 * @default 1, 1
		 */			
		public function get gradientAlphas():String { return _gradientAlphas; }
		public function set gradientAlphas(value:String):void 
		{ 
			_gradientAlphas = value;
			gradientAlphaArray = _gradientAlphas.split(",")			
			updateGraphic();
		}
		
		
		protected var gradientRatioArray:Array = [0, 255];
		private var _gradientRatios:String = "0, 255";		
		/**
		 * Color distribution ratios; valid values are 0-255. 
		 * This value defines the percentage of the width where the color is sampled at 100%. 
		 * The value 0 represents the left position in the gradient box, 
		 * and 255 represents the right position in the gradient box.
		 * 
		 * Fill type must be gradient.
		 * 
		 * The values must increase sequentially; for example, "0, 63, 127, 190, 255".
		 * Ordered list, (ex: 0, 255)
		 * @default 0, 255
		 */		
		public function get gradientRatios():String { return _gradientRatios; }
		public function set gradientRatios(value:String):void 
		{ 
			_gradientRatios = value;
			gradientRatioArray = _gradientRatios.split(",")						
			updateGraphic();
		}
		
		private var _gradientWidth:Number = 100;		
		/**
		 * Sets the width (in pixels) to which the gradient will spread. 
		 * Fill type must be gradient.
		 * @default 100
		 */		
		public function get gradientWidth():Number { return _gradientWidth; }
		public function set gradientWidth(value:Number):void 
		{ 
			_gradientWidth = value; 
			updateGraphic();
		}
		
		private var _gradientHeight:Number = 100;
		/**
		 * The height (in pixels) to which the gradient will spread. 
		 * Fill type must be gradient.
		 * @default 100
		 */			
		public function get gradientHeight():Number { return _gradientHeight; }
		public function set gradientHeight(value:Number):void 
		{ 
			_gradientHeight = value;
			updateGraphic();
		}
		
		protected var _gradientRotation:Number = 0; //holds value in radians
		/**
		 * Sets the rotation (in degrees) that will be applied to the gradient.
		 * Fill type must be gradient.
		 * @default 0
		 */			
		public function get gradientRotation():Number 
		{ 
			return _gradientRotation*180/Math.PI; //convert radians to degrees
		}
		public function set gradientRotation(value:Number):void 
		{ 			
			_gradientRotation = value*Math.PI/180; //convert degrees to radians
			updateGraphic();
		}
		
		private var _gradientX:Number = 0;
		/**
		 * Sets how far (in pixels) the gradient is shifted horizontally. 
		 * Fill type must be gradient.
		 * @default 0
		 */			
		public function get gradientX():Number { return _gradientX; }
		public function set gradientX(value:Number):void 
		{ 
			_gradientX = value; 
			updateGraphic();
		}

		private var _gradientY:Number = 0;
		/**
		 * Sets how far (in pixels) the gradient is shifted vertically. 
		 * Fill type must be gradient.
		 * @default 0
		 */			
		public function get gradientY():Number { return _gradientY; }
		public function set gradientY(value:Number):void 
		{ 
			_gradientY = value; 
			updateGraphic();
		}
				
		protected var _gradientSpread:String = SpreadMethod.PAD;
		/**
		 * Specifies which gradient spread method to use.
		 * Choose: pad, reflect, or repeat.
		 * Fill type must be gradient.
		 * @default pad
		 */	
		public function get gradientSpread():String
		{ 
			if (_gradientSpread == SpreadMethod.REFLECT)
				return "reflect"
			else if (_gradientSpread == SpreadMethod.REPEAT)
				return "repeat";
			else
				return "pad";
		}
		public function set gradientSpread(value:String):void 
		{ 
			if (value == "reflect")
				_gradientSpread = SpreadMethod.REFLECT;
			else if (value == "repeat")
				_gradientSpread = SpreadMethod.REPEAT;
			else 
				_gradientSpread = SpreadMethod.PAD;
			updateGraphic();		
		}
	
		protected var _gradientInterpolation:String = InterpolationMethod.RGB;
		/**
		 * Specifies which interpolation value to use: RGB or linearRGB
		 * @default RGB
		 */		
		public function get gradientInterpolation():String 
		{ 
			if (_gradientInterpolation == InterpolationMethod.LINEAR_RGB)
				return "linearRGB"
			else
				return "RGB";
		}
		public function set gradientInterpolation(value:String):void 
		{ 
			if (value == "linearRGB")
				_gradientInterpolation = InterpolationMethod.LINEAR_RGB;
			else 
				_gradientInterpolation = InterpolationMethod.RGB;
			updateGraphic();				
		}
		
		private var _gradientFocalPointRatio:Number = 0.0;
		/**
		 * A number that controls the location of the focal point of the gradient. 
		 * A value of 0 sets the focal point in the center. 
		 * A value of 1 sets the focal point at one border of the gradient circle.
		 * A value of -1 sets the focal point at the other border of the gradient circle. 
		 * A value less than -1 or greater than 1 is rounded to -1 or 1, respectively.
		 * @default 0.0
		 */		
		public function get gradientFocalPointRatio():Number { return _gradientFocalPointRatio; }
		public function set gradientFocalPointRatio(value:Number):void 
		{ 
			_gradientFocalPointRatio = value; 
			updateGraphic();
		}
		
			
		///////////////////////////////////////////////
		// SHAPE TYPES AND SHAPE-SPECIFIC PROPERTIES //
		///////////////////////////////////////////////
		
		
		private var _shape:String = "line";
		/**
		 * Sets predefined shape type.
		 * Choose: line, rectangle, circle or ellipse
		 * @default line 
		 */		
		public function get shape():String {return _shape;}
		public function set shape(value:String):void 
		{
			_shape = value;
			updateGraphic();
		}	
		
	
		////////////////////////
		// SHAPE TYPE: CIRCLE //
		////////////////////////
		
		
		private var _radius:Number = 0;
		/**
		 * Sets radius (in pixels) of circle.
		 * Shape type must be circle.
		 * @default 100
		 */		
		public function get radius():Number{return _radius;}
		public function set radius(value:Number):void
		{
			if (value > 0)
			{
				_radius = value;
				width = radius * 2;
				height = radius * 2;
				updateGraphic();
			}
		}
	
		////////////////////////
		// SHAPE TYPE: CIRCLESEGMENT //
		////////////////////////
		private var _innerRadius:Number = 0;
		/**
		 * Set the inner radius of the circle segment in pixels.
		 * Shape must be circlesegement.
		 */
		
		public function get innerRadius():Number{return _innerRadius;}
		public function set innerRadius(value:Number):void
		{
			if (value >= 0)
			{
				_innerRadius = value;
				updateGraphic();
			}
		}
		
		private var _startAngle:Number = 0;
		/**
		 * Set the start angle of the circle segment in degrees, clockwise from X axis.
		 * Must be in range 0.0 - 360.0.
		 * Shape must be circleSegment.
		 */
		public function get startAngle():Number{return _startAngle;}
		public function set startAngle(value:Number):void
		{
			if (value >= 0 && value <= 360.0)
			{
				_startAngle = value;
				updateGraphic();
			}
		}
		
		private var _angleLength:Number = 0;
		/**
		 * Set the angle length of the circle segment in degrees.
		 * Must be in range 0.0 - 360.0.
		 * Shape must be circleSegment.
		 */
		public function get angleLength():Number{return _angleLength;}
		public function set angleLength(value:Number):void
		{
			if (value >= 0 && value <= 360.0)
			{
				_angleLength = value;
				
				updateGraphic();
			}
		}
		
		private var _clockwise:Boolean = true;
		/**
		 * Set if the circle segment should go clockwise/
		 * Shape must be circleSegment.
		 */
		public function get clockwise():Boolean{return _clockwise;}
		public function set clockwise(value:Boolean):void
		{
			if (_clockwise != value)
			{
				_clockwise = value;
				updateGraphic();
			}
		}
		
		/////////////////////////
		// SHAPE TYPE: PATH //
		////////////////////////
		
		public var pathCommandsVector:Vector.< int >  = new Vector.<int>();
		private var _pathCommands:String;
		/**
		 * 
		 * Sets the path moveTo and lineTo values
		 * 
		 */		
		public function get pathCommands():String{return _pathCommands;}
		public function set pathCommands(value:String):void
		{			
			var array:Array = [];
			_pathCommands = value;
			
			if (_pathCommands)
			{
				array = _pathCommands.split(",");
				for (var i:int = 0; i < array.length; i++)
				   pathCommandsVector.push(int(array[i]));
			}
			updateGraphic();
			
		}
		
		public var pathCoordinatesVector:Vector.< Number >  = new Vector.<Number>();
		private var _pathCoordinates:String;
		/**
		 * 
		 * Sets the path coordinates
		 * 
		 */		
		public function get pathCoordinates():String{return _pathCoordinates;}
		public function set pathCoordinates(value:String):void
		{
			var array:Array = [];
			_pathCoordinates = value;
			if (_pathCoordinates)
			{
				array = _pathCoordinates.split(",");
				for (var j:int = 0; j < array.length; j++)
					pathCoordinatesVector.push(array[j]);
			}
			updateGraphic();
		}
		
		
		/////////////////////////
		// SHAPE TYPE: CURVE //
		////////////////////////
		
		private var _controlX:Number = 10;
		/**
		 * Sets the control X of curve.
		 * @default 10 
		 */		
		public function get controlX():Number { return _controlX; }
		public function set controlX(value:Number):void 
		{ 
			_controlX = value;
			updateGraphic();			
		}
		
			private var _controlY:Number = 10;
		/**
		 * Sets the control y value of curve.
		 * @default 10 
		 */		
		public function get controlY():Number { return _controlY; }
		public function set controlY(value:Number):void 
		{ 
			_controlY = value;
			updateGraphic();			
		}
		
		private var _anchorX:Number = 10;
		/**
		 * Sets the anchor X of curve.
		 * @default 10 
		 */		
		public function get anchorX():Number { return _anchorX; }
		public function set anchorX(value:Number):void 
		{ 
			_anchorX = value;
			updateGraphic();			
		}
		
		private var _anchorY:Number = 10;
		/**
		 * Sets the anchor Y of curve.
		 * @default 10 
		 */		
		public function get anchorY():Number { return _anchorY; }
		public function set anchorY(value:Number):void 
		{ 
			_anchorY = value;
			updateGraphic();			
		}
		
		private var _startX:Number=0;
		/**
		 * Sets starting X position for curve
		 * @default 0
		 */		
		 public function get startX():Number{return _startX;}
		 public function set startX(value:Number):void
		{
			_startX = value;
			updateGraphic();
		}
		
		
		private var _startY:Number=0;
		/**
		 * Sets starting Y position for curve
		 * @default 0
		 */			
		 public function get startY():Number{return _startY;}
		 public function set startY(value:Number):void
		{
			_startY = value;
			updateGraphic();
		}
		
		/////////////////////////////////
		// SHAPE TYPE: ROUND RECTANGLE //
		/////////////////////////////////		
		
		
		private var _cornerWidth:Number = 10;
		/**
		 * Sets the width of the ellipse that is used to round the rectangle.
		 * Shape type must be round rectangle.
		 * @default 10 
		 */		
		public function get cornerWidth():Number { return _cornerWidth; }
		public function set cornerWidth(value:Number):void 
		{ 
			_cornerWidth = value;
			updateGraphic();			
		}
		
		private var _cornerHeight:Number = 10;
		/**
		 * Sets the height of the ellipse that is used to round the rectangle.
		 * Shape type must be round rectangle.
		 * @default 10 
		 */			
		public function get cornerHeight():Number { return _cornerHeight; }
		public function set cornerHeight(value:Number):void 
		{ 
			_cornerHeight = value;
			updateGraphic();			
		}
		
		private var _topLeftRadius:Number = 0;
		/**
		 * sets the top left radius of the graphic object
		 * @default 0;
		 */
		public function get topLeftRadius():Number { return _topLeftRadius; }
		public function set topLeftRadius(r:Number):void
		{
			_topLeftRadius = r;
			updateGraphic();
		}
		
		private var _topRightRadius:Number = 0;
		/**
		 * sets the top right radius of the grpahic object
		 * @default 0;
		 */
		public function get topRightRadius():Number { return _topRightRadius; }
		public function set topRightRadius(r:Number):void
		{
			_topRightRadius = r;
			updateGraphic();
		}

		private var _bottomLeftRadius:Number = 0;
		/**
		 * sets the bottom left radius of the graphic object
		 * @default 0;
		 */
		public function get bottomLeftRadius():Number { return _bottomLeftRadius; }
		public function set bottomLeftRadius(r:Number):void
		{
			_bottomLeftRadius = r;
			updateGraphic();
		}	
		
		private var _bottomRightRadius:Number = 0;
		/**
		 * sets the bottom right radius of the graphic object
		 * @default 0;
		 */
		public function get bottomRightRadius():Number { return _bottomRightRadius; }
		public function set bottomRightRadius(r:Number):void
		{
			_bottomRightRadius = r;
			updateGraphic();
		}
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		
		/**
		 * Clears the graphics that were drawn to this Graphics object, 
		 * and resets fill and line style settings.
		 */		
		public function clear():void
		{
			graphics.clear();
		}
		
		
		/**
		 * Copies all of drawing commands from the source Graphics object 
		 * into the calling Graphics object.
		 */		
		public function copyFrom(source:Graphic):void
		{
			graphics.copyFrom(source.graphics);
		}
				
		
	}
}