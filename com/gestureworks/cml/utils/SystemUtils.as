package com.gestureworks.cml.utils
{
	import flash.system.Capabilities
		
	/**
	 * The StringUtils utility is a collection of static methods for working with strings.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">

		if (SystemDetection.AIR)
			trace("You are running AIR!");
	 
	 * </codeblock>
	 * 
	 * @author Ideum
	 */	
	public class SystemUtils
	{
		/**
		 * specifies the player versions
		 */
		public static var VERSION:String
		
		/**
		 * specifies the player version number
		 */
		public static var VERSION_NUMBER:Number;
		
		/**
		 * specifies the opearting system
		 */
		public static var OS:String;
		
		/**
		 * debugger information
		 */
		public static var DEBUGGER:Boolean;
		
		/**
		 * AIR
		 */
		public static var AIR:Boolean;
		
		/**
		 * flash player information
		 */
		public static var FLASHPLAYER:Boolean;
		
		/**
		 * browser type
		 */
		public static var BROWSER:Boolean;
		
		/**
		 * external information
		 */
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