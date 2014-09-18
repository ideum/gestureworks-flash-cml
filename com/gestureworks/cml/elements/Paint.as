package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.*;
	import com.gestureworks.cml.utils.PNGEncoder;
	import com.gestureworks.core.*;
	import com.gestureworks.events.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ideum
	 */
	public class Paint extends TouchContainer
	{
		private var points:Array;
		private var lines:Array;
		private var lineThickness:Array;
		private var lineColor:Array;
		private var history:Array;
		private var _color:uint 	= 0xff00cc;
		private var lastColor:uint 	= 0xff00cc;
		private var image:Bitmap;
		private var fileR:FileReference;
				
		private var _canvasWidth:Number, _canvasHeight:Number;
		private var _background:uint;
		private var _backgroundAlpha:Number = 1.0;
		private var _brushSize:int;
		private var eraserColor:uint;
		private var _eraserOn:Boolean;

		/**
		 * Constructor
		 * @param	w - width, 1280 by default
		 * @param	h - height, 720 by default
		 * @param	bg - background color, an off white by default
		 * @param	bgAlpha - alpha for background, relevant in png or svg exporting.
		 */
		public function Paint(w:Number=1280, h:Number=720, bg:uint=0x00efefef, bgAlpha:Number=1.0){
			super();
			_canvasWidth  = w;
			_canvasHeight = h;
			_background = bg;
			_backgroundAlpha = bgAlpha;
			eraserColor = _background;
			active = true;
		}

		override public function init():void{
			super.init();
			createGraphics();
			createEvents();
			lines = new Array();
			lineThickness = new Array();
			lineColor = new Array();
			points = new Array();
			history = new Array();
			fileR = new FileReference();
			
			brushSize = 4;
			_eraserOn = false;
		}

		private function createGraphics():void {
			this.graphics.beginFill(_background, _backgroundAlpha);
			this.graphics.drawRect(0, 0, _canvasWidth, _canvasHeight);
			this.graphics.endFill();

			image = new Bitmap();
			addChild(image);
		}

		private function createEvents():void {
			this.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			this.addEventListener(TouchEvent.TOUCH_END, onTouchUp);
			this.addEventListener(TouchEvent.TOUCH_OUT, onTouchUp);
		}
		
		private function onTouchDown(e:TouchEvent):void {
			this.graphics.lineStyle(brushSize, _color);
			this.graphics.moveTo(e.localX, e.localY);
			points.push(new Point(e.localX, e.localY));
			this.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		}

		private function onTouchMove(e:TouchEvent):void {
			if (e.localX < 0 || e.localY < 0) {
				onTouchUp();
				return;
			}			
			else if (e.localX > width || e.localY > height) {
				onTouchUp();
				return;
			}
			
			points.push(new Point(e.localX, e.localY));
			var i:Number = points.length;
			this.graphics.lineTo(points[i-1].x, points[i-1].y);
		}

		private function onTouchUp(e:TouchEvent=null):void {			
			this.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			if (_eraserOn)
				eraseLines(points);
			else{
				lineThickness.push(brushSize);
				lineColor.push(_color);
				lines.push(points);
			}
			points = new Array();
		}

		private function randColor():Number {
			return Math.random() * 16777215;
		}
		
		private function getImageData():BitmapData {
			var drawing:Sprite = new Sprite();
			for (var i:Number = 0; i < lines.length; i++ ) {
				var tmpBrushSize:Number = lineThickness[i];
				var tmpCurrentColor:uint = lineColor[i];
				drawing.graphics.lineStyle(tmpBrushSize, tmpCurrentColor);
					for (var j:Number = 0; j < lines[i].length - 1; j++ ) {
						drawing.graphics.moveTo(lines[i][j].x, lines[i][j].y);
						drawing.graphics.lineTo(lines[i][j+1].x, lines[i][j+1].y);
					}
			}
			
			var data:BitmapData = new BitmapData(_canvasWidth, _canvasHeight, false, _background);
			data.draw(drawing);
			return data;
		}
		
		private function svgSelected (e:Event):void {
			fileR.load();
		}
		
		// Intended to read SVG's generated with this application.
		// Load SVG's from other sources at your own risk. 
		private function svgLoaded(e:Event):void {
			var xml:XML = new XML(fileR.data);
			
			resetImage();
			
			for each (var elem:XML in xml.children()) {
				var path:Array = (elem.@d).split(/ /);
				for (var i:Number = 1; i < path.length; i++) {
					var point:Array = path[i].split(",");
					//trace("point: ", new Point(parseInt(point[0]), parseInt(point[1])));
					points.push(new Point(parseInt(point[0]), parseInt(point[1])));
				}
				lines.push(points);
				lineColor.push(hexStringToUint(elem.@stroke));
				lineThickness.push(parseInt(elem['@stroke-width']));
				points = new Array();
			}
			redraw();
		}
		
		private function lineIntersectLine(A:Point,B:Point,E:Point,F:Point,as_seg:Boolean=true):Boolean {
			var ip:Point = new Point();
			var a1:Number, a2:Number;
			var b1:Number, b2:Number;
			var c1:Number, c2:Number;
		 
			a1 = B.y - A.y; 
			b1 = A.x - B.x;
			c1 = B.x * A.y - A.x * B.y;
			
			a2 = F.y - E.y;
			b2 = E.x - F.x;
			c2 = F.x * E.y - E.x * F.y;
			
			var denom:Number=a1*b2 - a2*b1;
			if (denom == 0) {
				return false;
			}

			ip.x=(b1*c2 - b2*c1)/denom;
			ip.y=(a2*c1 - a1*c2)/denom;
		 
			//checks to see if intersection to endpoints
			if(as_seg){
				if(Math.pow(ip.x - B.x, 2) + Math.pow(ip.y - B.y, 2) > Math.pow(A.x - B.x, 2) + Math.pow(A.y - B.y, 2))
				   return false;
				   
				if(Math.pow(ip.x - A.x, 2) + Math.pow(ip.y - A.y, 2) > Math.pow(A.x - B.x, 2) + Math.pow(A.y - B.y, 2))
				   return false;
		 
				if(Math.pow(ip.x - F.x, 2) + Math.pow(ip.y - F.y, 2) > Math.pow(E.x - F.x, 2) + Math.pow(E.y - F.y, 2))
				   return false;
				   
				if(Math.pow(ip.x - E.x, 2) + Math.pow(ip.y - E.y, 2) > Math.pow(E.x - F.x, 2) + Math.pow(E.y - F.y, 2))
				   return false;
			}
			return true;
		}
		
		private function eraseLines(eraserPath:Array):void {
			var tmpLines:Array = lines;
			var i:Number; 
			
			for (i = 0; i < eraserPath.length-2; i++ ){
				var p1:Point = eraserPath[i];
				var p2:Point = eraserPath[i + 1];
				if (p1 == p2)
					continue;
				for (var j:Number = 0; j < lines.length; j++ ) {
					for (var k:Number = 0; k < lines[j].length-2; k++) {
						var p3:Point = lines[j][k];
						var p4:Point = lines[j][k + 1];
						if (p3 == p4) 
							continue;
						if (lineIntersectLine(p1, p2, p3, p4)){
							//trace("intersection between (", p1, "," , p2, ") and (" , p3, ",", p4, ")" );
							tmpLines.splice(j, 1, subset(lines[j], 0, k+1), subset(lines[j], k+1, lines[j].length)); 
							lineColor.splice(j, 0, lineColor[j]);
							lineThickness.splice(j, 0, lineThickness[j]);
						}
					}
					
				}
			}
			lines = tmpLines;
			redraw();
			
			//filter empty or 1 point lines
			for (i = lines.length-1; i >= 0; i--) {
				if (lines[i].length <= 1) {
					lines.splice(i, 1);
				}
			}
		}
		
		private function subset(points:Array, start:Number, end:Number):Array {
			var ret:Array = new Array();
			for (var i:Number = start; i < end && i < points.length ; i++ ) {
				ret.push(points[i]);
			}
			if (ret.length <= 2)
				return [];
			else
				return ret;
		}
		
		private function prependZero(n:Number):String {
			if (n < 10)
				return "0" + n.toString(16);
			else 
				return n.toString(16);
		}
		
		//e.g. "#ff00cc" -> 0xff00cc  
		private function hexStringToUint(c:String):uint {
			c = c.substr(1, c.length - 1); 
			return parseInt(c, 16);
		}
		
		private function uintToHexString(c:uint):String {
			var r:String = prependZero(c >> 16);
			var g:String = prependZero(c >> 8 & 0x00ff);
			var b:String = prependZero(c & 0x0000ff);
			
			return "#" + r + g + b;
		}
		
		private function resetCanvas():void {
			this.graphics.clear();
			this.graphics.beginFill(_background);
			this.graphics.drawRect(0, 0, _canvasWidth, _canvasHeight);
			this.graphics.endFill();
		}

		private function redraw():void {
			resetCanvas();
			
			for (var i:Number = 0; i < lines.length; i++ ) {
				var tmpBrushSize:Number = lineThickness[i];
				var tmpCurrentColor:uint = lineColor[i];
				this.graphics.lineStyle(tmpBrushSize, tmpCurrentColor);
					for (var j:Number = 0; j < lines[i].length - 1; j++ ) {
						this.graphics.moveTo(lines[i][j].x, lines[i][j].y);
						this.graphics.lineTo(lines[i][j+1].x, lines[i][j+1].y);
					}
			}
		}
		
		//------------------
		//PUBLIC FUNCTIONS
		//------------------
		
		/**
		 * Erases data and clears canvas
		 */
		public function resetImage():void {
			points  	  = new Array();
			lines 		  = new Array();
			lineThickness = new Array();
			lineColor 	  = new Array();
			
			resetCanvas();
		}

		/**
		 * Turns on or off the eraser tool.
		 */
		public function toggleEraser():void {
			_eraserOn = !_eraserOn;
			if (_eraserOn){
				lastColor = _color;
				_color = eraserColor;
			}
			else {
				_color = lastColor;
			}
		}

		/**
		 * Sets gets canvas width
		 */
		override public function get width():Number { return _canvasWidth; }
		override public function set width(canvasWidth:Number):void {
			_canvasWidth = canvasWidth;
		}
		
		/**
		 * Sets gets canvas height
		 */
		override public function get height():Number{ return _canvasHeight; }
		override public function set height(canvasHeight:Number):void {
			_canvasHeight = canvasHeight;
		}
		
		/**
		 * Sets paint color
		 */
		public function set color(newColor:uint):void {
			if (newColor >= 0 && newColor <= 0xffffff && !_eraserOn)
				_color = newColor;
		}
		
		/**
		 * Sets background color
		 */
		public function set backgroundColor(newBg:uint):void {
			if (newBg >= 0 && newBg <= 0xffffff){
				_background = newBg;
				eraserColor = _background;
			}
		}

		/**
		 * Sets brush size, aka line width
		 */
		public function get brushSize():int { return _brushSize; }
		public function set brushSize(newSize:int):void {
			if (newSize > 0 && newSize < 25)
				_brushSize = newSize;
		}
		
		/**
		 * Sets background alphas
		 */		
		public function get backgroundAlpha():Number { return _backgroundAlpha; }
		public function set backgroundAlpha(value:Number):void {
			_backgroundAlpha = value;
		}
		
		/**
		 * Exports drawing as SVG
		 * @param	defaultFileName
		 */
		public function exportSVG(defaultFileName:String = "painting.svg"):void {
			if (lines.length < 1)
				return;
				
			var fileRef:FileReference = new FileReference();
			var svgXML:String = new String();
			
			svgXML += "<?xml version='1.0' encoding='UTF-8' standalone='no'?>\n";
			svgXML += "<svg xmlns:dc='http://purl.org/dc/elements/1.1/'\n";
			svgXML += "xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'\n";
			svgXML += "xmlns:svg='http://www.w3.org/2000/svg'\n";
			svgXML += "xmlns='http://www.w3.org/2000/svg'\n";
			svgXML += "width='"+_canvasWidth+"'\n";
			svgXML += "height='"+_canvasHeight+"' >\n";
			
			for (var i:Number = 0; i < lines.length; i++ ) {
				svgXML += "<path d='";
				svgXML += "M " + lines[i][0].x + "," + lines[i][0].y + " ";
				for (var j:Number = 1; j < lines[i].length-2; j++) {
					svgXML += lines[i][j].x + "," + lines[i][j].y + " ";
				}
				var end:Number = lines[i].length - 1;
				svgXML += lines[i][end].x + "," + lines[i][end].y + "' ";
				svgXML += "fill='none' stroke='" + uintToHexString(lineColor[i]) 
								+ "' stroke-width='" + lineThickness[i] + "' stroke-linecap='round' stroke-linejoin='round' />\n";
			}
			
			svgXML += "</svg>";
			fileRef.save(svgXML, defaultFileName);
		}
		
		/**
		 * Exports drawing as PNG
		 * @param	defaultFileName
		 */
		public function exportPNG(defaultFileName:String = "painting.png"):void {
			if (lines.length < 1)
				return;
			var encoder:PNGEncoder;
			var fileRef:FileReference;
			var imageData:BitmapData = getImageData();
			
			encoder = new PNGEncoder();
			fileRef = new FileReference();
		
			var ba:ByteArray = PNGEncoder.encode(imageData);
			fileRef.save(ba, defaultFileName);
			ba.clear();
		}
		
		/**
		 * Imports SVG file.
		 */
		public function importSVG():void {
			fileR.addEventListener(Event.SELECT, svgSelected);
			fileR.addEventListener(Event.COMPLETE, svgLoaded);
			fileR.browse([new FileFilter("SVG", "*.svg")]);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			points = null;
			lines = null;
			lineThickness = null;
			lineColor = null;
			history = null;
			image = null;
			
			if (fileR) {
				fileR.removeEventListener(Event.SELECT, svgSelected);
				fileR.removeEventListener(Event.COMPLETE, svgLoaded);	
				fileR = null;
			}
			
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		}
	}
}