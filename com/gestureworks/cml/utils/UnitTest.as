package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.element.OrbMenu;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.system.System;
	
	/**
	 * Class to test dispose methods and usage of system memory.
	 * ...
	 * @author uma
	 */
	
	public class UnitTest 
	{
		public static var classname:String;
			
		/**
		 * constructor
		 */
		public function UnitTest() 
		{
			 
		}

		/**
		 * sets the timer
		 */
		public static function setTime(): void
		{
		  var timer:Timer = new Timer(1000, 4);
		  timer.start();
		  timer.addEventListener(TimerEvent.TIMER , timerListener);
		}
		
		/**
		 * on timer event calls test dispose method
		 * @param	event
		 */
		public static function timerListener(event:TimerEvent):void
		{
			UnitTest.testdispose();
		}
		
		/**
		 * method checks the system memory usage
		 */
		public static function testdispose():void
		{
			var test =  CMLParser.instance.createObject(classname);
		    test.init();
		//	test.dispose();
			test = null;
			
			var memory:String = Number( System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb';
            trace("memory:" + memory);
			
		} 
	}

}