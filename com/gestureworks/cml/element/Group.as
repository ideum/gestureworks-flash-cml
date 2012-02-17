package com.gestureworks.cml.element 
{
	import flash.display.Sprite;
	
	public class Group extends Sprite 
	{
		public function Group() 
		{
			super();
		}
		
		private var _id:String="";
		public function get id():String{return _id;}
		public function set id(value:String):void
		{
			_id = value;
		}
	}
}