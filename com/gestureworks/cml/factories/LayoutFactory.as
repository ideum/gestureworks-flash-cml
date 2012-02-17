package com.gestureworks.cml.factories 
{
	import com.gestureworks.cml.interfaces.IContainer;
	import com.gestureworks.cml.interfaces.ILayout;	
	
	/**
	 * ...
	 * @author Charles Veasey
	 */
	public class LayoutFactory extends ObjectFactory implements ILayout
	{
		
		public function LayoutFactory() 
		{
			super();
		}
		
		
		public function layout(container:IContainer):void {}
	}

}