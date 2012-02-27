package com.gestureworks.cml.element 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Include 
	{
		
		public function Include() 
		{
			
		}

		
		private var _cml:String;
		/**
		 * 
		 */
		public function get cml():String {return _cml;}
		public function set cml(value:String):void 
		{
			if (_cml == value)
				return;
				
			_cml = value;
		}	
		
	}

}