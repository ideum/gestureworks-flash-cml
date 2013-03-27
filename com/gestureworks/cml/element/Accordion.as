package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.events.GWTouchEvent;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	
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
			
			snapLow = [];
			snapHigh = [];
			
			var tabHeight:Number;
			
			for (var i:int = 0; i < contents.length; i++)
			{
				tabs[i] = createTab();
				

				tabs[i].gestureList = { "n-tap":true, "n-drag-inertia":true };
				tabs[i].gestureEvents = true;
				tabs[i].addEventListener(GWGestureEvent.TAP, onTap);								
				tabs[i].addEventListener(GWGestureEvent.DRAG, onDrag);								
				tabs[i].addEventListener(GWGestureEvent.RELEASE, onRelease);
				tabs[i].gestureReleaseInertia = false;
					
				//contents[i].y = (i * tabs[i].height) + tabs[i].height;
				
				addChild(tabs[i]);
				
				if (i == 0)
					tabs[i].y = 0;
				else if (i > 0)
					tabs[i].y = tabs[i - 1].height + tabs[i - 1].y - 1;
					
				snapLow.push(tabs[i].y);
				snapHigh.push(tabs[i].y + tabs[i].height + height);
				
				contents[i].y = (tabs[i].height + tabs[i].y - 4);
				if (_labelsArray){
					if (i < _labelsArray.length){
						var label:Text = new Text();
						label.font = _font;
						label.color = _fontColor;
						label.fontSize = _fontSize;
						label.autoSize = "left";
						label.text = _labelsArray[i];
						tabs[i].addChild(label);
						if (autoLayout){
							label.y = (tabs[i].height - label.height) / 2;
							label.x = 15;
							if (twirlIndicator)
								label.x = fontSize * 2;
						} else {
							label.y = paddingTop;
							label.x = paddingLeft;
							if (twirlIndicator)
								label.x = fontSize + (paddingLeft * 2);
						}
						_labelsArray[i] = label;
					}
				}
				
				if (width == 0 && contents[i].width > width)
					width = contents[i].width;
					
				if (height == 0 && contents[i].height > height)
					height = contents[i].height;
			}
			
			tabHeight = tabs[0].height;	
			if (twirlIndicator)
				twirlIcons[twirlIcons.length - 1].rotation = 180;
				
			background.height = snapHigh[snapHigh.length - 1] + tabs[tabs.length - 1].height;
			//trace(background.height);
			
			cMask = new Graphic;
			cMask.shape = "rectangle";
			cMask.height = background.height;
			cMask.width = width;
			cMask.init();
			cMask.visible = false;
			addChild(cMask);
			
			this.mask = cMask;
			_current = tabs.length - 1;
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
		 
		private var _color:uint = 0xff00ff;
		/**
		 * The flat fill color
		 */
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			_color = value;
		}
		
		private var _fill:String = "gradient";
		/**
		 * Choose whether to use a solid fill color or gradient.
		 * @default "gradient"
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
			if(!_labelsArray || _labelsArray.length < 1)
				_labelsArray = _labels.split(",");
			else {
				var pa:Array = _labels.split(",");
				for (var i:int = 0; i < pa.length; i++) 
				{
					if (i < _labelsArray.length) {
						_labelsArray[i].font = _font;
						_labelsArray[i].color = _fontColor;
						Text(_labelsArray[i]).text = pa[i];
					}
					else
						throw(new Error("Cannot create new items on already initialized menu."));
				}
			}
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
		
		private var _autoLayout:Boolean = true;
		/**
		 * Set whether to automatically lay out labels,
		 * or to use padding properties that have been set.
		 */
		public function get autoLayout():Boolean { return _autoLayout; }
		public function set autoLayout(value:Boolean):void {
			_autoLayout = value;
		}
		
		private var _twirlIndicator:Boolean = false;
		/**
		 * Set whether or not to display triangles that twirl when a menu is opened.
		 */
		public function get twirlIndicator():Boolean { return _twirlIndicator; }
		public function set twirlIndicator(value:Boolean):void {
			_twirlIndicator = value;
		}
		
		private var _twirlStroke:Number = 1;
		/**
		 * Set the thickness of the twirl triangle. Everything else is based on font size.
		 */
		public function get twirlStroke():Number { return _twirlStroke; }
		public function set twirlStroke(value:Number):void {
			_twirlStroke = value;
		}
		
		private var _snapping:Boolean = true;
		/**
		 * Set whether or not the accordion menus snap on release.
		 */
		public function get snapping():Boolean { return _snapping; }
		public function set snapping(value:Boolean):void {
			_snapping = value;
		}
		
		private var _current:int;
		public function get current():int { return _current; }

		private var tabs:Array = [];			
		//private var labels:Array = ["label 1", "label 2", "label 3"];	
		
		private var cMask:Graphic;
		
		private var isTweening:Boolean = false;
		private var cTab:TouchContainer;
		private var down:Boolean;
		private var twirlIcons:Array = [];
		private var snapHigh:Array;
		private var snapLow:Array;
		
		private function onTap(e:GWGestureEvent):void 
		{
			if (isTweening) return;
			else (isTweening = true)
			
			var num:int = 0;
			var tweenArray:Array = [];
			var tweenGroup:TimelineLite;
						
			for (var i:int = 0; i < tabs.length; i++) {
				if (e.target == tabs[i]) {
					_current = i;
					if (twirlIndicator)
						tweenArray.push(TweenLite.to(twirlIcons[current], 0.3, {rotation:180}));
				}
				else {
					if (twirlIndicator)
						tweenArray.push(TweenLite.to(twirlIcons[i], 0.3, {rotation:90}));
				}
			}
			
			var futureSpace:Number = tabs[_current].y + tabs[_current].height + height;
			
			for (i = _current + 1; i < tabs.length; i++) {
				tweenArray.push(TweenLite.to(tabs[i], 0.3, {y:snapHigh[i]}));
				tweenArray.push(TweenLite.to(contents[i], 0.3, {y:snapHigh[i] + tabs[i].height-4}));
			}
			
			for (i = 1; i <= _current; i++) {
				tweenArray.push(TweenLite.to(tabs[i], 0.3, { y:snapLow[i] }));
				tweenArray.push(TweenLite.to(contents[i], 0.3,{ y:snapLow[i] + tabs[i].height - 4}));
			}	
			
			tweenGroup = new TimelineLite( { onComplete:function():void { isTweening = false }} );
			tweenGroup.appendMultiple(tweenArray);
			tweenGroup.play();			
		}
		
		public function select(index:Number):void {
						
			if (index > -1 && index < tabs.length) {
				_current = index;
				
			}
			var i:int = 0;
			for (i = _current + 1; i < tabs.length; i++) {
				tabs[i].y = snapHigh[i];
				contents[i].y = tabs[i].y + tabs[i].height - 3;
				if (twirlIndicator)
					twirlIcons[i].rotation = 90;
			}
			
			for (i = 1; i <= _current; i++) {
				tabs[i].y = snapLow[i];
				contents[i].y = snapLow[i] + tabs[i].height - 3;
				if (twirlIndicator)
					twirlIcons[i].rotation = 90;
			}	
			
			if (twirlIndicator)
				twirlIcons[_current].rotation = 180;
		}

		private function createTab():TouchSprite
		{
			var label:Text = new Text();
			label.font = _font;
			label.color = _fontColor;
			label.fontSize = _fontSize;
			label.autoSize = "left";
			label.text = "This is a test.";
			addChild(label);
			
			var tab:Graphic = new Graphic();
			tab.shape = "rectangle";
			tab.color = _color;
			tab.fill = _fill;
			tab.gradientAlphas = _gradientAlphas;
			tab.gradientColors = _gradientColors;
			tab.gradientRatios = _gradientRatios;
			tab.width = width;
			if (autoLayout)
				tab.height = label.height * 2;
			else
				tab.height = label.height + paddingBottom + paddingTop;
			tab.gradientWidth = tab.width;
			tab.gradientHeight = tab.height;
			tab.gradientRotation = 90;
			tab.lineStroke = 0;
			
			removeChild(label);
			
			var ts:TouchSprite = new TouchSprite;
			ts.addChild(tab);
			
			if (twirlIndicator) {
				var sp:Sprite = new Sprite();
				sp.graphics.beginFill(0x000000, 0);
				sp.graphics.drawCircle(fontSize / 2, fontSize / 2, fontSize / 2);
				sp.graphics.endFill();
				
				var twirl:Graphic = new Graphic();
				twirl.shape = "triangle";
				twirl.height = fontSize;
				twirl.fillAlpha = 0;
				//twirl.color = backgroundColor;
				//twirl.fill = "color";
				twirl.lineStroke = _twirlStroke;
				twirl.lineColor = fontColor;
				//twirl.rotation = 90;
				twirl.x -= fontSize / 2;
				twirl.y -= fontSize / 2;
				
				sp.addChild(twirl);
				ts.addChild(sp);
				if (autoLayout) {
					sp.x = sp.width + (sp.width / 2);
					sp.y = sp.height;
				} else {
					sp.x = paddingLeft + (fontSize);
					sp.y = paddingTop + (fontSize * 0.75);
				}
				sp.rotation = 90;
				twirlIcons.push(sp);
				//paddingLeft = sp.width + (paddingLeft * 2);
			}
			
			return ts;
		}	
				
		
		
		private function onDrag(e:GWGestureEvent):void
		{
			
			for (var i:int = 0; i < tabs.length; i++) {
				if (e.target == tabs[i]) {
					_current = i;
				}
			}
			
			var dragGroup:Array = [];
		/*	for (var j:int = 1; j < tabs.length; j++) {
				if ( tabs[j].y == j * tabs[j].height || tabs[j].y == background.height - ((tabs.length - j) * tabs[j].height)) {
					continue;
				} else {
					dragGroup.push(tabs[j]);
				}
			}*/
			
			for (var j:int = 1; j < tabs.length; j++) {
				if ( tabs[j].y == snapLow[j] || tabs[j].y == snapHigh[j]) {
					continue;
				} else {
					dragGroup.push(tabs[j]);
				}
			}
			
			if (_current == 0) return;
			
			down = false;
			if (e.value.drag_dy > 0) 
				down = true;
			
			
			if (down){
				for (i = _current; i < tabs.length; i++) {
					
					/*if (tabs[i].y + e.value.drag_dy > background.height - (tabs[i].height * (tabs.length - i))) {
						tabs[i].y = background.height - (tabs[i].height * (tabs.length - i));
						contents[i].y = tabs[i].height + tabs[i].y;
						
					}	
					else {
						tabs[i].y += e.value.drag_dy;
						contents[i].y += e.value.drag_dy;
					}*/
					
					if (tabs[i].y + e.value.drag_dy > snapHigh[i]) {
						tabs[i].y = snapHigh[i];
						contents[i].y = tabs[i].height + snapHigh[i] - 3;
						
					}	
					else {
						tabs[i].y += e.value.drag_dy;
						contents[i].y = tabs[i].y + tabs[i].height - 3;
					}
					
					if (dragGroup.length > 1) {
						//trace("Drag grouping");
						for (var k:int = dragGroup.length - 1; k > -1; k--) 
						{
							//trace("K:", k);
							var index:Number = tabs.indexOf(dragGroup[k]);
							if (k == dragGroup.length - 1 && twirlIndicator) // Last element in the group that was open before, getting closed now.
								twirlIcons[index].rotation = 180 - (90 * (tabs[index].y / snapHigh[index]));
							else if (k == 0 && twirlIndicator)
								twirlIcons[index - 1].rotation = (90 * (tabs[index].y / snapHigh[index])) + 90;
						}
					}
					else if (i - 1 == _current - 1 && dragGroup.length == 1 && twirlIndicator) {
						twirlIcons[i - 1].rotation = (90 * (tabs[i].y / snapHigh[i])) + 90;
						twirlIcons[i].rotation = 180 - (90 * (tabs[i].y / snapHigh[i]));
					}
				}
			}
			else {
				for (i = 1; i <= _current; i++) {
					
					if (tabs[i].y + e.value.drag_dy < snapLow[i]) {
						tabs[i].y = snapLow[i];
						contents[i].y = tabs[i].height + snapLow[i] - 3;
					}
					else {
						tabs[i].y += e.value.drag_dy;
						contents[i].y = tabs[i].y + tabs[i].height - 3;
					}
					
					if (dragGroup.length > 1){
						for (var l:int = dragGroup.length - 1; l > -1; l--) 
						{
							var ndex:Number = tabs.indexOf(dragGroup[l]);
							
							if (l == dragGroup.length - 1 && twirlIndicator) { // Last element in the group that was closed before, getting opened now.
								//twirlIcons[index].rotation = 180 - (90 * (tabs[index].y / (height - (tabs[index].height * (index)))));
								var zIndex:Number = tabs.indexOf(dragGroup[0]);
								zIndex -= 1;
								//var baseHeight:Number = tabs[zIndex].y + tabs[zIndex].height;
								// snapLow[zIndex] + tabs[zIndex].height;
								//var groupHeight:Number = tabs[ndex].height * (dragGroup.length - 1);
								// snapHigh[nDex];
								//var nTarget:Number = baseHeight + groupHeight;
								twirlIcons[ndex].rotation = (90 * (snapLow[ndex] / tabs[ndex].y)) + 90;
								//trace(twirlIcons[ndex].rotation);
							}
							else if (l == 0 && twirlIndicator)
								twirlIcons[ndex - 1].rotation = (90 * ((tabs[ndex].y - (tabs[ndex - 1].y + tabs[ndex - 1].height)) / (height - tabs[ndex].height))) + 90;
						}
					}
					else if (dragGroup.length == 1 && twirlIndicator) {
						var n:Number = _current - 1;
						var offset:Number = tabs[n].y + tabs[n].height;
						var target:Number = height - tabs[current].height;
						var tempY:Number = tabs[current].y - offset;
						twirlIcons[n].rotation = 90 * ((tabs[current].y - snapLow[current]) / (snapHigh[current] - snapLow[current])) + 90;
						twirlIcons[current].rotation = 180 - (90 * ((tabs[current].y  - snapLow[current]) / (snapHigh[current] - snapLow[current])));
					}
				}
			}
			
			if (_snapping) {
				addEventListener(GWGestureEvent.RELEASE, onRelease);
			}
		}
		
		private function onRelease(e:GWGestureEvent):void {
			//tabs[i].gestureReleaseInertia = false;
			if (isTweening) return;
			else (isTweening = true)
			
			// Find each tab that's been pulled away from either rest point
			// Fill a group with all tabs so they all snap the same direction on release.
			var dragGroup:Array = [];
			for (var j:int = 1; j < tabs.length; j++) {
				if ( tabs[j].y == snapLow[j] || tabs[j].y == snapHigh[j]) {
					continue;
				} else {
					dragGroup.push(tabs[j]);
				}
			}
			
			//trace("Target index:", dragGroup.indexOf(e.target));
			
			var outIndex:Number = tabs.indexOf(dragGroup[0]);
			var endIndex:Number = tabs.indexOf(dragGroup[dragGroup.length - 1]);
			
			var tweenArray:Array = [];
			var tweenGroup:TimelineLite;
			var targetIndex:Number = tabs.indexOf(e.target)
			
			// Check the target's snapping direction, and make everything in the dragGroup follow that;
			if (e.target.y < (tabs[targetIndex].height + snapLow[targetIndex] + (height / 2))) {
				for (var k:int = 0; k < dragGroup.length; k++) 
				{
					// Grab index of the dragGroup member in the actual list of tabs.
					var cNum:Number = tabs.indexOf(dragGroup[k]);
					
					// up?
					//tweenArray.push(BetweenAS3.to(tabs[cNum], { y:(cNum) * tabs[cNum].height }, 0.3));
					//tweenArray.push(BetweenAS3.to(contents[cNum], { y:((cNum) * tabs[cNum].height) + tabs[cNum].height }, 0.3));
					tweenArray.push(TweenLite.to(tabs[cNum], 0.3, { y: snapLow[cNum] }));
					tweenArray.push(TweenLite.to(contents[cNum], 0.3, { y:snapLow[cNum] + tabs[cNum].height }));
				}
				
				
				// if ab || B
				if (e.target == dragGroup[0] || e.target == dragGroup[dragGroup.length - 1] && twirlIndicator) {
					//Rotate the item preceding the dragGroup to closed.
					tweenArray.push(TweenLite.to(twirlIcons[outIndex-1], 0.3, {rotation:90}));
					//Rotate the item ending the dragGroup to open.
					tweenArray.push(TweenLite.to(twirlIcons[endIndex], 0.3, {rotation:180}));
				}
				
			} else {
				for (var i:int = 0; i < dragGroup.length; i++) 
				{
					var cNum:Number = tabs.indexOf(dragGroup[i]);
					
					// Down?
					//tweenArray.push(BetweenAS3.to(tabs[cNum], { y: background.height - (tabs.length - cNum) * tabs[cNum].height }, 0.3));
					//tweenArray.push(BetweenAS3.to(contents[cNum], { y: (background.height - (tabs.length - cNum) * tabs[cNum].height) + tabs[cNum].height }, 0.3));
					
					tweenArray.push(TweenLite.to(tabs[cNum], 0.3, { y: snapHigh[cNum] }));
					tweenArray.push(TweenLite.to(contents[cNum], 0.3, { y: snapHigh[cNum] + tabs[cNum].height }));
				}
				
				// if a || ba
				if (e.target == dragGroup[0] || e.target == dragGroup[dragGroup.length - 1] && twirlIndicator) {
					// Rotate the item preceding all the dragGroup items to open.
					tweenArray.push(TweenLite.to(twirlIcons[outIndex-1], 0.3, {rotation:180}));
					//Rotate the item ending the dragGroup to closed.
					tweenArray.push(TweenLite.to(twirlIcons[endIndex], 0.3, {rotation:90}));
				}
			}
			
			
			tweenGroup = new TimelineLite( { onComplete: function():void { isTweening = false; }} );
			tweenGroup.appendMultiple(tweenArray);
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