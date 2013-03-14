package com.gestureworks.cml.utils 
{
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.net.registerClassAlias;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Proxy;

	public class CMLQuery extends Proxy
	{
		public function CMLQuery(array:Array)
		{				
			trace(array);
		}		
	}
}