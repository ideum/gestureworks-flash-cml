package com.gestureworks.cml.kits
{
	import com.gestureworks.cml.interfaces.ICML;	
	import com.gestureworks.cml.utils.SystemWindow;
	import com.gestureworks.cml.managers.ScreenManager;
	import com.gestureworks.cml.managers.WindowManager;
	import com.gestureworks.core.DisplayList;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	/**
	 * WindowKit
	 * The WindowKit contains classes that create and mangage system windows 
	 * @author Charles Veasey
	 */	
	
	public class WindowKit
	{		
		public function WindowKit(enforcer:SingletonEnforcer){}

		
		private static var _instance:WindowKit;
		public static function get instance():WindowKit 
		{ 
			if (_instance == null)
				_instance = new WindowKit(new SingletonEnforcer());			
			return _instance;	
		}			
		
		
		public function parseCML(cml:XMLList):void
		{						
			var window:Object;
			
			for each (var node:* in cml.*)
			{
				if (node.@id == undefined)
					node.@id = "default";
				
				if (node.@id != "default")
					WindowManager.instance.createWindow(node.@id);
				
				window = WindowManager.instance.getWindowKey(node.@id);
								
				for each (var attr:* in node.@*)
				{
					if (attr.name() == "screen") 
						ScreenManager.instance.addWindow(window, attr);					
					else if (attr.name() == "fullscreen" && attr == "true")
						window.stage.displayState = StageDisplayState.FULL_SCREEN;
					else if (attr.name() == "backgroundColor")
						WindowManager.instance.setBackgroundColor(node.@id, attr);
					else if (attr.name() == "ref")
					{
						if (DisplayList.object[attr.toString()])
							WindowManager.instance.appendDisplay(DisplayList.object[attr.toString()], node.@id);						
					}
					else if (window.hasOwnProperty(attr.name().toString()))
						window[attr.name().toString()] = attr;						
				}
								
				if (node.@id != "default")
					WindowManager.instance.activateWindow(node.@id);
			}
		}			
	}
}

class SingletonEnforcer{}