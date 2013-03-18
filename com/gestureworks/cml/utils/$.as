package com.gestureworks.cml.utils 
{
	import com.gestureworks.cml.utils.as3Query;
	
		public function $(... args):* 
		{
			return as3Query.create(args[0], args[1]);
		}

}