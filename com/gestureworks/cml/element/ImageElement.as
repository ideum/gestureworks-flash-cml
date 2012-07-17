////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.cml.element 
{
	import com.gestureworks.cml.factories.*;
	import flash.events.*;
	
	/** 
	 * The ImageElement class loads and displays an external bitmap file.
	 * 
	 * @includeExample ImageElementExample.as -noswf
	 *
	 * @author Charles Veasey
	 * @langversion 3.0
	 * @playerversion Flash 10.1
	 * @playerversion AIR 2.5
	 * 
	 * @see com.gestureworks.cml.factories.BitmapFactory
	 * @see com.gestureworks.cml.factories.ElementFactory
	 * @see com.gestureworks.cml.factories.ObjectFactory
	 */	 	
	public class ImageElement extends BitmapFactory
	{				
		public function ImageElement() 
		{						
			super();
		}
		
		override protected function bitmapComplete():void 
		{						
			dispatchEvent(new Event(Event.COMPLETE, true, true));
		}
	}
}