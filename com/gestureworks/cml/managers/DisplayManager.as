package com.gestureworks.cml.managers
{
	import com.gestureworks.cml.core.*;
	import com.gestureworks.cml.interfaces.*;
	import com.gestureworks.cml.managers.*;
	import flash.events.*;

	
	/**
	 * DisplayManager, Singleton
	 * Manages display objects
	 * 
	 * @authors Charles Veasey 
	 */	
	
	public class DisplayManager extends EventDispatcher
	{		
		/**
		 * allows single instance for this CMLLoader class
		 * @param	enforcer
		 */
		public function DisplayManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:DisplayManager;
		/**
		 * method returns display manager
		 */
		public static function get instance():DisplayManager 
		{ 
			if (_instance == null)
			{
				_instance = new DisplayManager(new SingletonEnforcer());
				//DefaultStage.instance.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				//DefaultStage.instance.stage.addEventListener(Event.EXIT_FRAME, onExitFrame);
			}
			return _instance; 
		}
		
		/**
		 * searches the object and updates each display object properties
		 */
		public function updateCMLProperties():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{					
				CMLObjectList.instance.getIndex(i).updateProperties();	
			}
		}		
		
		/**
		 * searches the child and add the children to cml
		 */
		public function addCMLChildren():void
		{	
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i) is IContainer)
					CMLObjectList.instance.getIndex(i).addAllChildren();					
			}
		}

		/**
		 * removes the children
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
		 * CML callback initialisation
		 */
		public function displayComplete():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("displayComplete"))
					CMLObjectList.instance.getIndex(i).displayComplete();	
			}
		}			
		
		/**
		 * method checks whether an object has a specified property defined.
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
					{
						trace(CMLObjectList.instance.getIndex(i).id);
						
						CMLObjectList.instance.getIndex(i).loadCML();
					}

				}					
				
			}
		}
		
		/**
		 * method checks whether an object has a specified property defined.
		 */
		public function activateTouch():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("activateTouch"))
					CMLObjectList.instance.getIndex(i).activateTouch();
			}
		}			
		
		/**
		 * method checks whether an object has a specified property defined.
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
		 * applies the layout
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
	
		/**
		 * method checks whether an object has a onEnterFrame property defined.
		 */
		public function updateDisplay():void
		{
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("onEnterFrame"))
					CMLObjectList.instance.getIndex(i).onEnterFrame();					
			}
		}	
		
		/**
		 * event
		 * @param	event
		 */
		public static function onEnterFrame(event:Event=null):void
		{
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("onEnterFrame"))
					CMLObjectList.instance.getIndex(i).onEnterFrame();					
			}
		}
		
	
		/**
		 * event handlers
		 * @param	event
		 */
		public static function onExitFrame(event:Event):void
		{
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("onExitFrame"))
					CMLObjectList.instance.getIndex(i).onEnterFrame();					
			}
		}		
		
		
	}
}
/**
 * class can only be access by the DisplayManager class only. 
 */
class SingletonEnforcer{}