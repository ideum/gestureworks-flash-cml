package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWTouchEvent;
	import flash.text.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.filters.*;
	import com.gestureworks.core.GestureWorks;

	/**
	 * The DatePicker element provides date selection capability. The initial state will display the current
	 * date. Previous and future months can be navigated via the "left" and "right" arrows. 
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 	
		var dp:DatePicker = new DatePicker();
		dp.x = 300;
		dp.y = 200;
		dp.scaleX = dp.scaleX + 2;
		dp.scaleY = dp.scaleY + 2;
		dp.addEventListener(StateEvent.CHANGE, selectedDate);
		addChild(dp);
				
		function selectedDate(event:StateEvent):void
		{
			trace(event.value);
		}	
	 * 
	 * </codeblock>
	 * 
	 * @author Shaun
	 * @see ColorPicker
	 */
	public class DatePicker extends TouchContainer
	{ 
		private var todayDate:Date = new Date();	// contains Date of Today
		private var xDate:Date = new Date();		// contains currently selected date
		private var monthArray:Array;		
		private var dayNameArray:Array;
		private var daysMonthArray:Array = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);		
		private var fontColor:uint;		
		private var _calendarWidth:Number = 240;
		private var _calendarHeight:Number = 175;
		private var mCount:Number;					
		private var yCount:Number;					
		private var calendar:Sprite;			// container-Sprite for the Date-Grid
		private var bkg:Sprite;
		private var prevArrow:TouchSprite;
		private var nextArrow:TouchSprite;
		private var dayDisplay:Sprite;
		
		/**
		 * Constructor
		 */				
		public function DatePicker() {
			super();
			mouseChildren = true;
			init();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			todayDate = null;
			xDate = null;
			monthArray = null;
			dayNameArray = null;
			daysMonthArray = null;
			prevArrow = null;
			dayDisplay = null;
			nextArrow = null;
			calendar = null;
			bkg = null;
		} 
		 
		
		/**
		 * A flag indicating the calendars color scheme
		 */
		private var _colorSchemeDark:Boolean = true;
		public function get colorSchemeDark():Boolean { return _colorSchemeDark; } 
		public function set colorSchemeDark(ds:Boolean):void
		{
			_colorSchemeDark = ds;
		}
		
		/**
		 * The selected date
		 */
		private var _selectedDate:String;				
		public function get selectedDate():String { return _selectedDate; }
		public function set selectedDate(d:String):void
		{
			_selectedDate = d;
		}
		
		/**
		 * A comma delimited string representing the days of the week
		 */
		private var _days:String = "Mo,Tu,We,Th,Fr,Sa,Su";
		public function get days():String { return _days; }
		public function set days(d:String):void
		{
			for (var i:int = d.split(",").length; i < 7; i++)
				d = d + ",";
			_days = d;
		}			
		
		/**
		 * A comma delimited string representing the months of the year
		 */
		private var _months:String = "January,February,March,April,May,June,July,August,September,October,November,December";
		public function get months():String { return _months };
		public function set months(m:String):void
		{
			for (var i:int = m.split(",").length; i < 12; i++)
				m = m + ",";
			_months = m;
		}
			
		/**
		 * Initializes the calendar components
		 * @param	e  ADDED_TO_STAGE event
		 */
		override public function init():void{
			fontColor = _colorSchemeDark ? 0xCCCCCC : 0x333333;
			bkg = drawRadialBackground(_calendarWidth, _calendarHeight);
		    addChild(bkg);			
			
			nextArrow = drawArrow(_calendarWidth-25,12,0);
			addEvents(nextArrow, onNext); 
			addChild(nextArrow);
			
			prevArrow = drawArrow(25,12,180);
			addEvents(prevArrow, onPrev);
			addChild(prevArrow);
			
			dayDisplay = drawDayNameRow(5, 25);
			addChild(dayDisplay);
			
			calendar = drawDateGrid(xDate.getMonth(), xDate.getFullYear());
		    addChild(calendar);			
		}		
		
		/**
		 * Create the box displaying the days of the week. 
		 * @param	x  x location
		 * @param	y  y location
		 * @return  the days of the week display
		 */
		private function drawDayNameRow(x:Number,y:Number):Sprite{
			var cont:Sprite = new Sprite();
			cont.x = x;
			cont.y = y;
			
			//add day container to the calendar
			var rowColor:uint = _colorSchemeDark ? 0x000000 : 0xFFFFFF;			
			cont.addChild(rect(_calendarWidth - 15, 22, rowColor, 0.5));
			
			//add day names to the container
			dayNameArray = _days.split(",");
			for(var i:int = 0; i<7; i++){
				var d_txt:TextField = new TextField();
				d_txt.text = dayNameArray[i];
				d_txt.width = 30; d_txt.height = 20;
				d_txt.selectable = false;
				d_txt.y = 3;
				d_txt.x = i*32;
				d_txt.setTextFormat(txtFormat("dayNameRow"));
				cont.addChild(d_txt);
			}
			return cont;
		}
		
		/**
		 * Generates the month and day display and the date layout of the calendar
		 * @param	mm  the selected month
		 * @param	yy  the selected year
		 * @return  the current calendar
		 */
		private function drawDateGrid(mm:Number, yy:Number):Sprite{
			var grid:Sprite = new Sprite();
			grid.x = 5;
			addChild(grid);

			/*******month and year display******/
			var month_txt:TextField = new TextField();
			monthArray = _months.split(",");
            month_txt.text = monthArray[mm] + " " + yy;
            month_txt.autoSize = TextFieldAutoSize.CENTER;
			month_txt.y = 5;			
			month_txt.x = (_calendarWidth / 2) - (month_txt.width / 2);
			month_txt.setTextFormat(txtFormat("month"));
			grid.addChild(month_txt);
			
			/*******rows of date numbers******/
			var daysNr:int = (yy%4 == 0 && mm == 1) ? 29 : daysMonthArray[mm];  //  recognizing leap years
			var myDate:Date = new Date(yy,mm,1);								//  1st of Month(mm)
			// dayNameNr is required for the x-value of each Datenumber and determines which day the 1st is (0 = Sunday etc.)
			// since getDay() returns a 0 for Sunday, dayNameNr needs to be switched to 7
			var dayNameNr:int = (myDate.getDay() == 0) ? 7 : myDate.getDay();  
			var row:int = 1;
			for(var i:int = 1; i<=daysNr; i++){	
				if (dayNameNr == 1 && i != 1)  row++;  // increases the row-counter
				//date number container
				var nr_spr:TouchSprite = new TouchSprite();
				nr_spr.name = (mm+1)+"/"+i+"/"+yy;
				nr_spr.x = (dayNameNr-1)*32;
				nr_spr.y = row*20+30;
				nr_spr.mouseChildren = false;
				addEvents(nr_spr, onDateSelect);				
				
				//background sprite for each date number
				var bgrColor:uint;
				bgrColor = _colorSchemeDark ? 0x000000 : 0xFFFFFF;
				var nr_bgr:Sprite = rect(27, 18, bgrColor, 0.5);
				nr_bgr.x = 3;
				nr_spr.addChild(nr_bgr);
				
				//text field for each date number
				var nr_txt:TextField = new TextField();
				nr_txt.width = 30;
				nr_txt.height = 20;
				nr_txt.text = String(i);
				nr_txt.selectable = false;	
				
				//initialize selected date to today's date
				selectedDate = todayDate.getMonth()+1 + "/" + todayDate.getDate() + "/" + todayDate.getFullYear();
				
				// format text & highlight date of today:
				(todayDate.getFullYear() == yy && todayDate.getMonth() == mm  && todayDate.getDate() == i) ? nr_txt.setTextFormat(txtFormat("today")) : nr_txt.setTextFormat(txtFormat("dateGrid"));
				nr_spr.addChild(nr_txt);
				
				grid.addChild(nr_spr);								
				dayNameNr == 7 ? dayNameNr = 1 : dayNameNr++;  // if dayNameNr is 7 (Sunday) set it back to 1 (Monday)
			}
			return grid;
		}
		
		/**
		 * Adds the appropriate events to the calendar utilities (arrows and dates buttons)
		 * @param	util  the utilitiy to add the button to
		 * @param	touchHandler  the handler for the touch event
		 */
		private function addEvents(util:TouchSprite, touchHandler:Function):void
		{
			util.buttonMode = true;	
			util.addEventListener(GWTouchEvent.TOUCH_BEGIN, touchHandler);
			util.addEventListener(GWTouchEvent.TOUCH_OVER, onOver);			
			util.addEventListener(GWTouchEvent.TOUCH_OUT, onOut);					
		}		
		
		//**************************Event Handlers**************************//
		/**
		 * Handles the "next month" button touch event
		 * @param	e  the event
		 */
		private function onNext(e:*):void{
			removeChild(calendar);					// remove current DateGrid-Sprite
			if(isNaN(mCount)) mCount = xDate.month;    	// initialize month-Counter but only if not already set
			if(isNaN(yCount)) yCount = xDate.fullYear; 	// initialize year-Counter but only if not already set
			if(mCount == 11){							// if month == 11 (December)
				mCount = 0;								// set month to 0 (January)
				yCount++;								// and increase the year counter by 1
			} else {
				mCount++;								// else increase month counter by 1
			}
			calendar = drawDateGrid(mCount, yCount);	// make DateGrid-Sprite for the next month
			addChild(calendar);
		}
		
		/**
		 * Handles the "previous month" button touch event
		 * @param	e  the event
		 */
		private function onPrev(e:*):void{
			removeChild(calendar);					// remove current DateGrid-Sprite
			if(isNaN(mCount)) mCount = xDate.month;		// initialize month-Counter but only if not already set
			if(isNaN(yCount)) yCount = xDate.fullYear;	// initialize year-Counter but only if not already set
			if(mCount == 0){							// if month == 0 (January)
				mCount = 11;							// set month to 11 (December)
				yCount--;								// and decrease the year counter by 1
			} else {
				mCount--;								// else decrease month counter by 1
			}
			calendar = drawDateGrid(mCount, yCount);	// make DateGrid-Sprite for the previous month
			addChild(calendar);
		}
		
		/**
		 * Reduces the alpha value on touch over events
		 * @param	e  the event
		 */
		private function onOver(e:*):void {
			e.target.alpha = 0.5;
		}
		
		/**
		 * Increases the alpah value on touch out events
		 * @param	e  the event
		 */
		private function onOut(e:*):void{
			e.target.alpha = 1;
		}
		
		/**
		 * Handles the date selection
		 * @param	e  the selection event
		 */
		private function onDateSelect(e:*):void{
			selectedDate = e.target.name;
			dispatchEvent(new StateEvent(StateEvent.CHANGE, this.id, "selectedDate", _selectedDate));			
		}

		//************************** UTILITIES **************************//
		
		/**
		 * Sets the text format of the calendar element
		 * @param	str  the calendar element
		 * @return  the text format
		 */
		private function txtFormat(str:String):TextFormat{
			var fmt:TextFormat = new TextFormat("Arial",12,fontColor);			
			if(str == "dateGrid") fmt.align = TextFormatAlign.RIGHT;
			if(str == "dayNameRow") {
				fmt.bold = true;
				fmt.align = TextFormatAlign.RIGHT;
			}
			if(str == "today") {
				fmt.align = TextFormatAlign.RIGHT;
				fmt.bold = true;
				fmt.color = _colorSchemeDark ? 0xFFE609 : 0x042162;
			}
			return fmt;
		}
		
		/**
		 * Creates the arrow Sprites for the previous button and next button
		 * @param	x  the x location
		 * @param	y  the y location
		 * @param	rot  the rotation value
		 * @return  the arrow sprite
		 */
		private function drawArrow(x:Number,y:Number,rot:Number):TouchSprite{  
			var spr:TouchSprite = new TouchSprite();
			spr.graphics.lineStyle(1, 0);
			spr.graphics.beginFill(fontColor);
			spr.graphics.lineTo(0,-7.5);
			spr.graphics.lineTo(7.5,0);
			spr.graphics.lineTo(0,7.5);
			spr.graphics.endFill();
			spr.x = x;
			spr.y = y;
			spr.rotation = rot;
			return spr;
		}
		
		/**
		 * Creates a background with gradient-fill
		 * @param	tw  background width
		 * @param	th  background height
		 * @return  the background Sprite
		 */
		private function drawRadialBackground(tw:Number, th:Number):Sprite{  
			var bg:Sprite = new Sprite();
			var fillType:String = GradientType.LINEAR;
			var colors:Array = new Array();			
			colors = _colorSchemeDark ? [0x4B5767, 0x1F222E] : [0xEEEEEE, 0xBFBFBF];
			var alphas:Array = [1, 1];
			var ratios:Array = [0x00, 0xFF];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(tw, th, 90, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			bg.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			bg.graphics.lineStyle(2, 0xD9D9D9);
			bg.graphics.drawRoundRect(0, 0, tw, th, 5);
			//=============== apply Filter ===============//
			var glowColor:uint;
			glowColor = _colorSchemeDark ? 0x000000 : 0x888888;
			//glowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout)
			var glowFilter:BitmapFilter = new GlowFilter(glowColor, 1, 50, 25, 1, BitmapFilterQuality.HIGH, true, false);
			//shadowFilter( distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout)
			var shadowFilter:DropShadowFilter = new DropShadowFilter(5,90,0x000000,1,10,10,0.9,BitmapFilterQuality.LOW,false,false);
			var myFilter:Array = new Array(glowFilter, shadowFilter);
			bg.filters = myFilter;
			return bg;
		}
		
		/**
		 * Creates a simple rectangle with a color-fill
		 * @param	w  width 
		 * @param	h  height
		 * @param	col  color
		 * @param	alph  alpha
		 * @return  the rectangle Sprite
		 */
		private function rect(w:Number,h:Number,col:uint, alph:Number):Sprite{  
			var s:Sprite = new Sprite();
			s.graphics.beginFill(col,alph);
			s.graphics.drawRoundRect(0,0,w,h,10);
			s.graphics.endFill();
			return s;
		}
			
	}

}