package com.gestureworks.cml.managers 
{
	import com.gestureworks.cml.components.Component;
	import com.gestureworks.cml.events.StateEvent;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author 
	 */
	public class ResourceManager 
	{		
		protected static var _instance:ResourceManager;
		private var _resources:Array = new Array();
		public var debug:Boolean = false;
		
		public function ResourceManager() {
			if (_instance)
				throw new Error("Error: Instantiation failed: Use ResourceManager.getInstance() instead of new.");
		}
		
		public static function getInstance():ResourceManager {
			if (!_instance)
				_instance = new ResourceManager();
			return _instance;
		}
		
		public function get resources():Array { return _resources; }
		public function set resources(r:Array):void {
			_resources = r;
			queue();
		}
		
		public function get resource():* { 
			return resources.length ? resources[0] : null;
		}
		
		protected function queue():void {
			for each(var res:* in resources) {
				if (res is Component) {
					res.addEventListener(StateEvent.CHANGE, function(e:StateEvent):void {
						if ((e.property == "visible" || e.property == "activity") && e.value) {
							resources.splice(resources.indexOf(e.target), 1);
							resources.push(e.target);
							if(debug)
								trace(e.target.id, ": occupied"," index:",resources.indexOf(e.target));
						}
						else if (e.property == "visible" && !e.value) {
							resources.splice(resources.indexOf(e.target), 1);
							resources.unshift(e.target);
							if(debug)
								trace(e.target.id, ": free", " index:",resources.indexOf(e.target));
						}
					});
				}
			}
		}
				
	}

}