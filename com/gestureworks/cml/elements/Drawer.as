package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.utils.DisplayUtils;
	import com.gestureworks.cml.utils.StringUtils;
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
		private var _handleAlpha:Number = 1.0;		
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
		private var _handleGestureList:Object;
		private var _dragAngle:Number = 0;
		private var dragOpen:Boolean;
		private var dragDelta:Number;
		
		private var _isOpen:Boolean = false;	
		public function get isOpen():Boolean { return _isOpen; }
		
		private var contentHolder:Container;
		private var contentMask:Graphic;
		private var timer:Timer;
		
		private var upDestination:Dictionary = new Dictionary();
		private var downDestination:Dictionary = new Dictionary();			
		
		private var initialized:Boolean = false;

		
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
		 * Initialization function
		 */
		override public function init():void
		{
			addHandles();
			addContentHolder();
			generateTweenDest();
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
			initialized = true;
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
		 * The alpha of the drawer's handle
		 * @default 1.0
		 */		
		public function get handleAlpha():Number { return _handleAlpha; }
		public function set handleAlpha(value:Number):void {
			_handleAlpha = value;
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
		public function get verticalHandle():Boolean {
			return handleOrientation == "left" || handleOrientation == "right";
		}
		
		/**
		 * Determines the drag direction. Must be adjusted for rotation and nested rotations.
		 * @default 0
		 */
		public function get dragAngle():Number { return _dragAngle; }
		public function set dragAngle(d:Number):void {
			_dragAngle = d;
		}
		
		/**
		 * Sets the width of the drawer and drawer's UI components
		 * @default 500
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			
			if (verticalHandle) {
				contentHolder.width = handle ? value - handle.height : value;
				handleWidth = contentHolder.height;
			}
			else {	
				contentHolder.width = leftHandle ? width - leftHandle.width : width;
				contentHolder.width = rightHandle ? contentHolder.width - rightHandle.width : width;
				handleWidth = value;				
			}
			
			if (contentMask) contentMask.width = width;
			if (background) background.width = contentHolder.width;
			
			update = initialized;
		}

		/**
		 * Sets the height of the drawer and drawer's UI components
		 * @default 420
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			
			if(verticalHandle){
				contentHolder.height = leftHandle ? height - leftHandle.width : height;
				contentHolder.height = rightHandle ? contentHolder.height - leftHandle.width : height;
			}
			else{
				contentHolder.height = handle ? value - handle.height : value;
			}
				
			if (contentMask) contentMask.height = height;
			if (background) background.height = contentHolder.height;
			
			update = initialized;
		}
		
		/**
		 * Reroutes non-UI child additions to the drawer's content holder
		 * @param	child  the child to add to the content holder
		 * @return  the child added to the content holder
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{
			try {
				//is UI
				super.getChildIndex(child);
			}
			catch (e:Error) {
				return contentHolder.addChild(child);
			}
			return child;
		}
		
		/**
		 * Reroutes non-UI child additions to the drawer's content holder
		 * @param	child  the child to add to the content holder
		 * @return  the child added to the content holder
		 */		
		override public function addChildAt(child:DisplayObject, index:int):flash.display.DisplayObject 
		{
			try {
				super.getChildIndex(child);
			}
			catch (e:Error) {
				return contentHolder.addChildAt(child, index);	
			}
			return child;
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
		 * Modifies the handle's gesture list to disable default (tap, flick, drag) gestures. Through AS3, pass the list
		 * as an Object (e.g. {n-tap:true, n-drag:true}) and through CML, pass the list as comma delimited string 
		 * (e.g. "n-tap:true, n-drag:true"). 
		 * @param	list
		 */
		public function get handleGestureList():Object { return _handleGestureList; }
		public function set handleGestureList(list:*):void {			
			if (list is XML) { 
				var tmp:Object = new Object();
				for each(var g:String in list.split(",")) 
					tmp[StringUtils.trim(g.split(":")[0])] = Boolean(g.split(":")[1]); 
				list = tmp;
			}				
			
			_handleGestureList = list;
			if(handle) handle.gestureList = handleGestureList;				
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
			if(!handleGestureList)
				handleGestureList = { "n-tap":true, "n-flick":false, "n-drag":true };
			else
				handleGestureList = handleGestureList;  //reset incase handle was null when list was set
				
			handle.nativeTransform = false;
			handle.affineTransform = false;
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
			bkg.alpha = handleAlpha;
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
		 * Creates the up and down tween destinations for drawer components
		 */
		private function generateTweenDest():void
		{	
			var ease:ExpoOut = Expo.easeOut;						
			var hUp:Object, hDwn:Object;
			var cUp:Object, cDwn:Object;
			
			switch(handleOrientation) {
				case "left":
					
					hUp = { x:0, ease:ease };
					hDwn = { x:contentHolder.width, ease:ease };
					cUp = { x:handle.height, ease:ease };
					cDwn = { x:contentHolder.width + handle.height, ease:ease, onComplete:handleTransition };	
					
					//drag limits
					handle.minX = hUp.x;
					handle.maxX = hDwn.x;
					contentHolder.minX = cUp.x;
					contentHolder.maxX = cDwn.x;
					
					break;
				case "right":
					
					hUp = { x:contentHolder.width+handle.height, ease:ease };
					hDwn = { x:handle.height, ease:ease };
					cUp = { x:0, ease:ease };
					cDwn = { x: -contentHolder.width, ease:ease, onComplete:handleTransition };
					
					//drag limits
					handle.minX = hDwn.x;
					handle.maxX = hUp.x;
					contentHolder.minX = cDwn.x;
					contentHolder.maxX = cUp.x;
					
					break;
				case "bottom":
					
					hUp = { y:contentHolder.height + handle.height, ease:ease };
					hDwn = { y:handle.height, ease:ease };
					cUp = { y:0, ease:ease };
					cDwn = { y: -contentHolder.height, ease:ease, onComplete:handleTransition };	
					
					//drag limits
					handle.minY = hDwn.y;
					handle.maxY = hUp.y;
					contentHolder.minY = cDwn.y;
					contentHolder.maxY = cUp.y;		
					
					break;
				default:
					
					hUp = { y:0, ease:ease };
					hDwn = { y:contentHolder.height, ease:ease };
					cUp = { y:handle.height, ease:ease };
					cDwn = { y:contentHolder.height + handle.height, ease:ease, onComplete:handleTransition };
					
					//drag limits
					handle.minY = hUp.y;
					handle.maxY = hDwn.y;
					contentHolder.minY = cUp.y;
					contentHolder.maxY = cDwn.y;							
					
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
		}
		
		/**
		 * Positions the components 
		 */
		private function initialState():void
		{		
			positionHandle();
			_isOpen = initializeOpen;
			
			if (leftHandle){
				leftHandle.y = contentHolder.y;
				leftHandle.visible = isOpen;
			}
			if (rightHandle)
			{
				rightHandle.y = contentHolder.y;
				rightHandle.x = contentHolder.x + contentHolder.width;
				rightHandle.visible = isOpen;
			}						
			if (useRightHandle || useLeftHandle) 
				handle.visible = !isOpen;	
				
			addEventListeners();
		}
		
		/**
		 * Registers the appropriate listener based on the drawer's initial state. Side handles will always
		 * close the drawer since they are inaccessible when the drawer is closed.
		 */
		private function addEventListeners():void {
			
			var action:Function = isOpen ? close : open;
			
			//descrete gesture event listeners
			if (handleGestureList["n-tap"]) {				
				handle.addEventListener(GWGestureEvent.TAP, action);
				if (leftHandle) leftHandle.addEventListener(GWGestureEvent.TAP, close);
				if (rightHandle) rightHandle.addEventListener(GWGestureEvent.TAP, close);				
			}			
			if (handleGestureList["n-flick"]) {				
				handle.addEventListener(GWGestureEvent.FLICK, action);
				if (leftHandle) leftHandle.addEventListener(GWGestureEvent.FLICK, close);
				if (rightHandle) rightHandle.addEventListener(GWGestureEvent.FLICK, close);				
			}						
			if (handleGestureList["n-drag"]) {
				handle.addEventListener(GWGestureEvent.DRAG, dragHandle);
				handle.addEventListener(GWGestureEvent.RELEASE, function(e:GWGestureEvent):void {
					if (dragOpen)
						open();
					else
						close();
				});
			}
			
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
				
			TweenLite.to(handle, .3, upDestination[handle] );
			TweenLite.to(contentHolder, .3, upDestination[contentHolder] );			
			
			if (leftHandle){
				leftHandle.searchChildren(Graphic).topLeftRadius = leftCornerRadius;
				TweenLite.to(leftHandle, .3, upDestination[contentHolder]);
			}
			if(rightHandle){
				rightHandle.searchChildren(Graphic).topRightRadius = rightCornerRadius;			
				TweenLite.to(rightHandle, .3, upDestination[contentHolder]);
			}
			
			handle.removeEventListener(GWGestureEvent.TAP, open);
			handle.removeEventListener(GWGestureEvent.FLICK, open);
			handle.addEventListener(GWGestureEvent.TAP, close);	
			handle.addEventListener(GWGestureEvent.FLICK, close);
			
			_isOpen = true;
			handleTransition();			
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "open", _isOpen));			
		}

		/**
		 * Plays the down tween, registers the open listener, and removes the close listener
		 * @param	e  the tap event
		 */		
		public function close(e:GWGestureEvent = null):void
		{			
			if (!tweenThreshold()) return;
			handle.visible = true;		
				
			TweenLite.to(handle, .3, downDestination[handle] );
			TweenLite.to(contentHolder, .3, downDestination[contentHolder]);			
			
			if (leftHandle) {				
				leftHandle.searchChildren(Graphic).topLeftRadius = 0;
				TweenLite.to(leftHandle, .3, downDestination[contentHolder]);
			}
			if(rightHandle){
				rightHandle.searchChildren(Graphic).topRightRadius = 0;				
				TweenLite.to(rightHandle, .3, downDestination[contentHolder]);				
			}
			
			handle.removeEventListener(GWGestureEvent.TAP, close);
			handle.removeEventListener(GWGestureEvent.FLICK, close);
			handle.addEventListener(GWGestureEvent.TAP, open);	
			handle.addEventListener(GWGestureEvent.FLICK, open);	
			
			_isOpen = false;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "open", _isOpen));			
		}
		
		/**
		 * Translate content holder with handle drag event
		 * @param	e
		 */
		private function dragHandle(e:GWGestureEvent):void {
			if (verticalHandle) {		
				dragDelta = e.value.drag_dy * Math.sin(dragAngle) + e.value.drag_dx * Math.cos(dragAngle);			
				handle.x += dragDelta;
				contentHolder.x = handle.x + handle.height;
				dragOpen = handleOrientation == "left" ? dragDelta < 0 : dragDelta > 0;
			}
			else {
				dragDelta = e.value.drag_dy * Math.cos(dragAngle) - e.value.drag_dx * Math.sin(dragAngle);				
				handle.y += dragDelta;
				contentHolder.y = handle.y + handle.height;
				dragOpen = handleOrientation == "top" ? dragDelta < 0 : dragDelta > 0;
			}
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
		 * Updates the visibility of the handles
		 */
		private function handleTransition():void
		{
			if (useLeftHandle || useRightHandle)
				handle.visible = !_isOpen;
			if (leftHandle)
				leftHandle.visible = _isOpen;
			if (rightHandle)
				rightHandle.visible = _isOpen;
		}
		
		/**
		 * Updates Drawer when set to true
		 */
		public function set update(u:Boolean):void {
			if (u) {
				generateTweenDest();
				positionHandle();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void 
		{
			super.dispose();
			
			_label = null;
			_background = null; 
			contentHolder = null; 
			contentMask = null; 
			_handle = null;
			_leftHandle = null;
			_rightHandle = null;
			_handleGestureList = null;
			upDestination = null; 
			downDestination = null;
			
			if (timer) { 
				timer.removeEventListener(TimerEvent.TIMER, thresholdCheck);
				timer.stop();
				timer = null;
			}
		}
	}

}