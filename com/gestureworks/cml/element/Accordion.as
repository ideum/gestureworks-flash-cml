package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	
	/**
	 * ...
	 * @author 
	 */
	public class Accordion extends Container 
	{
		private var _selectedIndex:int = -1;
		private var _backgroundColor:uint = 0x424141;
		private var _spacing:Number = 5;
		private var background:Graphic;
		private var contents:Array = [];
		
		
		public function Accordion() 
		{
			super();
			//width = 500;
			//height = 375;	
			//background = new Graphic();			
			//addChild(background);
		}

		
		
		/**
		 * Initialization call
		 */
		public function init():void
		{					
			for (var j:int = 0; j < numChildren; j++) {
				contents.push(getChildAt(j));
			}
			
			background = new Graphic();
			background.lineStroke = 0;
			background.color = backgroundColor;
			background.shape = "rectangle";
			background.width = width;
			background.height = height;
			addChildAt(background, 0);
			background.init();
			
			var tabHeight:Number;
			
			for (var i:int = 0; i < contents.length; i++)
			{
				tabs[i] = createTab();
				
				if (i != 0)
					tabs[i].y = tabs[i-1].height * i;


				tabs[i].gestureList = { "n-tap":true, "n-drag-inertia":true };
				tabs[i].gestureEvents = true;
				tabs[i].addEventListener(GWGestureEvent.TAP, onTap);								
				tabs[i].addEventListener(GWGestureEvent.DRAG, onDrag);								
				tabs[i].addEventListener(GWGestureEvent.RELEASE, onRelease);
				tabs[i].gestureReleaseInertia = true;
					
				
				
				contents[i].y = (i * tabs[i].height) + tabs[i].height;
				
				addChild(tabs[i]);
			
				if (i < _labelsArray.length){
					var label:Text = new Text();
					label.font = _font;
					label.color = _fontColor;
					label.fontSize = _fontSize;
					label.autoSize = "left";
					label.text = _labelsArray[i];
					tabs[i].addChild(label);
					label.y = (tabs[i].height - label.height) / 2;
				}
				
				if (width == 0 && contents[i].width > width)
					width = contents[i].width;
					
				if (height == 0 && contents[i].height > height)
					height = contents[i].height;
			}
			
			tabHeight = tabs[0].height;	
				
			background.height = height + tabHeight * (tabs.length - 1);
			
			cMask = new Graphic;
			cMask.shape = "rectangle";
			cMask.height = background.height;
			cMask.width = width;
			cMask.init();
			cMask.visible = false;
			addChild(cMask);
			
			this.mask = cMask;
		}
		
		
		/**
		 * CML initialization. 
		 */
		override public function displayComplete():void 
		{			
			init();	
		}
		
		
		/**
		 * The index of the currently selected tab. 
		 */
		public function get selectedIndex():int { return _selectedIndex; }
		public function set selectedIndex(i:int):void
		{
			if (i < tabs.length)
				_selectedIndex = i;
		}		
		

		
		/**
		 * The width of the container 
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			if(background) background.width = value;
		}		
		
		/**
		 * The height of the container 
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			if (background) background.height = value;
		}
		
		
		
		/**
		 * The color of the background graphic element
		 * @default 0x424141
		 */
		public function get backgroundColor():uint { return _backgroundColor; }
		public function set backgroundColor(c:uint):void
		{
			_backgroundColor = c;
			if (background)
			{
				var ct:ColorTransform = new ColorTransform();
				ct.color = _backgroundColor;
				background.transform.colorTransform = ct;
			}
		}
		
		private var _gradientColors:String = "0x000000, 0xFFFFFF, 0xFFFFFF, 0x00000";
		/**
		 * Input the gradient colors as a comma-separated list.
		 */
		public function get gradientColors():String { return _gradientColors; }
		public function set gradientColors(value:String):void {
			_gradientColors = value;
		}
		
		private var _gradientAlphas:String = "1, 1, 1, 1";
		/**
		 * Input the gradient alphas as a comma separated string.
		 */
		public function get gradientAlphas():String { return _gradientAlphas; }
		public function set gradientAlphas(value:String):void {
			_gradientAlphas = value;
		}
		 
		private var _color:uint = 0x0;
		/**
		 * The flat fill color
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			_color = value;
		}
		
		private var _fill:String = "color";
		/**
		 * Choose whether to use a solid fill color or gradient.
		 * @default "color"
		 */
		public function get fill():String { return _fill; }
		public function set fill(value:String):void {
			_fill = value;
		}
		
		private var _gradientRatios:String = "0, 10, 230, 255";
		public function get gradientRatios():String { return _gradientRatios; }
		public function set gradientRatios(value:String):void {
			_gradientRatios = value;
		}
		
		private var _labelsArray:Array;
		private var _labels:String;
		public function get labels():String { return _labels; }
		public function set labels(value:String):void {
			_labels = value;
			_labelsArray = _labels.split(",");
		}
		
		private var _font:String = "OpenSansRegular";
		/**
		 * Set the font of the tabs.
		 */
		public function get font():String { return _font; }
		public function set font(value:String):void {
			_font = value;
		}
		
		private var _fontSize:Number = 12;
		/**
		 * Set the font size.
		 */
		public function get fontSize():Number { return _fontSize; }
		public function set fontSize(value:Number):void {
			_fontSize = value;
		}
		
		private var _fontColor:uint = 0xffffff;
		/**
		 * Set the font color.
		 */
		public function get fontColor():uint { return _fontColor; }
		public function set fontColor(value:uint):void {
			_fontColor = value;
		}
		

		private var tabs:Array = [];			
		//private var labels:Array = ["label 1", "label 2", "label 3"];	
		
		private var cMask:Graphic;
		private var current:int;
		private var isTweening:Boolean = false;
		private var cTab:TouchContainer;
		private var down:Boolean;
		
		private function onTap(e:GWGestureEvent):void 
		{
			if (isTweening) return;
			else (isTweening = true)
			
			var num:int = 0;
			var tweenArray:Array = [];
			var tweenGroup:ITweenGroup;
						
			for (var i:int = 0; i < tabs.length; i++) {
				if (e.target == tabs[i])
					current = i;
			}
			
			for (i = current + 1; i < tabs.length; i++) {
				tweenArray.push(BetweenAS3.to(tabs[i], { y: background.height - (tabs.length - i) * tabs[i].height }, 0.3));
				tweenArray.push(BetweenAS3.to(contents[i], { y: (background.height - (tabs.length - i) * tabs[i].height) + tabs[i].height }, 0.3));
			}
			
			for (i = 1; i <= current; i++) {
				tweenArray.push(BetweenAS3.to(tabs[i], { y:(i) * tabs[i].height }, 0.3));
				tweenArray.push(BetweenAS3.to(contents[i], { y:((i) * tabs[i].height) + tabs[i].height }, 0.3));
			}	
			
			tweenGroup = BetweenAS3.parallel.apply(null, tweenArray);
			tweenGroup.onComplete = function():void { isTweening = false };
			tweenGroup.play();			
		}

		private function createTab():TouchSprite
		{
			var tab:Graphic = new Graphic();
			tab.shape = "rectangle";
			tab.color = _color;
			tab.fill = _fill;
			tab.gradientAlphas = _gradientAlphas;
			tab.gradientColors = _gradientColors;
			tab.gradientRatios = _gradientRatios;
			tab.width = width ;
			tab.height = height * .1;
			tab.gradientWidth = tab.width;
			tab.gradientHeight = tab.height;
			tab.gradientRotation = 90;
			tab.lineStroke = 0;
			
			var ts:TouchSprite = new TouchSprite;
			ts.addChild(tab);
			
			return ts;
		}	
				
		
		
		private function onDrag(e:GWGestureEvent):void
		{
			
			for (var i:int = 0; i < tabs.length; i++) {
				if (e.target == tabs[i])
					current = i;
			}
			
			if (current == 0) return;
			
			down = false;
			if (e.value.drag_dy > 0) 
				down = true;
			
			
			if (down){
				for (i = current; i < tabs.length; i++) {
					
					if (tabs[i].y + e.value.drag_dy > background.height - (tabs[i].height * (tabs.length - i))) {
						tabs[i].y = background.height - (tabs[i].height * (tabs.length - i));
						contents[i].y = tabs[i].height + tabs[i].y;
					}	
					else {
						tabs[i].y += e.value.drag_dy;
						contents[i].y += e.value.drag_dy;
					}
				}
			}
			else {
				for (i = 1; i <= current; i++) {
					
					if (tabs[i].y + e.value.drag_dy < tabs[i].height * i) {
						tabs[i].y = tabs[i].height * i;
						contents[i].y = tabs[i].height + tabs[i].y;
					}
					else {
						tabs[i].y += e.value.drag_dy;
						contents[i].y += e.value.drag_dy;
					}
				}
			}
			
			var _snapping:Boolean = true;
			
			if (_snapping) {
				addEventListener(GWGestureEvent.RELEASE, onRelease);
			}
		}
		
		private function onRelease(e:GWGestureEvent):void {
			if (isTweening) return;
			else (isTweening = true)
			
			// Find each tab that's been pulled away from either rest point
			// Fill a group with all tabs so they all snap the same direction on release.
			var dragGroup:Array = [];
			for (var j:int = 1; j < tabs.length; j++) {
				if ( tabs[j].y == j * tabs[j].height || tabs[j].y == background.height - (tabs.length - j) * tabs[j].height) {
					continue;
				} else {
					dragGroup.push(tabs[j]);
				}
			}
			
			//trace("Target index:", dragGroup.indexOf(e.target));
			
			var tweenArray:Array = [];
			var tweenGroup:ITweenGroup;
			
			// Check the target's snapping direction, and make everything in the dragGroup follow that;
			if (e.target.y < (background.height - (tabs[tabs.indexOf(e.target)].height * tabs.indexOf(e.target))) / 2) {
				for (var k:int = 0; k < dragGroup.length; k++) 
				{
					// Grab index of the dragGroup member in the actual list of tabs.
					var cNum:Number = tabs.indexOf(dragGroup[k]);
					
					// up?
					tweenArray.push(BetweenAS3.to(tabs[cNum], { y:(cNum) * tabs[cNum].height }, 0.3));
					tweenArray.push(BetweenAS3.to(contents[cNum], { y:((cNum) * tabs[cNum].height) + tabs[cNum].height }, 0.3));
				}
			} else {
				for (var i:int = 0; i < dragGroup.length; i++) 
				{
					var cNum:Number = tabs.indexOf(dragGroup[i]);
					
					// Down?
					tweenArray.push(BetweenAS3.to(tabs[cNum], { y: background.height - (tabs.length - cNum) * tabs[cNum].height }, 0.3));
					tweenArray.push(BetweenAS3.to(contents[cNum], { y: (background.height - (tabs.length - cNum) * tabs[cNum].height) + tabs[cNum].height }, 0.3));
				}
				
			}
			
			tweenGroup = BetweenAS3.parallel.apply(null, tweenArray);
			tweenGroup.onComplete = function():void { isTweening = false };
			tweenGroup.play();
		}
		
		
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			background = null;
			tabs = null;			
		}		
		
		
	}

}