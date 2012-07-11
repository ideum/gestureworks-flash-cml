 package com.gestureworks.cml.element
    {
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.factories.ElementFactory;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import com.gestureworks.core.GestureWorks;
	import flash.events.MouseEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * The Toggle is a element that acts as a toggle button.
	 * It has the following parameters: fillColor, outlineColor and lineStroke.
	 * 
	 * <code>
	 * 
	 *      var toggle:Toggle = new Toggle();
			toggle.fillColor = 0x333333;
			toggle.outlineColor = 0xFF0000;
			toggle.lineStroke = 4;
			toggle.x = 100;
			toggle.y = 100;
			addChild(toggle);
			
			toggle.addEventListener(StateEvent.CHANGE, onToggle);
			
			var txt:TextField = new TextField;
			txt.text = "hello";
			txt.x = 200;
			txt.y = 130;
			txt.visible = false;
			addChild(txt);
			
			function onToggle(event:StateEvent):void
			{
				trace("toggle text", event.value);
				
				if (event.value == "true")
					txt.visible = true;
				else
					txt.visible = false;
			}
	 * 
	 * 
	 * </code>
	 */
	public class Toggle extends ElementFactory 
	  {

    public function Toggle()
		    {
			super();
			init();
		   }
	
	/**
	 * The background square
	 */	   
	public var square:Sprite = new Sprite();
	
	
	/**
	 * The "x" graphic in the square
	 */
	public var crossline:Sprite = new Sprite();	   
		   
		   
	private var _fillColor:uint = 0x333333;
	/**
	 * Sets the inside color of the square
	 * @default = 0x333333;
	 */
	public function get fillColor():uint {return _fillColor;}
	public function set fillColor(value:uint):void 
	{
		_fillColor = value;
		draw();
	}
	
	private var _outlineColor:uint = 0x00ff00;
	/**
	 * Sets the color of the outline of the square and the inside cross
	 * @default = 0x00ff00;
	 */
	public function get outlineColor():uint {return _outlineColor;}
	public function set outlineColor(value:uint):void 
	{
		_outlineColor = value;
		draw();
	}	
		  
	private var _lineStroke:Number = 1;
	/**
	 * Sets the linestroke of the sqaure
	 *  @default = 1;
	 */
	public function get lineStroke():Number {return _lineStroke;}
	public function set lineStroke(value:Number):void 
	{
		_lineStroke = value;
		draw();
	}	
	
	private function init ():void
		   {
			draw();
				
	       }
					
	public function draw():void
		{
	  	
		square.graphics.lineStyle(lineStroke, outlineColor);
		square.graphics.beginFill(fillColor);
        square.graphics.drawRect(0, 0, 50, 50);
		square.graphics.endFill();
	 
		addChild(square);
			
		crossline.graphics.lineStyle(lineStroke, outlineColor);
		crossline.graphics.moveTo(0, 50);
		crossline.graphics.lineTo(50, 0);
		crossline.graphics.moveTo(50, 50);
		crossline.graphics.lineTo(0, 0);
		
		crossline.visible = false
		addChild(crossline);

		
		
		if (GestureWorks.activeTUIO) 
			this.addEventListener(TuioTouchEvent.TOUCH_DOWN, onTouchBegin);
		else if (GestureWorks.supportsTouch) 
			this.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		else 
			this.addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		

		}
			

	
	private function onTouchBegin(event:TouchEvent):void
	{
		crossline.visible = !crossline.visible;
		dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "visible", crossline.visible));
	}	
		
}
}