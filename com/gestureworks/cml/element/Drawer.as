package com.gestureworks.cml.element 
{
	import com.gestureworks.events.GWGestureEvent;
	import flash.display.DisplayObject;
	import flash.events.GestureEvent;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Exponential;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	
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
		private var _background:*;
		private var _applyMask:Boolean = true;
		private var _initializeOpen:Boolean = false;
		
		private var _title:String;
		private var _handleColor:uint = 0x2E2D2D;		
		private var _bkgColor:uint = 0x424141;
		
		private var _leftCornerRadius:Number = 15;
		private var _rightCornerRadius:Number = 15;
		private var _handleWidth:Number = 500;
		private var _handleHeight:Number = 60;
		
		private var contentHolder:Container;
		private var contentMask:Graphic;
		private var upTween:ITweenGroup;
		private var downTween:ITweenGroup;

		
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
		public function init():void
		{
			addHandle();
			addContentHolder();
			generateTweens();
			initialState();
			
			if (applyMask)
			{
				contentMask = new Graphic();
				contentMask.shape = "rectangle";
				contentMask.width = width;
				contentMask.height = height;
				addUIComponent(contentMask);
				mask = contentMask;
			}				
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
		 * The <code>TouchContainer</code> used to close/open the drawer when tapped. The handle must contain a <code>DisplayObject</code> 
		 * to target.
		 */
		public function get handle():* { return _handle; }
		public function set handle(h:*):void
		{
			if (h is TouchContainer)
				_handle = h;
			else if(childList.hasKey(h.toString()))
				_handle = childList.getKey(h.toString());
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
		 * Sets the width of the drawer and drawer's UI components
		 * @default 500
		 */
		override public function set width(value:Number):void 
		{
			super.width = value;
			contentHolder.width = value;
			handleWidth = value;
		}

		/**
		 * Sets the height of the drawer and drawer's UI components
		 * @default 420
		 */
		override public function set height(value:Number):void 
		{
			super.height = value;
			contentHolder.height = handle ? value - handle.height : value;
		}
		
		/**
		 * Reroutes child additions to the drawer's content holder
		 * @param	child  the child to add to the content holder
		 * @return  the child added to the content holder
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject 
		{
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
		 * Configures the handle component and adds it the drawer. If the handle is not provided, a
		 * default is generated. 
		 */
		private function addHandle():void
		{
			if (!handle)
			{
				handle = new TouchContainer();				
				var handleBkg:Graphic = new Graphic();
				handleBkg.shape = "roundRectangleComplex";
				handleBkg.topRightRadius = rightCornerRadius;
				handleBkg.topLeftRadius = leftCornerRadius;
				handleBkg.color = handleColor;
				handleBkg.lineStroke = 0;
				handleBkg.width = handleWidth;
				handleBkg.height = handleHeight;
				handle.addChild(handleBkg);
			}
			
			handle.width = handleWidth;
			handle.height = handleHeight;
			handle.gestureList = { "n-tap":true };			
			
			addUIComponent(handle);
			addLabel();
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
			contentHolder.width = width;
			contentHolder.height = height - handle.height;
			contentHolder.y = handle.height;
			
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
			var upTweens:Array = new Array();
			upTweens.push(BetweenAS3.tween(handle, { y:0 }, null, .3, Exponential.easeOut));
			upTweens.push(BetweenAS3.tween(contentHolder, { y:handle.height }, null, .3, Exponential.easeOut));
			upTween = BetweenAS3.parallel.apply(null, upTweens);
			
			var downTweens:Array = new Array();
			downTweens.push(BetweenAS3.tween(handle, { y:contentHolder.height +1}, null, .3, Exponential.easeOut));
			downTweens.push(BetweenAS3.tween(contentHolder, { y:contentHolder.height + handle.height +1}, null, .3, Exponential.easeOut));
			downTween = BetweenAS3.parallel.apply(null, downTweens);
		}
		
		/**
		 * Positions the components and registers the appropriate listener based on the drawer's initial state.
		 */
		private function initialState():void
		{
			if (!initializeOpen)
			{
				handle.y = contentHolder.height + 1;
				contentHolder.y = contentHolder.height + handle.height + 1;
				handle.addEventListener(GWGestureEvent.TAP, open); 
			}
			else
				handle.addEventListener(GWGestureEvent.TAP, close); 
		}
		
		/**
		 * Plays the up tween, registers the close listener, and removes the open listener
		 * @param	e  the tap event
		 */
		private function open(e:GWGestureEvent):void
		{
			downTween.stop();
			upTween.play();
			handle.removeEventListener(GWGestureEvent.TAP, open);
			handle.addEventListener(GWGestureEvent.TAP, close);			
		}

		/**
		 * Plays the down tween, registers the open listener, and removes the close listener
		 * @param	e  the tap event
		 */		
		private function close(e:GWGestureEvent):void
		{
			upTween.stop();
			downTween.play();
			handle.removeEventListener(GWGestureEvent.TAP, close);
			handle.addEventListener(GWGestureEvent.TAP, open);			
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