package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.easing.Expo;
	import com.greensock.easing.ExpoOut;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * The <code>Drawer</code> is a container that animates down to conceal its contents (closed state) and animates up to
	 * reveal its contents (open state). The open and closed states are toggled by tapping the top of the drawer (handle).
	 * @author Shaun
	 */
	public class Drawer extends Container
	{
	
		private var _label:Text;
		private var _labelFont:String = "OpenSansRegular";
		private var _labelColor:uint = 0xFFFFFF;
		private var _labelFontSize:Number = 30;
		private var _handle:TouchContainer;
		private var _leftHandle:TouchContainer;
		private var _rightHandle:TouchContainer;
		private var _background:*;
		private var _applyMask:Boolean = true;
		private var _initializeOpen:Boolean = false;
		
		private var _title:String;
		private var _handleColor:uint = 0x2E2D2D;		
		private var _bkgColor:uint = 0x424141;
		
		private var _leftCornerRadius:Number = 20;
		private var _rightCornerRadius:Number = 20;
		private var _handleWidth:Number = 500;
		private var _handleHeight:Number = 60;
		private var _handleLineStroke:Number = 0;
		private var _handleLineColor:uint = 0xFFFFFF;
		private var _useSideHandles:Boolean = false;
		private var _useLeftHandle:Boolean = false;
		private var _useRightHandle:Boolean = false;
		private var _handleOrientation:String = "top";
		
		private var _isOpen:Boolean = false;	
		public function get isOpen():Boolean { return _isOpen; }
		
		private var contentHolder:Container;
		private var contentMask:Graphic;
		private var upTween:TimelineLite;
		private var downTween:TimelineLite;
		private var timer:Timer;

		
		/**
		 * Constructor
		 */
		public function Drawer() 
		{
			super();
			contentHolder = new Container();
			width = 500;
			height = 420;			
		}
		
		/**
		 * CML init
		 */
		override public function displayComplete():void 
		{
			init();
		}
		
		/**
		 * Initialization function
		 */
		override public function init():void
		{
			addHandles();
			addContentHolder();
			generateTweens();
			initialState();
			
			//drawer mask
			if (applyMask)
			{
				contentMask = new Graphic();
				contentMask.shape = "rectangle";
				contentMask.width = width;
				contentMask.height = height;				
				addUIComponent(contentMask);
				mask = contentMask;
			}			
			
			//contentHolder mask
			var chmsk:Graphic = new Graphic();
			chmsk.shape = "rectangle";
			chmsk.width = contentHolder.width;
			chmsk.height = contentHolder.height;
			contentHolder.addChild(chmsk);
			contentHolder.mask = chmsk;			
			
			//threshold timer to allow tweening to process
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, thresholdCheck);
		}
		
		/**
		 * The <code>Text</code> component that displays the drawer's title
		 */
		public function get label():* { return _label; }
		public function set label(l:*):void
		{
			if (l is Text)
				_label = l;
			else if(childList.hasKey(l.toString()))
				_label = childList.getKey(l.toString());
		}
		
		/**
		 * The top mounted <code>TouchContainer</code> used to close/open the drawer when tapped. The handle must contain a <code>DisplayObject</code> 
		 * to target.
		 */
		public function get handle():* { return _handle; }
		public function set handle(h:*):void
		{
			if (h is TouchContainer)
				_handle = h;
			else if(childList.hasKey(h.toString()))
				_handle = childList.getKey(h.toString());
				
			addUIComponent(_handle);				
		}			
		
		/**
		 * The left mounted <code>TouchContainer</code> used to close the drawer when tapped. The handle must contain a <code>DisplayObject</code> 
		 * to target.
		 */
		public function get leftHandle():* { return _leftHandle; }
		public function set leftHandle(h:*):void
		{
			if (h is TouchContainer)
				_leftHandle = h;
			else if(childList.hasKey(h.toString()))
				_leftHandle = childList.getKey(h.toString());
				
			addUIComponent(_leftHandle);			
		}
		
		/**
		 * The right mounted <code>TouchContainer</code> used to close the drawer when tapped. The handle must contain a <code>DisplayObject</code> 
		 * to target.
		 */
		public function get rightHandle():* { return _rightHandle; }
		public function set rightHandle(h:*):void
		{
			if (h is TouchContainer)
				_rightHandle = h;
			else if(childList.hasKey(h.toString()))
				_rightHandle = childList.getKey(h.toString());							
				
			addUIComponent(_rightHandle);			
		}
		
		/**
		 * A flag indicating the hiding of the top mounted handle when the drawer is in the open state and transferring the
		 * close operation to the side handles. 
		 */
		public function get useSideHandles():Boolean { return _useSideHandles; }
		public function set useSideHandles(s:Boolean):void
		{
			_useSideHandles = s;
			useLeftHandle = s;
			useRightHandle = s;
		}
		
		/**
		 * A flag indicating the hiding of the top mounted handle when the drawer is in the open state and transferring the
		 * close operation to the left handle. 
		 */
		public function get useLeftHandle():Boolean { return _useLeftHandle; }
		public function set useLeftHandle(l:Boolean):void
		{
			_useLeftHandle = l;
		}				
		
		/**
		 * A flag indicating the hiding of the top mounted handle when the drawer is in the open state and transferring the
		 * close operation to the right handle. 
		 */
		public function get useRightHandle():Boolean { return _useRightHandle; }
		public function set useRightHandle(l:Boolean):void
		{
			_useRightHandle = l;
		}						
		
		/**
		 * The <code>DisplayObject</code> representing the drawer's content area
		 */
		public function get background():* { return _background; }
		public function set background(b:*):void
		{
			if (b is DisplayObject)
				_background = b;
			else if(childList.hasKey(b.toString()))
				_background = childList.getKey(b.toString());
		}				
		
		/**
		 * The text of the handle's label
		 */
		public function get title():String { return _title; }
		public function set title(t:String):void
		{
			_title = t;
		}				
		
		/**
		 * The color of the drawer's handle
		 * @default 0x2E2D2D
		 */
		public function get handleColor():uint { return _handleColor; }
		public function set handleColor(c:uint):void
		{
			_handleColor = c;
		}
		
		/**
		 * The width of the handle's border in pixels
		 */
		public function get handleLineStroke():Number { return _handleLineStroke; }
		public function set handleLineStroke(l:Number):void
		{
			_handleLineStroke = l;
		}
		
		/**
		 * The color the handle's border 
		 */
		public function get handleLineColor():uint { return _handleLineColor; }
		public function set handleLineColor(c:uint):void
		{
			_handleLineColor = c;
		}		
		
		/**
		 * The color of the drawer's content area
		 * @default 0x424141
		 */
		public function get bkgColor():uint { return _bkgColor; }
		public function set bkgColor(c:uint):void
		{
			_bkgColor = c;
		}									
		
		/**
		 * The radius of the upper right corner of the handle
		 * @default 15
		 */
		public function get rightCornerRadius():Number { return _rightCornerRadius; }
		public function set rightCornerRadius(r:Number):void
		{
			_rightCornerRadius = r;
		}									
		
		/**
		 * The radius of the upper left corner of the handle
		 * @default 15
		 */		
		public function get leftCornerRadius():Number { return _leftCornerRadius; }
		public function set leftCornerRadius(r:Number):void
		{
			_leftCornerRadius = r;
		}									
		
		/**
		 * The width of the drawer's handle
		 * @default 500
		 */
		public function get handleWidth():Number { return _handleWidth; }
		public function set handleWidth(w:Number):void
		{
			_handleWidth = w;
		}									
		
		/**
		 * The height of the drawer's handle
		 * @default 60
		 */
		public function get handleHeight():Number { return _handleHeight; }
		public function set handleHeight(h:Number):void
		{
			_handleHeight = h;
		}		
		
		/**
		 * Flag indicating the application of a mask to the drawer to prevent
		 * content from exceeding the drawer's boundaries
		 * @default true
		 */
		public function get applyMask():Boolean { return _applyMask; }
		public function set applyMask(m:Boolean):void
		{
			_applyMask = m;
		}
		
		/**
		 * Flag indicating whether the initial state of the drawer is open or closed
		 * @default false
		 */
		public function get initializeOpen():Boolean { return _initializeOpen; }
		public function set initializeOpen(o:Boolean):void
		{
			_initializeOpen = o;
		}
		
		/**
		 * The font of the handle's label
		 * @default OpenSansRegular
		 */
		public function get labelFont():String { return _labelFont; }
		public function set labelFont(f:String):void
		{
			_labelFont = f;
		}
		
		/**
		 * The font size of the handle's label
		 * @default 30
		 */
		public function get labelFontSize():Number { return _labelFontSize; }
		public function set labelFontSize(s:Number):void
		{
			_labelFontSize = s;
		}
		
		/**
		 * The color of the handle's label
		 * @default 0xFFFFFF
		 */
		public function get labelColor():uint { return _labelColor; }
		public function set labelColor(c:uint):void
		{
			_labelColor = c;
		}
		
		/**
		 * The side of the container (top, bottom, right, left) to position the handle. This setting also determines
		 * the direction the Drawer opens and closes. 
		 * @default top
		 */
		public function get handleOrientation():String { return _handleOrientation; }
		public function set handleOrientation(h:String):void {
			_handleOrientation = h;
		}
		
		/**
		 * Flag indicating handle orientation is either left or right
		 */
		public function get horizontalHandle():Boolean {
			return handleOrientation == "left" || handleOrientation == "right";
		}
		
		/**
		 * Sets the width of the drawer and drawer's UI components
		 * @default 500
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			contentHolder.width = value;
			
			if (horizontalHandle) {
				contentHolder.width = handle ? value - handle.height : value;
				handleWidth = contentHolder.height;
			}
			else {	
				contentHolder.width = leftHandle ? contentHolder.width - leftHandle.width : width;
				contentHolder.width = rightHandle ? contentHolder.width - rightHandle.width : width;
				handleWidth = value;				
			}
			
			if (contentMask) contentMask.width = contentHolder.width;
		}

		/**
		 * Sets the height of the drawer and drawer's UI components
		 * @default 420
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			
			if(horizontalHandle){
				contentHolder.height = leftHandle ? contentHolder.height - leftHandle.width : height;
				contentHolder.height = rightHandle ? contentHolder.height - leftHandle.width : height;
			}
			else{
				contentHolder.height = handle ? value - handle.height : value;
			}
				
			if (contentMask) contentMask.height = contentHolder.height;
		}
		
		/**
		 * Reroutes child additions to the drawer's content holder
		 * @param	child  the child to add to the content holder
		 * @return  the child added to the content holder
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{
			if (contains(child))
				return child;
			return contentHolder.addChild(child);
		}
		
		/**
		 * Reroutes child additions to the drawer's content holder
		 * @param	child  the child to add to the content holder
		 * @return  the child added to the content holder
		 */		
		override public function addChildAt(child:DisplayObject, index:int):flash.display.DisplayObject 
		{
			return contentHolder.addChildAt(child, index);
		}
		
		/**
		 * Adds a UI component directly to the drawer 
		 * @param	child  the UI component
		 */
		private function addUIComponent(child:DisplayObject):void
		{
			super.addChild(child);
		}
		
		/**
		 * Configures the handle components and adds them to the drawer. If the handles are not provided,
		 * defaults are generated. 
		 */
		private function addHandles():void
		{
			//update handle dimensions
			height = height;
			width = width;			
			
			if (!handle)
				handle = getDefaultHandle();
			if (useLeftHandle && ! leftHandle)
				leftHandle = getDefaultHandle("left");
			if (useRightHandle && ! rightHandle)			
				rightHandle = getDefaultHandle("right");
				
			handle.gestureList = { "n-tap":true, "n-flick":true };
			handle.width = handleWidth;
			handle.height = handleHeight			
			
			if (leftHandle) leftHandle.gestureList = { "n-tap":true, "n-flick":true };
			if (rightHandle) rightHandle.gestureList = { "n-tap":true, "n-flick":true };
					
			addLabel();
		}
		
		/**
		 * Generates default drawer handles 
		 * @param	type "left" or "right", top handle by default
		 * @return default handle
		 */
		private function getDefaultHandle(type:String = null):TouchContainer
		{
			var h:TouchContainer = new TouchContainer();
			var bkg:Graphic = new Graphic();
			bkg.shape = "roundRectangleComplex";
			bkg.color = handleColor;
			bkg.lineStroke = handleLineStroke;
			bkg.lineColor = handleLineColor;
			h.addChild(bkg);
			
			switch(type)
			{
				case "left":
					bkg.topLeftRadius = leftCornerRadius;
					bkg.width = h.width= handleHeight;
					bkg.height = h.height = height - handleHeight;
					break;
				case "right":
					bkg.topRightRadius = rightCornerRadius;
					bkg.width = h.width = handleHeight;
					bkg.height = h.height = height - handleHeight;
					break;
				default:
					bkg.topRightRadius = rightCornerRadius;
					bkg.topLeftRadius = leftCornerRadius;
					bkg.width = h.width = handleWidth;
					bkg.height = h.height = handleHeight;
					break;
			}
			
			return h;
		}
		
		/**
		 * Sets the label's text and adds it to the handle. If a label is not provided,
		 * a default is generated. 
		 */
		private function addLabel():void
		{
			if (!label)
			{
				label = new Text();
				label.textAlign = "center";
				label.verticalAlign = true;
				label.width = handleWidth;
				label.height = handleHeight;
				label.font = labelFont;
				label.color = labelColor;
				label.fontSize = labelFontSize;
			}
			
			if (title) 
				label.text = title;
				
			handle.addChild(label);
		}
		
		/**
		 * Configures the drawers content container and background. If a background is not provided,
		 * a default is generated. 
		 */
		private function addContentHolder():void
		{
			width = width;
			height = height;
			contentHolder.y = handle.height;
			contentHolder.x = leftHandle ? leftHandle.width : 0;
			
			if(!background)
			{
				background = new Graphic();
				background.shape = "rectangle";
				background.color = bkgColor;
				background.lineStroke = 0;
			}
			
			background.width = contentHolder.width;
			background.height = contentHolder.height;	
			contentHolder.addChildAt(background, 0);
			
			addUIComponent(contentHolder);			
		}
		
		/**
		 * Creates the up and down tweens for the drawer components. 
		 */
		private function generateTweens():void
		{	
			var upDestination:Dictionary = new Dictionary();
			var downDestination:Dictionary = new Dictionary();
			var ease:ExpoOut = Expo.easeOut;
			
			var hUp:Object, hDwn:Object;
			var cUp:Object, cDwn:Object;
			
			switch(handleOrientation) {
				case "left":
					hUp = { x:0, ease:ease };
					hDwn = { x:contentHolder.width, ease:ease };
					cUp = { x:handle.height, ease:ease };
					cDwn = { x:contentHolder.width + handle.height, ease:ease };							
					break;
				case "right":
					hUp = { x:contentHolder.width+handle.height, ease:ease };
					hDwn = { x:handle.height, ease:ease };
					cUp = { x:0, ease:ease };
					cDwn = { x:-contentHolder.width, ease:ease };								
					break;
				case "bottom":
					hUp = { y:contentHolder.height + handle.height, ease:ease };
					hDwn = { y:handle.height, ease:ease };
					cUp = { y:0, ease:ease };
					cDwn = { y:-contentHolder.height, ease:ease };					
					break;
				default:
					hUp = { y:0, ease:ease };
					hDwn = { y:contentHolder.height, ease:ease };
					cUp = { y:handle.height, ease:ease };
					cDwn = { y:contentHolder.height + handle.height, ease:ease };					
				break;
			}
			
			upDestination[handle] = hUp;
			downDestination[handle] = hDwn;			
			upDestination[contentHolder] = cUp;
			downDestination[contentHolder] = cDwn;	
			
			if (leftHandle) {
				upDestination[leftHandle] = cUp;
				downDestination[leftHandle] = cDwn;
			}
			if (rightHandle) {
				upDestination[rightHandle] = cUp;
				downDestination[rightHandle] = cDwn;
			}			
			
			var upTweens:Array = new Array();				
			for (var key:* in upDestination)
				upTweens.push(TweenLite.to(key, .3, upDestination[key]));
			upTween = new TimelineLite();
			upTween.appendMultiple(upTweens);
			upTween.stop();
			
			var downTweens:Array = new Array();
			for (key in downDestination)
				downTweens.push(TweenLite.to(key, .3, downDestination[key]));
			downTween = new TimelineLite({onComplete: handleTransition});
			downTween.appendMultiple(downTweens);
			downTween.stop();
		}
		
		/**
		 * Positions the components and registers the appropriate listener based on the drawer's initial state.
		 */
		private function initialState():void
		{		
			positionHandle();
			if (!initializeOpen)
			{
				_isOpen = false;	
				handle.addEventListener(GWGestureEvent.TAP, open); 
				handle.addEventListener(GWGestureEvent.FLICK, open);
			}
			else
			{
				_isOpen = true;
				handle.addEventListener(GWGestureEvent.TAP, close); 
				handle.addEventListener(GWGestureEvent.FLICK, close);
			}
			
			if (leftHandle)
			{
				leftHandle.y = contentHolder.y;
				leftHandle.addEventListener(GWGestureEvent.TAP, close);
				leftHandle.addEventListener(GWGestureEvent.FLICK, close);
			}
			if (rightHandle)
			{
				rightHandle.y = contentHolder.y;
				rightHandle.x = contentHolder.x + contentHolder.width;
				rightHandle.addEventListener(GWGestureEvent.TAP, close);
				rightHandle.addEventListener(GWGestureEvent.FLICK, close);
			}			
			
			if(useRightHandle || useLeftHandle) handle.visible = !_isOpen;										
			if (leftHandle) leftHandle.visible = _isOpen;
			if (rightHandle) rightHandle.visible = _isOpen;
		}
		
		/**
		 * Set the orientation and position of each handle
		 */
		private function positionHandle():void {
			if (initializeOpen) {
				switch(handleOrientation) {
					case "left":
						handle.rotation = -90;
						handle.y = contentHolder.height;
						contentHolder.y = -handle;
						contentHolder.x = handle.height;
						break;
					case "right":
						handle.rotation = 90;
						handle.x = contentHolder.width + handle.height;
						contentHolder.y = handle.y;
						break;
					case "bottom":
						handle.y = contentHolder.height;
						DisplayUtils.rotateAroundCenter(handle, 180);
						contentHolder.y -= handle.height;
						break;
					default:
						break;
				}				
			}
			else{
				switch(handleOrientation) {
					case "left":
						handle.rotation = -90;
						handle.y = contentHolder.height;
						handle.x = contentHolder.width;
						contentHolder.y = -handle;
						contentHolder.x = contentHolder.width + handle.height;
						break;
					case "right":
						handle.rotation = 90;
						handle.x = handle.height;
						contentHolder.y = handle.y;
						contentHolder.x = -contentHolder.width;
						break;
					case "bottom":
						DisplayUtils.rotateAroundCenter(handle, 180);
						contentHolder.y = -(contentHolder.height + handle.height);
						break;
					default:
						handle.y = contentHolder.height;
						contentHolder.y = contentHolder.height + handle.height;						
						break;
				}
			}
		}
		
		/**
		 * Plays the up tween, registers the close listener, and removes the open listener
		 * @param	e  the tap event
		 */
		public function open(e:GWGestureEvent = null):void
		{	
			if (!tweenThreshold()) return;
			handleTransition();
			if (leftHandle)
				leftHandle.searchChildren(Graphic).topLeftRadius = leftCornerRadius;
			if(rightHandle)
				rightHandle.searchChildren(Graphic).topRightRadius = rightCornerRadius;
			upTween.restart();
			handle.removeEventListener(GWGestureEvent.TAP, open);
			handle.removeEventListener(GWGestureEvent.FLICK, open);
			handle.addEventListener(GWGestureEvent.TAP, close);	
			handle.addEventListener(GWGestureEvent.FLICK, close);	
		}

		/**
		 * Plays the down tween, registers the open listener, and removes the close listener
		 * @param	e  the tap event
		 */		
		public function close(e:GWGestureEvent = null):void
		{			
			if (!tweenThreshold()) return;
			handle.visible = true;
			if(leftHandle)
				leftHandle.searchChildren(Graphic).topLeftRadius = 0;
			if(rightHandle)
				rightHandle.searchChildren(Graphic).topRightRadius = 0;			
			downTween.restart();
			handle.removeEventListener(GWGestureEvent.TAP, close);
			handle.removeEventListener(GWGestureEvent.FLICK, close);
			handle.addEventListener(GWGestureEvent.TAP, open);	
			handle.addEventListener(GWGestureEvent.FLICK, open);	
		}
		
		/**
		 * Locks tweening until threshold expires
		 * @return
		 */
		private function tweenThreshold():Boolean {
			if (timer.running)
				return false;
			timer.start();
			return true;
		}
		
		/**
		 * Tween threshold expired so unlock tweening
		 * @param	e
		 */
		private function thresholdCheck(e:TimerEvent):void {
			timer.stop();
		}
		
		/**
		 * Sets the open state of the drawer and updates the visibility of the handles
		 */
		private function handleTransition():void
		{
			_isOpen = !_isOpen;
			if (useLeftHandle || useRightHandle)
				handle.visible = !_isOpen;
			if (leftHandle)
				leftHandle.visible = _isOpen;
			if (rightHandle)
				rightHandle.visible = _isOpen;
		}
		
		/**
		 * Destructor
		 */
		override public function dispose():void 
		{
			super.dispose();
			
			label = null;
			background = null;
			contentHolder = null;
			contentMask = null;
			upTween = null;
			downTween = null;
			
			handle.removeEventListener(GWGestureEvent.TAP, open);
			handle.removeEventListener(GWGestureEvent.TAP, close);
			handle = null;			
		}
	}

}