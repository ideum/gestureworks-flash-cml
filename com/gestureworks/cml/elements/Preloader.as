package com.gestureworks.cml.elements 
{
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.events.FileEvent;
	import com.gestureworks.cml.events.StateEvent;
	import com.gestureworks.cml.managers.FileManager;
	import com.gestureworks.events.GWTouchEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.utils.Timer;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	/**
	 * 
	 * 
	 * @author Ideum
	 * @see Container
	 */
	public class Preloader extends TouchContainer
	{
		private var _filesToLoad:int = FileManager.fileCount;
		private var _filesLoaded:int = 0;
		private var _percentage:Number
		
		/**
		 * Constructor
		 */
		public function Preloader() 
		{
			super();
			mouseChildren = true;
		}
		
		private var _currentNumberDisplay:*;
		/**
		 * Sets the text object that will relay the current total.
		 */
		public function get currentNumberDisplay():* { return _currentNumberDisplay; }
		public function set currentNumberDisplay(value:*):void {
			if (!value) return;
			
			if (value is DisplayObject)
				_currentNumberDisplay = value;
			else 
				_currentNumberDisplay = searchChildren(value);	
		}
		
		private var _fileNumberTotal:*;
		/**
		 * Sets the text object that will rela
		 */
		public function get fileNumberTotal():* { return _fileNumberTotal; }
		public function set fileNumberTotal(value:*):void {
			if (!value) return;
			_fileNumberTotal = value;
		}
		
		private var _percentageDisplay:*;
		/**
		 * Sets the object to route percentage data too.
		 */
		public function get percentageDisplay():* { return _percentageDisplay; }
		public function set percentageDisplay(value:*):void {
			if (!value) return;
			
			if (value is DisplayObject)
				_percentageDisplay = value;
			else
				_percentageDisplay = searchChildren(value);
		}

		/**
		 * CML callback initialisation
		 */
		override public function init():void
		{
			FileManager.addEventListener(FileEvent.FILE_LOADED, onFileLoaded);
		}
		
		private function onFileLoaded(e:FileEvent):void {
			/*if (!(_currentNumberDisplay is Text)) {
				for (var i:int = 0; i < numChildren; i++) {
					if ("id" in getChildAt(i) && getChildAt(i)["id"] == _currentNumberDisplay.name()) {
						_currentNumberDisplay = getChildAt(i);
					}
				}
			}*/
			
			_filesToLoad = FileManager.fileCount;
			_filesLoaded++;
			_percentage = _filesLoaded / _filesToLoad;
			_percentage *= 100;
			Text(_currentNumberDisplay).text = _percentage + "%";
			if (_percentageDisplay) {
				if (_percentageDisplay is ProgressBar) {
					ProgressBar(_percentageDisplay).input(_percentage / 100);
				} else if (_percentageDisplay is Text) {
					
				}
			}
			trace("File loaded heard in Preloader.", _filesLoaded, "/", _filesToLoad, _percentage);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{	
			super.dispose();
			_currentNumberDisplay = null;
			_fileNumberTotal = null;
			_percentageDisplay = null;
			FileManager.removeEventListener(FileEvent.FILE_LOADED, onFileLoaded);
		}		
	}
}