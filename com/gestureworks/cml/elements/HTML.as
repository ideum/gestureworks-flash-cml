package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	
	/**
	 * The HTML loads and runs an HTMLLoader display object.
	 * By default Flash is hidden from the web pages after loading via javascript to prevent display bugs native to the HTMLLoader
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 			
		
			var html:HTML = new HTML();
			html.load(
			addChild(html);

	 * </codeblock>
	 * @author Ideum
	 */
	
	public class HTML extends Container {	
		private var _backgroundGraphic:Sprite;	
		private var _html:HTMLLoader;
		private var _src:String;
		private var _loadURL:String;
		private var _prevURL:String;
		private var _urlReq:URLRequest;
		private var loaded:Boolean = false;
		private var tmpImage:BitmapData;
		private var rawSmoothCap:Bitmap;
		private var smoothCap:Sprite;
		private var _baseURL:String = "http://";
		private var _hideFlash:Boolean = true;
		private var _hideFlashType:String = "visibility:hidden;";
		private var _smooth:Boolean = false;
		private var _lockBaseURL:Boolean = true;
		private var _width:Number = 1024;		
		private var _height:Number = 768;
		private var _srcString:String;

		public var _verticalScroll:ScrollBar;
		public var _horizontalScroll:ScrollBar;
		
		/**
		 * Constructor
		 */
		public function HTML() {
			super();
			_urlReq = new URLRequest;
			_html = new HTMLLoader;
		}
		
		override public function parseCML(cml:XMLList):XMLList {
			var ret:XMLList = cml.copy();
			var str:String = cml.children().toString();
			if (str.length) {
				_srcString = str;
			}	
			cml.setChildren(new XMLList());				
			return CMLParser.parseCML(this, cml);
		}
		
		/**
		 * Returns html object
		 */
		public function get html():HTMLLoader { return _html; }
		
		/**
		 * @inheritDoc
		 */
		override public function init():void {			
			if (src) {
				_urlReq.url = src;		
			}
			
			// background graphic
			_backgroundGraphic = new Sprite();
			_backgroundGraphic.graphics.beginFill(0x000000);
			_backgroundGraphic.graphics.drawRect(0, 0, _width, _height);
			_backgroundGraphic.graphics.endFill();
			addChild(_backgroundGraphic);
			
			// smoothed bitmap
			rawSmoothCap = new Bitmap();
			smoothCap = new Sprite();
			smoothCap.addChild(rawSmoothCap);
			addChild(smoothCap);
			
			// html element
			_html.width = _width;
			_html.height = _height;
			_html.addEventListener(Event.COMPLETE, onURLLoadComplete);
			_html.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChange);
			_html.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChanging);
			_html.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChanging);
			_html.addEventListener(Event.HTML_RENDER, onRender);
			
			//_html.window.as3Function = Main.changeStageColor;
			
			if (srcString) {
				_html.placeLoadStringContentInApplicationSandbox = true;				
				_html.loadString(_srcString);				
			}
			else {
				_html.load(_urlReq); 
			}
			
			addChild(_html);
			
			// scrollbars
			_verticalScroll = new ScrollBar();	
			_verticalScroll.x = _html.width - 25;
			_verticalScroll.y = 0;
			_verticalScroll.fill = 0xFFFFFF;
			_verticalScroll.orientation = "vertical";
			_verticalScroll.contentHeight = 768;
			_verticalScroll.width = 25;
			_verticalScroll.height = _html.height;
			_verticalScroll.visible = false;
			_verticalScroll.addEventListener(StateEvent.CHANGE, onScroll);        
			_verticalScroll.init();
			addChild(_verticalScroll);
			
			_horizontalScroll = new ScrollBar();	
			_horizontalScroll.x = 0;
			_horizontalScroll.y = _html.height - 25;
			_horizontalScroll.fill = 0xFFFFFF;
			_horizontalScroll.orientation = "horizontal";
			_horizontalScroll.contentWidth = 1024;
			_horizontalScroll.height = 25;
			_horizontalScroll.width = _html.width;
			_horizontalScroll.visible = false;
			_horizontalScroll.addEventListener(StateEvent.CHANGE, onScroll); 
			_horizontalScroll.init();
			addChild(_horizontalScroll);
			
			if (_smooth) {
				generateSmoothVersion();
			}
		}
			
		/**
		 * Sets whether or not if Flash will be hidden (object/embed).
		 * hideFlashType = "display: none;" or "visibility:hidden;"
		 * @default true
		 */	
		public function get hideFlash():Boolean{ return _hideFlash;}
		public function set hideFlash(value:Boolean):void {
			_hideFlash = value;	
		}
		
		/**
		 * Sets the specific type flash embed. Options are "display: none;" or "visibility:hidden;
		 * @default visibility:hidden
		 */
		public function get hideFlashType():String{ return _hideFlashType;}
		public function set hideFlashType(value:String):void
		{
			_hideFlashType = value;	
		}
		
		/**
		 * Sets whether or not to smooth the rendered html page
		 * @default true
		 */	
		public function get smooth():Boolean{ return _smooth;}
		public function set smooth(value:Boolean):void
		{
			_smooth = value;	
		}
		
		/**
		 * Locks base url.
		 * Set to true if you don't want users to be able to navigate awaw from http://www.xxxxxxx.xxx/
		 * @default true 
		 */	
		public function get lockBaseURL():Boolean{ return _lockBaseURL;}
		public function set lockBaseURL(value:Boolean):void
		{
			_lockBaseURL = value;	
		}
		
		/**
		 * Get/Set the base URL.
		 * Initial URL loaded.
		 * @default http://
		 */	
		public function get baseURL():String{ return _baseURL;}
		public function set baseURL(value:String):void
		{
			_baseURL = value;
		}
		
		/**
		 * Sets the width;
		 * @defualt 1024
		 */	
		override public function get width():Number{ return _width;}
		override public function set width(value:Number):void
		{
			_width = value;
			super.width = value;	
		}
		
		/**
		 * Sets the height.
		 * @height 768
		 */	
		override public function get height():Number{ return _height;}
		override public function set height(value:Number):void
		{
			_height = value;
			super.height = value;
		}
		
		/**
		 * Sets the src URL and sends load request.
		 */
		public function get src():String { return _src; }
		public function set src(value:String):void	{ 
			_src = value;
			if(!loaded)
				loadURL(_src);
		}
		
		public function get srcString():String {
			return _srcString;
		}
		
		public function set srcString(value:String):void {
			_srcString = value;
		}
		
		/**
		 * Load url
		 * @param	URL
		 */
		public function loadURL(URL:String = ""):void {
			if (URL == "")
				_loadURL = _prevURL;
			else
				_loadURL = URL;
			_urlReq = new URLRequest(_loadURL);
			_html.load(_urlReq);
		}
		
		/**
		 * Go back in history
		 */
		public function goBack():void { _html.historyBack(); }
		
		/**
		 * Go forward in history
		 */
		public function goForward():void { _html.historyForward(); }
		
		/**
		 * Scroll bar event handler
		 */
		private function onScroll(e:StateEvent):void { 
			if (e.target == _verticalScroll) {				
				html.scrollV = ((html.contentHeight - html.height)) * e.value;
			} else if (e.target == _horizontalScroll) {
				html.scrollH = ((html.contentWidth - html.width)) * e.value;
			}
			if(_smooth)
				generateSmoothVersion();
			if (loaded) {
				if (_smooth)
					smoothCap.alpha = 1;
				if (!_smooth)
					_html.alpha = 1;			
			}else {
				if (_smooth)
					smoothCap.alpha = .5;
				if (!_smooth)
					_html.alpha = .5;		
			}
		}

		/**
		 * HTML load complete event handler
		 */
		protected function onURLLoadComplete(event:*):void {	
			trace("URL Loaded: ", _loadURL);
			_verticalScroll.scrollPosition = 0;
			_horizontalScroll.scrollPosition = 0;
			_verticalScroll.thumbPosition = 0;
			_horizontalScroll.thumbPosition = 0;
			_prevURL = _loadURL;
			
			if (_html.contentWidth > _html.width) {
				_html.height = _height - _horizontalScroll.height;
				_horizontalScroll.visible = true;
				_horizontalScroll.resize(_html.contentWidth);
			}
			else{
				_horizontalScroll.visible = false;
				_html.height = _height;
			}			
			if (_html.contentHeight > _html.height) {
				_html.width = _width - _verticalScroll.width;
				_verticalScroll.visible = true;
				_verticalScroll.resize(_html.contentHeight);
			}
			else{
				_verticalScroll.visible = false;
				_html.width = _width;
			}
			
			loaded = true;
			if(_smooth){
				generateSmoothVersion();
				smoothCap.alpha = 1;
			}
			if (!_smooth)
				_html.alpha = 1;
				
			// hides flash
			if(_hideFlash){
				_html.window.document.location = "javascript:var css = document.createElement('style');css.type = 'text/css';css.innerHTML = 'embed, object { "+_hideFlashType+" }';document.body.appendChild(css);window.scrollTo(0,0)";
			}
		}
		
		/**
		 * HTML error event handler
		 * @param	event
		 */
		protected function onURLLoadError(event:*):void {	
			trace("URL Error");
		}
		
		/**
		 * HTML location currently changing event handler
		 * @param	event
		 */
		protected function onLocationChanging(event:LocationChangeEvent):void {	
			if ( event.location.indexOf( _baseURL ) < 0 && _lockBaseURL && event.location.match("*.pdf")) {
                event.preventDefault();
				return;
            }			
			if (_smooth)
				smoothCap.alpha = .5;
			if (!_smooth)
				_html.alpha = .5;
			loaded = false
		}
		
		/**
		 * HTML location change event handler
		 * @param	event
		 */
		protected function onLocationChange(event:LocationChangeEvent):void {	
			if ( event.location.indexOf( _baseURL ) < 0 && _lockBaseURL && event.location.match("*.pdf") ) {
              //  event.preventDefault();
				return;
            }
			if (_smooth)
				smoothCap.alpha = .5;
			if (!_smooth)
				_html.alpha = .5;
			loaded = false;
		}
		
		public function onRender(event:Event):void {
			if (_smooth) {
				generateSmoothVersion();
			}
			
			if (_html.contentWidth > _html.width) {
				_html.height = _height - _horizontalScroll.height;
				_horizontalScroll.visible = true;
				_horizontalScroll.resize(_html.contentWidth);
			}
			else{
				_horizontalScroll.visible = false;
				_html.height = _height;
			}			
			if (_html.contentHeight > _html.height) {
				_html.width = _width - _verticalScroll.width;
				_verticalScroll.visible = true;
				_verticalScroll.resize(_html.contentHeight);
			}
			else{
				_verticalScroll.visible = false;
				_html.width = _width;
			}
						
		}
		
		/**
		 * Smoothing Function
		 */
		public function generateSmoothVersion():void {	
			_html.alpha = 1;
			smoothCap.removeChild(rawSmoothCap);
			removeChild(smoothCap);
			tmpImage = new BitmapData(_html.width, _html.height, false, 0xFFFFFF);
			tmpImage.draw(_html, null, null, null, null, true);
			rawSmoothCap = new Bitmap(tmpImage);
			rawSmoothCap.smoothing = true;
			smoothCap = new Sprite();
			smoothCap.addChild(rawSmoothCap);
			_html.alpha = 0;
			addChild(smoothCap);
			setChildIndex(smoothCap, 0);
			setChildIndex(_backgroundGraphic, 0);
		}	
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_html.removeEventListener(Event.COMPLETE, onURLLoadComplete);
			_html.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, onLocationChange);
			_html.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, onLocationChanging );
			_verticalScroll.removeEventListener(StateEvent.CHANGE, onScroll);   
			_horizontalScroll.removeEventListener(StateEvent.CHANGE, onScroll);
			smoothCap.removeChild(rawSmoothCap);
			removeChild(smoothCap);  
			removeChild(_verticalScroll);
			removeChild(_horizontalScroll); 
			tmpImage = null;
			rawSmoothCap = null;
			smoothCap = null;
			_src = null;
			_html = null;
			_urlReq = null;
		}		
		
	}
}