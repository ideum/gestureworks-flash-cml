package com.gestureworks.cml.components
{
	import com.gestureworks.cml.elements.ColorPicker;
	import com.gestureworks.cml.elements.Paint;
	import com.gestureworks.cml.events.StateEvent;
	
	/**
	 * The PaintViewer component displays an Paint on the front side and meta-data on the back side.
	 * The width and height of the component are automatically set to the dimensions of the Paint element unless it is 
	 * previously specifed by the component.
	 * @author Ideum
	 * @see Component
	 * @see com.gestureworks.cml.elements.Paint
	 */	
	public class PaintViewer extends Component 
	{	
		private var _colorPicker:ColorPicker;
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {				
			//search for local instances
			if (!front){
				front = displayByTagName(Paint);
			}	
			if (!colorPicker) {
				colorPicker = displayByTagName(ColorPicker) as ColorPicker;				
			}
			if (colorPicker) {
				colorPicker.addEventListener(StateEvent.CHANGE, changeColor);
			}
			
			super.init();				
		}
		
		/**
		 * Color selection tool
		 */
		public function get colorPicker():* { return _colorPicker; }
		public function set colorPicker(value:ColorPicker):void {
			_colorPicker = displayById(value) as ColorPicker;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onStateEvent(event:StateEvent):void {
			
			switch (event.value) {
				case "increaseBrushSize":
					Paint(front).brushSize++;
					break;
				case "decreaseBrushSize":
					Paint(front).brushSize--;
					break;
				case "reset":
					Paint(front).resetImage();
					break;
				case "changeColor":
					toggleColorPicker();
					break;
				case "toggleEraser":
					Paint(front).toggleEraser();
					break;
				default:
					break;
			}
		}
			
		/**
		 * Toggle visiblity of color picker
		 */
		public function toggleColorPicker():void {
			colorPicker.visible = !colorPicker.visible; 
		}
		
		/**
		 * Update paint color based on color picker selection
		 * @param	e
		 */
		public function changeColor(e:StateEvent):void {
			if (front) {
				Paint(front).color = uint (e.value);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			colorPicker = null;
		}		
	}
}