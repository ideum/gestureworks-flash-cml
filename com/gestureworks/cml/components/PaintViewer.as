package com.gestureworks.cml.components
{
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	
	
	public class PaintViewer extends Component 
	{	
		private var _painter:*;
		private var colorPicker:*;
		
		public function PaintViewer() 
		{
			super();
			mouseChildren = true;
			nativeTransform = true;
			affineTransform = true;	
		}
		
		public function get painter():* { return _painter; }
		public function set painter(value:*):void
		{
			if (!value) return;
			
			_painter = value;
			_painter.init();
			addChild(_painter);
		}
		
		override public function init():void 
		{	
			// automatically try to find elements based on AS3 class
			if (!_painter)
				_painter = searchChildren(Paint);
			
			if (_painter)
				_painter.addEventListener(StateEvent.CHANGE, painterComplete);
			
			super.init();	
		}
		
		private function painterComplete(e:StateEvent):void {
			//trace("Painter Started");
		}	
					
		override protected function updateLayout(event:*=null):void 
		{
			if (_painter) {
				width = _painter.width;
				height = _painter.height;	
			}	
			super.updateLayout();				
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			_painter = null;
			colorPicker = null;
		}
		
		override protected function onStateEvent(event:StateEvent):void {
			
			switch (event.value) {
				case "increaseBrushSize":
					_painter.brushSize = _painter.brushSize + 1;
					break;
				case "decreaseBrushSize":
					_painter.brushSize = _painter.brushSize - 1;
					break;
				case "reset":
					_painter.resetImage();
					break;
				case "changeColor":
					toggleColorPicker();
					break;
				case "toggleEraser":
					_painter.toggleEraser();
					break;
				default:
					break;
			}
		}
		
		public function toggleColorPicker():void 
		{
			if(!colorPicker){
				colorPicker = new ColorPicker();
				addChild(colorPicker);
				colorPicker.addEventListener(StateEvent.CHANGE, changeColor);
				colorPicker.visible = true;
				return;
			}
			
			if (colorPicker.visible == true)
				colorPicker.visible = false;
			else
				colorPicker.visible = true;
		}
		
		public function changeColor(e:StateEvent):void {
			if (_painter) {
				//trace(e.value);
				_painter.color = uint (e.value);
			}
		}
	}
}