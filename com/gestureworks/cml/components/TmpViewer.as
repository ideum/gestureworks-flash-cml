package com.gestureworks.cml.components 
{
	import com.gestureworks.cml.element.*;
	import com.gestureworks.cml.kits.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TmpViewer extends ComponentKit 
	{
		
		public function TmpViewer() 
		{
			super();
			
			var g:GraphicElement = new GraphicElement;
			
			g.shape = "circle";
			g.radius = 100;
			addChild(g);
		}
		
	}

}