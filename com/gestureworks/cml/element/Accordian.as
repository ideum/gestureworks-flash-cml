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
	public class Accordian extends Container 
	{
		private var _selectedIndex:int = -1;
		private var _backgroundColor:uint = 0x424141;
		private var _spacing:Number = 5;
		private var background:Graphic;
		private var contents:Array = [];
		
		
		public function Accordian() 
		{
			super();
			width = 500;
			height = 375;	
			background = new Graphic();			
			addChild(background);
		}

		
		
		/**
		 * Initialization call
		 */
		public function init():void
		{					
			background.lineStroke = 0;
			background.color = backgroundColor;
			background.shape = "rectangle";
			background.width = width;
			background.height = height;
			
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
		

		private var tabs:Array = [];			
		private var labels:Array = ["label 1", "label 2", "label 3"];	
		
		private var cMask:Graphic;
		private var current:int;
		private var isTweening:Boolean = false;
		private var cTab:TouchContainer;
		
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

		
		public function append(obj:DisplayObject):void
		{
			contents.push(obj);
			addChild(obj);
		}
		
		
		

		private function createTab():TouchSprite
		{
			var tab:Graphic = new Graphic();
			tab.shape = "rectangle";
			tab.color = 0xFFFFFF;
			tab.fill = "gradient";
			tab.gradientAlphas = "1, 1, 1, 1";
			tab.gradientColors = "0x000000, 0xFFFFFF, 0xFFFFFF, 0x00000";
			tab.gradientRatios = "0, 10, 230, 255";
			tab.width = background.width ;
			tab.height = background.height * .1;
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
			
			var down:Boolean = false;
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
			

		}
		
		
		private function onRelease(e:GWGestureEvent):void
		{
			trace("release");
			
	
			
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