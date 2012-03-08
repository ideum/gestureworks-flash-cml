package com.gestureworks.cml.managers
{
	import com.codeazur.as3swf.timeline.*;
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
		public function DisplayManager(enforcer:SingletonEnforcer) {}
		
		private static var _instance:DisplayManager;
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
		
		public function activateTouch():void
		{			
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{				
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("activateTouch"))
					CMLObjectList.instance.getIndex(i).activateTouch();
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
	
		
		public function updateDisplay():void
		{
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("onEnterFrame"))
					CMLObjectList.instance.getIndex(i).onEnterFrame();					
			}
		}	
		
		
		public static function onEnterFrame(event:Event=null):void
		{
			for (var i:int = 0; i < CMLObjectList.instance.length; i++) 
			{		
				if (CMLObjectList.instance.getIndex(i).hasOwnProperty("onEnterFrame"))
					CMLObjectList.instance.getIndex(i).onEnterFrame();					
			}
		}
		
	
		
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

class SingletonEnforcer{}