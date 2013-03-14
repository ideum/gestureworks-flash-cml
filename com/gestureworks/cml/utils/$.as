package com.gestureworks.cml.utils 
{
	public function $(... args):CMLQuery 
	{
		return CMLQuery.create(args[0], args[1]);
	}
}