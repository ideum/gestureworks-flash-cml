package com.gestureworks.cml.utils
{
	import flash.system.Capabilities
		
	public class SystemDetection
	{
		public static var VERSION:String
		public static var VERSION_NUMBER:Number;
		public static var OS:String;
		public static var DEBUGGER:Boolean;
		public static var AIR:Boolean;
		public static var FLASHPLAYER:Boolean;
		public static var BROWSER:Boolean;
		public static var OTHER:Boolean;		
		{
			VERSION = (Capabilities.version);
			VERSION_NUMBER = (formatVersion(Capabilities.version));		
			OS = (Capabilities.os);
			DEBUGGER = (Capabilities.isDebugger);
			AIR = (Capabilities.playerType == "Desktop");			
			FLASHPLAYER = (Capabilities.playerType == "StandAlone");
			BROWSER = (Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn");
			OTHER = (Capabilities.playerType == "External");
		}
		
		
		private static function formatVersion(ver:String):Number
		{
			var str:String = ver.slice(4);
			var arr:Array = str.split(",");

			if (arr[0])
				str = arr[0];
			if (arr[1])
				str += "." + arr[1];

			return Number(str);
		}
	}
}