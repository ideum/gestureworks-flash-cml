package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.managers.*;
	import flash.events.*;

	
	/**
	 * The DisplayManager utlizes the CMLObjectList to make global updates
	 * to all of the CML objects.
	 * 
	 * @author Charles
	 * @see com.gestureworks.cml.core.CMLObjectList
	 */
	public class DisplayManager extends EventDispatcher
	{		
		/**
		 * Constructor
		 * @param	enforcer
		 */
		public function DisplayManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:DisplayManager;
		/**
		 * Returns instance of DisplayManaager
		 */
		public static function get instance():DisplayManager 
		{ 
			if (_instance == null)
				_instance = new DisplayManager(new SingletonEnforcer());
			return _instance; 
		}
		
		/**
		 * Calls the updateProperties() method on the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function updateCMLProperties():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{					
				CMLObjectList.instance.getIndex(i).updateProperties();	
			}
		}		
		
		/**
		 * Calls the addAllChildren() method on the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function addCMLChildren():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("addAllChildren"))
					CMLObjectList.instance.getIndex(i).addAllChildren();					
			}
		}

		/**
		 * Removes all children of the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function removeCMLChildren():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i) is IContainer)
				{
					while (CMLObjectList.instance.getIndex(i).numChildren > 0) {
						CMLObjectList.instance.getIndex(i).removeChildAt(0);
					}
				}
			}
		}		

		/**
		 * Calls the init() method on the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function init():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("init"))
					CMLObjectList.instance.getIndex(i).init();
			}
		}			
		
		/**
		 * Loads all renderers through the CMLObjectList by 
		 * looping through the index of the CMLObjectList.
		 */
		public function loadRenderer():void
		{
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("loadRenderer"))
				{
					if (CMLObjectList.instance.getIndex(i).rendererList)
						CMLObjectList.instance.getIndex(i).loadRenderer();
				}
				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("loadCML"))
				{
					if (CMLObjectList.instance.getIndex(i).cml)					
						CMLObjectList.instance.getIndex(i).loadCML();
				}
			}
		}
		
		/**
		 * Calls the activateTouch() method on the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function activateTouch():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) {				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("activateTouch")) {
					CMLObjectList.instance.getIndex(i).activateTouch();
				}
				else if ("vto" in CMLObjectList.instance.getIndex(i)) {
					if (CMLObjectList.instance.getIndex(i).vto) {
						CMLObjectList.instance.getIndex(i).vto.activateTouch();
					}
				}
			}
		}			
		
		/**
		 * Calls the loadComplete() method on the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function loadComplete():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("loadComplete"))
					CMLObjectList.instance.getIndex(i).loadComplete();
			}
		}		
		

		/**
		 * Calls the applyLayout() method on the entire CMLObjectList
		 * by looping through the index of the CMLObjectList.
		 */
		public function layoutCML():void
		{
			var layoutString:String;
			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{
				if (CMLObjectList.instance.getIndex(i) is IContainer)
				{
					CMLObjectList.instance.getIndex(i).setDimensionsToChild();	
					
					if (CMLObjectList.instance.getIndex(i).layout)
					{						
						layoutString = CMLObjectList.instance.getIndex(i).layout;
						//apply local layout
						if (CMLObjectList.instance.getIndex(i).layoutList[layoutString])
							CMLObjectList.instance.getIndex(i).applyLayout();
	
						//apply global layout
						else 
							LayoutManager.instance.layout(CMLObjectList.instance.getIndex(i).layout, CMLObjectList.instance.getIndex(i));					
					}
				}	
			}
		}		
	}
}

class SingletonEnforcer{}