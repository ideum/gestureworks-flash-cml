package com.gestureworks.cml.elements
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.elements.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.managers.*;
		
	/**
	 * The Container element controls the layout characteristics of child components.
	 * The container gives a large amount of control in keeping track of 
	 * objects and can hold a variety of items. It keeps track of cml 
	 * children through it's childlist object.
	 * 
	 * The Container element supports thhe ILayout interface. 
	 * Create a layout and use the <code>applyLayout()</code> method 
	 * of the container to arrange the child display objects according 
	 * to the layout definition.
	 * 
	 * <codeblock xml:space="preserve" class="+ topic/pre pr-d/codeblock ">
	 * 	
		var container:Container = new Container;
		container.addChild(new Graphic);
		container.addChild(new Graphic);
	  
		var randomLayout:RandomLayout = new RandomLayout();
		randomLayout.maxX = 400;
		randomLayout.maxY = 500;
		randomLayout.minRot = -30;
		randomLayout.maxRot = 30;
		randomLayout.type = "randomXYRotation";
		randomLayout.tween = true;
		randomLayout.tweenTime = 1500;
		container.applyLayout(randomLayout);
		
	 * </codeblock>
	 * @author Ideum
	 */
	public class Container extends TouchContainer
	{				
		/**
		 * Constructor
		 */
		public function Container()
		{
			super();
			mouseChildren = true;
		}	
	
	}
}