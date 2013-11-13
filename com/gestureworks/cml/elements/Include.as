package com.gestureworks.cml.elements 
{
	/**
	 * The Include element allows one to nest CML files. 
	 * It is not intended to be used outside of CML.
	 * 
	 * @author Ideum
	 */
	public class Include 
	{
		/**
		 * Constructor
		 */
		public function Include() {}
		
		
		private var _cml:String;
		/**
		 * Sets the source cml file
		 */
		[Deprecated(replacement = "src")]					
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
		 * Sets the source cml file
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