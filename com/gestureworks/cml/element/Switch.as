package 
{
	
	import com.gestureworks.cml.factories.ElementFactory;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import org.tuio.TuioTouchEvent;
	import flash.events.MouseEvent;
	import com.gestureworks.core.GestureWorks;

	/**
	 * The Switch is a UIelement that acts as a Switch button.
	 * It has the following parameters: shapefillColor, shapeoutlineColor, shapelineStroke, shapeX, shapeY, shapeWidth, shapeHeight, shapeEllipseWidth,shapeEllipseHeight, buttonfillColor, buttonoutlineColor, buttonlineStroke, buttonX, buttonY, buttonWidth, buttonHeight, buttonEllipseWidth, buttonEllipseHeight.
	 * 
	 * <code>
	 * 
	 * var switch1:Switch = new Switch();
			
		switch1.shapefillColor = 0x333333;
		switch1.shapeoutlineColor = 0xFF0000;
		switch1.shapelineStroke = 3;
		switch1.buttonfillColor = 0x000000;
		switch1.buttonoutlineColor = 0x000000;
		switch1.buttonlineStroke = 1;
		switch1.shapeX = 0;
		switch1.shapeY = 0;
		switch1.shapeWidth = 100;
		switch1.shapeHeight = 50;
		switch1.shapeEllipseWidth = 25;
		switch1.shapeEllipseHeight = 25;
		switch1.buttonX = 0;
		switch1.buttonY = 0;
		switch1.buttonWidth = 50;
		switch1.buttonHeight = 50;
		switch1.buttonEllipseWidth = 25;
		switch1.buttonEllipseHeight = 25;
		switch1.x = 20;
		switch1.y = 20;
	
		addChild(switch1);     
	 * 
	 * 
	 * </code>
	 */
	public class Switch extends ElementFactory
	{
	public function Switch()
		{
			super();
			init();
		}
		
	public var shape:Sprite = new Sprite();
	public var button:Sprite = new Sprite();
	public var state:Boolean = false;
		
	private var _shapefillColor:uint = 0xFFFFFF;
	/**
	 * Sets the shape inside color of the Rounded Rectangle
	 * @default = 0xFFFFFF;
	 */
	public function get shapefillColor():uint {return _shapefillColor;}
	public function set shapefillColor(value:uint):void 
	{
		_shapefillColor = value;
		displayButton();
	}
	
	private var _shapeoutlineColor:uint = 0x333333;
	/**
	 * Sets the shape outline color of Rounded Rectangle
	 * @default = 0x333333;
	 */
	public function get shapeoutlineColor():uint {return _shapeoutlineColor;}
	public function set shapeoutlineColor(value:uint):void 
	{
		_shapeoutlineColor = value;
		displayButton();
	}	
		  
	private var _shapelineStroke:Number = 3;
	/**
	 * Sets the shape linestroke of the Rounded Rectangle
	 *  @default = 3;
	 */
	public function get shapelineStroke():Number {return _shapelineStroke;}
	public function set shapelineStroke(value:Number):void 
	{
		_shapelineStroke = value;
		displayButton();
	}	
	
	private var _buttonfillColor:uint = 0x000000;
	/**
	 * Sets the button inside color of the Rounded Rectangle
	 * @default = 0x000000;
	 */
	public function get buttonfillColor():uint {return _buttonfillColor;}
	public function set buttonfillColor(value:uint):void 
	{
		_buttonfillColor = value;
		displayButton();
	}
	
	private var _buttonoutlineColor:uint = 0x000000;
	/**
	 * Sets the button outline color of Rounded Rectangle
	 * @default = 0x000000;
	 */
	public function get buttonoutlineColor():uint {return _buttonoutlineColor;}
	public function set buttonoutlineColor(value:uint):void 
	{
		_buttonoutlineColor = value;
		displayButton();
	}	
		  
	private var _buttonlineStroke:Number = 1;
	/**
	 * Sets the button line stroke of the Rounded Rectangle
	 *  @default = 1;
	 */
	public function get buttonlineStroke():Number {return _buttonlineStroke;}
	public function set buttonlineStroke(value:Number):void 
	{
		_buttonlineStroke = value;
		displayButton();
	}	
	
	private var _shapeX:Number = 0;
	/**
	 * Sets the shape X position of Rounded Rectangle
	 * @default = 0;
	 */
	public function get shapeX():uint {return _shapeX;}
	public function set shapeX(value:uint):void 
	{
		_shapeX = value;
		displayButton();
	}
	
	private var _shapeY:Number = 0;
	/**
	 * Sets the shape Y position of Rounded Rectangle
	 * @default = 0;
	 */
	public function get shapeY():uint {return _shapeY;}
	public function set shapeY(value:uint):void 
	{
		_shapeY = value;
		displayButton();
	}
	
	private var _shapeWidth:Number = 100;
	/**
	 * Sets the shape Width  of Rounded Rectangle
	 * @default = 100;
	 */
	public function get shapeWidth():uint {return _shapeWidth;}
	public function set shapeWidth(value:uint):void 
	{
		_shapeWidth = value;
		displayButton();
	}	
		  
	private var _shapeHeight:Number = 50;
	/**
	 * Sets the shape Height of Rounded Rectangle
	 *  @default = 50;
	 */
	public function get shapeHeight():Number {return _shapeHeight;}
	public function set shapeHeight(value:Number):void 
	{
		_shapeHeight = value;
		displayButton();
	}
	
	private var _shapeEllipseWidth:Number = 25;
	/**
	 * Sets the shape Ellipse Width  of Rounded Rectangle
	 * @default = 25;
	 */
	public function get shapeEllipseWidth():uint {return _shapeEllipseWidth;}
	public function set shapeEllipseWidth(value:uint):void 
	{
		_shapeEllipseWidth = value;
		displayButton();
	}	
		  
	private var _shapeEllipseHeight:Number = 25;
	/**
	 * Sets the shape Ellipse Height of Rounded Rectangle
	 *  @default = 25;
	 */
	public function get shapeEllipseHeight():Number {return _shapeEllipseHeight;}
	public function set shapeEllipseHeight(value:Number):void 
	{
		_shapeEllipseHeight = value;
		displayButton();
	}
	
	private var _buttonX:Number = 0;
	/**
	 * Sets the button X position of Rounded Rectangle
	 * @default = 0;
	 */
	public function get buttonX():uint {return _buttonX;}
	public function set buttonX(value:uint):void 
	{
		_buttonX = value;
		displayButton();
	}
	
	private var _buttonY:Number = 0;
	/**
	 * Sets the button Y position of Rounded Rectangle
	 * @default = 0;
	 */
	public function get buttonY():uint {return _buttonY;}
	public function set buttonY(value:uint):void 
	{
		_buttonY = value;
		displayButton();
	}
	
	private var _buttonWidth:Number = 50;
	/**
	 * Sets the button Width  of Rounded Rectangle
	 * @default = 50;
	 */
	public function get buttonWidth():uint {return _buttonWidth;}
	public function set buttonWidth(value:uint):void 
	{
		_buttonWidth = value;
		displayButton();
	}	
		  
	private var _buttonHeight:Number = 50;
	/**
	 * Sets the button Height of Rounded Rectangle
	 *  @default = 50;
	 */
	public function get buttonHeight():Number {return _buttonHeight;}
	public function set buttonHeight(value:Number):void 
	{
		_buttonHeight = value;
		displayButton();
	}
	
	private var _buttonEllipseWidth:Number = 25;
	/**
	 * Sets the button Ellipse Width  of Rounded Rectangle
	 * @default = 25;
	 */
	public function get buttonEllipseWidth():uint {return _buttonEllipseWidth;}
	public function set buttonEllipseWidth(value:uint):void 
	{
		_shapeEllipseWidth = value;
		displayButton();
	}	
		  
	private var _buttonEllipseHeight:Number = 25;
	/**
	 * Sets the button Ellipse Height of Rounded Rectangle
	 *  @default = 25;
	 */
	public function get buttonEllipseHeight():Number {return _buttonEllipseHeight;}
	public function set buttonEllipseHeight(value:Number):void 
	{
		_buttonEllipseHeight = value;
		displayButton();
	}
	
	private function init ():void
		{
			displayButton();
		}
	
	public function displayButton():void
		{
			 
		this.mouseChildren = true;
	  
		shape.graphics.lineStyle(shapelineStroke,shapeoutlineColor);
		shape.graphics.beginFill(shapefillColor);
        shape.graphics.drawRoundRect(shapeX, shapeY, shapeWidth, shapeHeight, shapeEllipseWidth, shapeEllipseHeight);
		shape.graphics.endFill();
				
		button.graphics.lineStyle(buttonlineStroke,buttonoutlineColor);
		button.graphics.beginFill(buttonfillColor);
        button.graphics.drawRoundRect(buttonX, buttonY, buttonWidth, buttonHeight, buttonEllipseWidth, buttonEllipseHeight);
		button.graphics.endFill();
		button.visible = true;
	
		var touchSprite:TouchSprite = new TouchSprite();
		touchSprite.gestureReleaseInertia = false;
		touchSprite.gestureEvents = true;
		touchSprite.mouseChildren = false;
		touchSprite.disableNativeTransform = true; 
		touchSprite.disableAffineTransform = false;
		touchSprite.gestureList = { "n-drag":true ,"n-tap":true };
		touchSprite.addEventListener(GWGestureEvent.DRAG, gestureDragHandler);
		//touchSprite.addEventListener(TouchEvent.TOUCH_END, onEnd);
		//touchSprite.addEventListener(TouchEvent.TOUCH_OUT, onEnd);
			
		
			if (GestureWorks.activeTUIO) 
			this.addEventListener(TuioTouchEvent.TOUCH_UP, onEnd);
		else if (GestureWorks.supportsTouch) 
			this.addEventListener(TouchEvent.TOUCH_END, onEnd);
		else 
			this.addEventListener(MouseEvent.MOUSE_UP, onEnd);
			
			if (GestureWorks.activeTUIO) 
			this.addEventListener(TuioTouchEvent.TOUCH_OUT, onEnd);
		else if (GestureWorks.supportsTouch) 
			this.addEventListener(TouchEvent.TOUCH_OUT, onEnd);
		else 
			this.addEventListener(MouseEvent.MOUSE_OUT, onEnd);
			
			
		var touchSpriteBg:TouchSprite = new TouchSprite();
	    touchSpriteBg.gestureReleaseInertia = false;
		touchSpriteBg.gestureEvents = true;
		touchSpriteBg.mouseChildren = false;
		touchSpriteBg.disableNativeTransform = true; 
		touchSpriteBg.disableAffineTransform = false;
		touchSpriteBg.gestureList = { "n-tap":true };
	    touchSpriteBg.addEventListener(GWGestureEvent.TAP, onTap);
		
		touchSpriteBg.addChild(shape);
		addChild(touchSpriteBg);
		
		addChild(touchSprite);
		touchSprite.addChild(button);
		
		minButtonPos = shape.x;
		maxButtonPos = shape.width - button.width;
		}
		
	private var minButtonPos:Number;
	private var maxButtonPos:Number;
		
	private function gestureDragHandler(event:GWGestureEvent):void
		{ 
			
		if ((event.value.dx + button.x) > maxButtonPos)
		{
		 button.x = maxButtonPos;
		 state = true;
		}
		 else if ((event.value.dx + button.x) < minButtonPos)
		{
		 button.x = minButtonPos;
		 state = false;
		}
		 else
		{
		 button.x += event.value.dx;
		}
		
		if (event.value.localY < shape.y || event.value.localY > shape.height)
			onEnd();
		}
 
	private function onTap(event:GWGestureEvent):void
		{ 
				
		if (button.x < button.width)
		 button.x = maxButtonPos;
		else
		 button.x = minButtonPos;
		} 

	private function onEnd(event:*=null):void
		{ 
						
		if (button.x + button.width/2 >= (shape.width / 2))
		 button.x = maxButtonPos;
		else
		 button.x = minButtonPos;
			
        } 
}
}