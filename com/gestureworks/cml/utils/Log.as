package com.gestureworks.cml.utils {

	import com.gestureworks.cml.elements.Text;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Ken Willes
	 */
	public final class Log {
		
		/**
		 * message levels
		 */
		public static const ERROR:uint = 3;
		public static const WARNING:uint = 2;
		public static const COMMENT:uint = 1;
		
		public static const OUT_TO_CONSOLE:String = "console";
		public static const OUT_TO_SCREEN:String = "screen";
		
		private var _messages:Array;
		private var _textBox:Text;
		
		/**
		 * stage reference for screen rendering
		 */
		private var _stageRef:Stage;
		
		private function get stageRef():Stage {
			return _stageRef;
		}
		
		private function set stageRef(value:Stage):void {
			_stageRef = value;
		}

		/**
		 * last message string, private for now
		 */
		private var _message:String;
		
		private function get message():String {
			return _message;
		}
		
		private function set message(value:String):void {
			_message = value;
		}
		
		private var _dumpEnabled:Boolean = false;
		
		/**
		 * Sets output level threshold from which log messages may appear. 
		 * Example: _outputLevel = Log.MESSAGE will output all COMMENT, WARNING, ERROR
		 * Example: _outputLevel = Log.WARNING will output all WARNING, ERROR
		 */
		private var _outputLevel:uint;
		public function get outputLevel():uint {
			return _outputLevel;
		}
		
		public function set outputLevel(value:uint):void {
			if ( value <= Log.ERROR && value >= Log.COMMENT) {
				_outputLevel = value;
			} else {
				out("You must specify an message type of Log.COMMENT, Log.WARNING, or Log.ERROR", Log.ERROR);
			}
		}
		/**
		 * sets the intended log type to one of the predefined private const
		 */
		private var _outputMode:String;
		
		public function get outputMode():String {
			return _outputMode;
		}
		
		public function set outputMode(value:String):void {
			switch (value) {
				case OUT_TO_CONSOLE:
					_outputMode = value;
					if (_textBox != null) {
						_textBox.visible = false;
					}
					break;
				case OUT_TO_SCREEN:
					if (stageRef == null) {
						out("You must specify the stage first before using this mode. Set the output mode after CML has loaded", Log.WARNING);
					} else {
						if (_textBox == null) { 
							buildOutputPanel(); 
						} else {
							_textBox.visible = true;
						}
						_outputMode = value;
					}
					break;
				default:
					out("Output mode is not implemented yet", Log.WARNING);
			}
		
		}
		
		/**
		 * Log class for tracing
		 * @param	enforcer
		 */
		public function Log(enforcer:SingletonEnforcer){}
		
		/**
		 * Returns an instance of DefaultState class
		 */
		private static var _instance:Log;
		
		public static function get message():Log{
			if (_instance == null){
				_instance = new Log(new SingletonEnforcer());
				_instance.outputMode = OUT_TO_CONSOLE;
				_instance._messages = new Array();
				_instance.stageRef = DefaultStage.instance.stage;
				_instance.outputLevel = Log.COMMENT;
			}
			return Log._instance;
		}

		/**
		 * Trace out messages
		 * @param	message
		 * @param	type
		 */
		public function out(message:String, type:uint = Log.COMMENT):void
		{
			
			this.message = message;
			if (_dumpEnabled != true) {
				_messages.push({str: message, type: type});
			}
			
			if (type == Log.COMMENT && outputLevel <= type) {
				render("Msg: " + message);
			}
			else if (type == Log.WARNING && outputLevel <= type) {
				render("Warn: " + message);
			}
			else if (type == Log.ERROR && outputLevel <= type) {
				render("Err: " + message);
			}
			
		}
		
		public function dump():void
		{
			_dumpEnabled = true;
			out("Dump Logs ============================");
			_messages.reverse();
			while (_messages.length > 0) {
				var m:Object = _messages.pop();
				out(m.str, m.type);
			}
			out("Logs Clear ============================\n");
			_dumpEnabled = false;
		}
		
		private function render(message:String):void
		{
			switch (outputMode) {
				case OUT_TO_CONSOLE:
					trace(message);
					break;
				case OUT_TO_SCREEN:
					_textBox.text += message + "\n";
					break;
				default:
					out("Unsuppored render mode", Log.WARNING);
			}
		}
		
		private function buildOutputPanel():void {
			// create box if it hasn't been done before
			_textBox = new Text();
			_textBox.width = stageRef.stageWidth;
			_textBox.height = stageRef.stageHeight * .33;
			_textBox.x = 0;
			_textBox.y = stageRef.stageHeight - _textBox.height;
			_textBox.background = true;
			_textBox.backgroundColor = 0x000000;
			_textBox.color = 0x00ff00;
			_textBox.alpha = .75;
			_textBox.selectable = true;
			stageRef.addChildAt(_textBox, stageRef.numChildren);
		}
	}
}

class SingletonEnforcer {}
