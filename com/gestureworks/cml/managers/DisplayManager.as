package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.core.CMLObjectList;
	import com.gestureworks.cml.element.TouchContainer;
	import com.gestureworks.cml.interfaces.IContainer;	
	import com.gestureworks.cml.kits.ComponentKit;
	import com.gestureworks.cml.managers.LayoutManager;	

	
	/**
	 * DisplayManager, Singleton
	 * Manages display objects
	 * 
	 * @authors Matthew Valverde & Charles Veasey 
	 */	
	
	public class DisplayManager 
	{		
		public function DisplayManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:DisplayManager;
		public static function get instance():DisplayManager 
		{ 
			if (_instance == null)
				_instance = new DisplayManager(new SingletonEnforcer());			
			return _instance; 
		}
		
		
		public function updateCMLProperties():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				CMLObjectList.instance.getIndex(i).updateProperties();	
			}
		}		
		
		public function addCMLChildren():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i) is IContainer)
					CMLObjectList.instance.getIndex(i).addAllChildren();	
			}
		}
		

		public function displayComplete():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("displayComplete"))
					CMLObjectList.instance.getIndex(i).displayComplete();	
			}
		}			
		
		
		public function loadRenderer():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("loadRenderer"))
				{
					if (CMLObjectList.instance.getIndex(i).rendererList)
						CMLObjectList.instance.getIndex(i).loadRenderer();
				}	
			}
		}
		
		
		public function loadComplete():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("loadComplete"))
					CMLObjectList.instance.getIndex(i).loadComplete();
			}
		}		
		

		public function layoutCML():void
		{				
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{
				if (CMLObjectList.instance.getIndex(i) is IContainer)
				{
					CMLObjectList.instance.getIndex(i).setDimensionsToChild();	
					
					if (CMLObjectList.instance.getIndex(i).layout)
					{
						LayoutManager.instance.layout(CMLObjectList.instance.getIndex(i).layout, 
							CMLObjectList.instance.getIndex(i));
					}
				}	
			}
		}
	
		
		
		
		
	}
}

class SingletonEnforcer{}