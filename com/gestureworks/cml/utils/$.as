package com.gestureworks.cml.utils {	
	
	/**
	 * Searches CML document by given css selector.
	 * @param	selector
	 * @return Returns object if only one is found, otherwise returns of array. 
	 */
	public function $(selector:*):* {
		var ret:Array = document.querySelectorAll(selector);
		if (ret.length == 1) {
			return ret[0]; 
		}
		else {
			return ret;
		}
	}
}