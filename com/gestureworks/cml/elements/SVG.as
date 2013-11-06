package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.TouchContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.Event;
	
    import flash.net.URLLoaderDataFormat;
	import com.lorentz.SVG.display.SVGDocument;
	import com.lorentz.processing.ProcessExecutor;
	
	public class SVG extends TouchContainer {
		
		private var _svg:SVGDocument;
		private var _stage:Stage;
		
		public function SVG(st:Stage = null) {
			_stage = st;
		}
		
		override public function init():void {
			if (_stage){
				ProcessExecutor.instance.initialize(_stage);
				ProcessExecutor.instance.percentFrameProcessingTime = 0.9;
			}
			else if (stage) {
				ProcessExecutor.instance.initialize(stage);
				ProcessExecutor.instance.percentFrameProcessingTime = 0.9;
			}
		}
		
		public function set src(file:String):void { 
			_svg = new SVGDocument();
			_svg.load(file);
			addChild(_svg);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_svg = null;
			_stage = null;
		}
	}
	
}