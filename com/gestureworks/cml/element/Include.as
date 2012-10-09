package com.gestureworks.cml.element 
{
	/**
	 * Include element allows to nest external files.
	 * 
	 * @author ...
	 */
	public class Include 
	{
		/**
		 * include constructor
		 */
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
			
			_src = value;
			_cml = value;
		}

		
		private var _src:String;
		/**
		 * Sets the src xml file
		 *  @default 
		 */
		public function get src():String {return _src;}
		public function set src(value:String):void 
		{
			if (_src == value)
				return;
			
			_cml = value;
			_src = value;
		}
			
	}

}